import 'dart:async';
import 'dart:math' show pi;
import 'dart:ui' as ui;
import 'package:chessground/src/widgets/geometry.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'board_border.dart';
import 'board_painter.dart';
import 'color_filter.dart';
import 'highlight.dart';
import 'positioned_square.dart';
import 'animation.dart';
import 'explosion.dart';
import 'promotion.dart';
import 'shape.dart';
import 'board_annotation.dart';
import 'static_board.dart';
import '../images.dart';
import '../models.dart';
import '../fen.dart';
import '../premove.dart';
import '../board_settings.dart';

/// Number of logical pixels that have to be dragged before a drag starts.
const double _kDragDistanceThreshold = 3.0;

const _kCancelShapesDoubleTapDelay = Duration(milliseconds: 200);

/// A chessboard widget.
///
/// This widget is primarily used to display a chessboard with interactive pieces.
///
/// For a view-only board, see also [StaticChessboard].
class Chessboard extends StatefulWidget with ChessboardGeometry {
  /// Creates a new chessboard widget with interactive pieces.
  ///
  /// Provide a [game] state to enable interaction with the board.
  /// The [fen] string should be updated when the position changes.
  const Chessboard({
    super.key,
    required double size,
    this.settings = const ChessboardSettings(),
    required this.orientation,
    required this.fen,
    this.opponentsPiecesUpsideDown = false,
    this.lastMove,
    this.squareHighlights = const IMapConst({}),
    this.onTouchedSquare,
    required this.game,
    this.shapes,
    this.annotations,
    this.explosionSquares,
  }) : _size = size;

  /// Creates a new chessboard widget that cannot be interacted with.
  ///
  /// Provide a [fen] string to describe the position of the pieces on the board.
  /// Pieces will be animated when the position changes.
  const Chessboard.fixed({
    super.key,
    required double size,
    this.settings = const ChessboardSettings(),
    required this.orientation,
    required this.fen,
    this.lastMove,
    this.squareHighlights = const IMapConst({}),
    this.onTouchedSquare,
    this.shapes,
    this.annotations,
    this.explosionSquares,
  }) : _size = size,
       game = null,
       opponentsPiecesUpsideDown = false;

  final double _size;

  /// Size of the board in logical pixels.
  @override
  double get size => _size - (settings.border?.width ?? 0) * 2;

  /// Side by which the board is oriented.
  @override
  final Side orientation;

  /// Settings that control the theme and behavior of the board.
  final ChessboardSettings settings;

  /// If `true` the opponent`s pieces are displayed rotated by 180 degrees.
  final bool opponentsPiecesUpsideDown;

  /// Squares to highlight on the board.
  final IMap<Square, SquareHighlight> squareHighlights;

  /// FEN string describing the position of the board.
  final String fen;

  /// Last move played, used to highlight corresponding squares.
  final Move? lastMove;

  /// Callback called after a square has been touched.
  ///
  /// This will be called even when the board is not interactable, with each [PointerDownEvent] that
  /// targets a square.
  final void Function(Square)? onTouchedSquare;

  /// Game state of the board.
  ///
  /// If `null`, the board cannot be interacted with.
  final GameData? game;

  /// Optional set of [Shape] to be drawn on the board.
  final ISet<Shape>? shapes;

  /// Move annotations to be displayed on the board.
  final IMap<Square, Annotation>? annotations;

  /// Squares on which an atomic chess explosion should be shown.
  ///
  /// Whenever this value changes to a new non-null set the board will play a
  /// one-shot explosion animation on each listed square.  Typically this is the
  /// set of squares returned by the dartchess atomic-explosion computation
  /// (capture square + all adjacent non-pawn pieces).
  ///
  /// Set to `null` or to the same value to suppress re-triggering.
  final ISet<Square>? explosionSquares;

  /// Whether the pieces can be moved by one side or both.
  bool get interactive => game != null && game!.playerSide != PlayerSide.none;

  @override
  // No need to make this class public, as it is only used internally.
  // ignore: library_private_types_in_public_api
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Chessboard> with SingleTickerProviderStateMixin {
  /// Pieces on the board.
  Pieces pieces = {};

  /// Pieces that are currently being translated from one square to another.
  ///
  /// The key is the target square of the piece.
  TranslatingPieces translatingPieces = {};

  /// Pieces that are currently fading out.
  FadingPieces fadingPieces = {};

  /// Squares that currently have an active explosion animation.
  final Set<Square> _activeExplosions = {};

  /// Currently selected square.
  Square? selected;

  /// Last move that was played using drag and drop.
  Move? _lastDrop;

  /// Squares that the selected piece can premove to.
  Set<Square>? _premoveDests;

  /// Whether the selected piece should be deselected on the next tap up event.
  ///
  /// This is used to prevent the deselection of a piece when the user drags it,
  /// but to allow the deselection when the user taps on the selected piece.
  bool _shouldDeselectOnTapUp = false;

  /// Whether the premove should be canceled on the next tap up event.
  ///
  /// This is used to prevent the premove from being canceled when the user drags
  /// a piece, but to allow the cancelation when the user taps on the origin square of the premove.
  bool _shouldCancelPremoveOnTapUp = false;

  /// Avatar for the piece that is currently being dragged.
  _DragAvatar? _dragAvatar;

  /// Once a piece is dragged, holds the square id of the piece.
  Square? _draggedPieceSquare;

  /// Current pointer down event.
  ///
  /// This field is reset to null when the pointer is released (up or cancel).
  ///
  /// This is used to track board gestures, the pointer that started the drag,
  /// and to prevent other pointers from starting a drag while a piece is being
  /// dragged.
  ///
  /// Other simultaneous pointer events are ignored and will cancel the current
  /// gesture.
  PointerDownEvent? _currentPointerDownEvent;

  /// Current render box during drag.
  // ignore: use_late_for_private_fields_and_variables
  RenderBox? _renderBox;

  /// Pointer event that started the draw mode lock.
  ///
  /// This is used to switch to draw mode when the user holds the pointer to an
  /// empty square, while drawing a shape with another finger at the same time.
  PointerEvent? _drawModeLockOrigin;

  /// Pointer event that started the shape drawing.
  PointerEvent? _drawOrigin;

  /// Double tap detection timer, used to cancel the shapes being drawn.
  Timer? _cancelShapesDoubleTapTimer;

  /// Avatar of the shape being drawn.
  Shape? _shapeAvatar;

  /// Whether all piece images are available in the cache.
  bool _imagesLoaded = false;

  /// Drives [HighlightsPainter] repaints for selection/premove changes without
  /// triggering a full widget rebuild.
  late final BoardHighlightNotifier _highlightNotifier;

  /// Single controller shared by the fading and translating piece painters;
  /// drives repaints without a widget rebuild per frame.
  late final AnimationController _pieceAnimationController;
  late final CurvedAnimation _translationAnimation;
  late final CurvedAnimation _fadeAnimation;

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final colorScheme = settings.colorScheme;
    final shapes = widget.shapes ?? _emptyShapes;
    final annotations = widget.annotations ?? _emptyAnnotations;
    final checkSquare = widget.game?.isCheck == true ? _getKingSquare() : null;
    final premove = widget.game?.premovable?.premove;

    final background = BrightnessHueFilter(
      hue: widget.settings.hue,
      child:
          settings.border == null && settings.enableCoordinates
              ? widget.orientation == Side.white
                  ? colorScheme.whiteCoordBackground
                  : colorScheme.blackCoordBackground
              : colorScheme.background,
    );

    final bool premoveVisible =
        premove != null && widget.game?.playerSide.name == widget.game?.sideToMove.opposite.name;

    final Map<Square, Color> solidCustomHighlights = {};
    final List<Widget> customImageHighlights = [];
    for (final MapEntry(key: square, value: highlight) in widget.squareHighlights.entries) {
      if (highlight.details.image != null) {
        customImageHighlights.add(
          PositionedSquare(
            key: ValueKey('${square.name}-highlight'),
            size: widget.size,
            orientation: widget.orientation,
            square: square,
            child: highlight,
          ),
        );
      } else if (highlight.details.solidColor != null) {
        solidCustomHighlights[square] = highlight.details.solidColor!;
      }
    }

    final Set<Square> occupiedSquares = pieces.keys.toSet();

    final highlightsPainter = HighlightsPainter(
      interactionNotifier: _highlightNotifier,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      showLastMove: settings.showLastMove,
      lastMove: widget.lastMove,
      premove: premoveVisible ? premove : null,
      premoveColor: colorScheme.validPremoves,
      lastMoveColor: colorScheme.lastMove.solidColor,
      selectedColor: colorScheme.selected.solidColor,
      validMoveColor: colorScheme.validMoves,
      occupiedSquares: occupiedSquares,
      checkSquare: checkSquare,
      squareHighlights: IMap(solidCustomHighlights),
    );

    final List<Widget> highlightedBackground = [
      SizedBox.square(
        key: const ValueKey('board-background'),
        dimension: widget.size,
        child: background,
      ),
      if (settings.showLastMove && widget.lastMove != null && colorScheme.lastMove.image != null)
        for (final square in widget.lastMove!.squares)
          if (premove == null || !premove.hasSquare(square))
            PositionedSquare(
              key: ValueKey('${square.name}-lastMove'),
              size: widget.size,
              orientation: widget.orientation,
              square: square,
              child: SquareHighlight(details: colorScheme.lastMove),
            ),
      if (selected != null && colorScheme.selected.image != null)
        PositionedSquare(
          key: ValueKey('${selected!.name}-selected'),
          size: widget.size,
          orientation: widget.orientation,
          square: selected!,
          child: SquareHighlight(details: colorScheme.selected),
        ),
      SizedBox.square(
        key: const ValueKey('board-highlights'),
        dimension: widget.size,
        child: CustomPaint(painter: highlightsPainter),
      ),
      ...customImageHighlights,
    ];

    final Set<Square> upsideDownFadingSquares = {};
    for (final entry in fadingPieces.entries) {
      if (_isUpsideDown(entry.value.color)) {
        upsideDownFadingSquares.add(entry.key);
      }
    }

    final Set<Square> upsideDownPieceSquares = {};
    final Set<Square> upsideDownTranslatingSquares = {};
    for (final entry in pieces.entries) {
      final square = entry.key;
      if (translatingPieces.containsKey(square)) {
        if (_isUpsideDown(entry.value.color)) {
          upsideDownTranslatingSquares.add(square);
        }
        continue;
      }
      if (square == _draggedPieceSquare || square == widget.game?.promotionMove?.from) {
        continue;
      }
      if (_isUpsideDown(entry.value.color)) {
        upsideDownPieceSquares.add(square);
      }
    }

    final piecesPainter = PiecesPainter(
      pieces: pieces,
      pieceAssets: settings.pieceAssets,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      draggedPieceSquare: _draggedPieceSquare,
      translatingPieceSquares: translatingPieces.keys.toSet(),
      promotionMoveFrom: widget.game?.promotionMove?.from,
      blindfoldMode: settings.blindfoldMode,
      upsideDownSquares: upsideDownPieceSquares,
      imagesLoaded: _imagesLoaded,
    );

    final fadingPiecesPainter = FadingPiecesPainter(
      fadingPieces: fadingPieces,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      pieceAssets: settings.pieceAssets,
      blindfoldMode: settings.blindfoldMode,
      upsideDownSquares: upsideDownFadingSquares,
      animation: _fadeAnimation,
    );

    final translatingPiecesPainter = TranslatingPiecesPainter(
      translatingPieces: translatingPieces,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      pieceAssets: settings.pieceAssets,
      blindfoldMode: settings.blindfoldMode,
      upsideDownSquares: upsideDownTranslatingSquares,
      animation: _translationAnimation,
    );

    final List<Widget> objects = [
      CustomPaint(size: Size.square(widget.size), painter: fadingPiecesPainter),
      CustomPaint(size: Size.square(widget.size), painter: piecesPainter),
      CustomPaint(size: Size.square(widget.size), painter: translatingPiecesPainter),
      for (final shape in shapes)
        BoardShapeWidget(shape: shape, size: widget.size, orientation: widget.orientation),
      if (_shapeAvatar != null)
        BoardShapeWidget(shape: _shapeAvatar!, size: widget.size, orientation: widget.orientation),
      for (final entry in annotations.entries)
        BoardAnnotation(
          key: ValueKey('${entry.key.name}-${entry.value.symbol}-${entry.value.color}'),
          size: widget.size,
          orientation: widget.orientation,
          square: entry.key,
          annotation: entry.value,
        ),
      for (final square in _activeExplosions)
        PositionedSquare(
          key: ValueKey('${square.name}-explosion'),
          size: widget.size,
          orientation: widget.orientation,
          square: square,
          child: IgnorePointer(
            child: OverflowBox(
              maxWidth: widget.squareSize * 1.5,
              maxHeight: widget.squareSize * 1.5,
              child: ExplosionWidget(
                size: widget.squareSize * 1.5,
                onComplete: () {
                  setState(() {
                    _activeExplosions.remove(square);
                  });
                },
              ),
            ),
          ),
        ),
      if (widget.game?.droppable != null)
        ...Square.values.map((square) {
          return PositionedSquare(
            key: ValueKey('${square.name}-drag-target'),
            size: widget.size,
            orientation: widget.orientation,
            square: square,
            child: DragTarget<Piece>(
              hitTestBehavior: HitTestBehavior.opaque, // stops hit test traversal immediately
              builder:
                  (context, candidateData, _) =>
                      candidateData.isNotEmpty
                          ? Transform.scale(
                            scale: 2,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0x33000000),
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                          : const SizedBox.shrink(),

              onAcceptWithDetails: (details) {
                final game = widget.game;
                if (game == null) return;

                final piece = details.data;
                final backRankPawnDrop =
                    piece.role == Role.pawn &&
                    (square.rank == Rank.first || square.rank == Rank.eighth);
                if (backRankPawnDrop) return;

                final move = DropMove(to: square, role: details.data.role);
                if (game.sideToMove == piece.color &&
                    game.droppable != null &&
                    game.droppable!.validDropSquares.contains(square)) {
                  game.onMove(move, viaDragAndDrop: true);
                  _lastDrop = move;
                } else if (game.premovable != null) {
                  game.premovable?.onSetPremove.call(move);
                }
              },
            ),
          );
        }),
    ];

    final board = Listener(
      behavior: HitTestBehavior.opaque, // stops hit test traversal immediately
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: SizedBox.square(
        key: const ValueKey('board-container'),
        dimension: widget.size,
        child: Stack(
          alignment: Alignment.topLeft,
          clipBehavior: Clip.none,
          children: [
            if (settings.border == null &&
                (settings.boxShadow.isNotEmpty || settings.borderRadius != BorderRadius.zero))
              Container(
                key: const ValueKey('background-container'),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: settings.borderRadius,
                  boxShadow: settings.boxShadow,
                ),
                child: Stack(alignment: Alignment.topLeft, children: highlightedBackground),
              )
            else
              ...highlightedBackground,
            ...objects,
            if (widget.game?.promotionMove != null)
              PromotionSelector(
                pieceAssets: settings.pieceAssets,
                move: widget.game!.promotionMove!,
                size: widget.size,
                color: widget.game!.sideToMove,
                orientation: widget.orientation,
                piecesUpsideDown: _isUpsideDown(widget.game!.sideToMove),
                onSelect: widget.game!.onPromotionSelection,
                onCancel: () {
                  widget.game!.onPromotionSelection(null);
                },
                canPromoteToKing: widget.game!.canPromoteToKing,
              ),
          ],
        ),
      ),
    );

    final borderedChessboard =
        settings.border != null
            ? BorderedChessboard(
              size: widget.size,
              orientation: widget.orientation,
              border: settings.border!,
              showCoordinates: settings.enableCoordinates,
              child: board,
            )
            : board;

    return BrightnessHueFilter(brightness: widget.settings.brightness, child: borderedChessboard);
  }

  @override
  void initState() {
    super.initState();
    pieces = readFen(widget.fen);
    _highlightNotifier = BoardHighlightNotifier();
    _pieceAnimationController = AnimationController(
      animationBehavior: AnimationBehavior.preserve,
      duration: widget.settings.animationDuration,
      vsync: this,
    );
    _translationAnimation = CurvedAnimation(
      parent: _pieceAnimationController,
      curve: Curves.easeInOutCubic,
    );
    _fadeAnimation = CurvedAnimation(parent: _pieceAnimationController, curve: Curves.easeInQuad);
    _imagesLoaded = ChessgroundImages.instance.isAllLoaded(widget.settings.pieceAssets);
    if (!_imagesLoaded) _loadImages(widget.settings.pieceAssets);
  }

  Future<void> _loadImages(PieceAssets assets) async {
    final dpr = WidgetsBinding.instance.platformDispatcher.implicitView?.devicePixelRatio;
    await ChessgroundImages.instance.loadAll(assets, devicePixelRatio: dpr);
    if (mounted) setState(() => _imagesLoaded = true);
  }

  @override
  void dispose() {
    _highlightNotifier.dispose();
    _fadeAnimation.dispose();
    _translationAnimation.dispose();
    _pieceAnimationController.dispose();
    _dragAvatar?.cancel();
    _cancelShapesDoubleTapTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(Chessboard oldBoard) {
    super.didUpdateWidget(oldBoard);
    if (oldBoard.settings.drawShape.enable && !widget.settings.drawShape.enable) {
      _drawModeLockOrigin = null;
      _drawOrigin = null;
      _shapeAvatar = null;
    }
    if (widget.interactive == false) {
      _currentPointerDownEvent = null;
      _dragAvatar?.cancel();
      _dragAvatar = null;
      _draggedPieceSquare = null;
      selected = null;
      _premoveDests = null;
    }
    if (oldBoard.game?.sideToMove != widget.game?.sideToMove) {
      _premoveDests = null;
    }
    _syncHighlightNotifier();

    if (oldBoard.settings.pieceAssets != widget.settings.pieceAssets) {
      _imagesLoaded = ChessgroundImages.instance.isAllLoaded(widget.settings.pieceAssets);
      if (!_imagesLoaded) _loadImages(widget.settings.pieceAssets);
    }

    if (oldBoard.settings.animationDuration != widget.settings.animationDuration) {
      _pieceAnimationController.duration = widget.settings.animationDuration;
    }

    // Trigger explosion animations when the set of explosion squares changes.
    if (widget.explosionSquares != null && widget.explosionSquares != oldBoard.explosionSquares) {
      _activeExplosions.addAll(widget.explosionSquares!);
    }

    if (oldBoard.fen == widget.fen) {
      _lastDrop = null;
      // as long as the fen is the same as before let's keep animations
      return;
    }

    translatingPieces = {};
    fadingPieces = {};

    final newPieces = readFen(widget.fen);

    if (widget.settings.animationDuration > Duration.zero) {
      final (translatingPieces, fadingPieces) = preparePieceAnimations(
        pieces,
        newPieces,
        lastDrop: _lastDrop,
      );
      this.translatingPieces = translatingPieces;
      this.fadingPieces = fadingPieces;
    }

    if (translatingPieces.isNotEmpty || fadingPieces.isNotEmpty) {
      _pieceAnimationController.forward(from: 0.0);
    } else {
      _pieceAnimationController.stop();
    }

    _lastDrop = null;
    pieces = newPieces;
  }

  Square? _getKingSquare() {
    for (final square in pieces.keys) {
      if (pieces[square]!.color == widget.game?.sideToMove && pieces[square]!.role == Role.king) {
        return square;
      }
    }
    return null;
  }

  /// Updates the notifier with the current selection state so [HighlightsPainter]
  /// repaints without a full widget rebuild.
  void _syncHighlightNotifier() {
    final moveDests =
        widget.settings.showValidMoves && selected != null && widget.game?.validMoves != null
            ? widget.game!.validMoves[selected!] ?? _emptyValidMoves
            : _emptyValidMoves;
    final premoveDests =
        widget.settings.showValidMoves ? _premoveDests ?? const <Square>{} : const <Square>{};
    _highlightNotifier.update(selected: selected, moveDests: moveDests, premoveDests: premoveDests);
  }

  /// Sets interaction state and triggers a highlights repaint via the notifier.
  ///
  /// Skips [setState] for themes with solid-color highlights; only calls it
  /// when the color scheme uses image-based highlights (e.g. horsey) where
  /// the selected highlight is a separate widget in the tree.
  void _setSelection(Square? newSelected, {Set<Square>? newPremoveDests}) {
    selected = newSelected;
    _premoveDests = newPremoveDests;
    _syncHighlightNotifier();
    if (widget.settings.colorScheme.selected.image != null) {
      setState(() {});
    }
  }

  /// Returns the position of the square target during drag as a global offset.
  Offset? _squareTargetGlobalOffset(
    Offset localPosition,
    RenderBox box, {
    required bool isLargeCircle,
  }) {
    final square = widget.offsetSquare(localPosition);
    if (square == null) return null;
    final localOffset = widget.squareOffset(square);
    final tmpOffset = box.localToGlobal(localOffset);
    return Offset(
      (widget.settings.border?.width ?? 0) +
          tmpOffset.dx -
          (isLargeCircle ? widget.squareSize / 2 : 0),
      (widget.settings.border?.width ?? 0) +
          tmpOffset.dy -
          (isLargeCircle ? widget.squareSize / 2 : 0),
    );
  }

  void _onPointerDown(PointerDownEvent details) {
    if (details.buttons != kPrimaryButton) return;

    final square = widget.offsetSquare(details.localPosition);
    if (square == null) return;

    widget.onTouchedSquare?.call(square);

    final Piece? piece = pieces[square];

    if (widget.settings.drawShape.enable) {
      if (_drawModeLockOrigin == null) {
        if (piece == null) {
          // Sets a lock to the draw mode if the user holds the pointer to an
          // empty square
          _drawModeLockOrigin = details;

          // double tap on empty square to clear shapes
          if (_cancelShapesDoubleTapTimer != null) {
            widget.settings.drawShape.onClearShapes?.call();
            _cancelShapesDoubleTapTimer?.cancel();
            _cancelShapesDoubleTapTimer = null;
          } else {
            _cancelShapesDoubleTapTimer = Timer(_kCancelShapesDoubleTapDelay, () {
              _cancelShapesDoubleTapTimer = null;
            });
          }
        }
        // selecting a piece to move should clear shapes
        else if (_isMovable(piece) || _isPremovable(piece)) {
          _cancelShapesDoubleTapTimer?.cancel();
          widget.settings.drawShape.onClearShapes?.call();
        }
      }
      // draw mode takes priority over play mode when the draw mode lock is set
      else if (_drawModeLockOrigin!.pointer != details.pointer) {
        _drawOrigin = details;
        setState(() {
          _shapeAvatar = Circle(
            color: widget.settings.drawShape.newShapeColor,
            orig: square,
            scale: 0.80,
          );
        });
        return;
      }
    }

    if (widget.interactive == false) return;

    // From here on, we only allow 1 pointer to interact with the board. Other
    // pointers will cancel any current gesture.
    if (_currentPointerDownEvent != null) {
      _cancelGesture();
      return;
    }

    // keep a reference to the current pointer down event to handle simultaneous
    // pointer events
    _currentPointerDownEvent = details;

    // a piece was selected and the user taps on a different square:
    // - try to move the piece to the target square
    // - if the move was not possible but there is a movable piece under the
    // target square, select it
    if (selected != null && square != selected) {
      final couldMove = _tryMoveOrPremoveTo(square);
      if (!couldMove && _isMovable(piece)) {
        _setSelection(square);
      } else {
        _setSelection(null);
      }
    }
    // the selected piece is touched again:
    // - deselect the piece on the next tap up event (as we don't want to deselect
    // the piece when the user drags it)
    else if (selected == square) {
      _shouldDeselectOnTapUp = true;
    }
    // no piece was selected yet and a movable piece is touched:
    // - select the piece
    else if (_isMovable(piece)) {
      _setSelection(square);
    }
    // no piece was selected yet and a premovable piece is touched:
    // - select the piece
    // - make the premove destinations
    else if (_isPremovable(piece)) {
      _setSelection(
        square,
        newPremoveDests: premovesOf(
          square,
          pieces,
          canCastle: widget.settings.enablePremoveCastling,
        ),
      );
    }
    // pointer down on empty square:
    // - cancel premove
    // - unselect piece
    else if (widget.game?.premovable?.premove != null) {
      widget.game?.premovable?.onSetPremove.call(null);
      _setSelection(null);
    }

    // there is a premove set from the touched square:
    // - cancel the premove on the next tap up event
    if (widget.game?.premovable?.premove case NormalMove(:final from) when from == square) {
      _shouldCancelPremoveOnTapUp = true;
    }

    // prevent moving the piece by 2 taps when the piece shift method is drag only
    if (widget.settings.pieceShiftMethod == PieceShiftMethod.drag) {
      _shouldDeselectOnTapUp = true;
    }
  }

  void _onPointerMove(PointerMoveEvent details) {
    if (details.buttons != kPrimaryButton) return;
    if (!mounted) return;

    // draw mode takes priority over play mode when the draw mode lock is set
    if (_shapeAvatar != null && _drawOrigin != null && _drawOrigin!.pointer == details.pointer) {
      final distance = (details.position - _drawOrigin!.position).distance;
      if (distance > _kDragDistanceThreshold) {
        final square = widget.offsetSquare(details.localPosition);
        if (square == null) return;
        setState(() {
          _shapeAvatar = _shapeAvatar!.newDest(square);
        });
      }
    }

    if (_currentPointerDownEvent == null ||
        _currentPointerDownEvent!.pointer != details.pointer ||
        widget.settings.pieceShiftMethod == PieceShiftMethod.tapTwoSquares) {
      return;
    }

    final distance = (details.position - _currentPointerDownEvent!.position).distance;
    if (_dragAvatar == null && distance > _kDragDistanceThreshold) {
      _onDragStart(_currentPointerDownEvent!);
    }

    final bool isMousePointer = details.kind == PointerDeviceKind.mouse;

    _dragAvatar?.update(details);
    _dragAvatar?.updateSquareTarget(
      _squareTargetGlobalOffset(
        details.localPosition,
        _renderBox!,
        isLargeCircle: !isMousePointer && widget.settings.dragTargetKind == DragTargetKind.circle,
      ),
    );
  }

  void _onPointerUp(PointerUpEvent details) {
    if (!mounted) return;

    if (_drawModeLockOrigin != null && _drawModeLockOrigin!.pointer == details.pointer) {
      _drawModeLockOrigin = null;
    } else if (_shapeAvatar != null &&
        _drawOrigin != null &&
        _drawOrigin!.pointer == details.pointer) {
      widget.settings.drawShape.onCompleteShape?.call(_shapeAvatar!.withScale(1.0));
      setState(() {
        _shapeAvatar = null;
      });
      _drawOrigin = null;
      return;
    }

    if (_currentPointerDownEvent == null || _currentPointerDownEvent!.pointer != details.pointer) {
      return;
    }

    final square = widget.offsetSquare(details.localPosition);

    // handle pointer up while dragging a piece
    if (_dragAvatar != null) {
      bool shouldDeselect = true;

      if (square != null) {
        if (square != selected) {
          final couldMove = _tryMoveOrPremoveTo(square, drop: true);
          // if the premove was not possible, cancel the current premove
          if (!couldMove && widget.game?.premovable?.premove != null) {
            widget.game?.premovable?.onSetPremove.call(null);
          }
        } else {
          // if piece shift method is drag only we always deselect the piece after a drag
          shouldDeselect = widget.settings.pieceShiftMethod == PieceShiftMethod.drag;
        }
      }
      // if the user drags a piece outside the board, cancel the premove
      else if (widget.game?.premovable?.premove != null) {
        widget.game?.premovable?.onSetPremove.call(null);
      }
      _onDragEnd();
      if (shouldDeselect) _setSelection(null);
      setState(() {
        _draggedPieceSquare = null;
      });
    }
    // handle pointer up while not dragging a piece
    else if (selected != null) {
      if (square == selected && _shouldDeselectOnTapUp) {
        _shouldDeselectOnTapUp = false;
        _setSelection(null);
      }
    }

    // cancel premove if the user taps on the origin square of the premove
    if (_shouldCancelPremoveOnTapUp) {
      if (widget.game?.premovable?.premove case NormalMove(:final from) when from == square) {
        _shouldCancelPremoveOnTapUp = false;
        widget.game?.premovable?.onSetPremove.call(null);
      }
    }

    _shouldDeselectOnTapUp = false;
    _shouldCancelPremoveOnTapUp = false;
    _currentPointerDownEvent = null;
  }

  void _onPointerCancel(PointerCancelEvent details) {
    if (!mounted) return;

    if (_drawModeLockOrigin != null && _drawModeLockOrigin!.pointer == details.pointer) {
      _drawModeLockOrigin = null;
    } else if (_shapeAvatar != null &&
        _drawOrigin != null &&
        _drawOrigin!.pointer == details.pointer) {
      setState(() {
        _shapeAvatar = null;
      });
      _drawOrigin = null;
      return;
    }

    if (_currentPointerDownEvent == null || _currentPointerDownEvent!.pointer != details.pointer) {
      return;
    }

    _onDragEnd();
    setState(() {
      _draggedPieceSquare = null;
    });
    _currentPointerDownEvent = null;
    _shouldCancelPremoveOnTapUp = false;
    _shouldDeselectOnTapUp = false;
  }

  void _onDragStart(PointerEvent origin) {
    final bool isMousePointer = origin.kind == PointerDeviceKind.mouse;
    final square = widget.offsetSquare(origin.localPosition);
    final piece = square != null ? pieces[square] : null;
    final feedbackSize =
        widget.squareSize * (isMousePointer ? 1 : widget.settings.dragFeedbackScale);
    if (square != null && piece != null && (_isMovable(piece) || _isPremovable(piece))) {
      setState(() {
        _draggedPieceSquare = square;
      });
      _renderBox ??= context.findRenderObject()! as RenderBox;

      final dragFeedbackOffsetY =
          (_isUpsideDown(piece.color) ? -1 : 1) * widget.settings.dragFeedbackOffset.dy;

      final Offset feedbackOffset =
          feedbackSize == widget.squareSize
              ? Offset((-1 * feedbackSize) / 2, (-1 * feedbackSize) / 2)
              : Offset(
                ((widget.settings.dragFeedbackOffset.dx - 1) * feedbackSize) / 2,
                ((dragFeedbackOffsetY - 1) * feedbackSize) / 2,
              );

      final targetKind =
          isMousePointer && widget.settings.dragTargetKind != DragTargetKind.none
              ? DragTargetKind.square
              : widget.settings.dragTargetKind;

      final asset = widget.settings.pieceAssets[piece.kind]!;
      final image = ChessgroundImages.instance.get(asset);
      final upsideDown = _isUpsideDown(piece.color);

      _dragAvatar = _DragAvatar(
        overlayState: Overlay.of(context, debugRequiredFor: widget),
        initialPosition: origin.position,
        initialTargetPosition: _squareTargetGlobalOffset(
          origin.localPosition,
          _renderBox!,
          isLargeCircle: targetKind == DragTargetKind.circle,
        ),
        image: image,
        feedbackSize: feedbackSize,
        feedbackOffset: feedbackOffset,
        upsideDown: upsideDown,
        targetKind: targetKind,
        squareSize: widget.squareSize,
      );
    }
  }

  void _onDragEnd() {
    _dragAvatar?.end();
    _dragAvatar = null;
    _renderBox = null;
  }

  /// Cancels the current gesture and stops current selection/drag.
  void _cancelGesture() {
    _dragAvatar?.end();
    _dragAvatar = null;
    _renderBox = null;
    _setSelection(null);
    setState(() {
      _draggedPieceSquare = null;
    });
    _currentPointerDownEvent = null;
    _shouldDeselectOnTapUp = false;
    _shouldCancelPremoveOnTapUp = false;
  }

  /// Whether the piece with this color should be displayed upside down, according to the
  /// widget settings.
  bool _isUpsideDown(Side pieceColor) => switch (widget.settings.pieceOrientationBehavior) {
    PieceOrientationBehavior.facingUser => false,
    PieceOrientationBehavior.opponentUpsideDown => pieceColor == widget.orientation.opposite,
    PieceOrientationBehavior.sideToPlay => widget.game?.sideToMove == widget.orientation.opposite,
  };

  /// Whether the piece is movable by the current side to move.
  bool _isMovable(Piece? piece) {
    return piece != null &&
        (widget.game?.playerSide == PlayerSide.both ||
            widget.game?.playerSide.name == piece.color.name) &&
        widget.game?.sideToMove == piece.color;
  }

  /// Whether the piece is premovable by the current side to move.
  bool _isPremovable(Piece? piece) {
    return piece != null &&
        (widget.game?.premovable != null &&
            widget.game?.playerSide.name == piece.color.name &&
            widget.game?.sideToMove != piece.color);
  }

  /// Whether the piece is allowed to be moved to the target square.
  bool _canMoveTo(Square orig, Square dest) {
    final validDests = widget.game?.validMoves[orig];
    return orig != dest && validDests != null && validDests.contains(dest);
  }

  /// Whether the piece is allowed to be premoved to the target square.
  bool _canPremoveTo(Square orig, Square dest) {
    return orig != dest &&
        premovesOf(orig, pieces, canCastle: widget.settings.enablePremoveCastling).contains(dest);
  }

  /// Whether the move is pawn move to the first or eighth rank.
  bool _isPromoMove(Piece piece, Square targetSquare) {
    final rank = targetSquare.rank;
    return piece.role == Role.pawn && (rank == Rank.first || rank == Rank.eighth);
  }

  /// Tries to move or set a premove the selected piece to the target square.
  ///
  /// Returns true if the move/premove was successful.
  bool _tryMoveOrPremoveTo(Square square, {bool drop = false}) {
    final selectedPiece = selected != null ? pieces[selected] : null;
    if (selectedPiece != null && _canMoveTo(selected!, square)) {
      final move = NormalMove(from: selected!, to: square);
      if (drop) {
        _lastDrop = move;
      }
      if (_isPromoMove(selectedPiece, square)) {
        if (widget.settings.autoQueenPromotion) {
          widget.game?.onMove.call(move.withPromotion(Role.queen), viaDragAndDrop: drop);
        } else {
          widget.game?.onMove.call(move, viaDragAndDrop: drop);
        }
      } else {
        widget.game?.onMove.call(move, viaDragAndDrop: drop);
      }
      return true;
    } else if (_isPremovable(selectedPiece) && _canPremoveTo(selected!, square)) {
      final isPromoPremove = _isPromoMove(selectedPiece!, square);
      final premove =
          widget.settings.autoQueenPromotionOnPremove && isPromoPremove
              ? NormalMove(from: selected!, to: square, promotion: Role.queen)
              : NormalMove(from: selected!, to: square);
      widget.game?.premovable?.onSetPremove.call(premove);
      return true;
    }
    return false;
  }
}

// For the logic behind this see:
// https://github.com/flutter/flutter/blob/stable/packages/flutter/lib/src/widgets/drag_target.dart#L805
// and:
// https://github.com/flutter/flutter/blob/ee4e09cce01d6f2d7f4baebd247fde02e5008851/packages/flutter/lib/src/widgets/overlay.dart#L58
class _DragAvatar {
  final OverlayState overlayState;
  final ValueNotifier<Offset> _positionNotifier;
  final ValueNotifier<Offset?> _squareTargetNotifier;
  late final OverlayEntry _pieceEntry;
  late final OverlayEntry _squareTargetEntry;

  _DragAvatar({
    required this.overlayState,
    required Offset initialPosition,
    Offset? initialTargetPosition,
    required ui.Image? image,
    required double feedbackSize,
    required Offset feedbackOffset,
    required bool upsideDown,
    required DragTargetKind targetKind,
    required double squareSize,
  }) : _positionNotifier = ValueNotifier<Offset>(initialPosition),
       _squareTargetNotifier = ValueNotifier<Offset?>(initialTargetPosition) {
    // Only the paint phase runs on each pointer move.
    _pieceEntry = OverlayEntry(
      builder:
          (_) => Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DragPiecePainter(
                  image: image,
                  feedbackSize: feedbackSize,
                  feedbackOffset: feedbackOffset,
                  upsideDown: upsideDown,
                  positionNotifier: _positionNotifier,
                ),
              ),
            ),
          ),
    );
    _squareTargetEntry = OverlayEntry(
      builder:
          (_) => Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DragSquareTargetPainter(
                  squareSize: squareSize,
                  targetKind: targetKind,
                  positionNotifier: _squareTargetNotifier,
                ),
              ),
            ),
          ),
    );
    overlayState.insert(_squareTargetEntry);
    overlayState.insert(_pieceEntry);
  }

  void update(PointerEvent details) {
    _positionNotifier.value = _positionNotifier.value + details.delta;
  }

  void updateSquareTarget(Offset? squareTargetOffset) {
    if (_squareTargetNotifier.value != squareTargetOffset) {
      _squareTargetNotifier.value = squareTargetOffset;
    }
  }

  void end() {
    _finishDrag();
  }

  void cancel() {
    _finishDrag();
  }

  void _finishDrag() {
    _pieceEntry.remove();
    _squareTargetEntry.remove();
    _positionNotifier.dispose();
    _squareTargetNotifier.dispose();
  }
}

class _DragPiecePainter extends CustomPainter {
  _DragPiecePainter({
    required this.image,
    required this.feedbackSize,
    required this.feedbackOffset,
    required this.upsideDown,
    required this.positionNotifier,
  }) : super(repaint: positionNotifier);

  final ui.Image? image;
  final double feedbackSize;
  final Offset feedbackOffset;
  final bool upsideDown;
  final ValueNotifier<Offset> positionNotifier;

  @override
  void paint(Canvas canvas, Size size) {
    final img = image;
    if (img == null) return;
    final pos = positionNotifier.value;
    final dst = Rect.fromLTWH(
      pos.dx + feedbackOffset.dx,
      pos.dy + feedbackOffset.dy,
      feedbackSize,
      feedbackSize,
    );
    final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
    final paint = Paint()..filterQuality = FilterQuality.medium;
    if (upsideDown) {
      canvas.save();
      canvas.translate(dst.center.dx, dst.center.dy);
      canvas.rotate(pi);
      canvas.translate(-dst.center.dx, -dst.center.dy);
      canvas.drawImageRect(img, src, dst, paint);
      canvas.restore();
    } else {
      canvas.drawImageRect(img, src, dst, paint);
    }
  }

  @override
  bool shouldRepaint(_DragPiecePainter oldDelegate) {
    return image != oldDelegate.image ||
        feedbackSize != oldDelegate.feedbackSize ||
        feedbackOffset != oldDelegate.feedbackOffset ||
        upsideDown != oldDelegate.upsideDown;
  }
}

class _DragSquareTargetPainter extends CustomPainter {
  _DragSquareTargetPainter({
    required this.squareSize,
    required this.targetKind,
    required this.positionNotifier,
  }) : super(repaint: positionNotifier);

  final double squareSize;
  final DragTargetKind targetKind;
  final ValueNotifier<Offset?> positionNotifier;

  @override
  void paint(Canvas canvas, Size size) {
    final pos = positionNotifier.value;
    if (pos == null || targetKind == DragTargetKind.none) return;
    final paint =
        Paint()
          ..color = const Color(0x33000000)
          ..style = PaintingStyle.fill;
    if (targetKind == DragTargetKind.circle) {
      // pos is already offset by -squareSize/2 so the circle is centered on the square
      canvas.drawCircle(Offset(pos.dx + squareSize, pos.dy + squareSize), squareSize, paint);
    } else {
      canvas.drawRect(Rect.fromLTWH(pos.dx, pos.dy, squareSize, squareSize), paint);
    }
  }

  @override
  bool shouldRepaint(_DragSquareTargetPainter oldDelegate) {
    return squareSize != oldDelegate.squareSize || targetKind != oldDelegate.targetKind;
  }
}

const ISet<Square> _emptyValidMoves = ISetConst({});
const ISet<Shape> _emptyShapes = ISetConst({});
const IMap<Square, Annotation> _emptyAnnotations = IMapConst({});
