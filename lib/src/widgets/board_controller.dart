import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';

import 'animation.dart';
import 'board_painter.dart';
import '../fen.dart';
import '../models.dart';

/// Controls the board position, game state, and piece animations for a [Chessboard].
///
/// ## Constructors
///
/// Use [ChessboardController.new] for interactive boards passed to [Chessboard],
/// and [ChessboardController.nonInteractive] for display boards passed to
/// [Chessboard.fixed].
///
/// ## Updating the position
///
/// Call [updatePosition] after each move to advance the board with piece
/// animation. Call [jumpToPosition] to switch positions without animation
/// (e.g. analysis seeking or history navigation).
///
/// ## Premoves
///
/// Read [premove] or subscribe to [premoveNotifier] to detect a pending premove.
/// The parent is responsible for executing the premove at the right time (after
/// the opponent moves) and for clearing it with `premove = null` when needed.
///
/// ## Drawn shapes
///
/// [drawnShapes] exposes the shapes the user has drawn with gestures.
/// Use [addDrawnShape], [toggleDrawnShape], and [clearDrawnShapes] to
/// manipulate them programmatically.
///
/// ## Atomic explosions
///
/// Call [triggerExplosion] with the set of squares to animate a one-shot
/// explosion (used in atomic chess).
///
/// The controller must be disposed when no longer needed.
class ChessboardController extends ChangeNotifier {
  /// Creates a controller for an interactive [Chessboard] showing [fen] and driven by [game].
  ChessboardController({required String fen, required GameData game})
    : _fen = fen,
      _lastMove = null {
    _gameNotifier = ValueNotifier(game);
    _piecesNotifier = ValueNotifier(readFen(fen));
    _translatingPiecesNotifier = ValueNotifier({});
    _fadingPiecesNotifier = ValueNotifier({});
    _highlightNotifier = BoardHighlightNotifier();
    _drawnShapesNotifier = ValueNotifier({});
    _pendingPromotionNotifier = ValueNotifier(null);
    _premoveNotifier = ValueNotifier(null);
  }

  /// Creates a controller for a non-interactive [Chessboard.fixed] showing [fen].
  ChessboardController.nonInteractive({required String fen, Move? lastMove})
    : _fen = fen,
      _lastMove = lastMove {
    _gameNotifier = ValueNotifier(null);
    _piecesNotifier = ValueNotifier(readFen(fen));
    _translatingPiecesNotifier = ValueNotifier({});
    _fadingPiecesNotifier = ValueNotifier({});
    _highlightNotifier = BoardHighlightNotifier();
    _drawnShapesNotifier = ValueNotifier({});
    _pendingPromotionNotifier = ValueNotifier(null);
    _premoveNotifier = ValueNotifier(null);
  }

  String _fen;
  Move? _lastMove;
  Set<Square>? _pendingExplosionSquares;

  late final ValueNotifier<GameData?> _gameNotifier;
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

  // --- Public read-only state ---

  String get fen => _fen;
  GameData? get game => _gameNotifier.value;
  Move? get lastMove => _gameNotifier.value?.lastMove ?? _lastMove;
  bool get interactive =>
      _gameNotifier.value != null && _gameNotifier.value!.playerSide != PlayerSide.none;
  Pieces get pieces => _piecesNotifier.value;

  /// The currently registered premove, or `null` if none is set.
  Move? get premove => _premoveNotifier.value;

  /// A notifier that fires whenever the premove is set or cleared.
  ///
  /// Useful for parents that need to react to premove changes outside the board
  /// (e.g. updating pocket highlights, analytics, or haptic feedback).
  ValueNotifier<Move?> get premoveNotifier => _premoveNotifier;

  /// The most recently requested explosion squares, or `null` if none.
  ///
  /// The board tracks this value and triggers the animation whenever it sees
  /// a new, non-null set (i.e. different from the last seen value).
  Set<Square>? get pendingExplosionSquares => _pendingExplosionSquares;

  /// The set of shapes drawn by the user on the board.
  Set<Shape> get drawnShapes => _drawnShapesNotifier.value;

  // --- Notifiers consumed by board painters ---

  ValueNotifier<GameData?> get gameNotifier => _gameNotifier;
  ValueNotifier<Pieces> get piecesNotifier => _piecesNotifier;
  ValueNotifier<TranslatingPieces> get translatingPiecesNotifier => _translatingPiecesNotifier;
  ValueNotifier<FadingPieces> get fadingPiecesNotifier => _fadingPiecesNotifier;
  BoardHighlightNotifier get highlightNotifier => _highlightNotifier;
  ValueNotifier<Set<Shape>> get drawnShapesNotifier => _drawnShapesNotifier;
  ValueNotifier<NormalMove?> get pendingPromotionNotifier => _pendingPromotionNotifier;

  CurvedAnimation get translationAnimation {
    assert(_translationAnimation != null, 'ChessboardController is not attached to a board.');
    return _translationAnimation!;
  }

  CurvedAnimation get fadeAnimation {
    assert(_fadeAnimation != null, 'ChessboardController is not attached to a board.');
    return _fadeAnimation!;
  }

  // --- Lifecycle (called by _BoardState) ---

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

  void detach() {
    _fadeAnimation?.dispose();
    _translationAnimation?.dispose();
    _animationController?.dispose();
    _fadeAnimation = null;
    _translationAnimation = null;
    _animationController = null;
  }

  Duration get animationDuration => _animationController?.duration ?? Duration.zero;
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

  /// Adds [shape] to the controller's set of user-drawn shapes.
  ///
  /// The board re-renders automatically. This is equivalent to what the user
  /// achieves by drawing with their finger when [DrawShapeOptions.enable] is true.
  void addDrawnShape(Shape shape) {
    _drawnShapesNotifier.value = {..._drawnShapesNotifier.value, shape};
  }

  /// Toggles [shape] in the set of user-drawn shapes.
  ///
  /// If [shape] is already present it is removed; otherwise it is added.
  /// This is the behavior used by the board's drawing gesture — drawing the
  /// same shape a second time erases it.
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

  /// Updates the board to [fen] with piece animation.
  ///
  /// For interactive boards, pass [game] to update the game state.
  /// For non-interactive boards, omit [game] and optionally pass [lastMove].
  ///
  /// Pass [lastDrop] when the triggering move was performed via drag and drop so
  /// the animation engine can suppress the redundant translation of the dragged
  /// piece.
  void updatePosition(String fen, {GameData? game, Move? lastMove, Move? lastDrop}) {
    if (fen != _fen) {
      final oldPieces = _piecesNotifier.value;
      _translatingPiecesNotifier.value = {};
      _fadingPiecesNotifier.value = {};

      final newPieces = readFen(fen);

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

      _fen = fen;
      _piecesNotifier.value = newPieces;
    }

    _gameNotifier.value = game;
    _lastMove = lastMove;

    notifyListeners();
  }

  /// Updates the board to [fen] without animation (e.g. analysis seeking).
  ///
  /// For interactive boards, pass [game] to update the game state.
  /// For non-interactive boards, omit [game] and optionally pass [lastMove].
  ///
  /// Any registered premove is cleared, since it is no longer meaningful after
  /// jumping to an arbitrary position.
  void jumpToPosition(String fen, {GameData? game, Move? lastMove}) {
    _animationController?.stop();
    _translatingPiecesNotifier.value = {};
    _fadingPiecesNotifier.value = {};

    _fen = fen;
    _piecesNotifier.value = readFen(fen);
    _gameNotifier.value = game;
    _lastMove = lastMove;
    _premoveNotifier.value = null;

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
