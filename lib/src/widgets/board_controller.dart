import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'animation.dart';
import 'board_painter.dart';
import '../fen.dart';
import '../models.dart';

/// Controls the board position, game state, and piece animations for a [Chessboard].
///
/// ## Interactivity
///
/// A controller drives a [Chessboard]. To make the board non-interactive (e.g.
/// at the end of a game), update it with game data whose `playerSide` is
/// [PlayerSide.none]. For a fully static board, use [StaticChessboard] instead.
///
/// ## Updating the position
///
/// Call [updatePosition] after each move to advance the board. Pass
/// `animate: false` to switch positions without animation, and `resetPremove: true` to clear any
/// registered premove when jumping to an arbitrary position.
///
/// ## Premoves
///
/// Read [premove] or subscribe to [premoveNotifier] to detect a pending premove.
/// The parent is responsible for executing the premove at the right time (after
/// the opponent moves) and for clearing it with `premove = null` when needed.
///
/// ## Drawn shapes
///
/// User-drawn shapes are managed internally by the board via gestures.
/// External shapes are supplied via [Chessboard.shapes].
///
/// ## Atomic explosions
///
/// Call [triggerExplosion] with the set of squares to animate a one-shot
/// explosion (used in atomic chess).
///
/// The controller must be disposed when no longer needed.
class ChessboardController extends ChangeNotifier {
  /// Creates a controller for an interactive [Chessboard] driven by [game].
  ChessboardController({required GameData game}) {
    _gameNotifier = ValueNotifier(game);
    _piecesNotifier = ValueNotifier(readFen(game.fen));
    _translatingPiecesNotifier = ValueNotifier({});
    _fadingPiecesNotifier = ValueNotifier({});
    _highlightNotifier = BoardHighlightNotifier();
    _drawnShapesNotifier = ValueNotifier({});
    _pendingPromotionNotifier = ValueNotifier(null);
    _premoveNotifier = ValueNotifier(null);
  }

  Move? _lastDropMove;
  Set<Square>? _pendingExplosionSquares;

  late final ValueNotifier<GameData> _gameNotifier;
  late final ValueNotifier<Pieces> _piecesNotifier;
  late final ValueNotifier<TranslatingPieces> _translatingPiecesNotifier;
  late final ValueNotifier<FadingPieces> _fadingPiecesNotifier;
  late final BoardHighlightNotifier _highlightNotifier;
  late final ValueNotifier<Set<Shape>> _drawnShapesNotifier;
  late final ValueNotifier<NormalMove?> _pendingPromotionNotifier;
  late final ValueNotifier<Move?> _premoveNotifier;

  AnimationController? _animationController;
  CurvedAnimation? _translationAnimation;
  CurvedAnimation? _fadeAnimation;

  // --- Public API ---

  String get fen => _gameNotifier.value.fen;
  GameData get game => _gameNotifier.value;
  Move? get lastMove => _gameNotifier.value.lastMove;
  bool get interactive => _gameNotifier.value.playerSide != PlayerSide.none;
  Pieces get pieces => _piecesNotifier.value;

  /// The currently registered premove, or `null` if none is set.
  Move? get premove => _premoveNotifier.value;

  /// A notifier that fires whenever the premove is set or cleared.
  ///
  /// Useful for parents that need to react to premove changes outside the board
  /// (e.g. updating pocket highlights, analytics, or haptic feedback).
  ValueNotifier<Move?> get premoveNotifier => _premoveNotifier;

  @internal
  Set<Square>? get pendingExplosionSquares => _pendingExplosionSquares;

  @internal
  Iterable<Shape> get drawnShapes => _drawnShapesNotifier.value;

  // --- Notifiers consumed by board painters (internal use only) ---

  @internal
  ValueNotifier<GameData?> get gameNotifier => _gameNotifier;
  @internal
  ValueNotifier<Pieces> get piecesNotifier => _piecesNotifier;
  @internal
  ValueNotifier<TranslatingPieces> get translatingPiecesNotifier => _translatingPiecesNotifier;
  @internal
  ValueNotifier<FadingPieces> get fadingPiecesNotifier => _fadingPiecesNotifier;
  @internal
  BoardHighlightNotifier get highlightNotifier => _highlightNotifier;
  @internal
  ValueNotifier<Set<Shape>> get drawnShapesNotifier => _drawnShapesNotifier;
  @internal
  ValueNotifier<NormalMove?> get pendingPromotionNotifier => _pendingPromotionNotifier;

  @internal
  CurvedAnimation get translationAnimation {
    assert(_translationAnimation != null, 'ChessboardController is not attached to a board.');
    return _translationAnimation!;
  }

  @internal
  CurvedAnimation get fadeAnimation {
    assert(_fadeAnimation != null, 'ChessboardController is not attached to a board.');
    return _fadeAnimation!;
  }

  // --- Lifecycle (called by _BoardState) ---

  @internal
  void attachTo(TickerProvider vsync, Duration animationDuration) {
    assert(_animationController == null, 'ChessboardController is already attached.');
    _animationController = AnimationController(
      animationBehavior: AnimationBehavior.preserve,
      duration: animationDuration,
      vsync: vsync,
    );
    _translationAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOutCubic,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController!, curve: Curves.easeInQuad);
  }

  @internal
  void detach() {
    _fadeAnimation?.dispose();
    _translationAnimation?.dispose();
    _animationController?.dispose();
    _fadeAnimation = null;
    _translationAnimation = null;
    _animationController = null;
    // Drop any in-flight animation pieces. The fading/translating notifiers are
    // only cleared by the next `updatePosition`, so after an animated move they
    // stay populated and rely on the animation resting at value 1.0 to render
    // invisibly (faded out / at destination). A subsequent `attachTo` creates a
    // fresh controller at value 0.0, which would repaint these as opaque,
    // origin-positioned ghosts overlapping the static pieces. Clearing them here
    // ensures a detach/attach cycle (e.g. the board being reparented during an
    // Android predictive-back gesture) leaves no stale animation state.
    _translatingPiecesNotifier.value = {};
    _fadingPiecesNotifier.value = {};
  }

  @internal
  Duration get animationDuration => _animationController?.duration ?? Duration.zero;
  @internal
  set animationDuration(Duration value) {
    _animationController?.duration = value;
  }

  // --- Public mutation API ---

  /// Sets or clears the premove.
  ///
  /// Assign a non-null [Move] to register a premove, or `null` to clear it.
  /// The board updates its highlight display immediately.
  ///
  /// The parent is still responsible for executing the premove at the right time
  /// (typically after the opponent moves). Read [premove] or listen to [premoveNotifier]
  /// to know when a premove is pending.
  set premove(Move? move) {
    _premoveNotifier.value = move;
  }

  /// The pending promotion move, or `null` when no promotion is in progress.
  NormalMove? get pendingPromotion => _pendingPromotionNotifier.value;

  /// Sets or clears the pending promotion move.
  ///
  /// Setting a non-null value causes the board to show the promotion selector.
  /// Typically set when executing a premove that turns out to be a promotion and
  /// [ChessboardSettings.autoQueenPromotionOnPremove] is disabled.
  set pendingPromotion(NormalMove? move) {
    _pendingPromotionNotifier.value = move;
  }

  @internal
  void toggleDrawnShape(Shape shape) {
    final current = _drawnShapesNotifier.value;
    _drawnShapesNotifier.value =
        current.contains(shape) ? current.difference({shape}) : {...current, shape};
  }

  /// Removes all user-drawn shapes from the board.
  ///
  /// This does not affect externally supplied shapes passed via [Chessboard.shapes].
  void clearDrawnShapes() {
    _drawnShapesNotifier.value = {};
  }

  /// Records that [move] was just performed via drag and drop.
  ///
  /// Called internally by the board when the user completes a move by dropping a
  /// piece (a board drag or an external pocket drop). The next [updatePosition]
  /// uses this to suppress the redundant translation of the already-dragged
  /// piece, then clears it.
  @internal
  // ignore: use_setters_to_change_properties
  void recordDropMove(Move move) {
    _lastDropMove = move;
  }

  /// Triggers a one-shot explosion animation on the given squares.
  ///
  /// Typically used for atomic chess: pass the set of exploded squares (capture
  /// square + adjacent non-pawn pieces) after a capture. The board fires the
  /// animation the first time it sees a new, non-null set; calling this method
  /// with the exact same [Set] reference a second time has no effect. To
  /// re-trigger with identical squares pass a new [Set] instance.
  void triggerExplosion(Set<Square> squares) {
    _pendingExplosionSquares = squares;
    notifyListeners();
  }

  /// Updates the board to [game].
  ///
  /// By default, pieces are animated to their new positions. Pass
  /// `animate: false` to switch positions instantly (e.g. analysis seeking or
  /// history navigation).
  ///
  /// By default, any registered premove is preserved. Pass `resetPremove: true`
  /// to clear it — appropriate whenever the new position is not a direct
  /// continuation of the current one (e.g. jumping to an arbitrary position).
  ///
  /// If the triggering move was performed via drag and drop (recorded by the
  /// board through [recordDropMove]), the animation engine automatically
  /// suppresses the redundant translation of the dragged piece.
  void updatePosition(GameData game, {bool animate = true, bool resetPremove = false}) {
    if (!animate) {
      _animationController?.stop();
      _translatingPiecesNotifier.value = {};
      _fadingPiecesNotifier.value = {};
      _lastDropMove = null;
      _piecesNotifier.value = readFen(game.fen);
      _gameNotifier.value = game;
      if (resetPremove) _premoveNotifier.value = null;
      notifyListeners();
      return;
    }

    if (game.fen != fen) {
      final lastDrop = _lastDropMove;
      _lastDropMove = null;
      final oldPieces = _piecesNotifier.value;
      _translatingPiecesNotifier.value = {};
      _fadingPiecesNotifier.value = {};

      final newPieces = readFen(game.fen);

      if ((_animationController?.duration ?? Duration.zero) > Duration.zero) {
        final (tp, fp) = preparePieceAnimations(oldPieces, newPieces, lastDrop: lastDrop);
        _translatingPiecesNotifier.value = tp;
        _fadingPiecesNotifier.value = fp;
      }

      if (_translatingPiecesNotifier.value.isNotEmpty || _fadingPiecesNotifier.value.isNotEmpty) {
        _animationController?.forward(from: 0.0);
      } else {
        _animationController?.stop();
      }

      _piecesNotifier.value = newPieces;
    }

    _gameNotifier.value = game;
    if (resetPremove) _premoveNotifier.value = null;

    notifyListeners();
  }

  @override
  void dispose() {
    detach();
    _gameNotifier.dispose();
    _piecesNotifier.dispose();
    _translatingPiecesNotifier.dispose();
    _fadingPiecesNotifier.dispose();
    _highlightNotifier.dispose();
    _drawnShapesNotifier.dispose();
    _pendingPromotionNotifier.dispose();
    _premoveNotifier.dispose();
    super.dispose();
  }
}
