import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';

import 'animation.dart';
import 'board_painter.dart';
import '../fen.dart';
import '../models.dart';

/// Controls the board position, game state, and piece animations.
///
/// Create a controller and pass it to [Chessboard]. Call [updatePosition] after
/// each move to advance the board with animation, or [jumpToPosition] to switch
/// positions without animation (e.g. analysis seeking).
///
/// The controller must be disposed when no longer needed.
class ChessboardController extends ChangeNotifier {
  /// Creates a controller for an interactive board showing [fen] and driven by [game].
  ChessboardController({required String fen, required GameData game})
    : _fen = fen,
      _lastMove = null {
    _gameNotifier = ValueNotifier(game);
    _piecesNotifier = ValueNotifier(readFen(fen));
    _translatingPiecesNotifier = ValueNotifier({});
    _fadingPiecesNotifier = ValueNotifier({});
    _highlightNotifier = BoardHighlightNotifier();
  }

  /// Creates a controller for a non-interactive board showing [fen].
  ChessboardController.nonInteractive({required String fen, Move? lastMove})
    : _fen = fen,
      _lastMove = lastMove {
    _gameNotifier = ValueNotifier(null);
    _piecesNotifier = ValueNotifier(readFen(fen));
    _translatingPiecesNotifier = ValueNotifier({});
    _fadingPiecesNotifier = ValueNotifier({});
    _highlightNotifier = BoardHighlightNotifier();
  }

  String _fen;
  Move? _lastMove;
  Set<Square>? _pendingExplosionSquares;

  late final ValueNotifier<GameData?> _gameNotifier;
  late final ValueNotifier<Pieces> _piecesNotifier;
  late final ValueNotifier<TranslatingPieces> _translatingPiecesNotifier;
  late final ValueNotifier<FadingPieces> _fadingPiecesNotifier;
  late final BoardHighlightNotifier _highlightNotifier;

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

  /// The most recently requested explosion squares, or `null` if none.
  ///
  /// The board tracks this value and triggers the animation whenever it sees
  /// a new, non-null set (i.e. different from the last seen value).
  Set<Square>? get pendingExplosionSquares => _pendingExplosionSquares;

  // --- Notifiers consumed by board painters ---

  ValueNotifier<GameData?> get gameNotifier => _gameNotifier;
  ValueNotifier<Pieces> get piecesNotifier => _piecesNotifier;
  ValueNotifier<TranslatingPieces> get translatingPiecesNotifier => _translatingPiecesNotifier;
  ValueNotifier<FadingPieces> get fadingPiecesNotifier => _fadingPiecesNotifier;
  BoardHighlightNotifier get highlightNotifier => _highlightNotifier;

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
  void jumpToPosition(String fen, {GameData? game, Move? lastMove}) {
    _animationController?.stop();
    _translatingPiecesNotifier.value = {};
    _fadingPiecesNotifier.value = {};

    _fen = fen;
    _piecesNotifier.value = readFen(fen);
    _gameNotifier.value = game;
    _lastMove = lastMove;

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
    super.dispose();
  }
}
