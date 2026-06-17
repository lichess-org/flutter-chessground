import 'dart:async';
import 'dart:ui' as ui;
import 'package:chessground/src/widgets/geometry.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'board_border.dart';
import 'board_controller.dart';
import 'board_painter.dart';
import 'color_filter.dart';
import 'positioned_square.dart';
import 'explosion.dart';
import 'promotion.dart';
import 'shape.dart';
import 'board_annotation.dart';
import 'static_board.dart';
import '../images.dart';
import '../models.dart';
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
  /// Provide a [controller] to control the board position and game state.
  ///
  /// [onMove] is called when the user completes a move, including after a
  /// promotion piece has been selected. The promotion role is already set on
  /// the [Move] at that point.
  ///
  /// To make the board non-interactive (e.g. at the end of a game), drive the
  /// [controller] with game data whose `playerSide` is [PlayerSide.none]. For a
  /// fully static board, use [StaticChessboard] instead.
  const Chessboard({
    super.key,
    required double size,
    required this.controller,
    this.settings = const ChessboardSettings(),
    required this.orientation,
    this.onMove,
    this.onTouchedSquare,
    this.shapes = const {},
    this.annotations = const {},
  }) : _size = size;

  final double _size;

  /// Size of the board in logical pixels.
  @override
  double get size => _size - (settings.border?.width ?? 0) * 2;

  /// Side by which the board is oriented.
  @override
  final Side orientation;

  /// Settings that control the theme and behavior of the board.
  final ChessboardSettings settings;

  /// Controller that drives the board position, game state, and piece animations.
  final ChessboardController controller;

  /// Called after the user completes a move, including after a promotion piece
  /// has been selected. The promotion role is already set on the [Move].
  final void Function(Move, {bool? viaDragAndDrop})? onMove;

  /// Callback called after a square has been touched.
  ///
  /// This will be called even when the board is not interactable, with each [PointerDownEvent] that
  /// targets a square.
  final void Function(Square)? onTouchedSquare;

  /// Optional set of [Shape] to be drawn on the board.
  final Set<Shape> shapes;

  /// Move annotations to be displayed on the board.
  final Map<Square, Annotation> annotations;

  /// Whether the pieces can be moved by one side or both.
  bool get interactive => controller.interactive;

  @override
  // No need to make this class public, as it is only used internally.
  // ignore: library_private_types_in_public_api
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Chessboard> with TickerProviderStateMixin {
  ChessboardController get _controller => widget.controller;
  bool _controllerDetached = false;
  Side? _lastSideToMove;

  Pieces get pieces => _controller.pieces;

  /// Manages active explosion animations.
  late ExplosionSetNotifier _explosionNotifier;

  /// Last explosion set consumed from the controller, used to detect new triggers.
  Set<Square>? _lastSeenExplosionSquares;

  /// Currently selected square.
  Square? selected;

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

  /// Target follower shown while a tap-to-move destination is being chosen with
  /// the pointer still down, when [ChessboardSettings.moveOnRelease] is enabled.
  ///
  /// When non-null, the move is deferred until the pointer is released.
  _DragAvatar? _releaseMoveTarget;

  /// Once a piece is dragged, holds the square id of the piece.
  late final ValueNotifier<Square?> _draggedPieceSquareNotifier;

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

  /// Whether all highlight images are available in the cache.
  bool _highlightImagesLoaded = false;

  /// Whether the pending promotion move was initiated via drag and drop.
  bool _pendingPromotionViaDragAndDrop = false;

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final colorScheme = settings.colorScheme;
    final shapes = {...widget.shapes, ..._controller.drawnShapes};
    final annotations = widget.annotations;

    final background = BrightnessHueFilter(
      hue: widget.settings.hue,
      child:
          settings.border == null && settings.enableCoordinates
              ? widget.orientation == Side.white
                  ? colorScheme.whiteCoordBackground
                  : colorScheme.blackCoordBackground
              : colorScheme.background,
    );

    final highlightsPainter = HighlightsPainter(
      interactionNotifier: _controller.highlightNotifier,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      showLastMove: settings.showLastMove,
      premoveColor: colorScheme.validPremoves,
      lastMoveDetails: colorScheme.lastMove,
      selectedDetails: colorScheme.selected,
      validMoveColor: colorScheme.validMoves,
      squareHighlights: const {},
      highlightImagesLoaded: _highlightImagesLoaded,
    );

    final piecesPainter = PiecesPainter(
      piecesNotifier: _controller.piecesNotifier,
      translatingPiecesNotifier: _controller.translatingPiecesNotifier,
      pieceAssets: settings.pieceAssets,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      draggedPieceSquareNotifier: _draggedPieceSquareNotifier,
      gameNotifier: _controller.gameNotifier,
      pendingPromotionNotifier: _controller.pendingPromotionNotifier,
      blindfoldMode: settings.blindfoldMode,
      pieceOrientationBehavior: settings.pieceOrientationBehavior,
      imagesLoaded: _imagesLoaded,
    );

    final fadingPiecesPainter = FadingPiecesPainter(
      fadingPiecesNotifier: _controller.fadingPiecesNotifier,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      pieceAssets: settings.pieceAssets,
      blindfoldMode: settings.blindfoldMode,
      pieceOrientationBehavior: settings.pieceOrientationBehavior,
      gameNotifier: _controller.gameNotifier,
      animation: _controller.fadeAnimation,
    );

    final translatingPiecesPainter = TranslatingPiecesPainter(
      translatingPiecesNotifier: _controller.translatingPiecesNotifier,
      squareSize: widget.squareSize,
      orientation: widget.orientation,
      pieceAssets: settings.pieceAssets,
      blindfoldMode: settings.blindfoldMode,
      pieceOrientationBehavior: settings.pieceOrientationBehavior,
      gameNotifier: _controller.gameNotifier,
      animation: _controller.translationAnimation,
    );

    final List<Widget> highlightedBackground = [
      SizedBox.square(dimension: widget.size, child: background),
      CustomPaint(size: Size.square(widget.size), painter: highlightsPainter),
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
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: settings.borderRadius,
                  boxShadow: settings.boxShadow,
                ),
                child: Stack(alignment: Alignment.topLeft, children: highlightedBackground),
              )
            else
              ...highlightedBackground,
            CustomPaint(
              size: Size.square(widget.size),
              painter: fadingPiecesPainter,
              willChange: true,
            ),
            // RepaintBoundary isolates this layer so that animation ticks from the
            // fading/translating painters and highlight changes do not cause the
            // static pieces to be re-rasterized. isComplex hints to the raster cache
            // that this picture (up to 32 drawImageRect calls) is worth keeping.
            RepaintBoundary(
              child: CustomPaint(
                size: Size.square(widget.size),
                isComplex: true,
                painter: piecesPainter,
              ),
            ),
            CustomPaint(
              size: Size.square(widget.size),
              painter: translatingPiecesPainter,
              willChange: true,
            ),
            for (final shape in shapes)
              BoardShapeWidget(shape: shape, size: widget.size, orientation: widget.orientation),
            if (_shapeAvatar != null)
              BoardShapeWidget(
                shape: _shapeAvatar!,
                size: widget.size,
                orientation: widget.orientation,
              ),
            for (final entry in annotations.entries)
              BoardAnnotation(
                size: widget.size,
                orientation: widget.orientation,
                square: entry.key,
                annotation: entry.value,
              ),
            CustomPaint(
              size: Size.square(widget.size),
              painter: ExplosionsPainter(
                notifier: _explosionNotifier,
                squareSize: widget.squareSize,
                orientation: widget.orientation,
              ),
              willChange: true,
            ),
            if (widget.settings.enableDrops)
              ...Square.values.map((square) {
                return PositionedSquare(
                  key: ValueKey('${square.name}-drag-target'),
                  size: widget.size,
                  orientation: widget.orientation,
                  square: square,
                  child: DragTarget<Piece>(
                    hitTestBehavior: HitTestBehavior.opaque,
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
                      final currentGame = _controller.game;
                      final piece = details.data;
                      final backRankPawnDrop =
                          piece.role == Role.pawn &&
                          (square.rank == Rank.first || square.rank == Rank.eighth);
                      if (backRankPawnDrop) return;
                      final move = DropMove(to: square, role: piece.role);
                      if (currentGame.sideToMove == piece.color &&
                          currentGame.validDropSquares?.contains(square) == true) {
                        _controller.recordDropMove(move);
                        widget.onMove?.call(move, viaDragAndDrop: true);
                      } else if (widget.settings.enablePremoves &&
                          currentGame.sideToMove != piece.color) {
                        _controller.premove = move;
                      }
                    },
                  ),
                );
              }),
            ValueListenableBuilder<NormalMove?>(
              valueListenable: _controller.pendingPromotionNotifier,
              builder: (context, pendingMove, _) {
                if (pendingMove == null) return const SizedBox.shrink();
                final pawnColor = pieces[pendingMove.from]?.color ?? _controller.game.sideToMove;
                return PromotionSelector(
                  pieceAssets: settings.pieceAssets,
                  move: pendingMove,
                  size: widget.size,
                  color: pawnColor,
                  orientation: widget.orientation,
                  piecesUpsideDown: _isUpsideDown(pawnColor),
                  onSelect: (role) {
                    final resolvedMove = pendingMove.withPromotion(role);
                    final viaDragAndDrop = _pendingPromotionViaDragAndDrop;
                    _pendingPromotionViaDragAndDrop = false;
                    _controller.pendingPromotion = null;
                    if (viaDragAndDrop) _controller.recordDropMove(resolvedMove);
                    widget.onMove?.call(resolvedMove, viaDragAndDrop: viaDragAndDrop);
                  },
                  onCancel: () {
                    _pendingPromotionViaDragAndDrop = false;
                    _controller.pendingPromotion = null;
                  },
                  canPromoteToKing: widget.settings.canPromoteToKing,
                );
              },
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

    // RepaintBoundary stops board repaints from propagating to the app's widget
    // tree. Without it, every animation tick or piece selection would dirty the
    // nearest ancestor compositing layer outside the board.
    return BrightnessHueFilter(
      brightness: widget.settings.brightness,
      child: RepaintBoundary(child: borderedChessboard),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.attachTo(this, widget.settings.animationDuration);
    _controller.addListener(_onControllerChange);
    _lastSideToMove = _controller.game.sideToMove;
    _controller.drawnShapesNotifier.addListener(_onDrawnShapesChange);
    _controller.premoveNotifier.addListener(_onPremoveChange);
    _explosionNotifier = ExplosionSetNotifier(vsync: this);
    _lastSeenExplosionSquares = _controller.pendingExplosionSquares;
    _syncHighlightNotifier();
    _draggedPieceSquareNotifier = ValueNotifier<Square?>(null);
    _imagesLoaded = ChessgroundImages.instance.isAllLoaded(widget.settings.pieceAssets);
    if (!_imagesLoaded) _loadImages(widget.settings.pieceAssets);
    _highlightImagesLoaded = _areHighlightImagesLoaded();
    if (!_highlightImagesLoaded) _loadHighlightImages();
  }

  Future<void> _loadImages(PieceAssets assets) async {
    final dpr = WidgetsBinding.instance.platformDispatcher.implicitView?.devicePixelRatio;
    await ChessgroundImages.instance.loadAll(assets, devicePixelRatio: dpr);
    if (mounted) setState(() => _imagesLoaded = true);
  }

  bool _areHighlightImagesLoaded() {
    final colorScheme = widget.settings.colorScheme;
    if (colorScheme.lastMove.image != null &&
        ChessgroundImages.instance.get(colorScheme.lastMove.image!) == null) {
      return false;
    }
    if (colorScheme.selected.image != null &&
        ChessgroundImages.instance.get(colorScheme.selected.image!) == null) {
      return false;
    }
    return true;
  }

  Future<void> _loadHighlightImages() async {
    final dpr = WidgetsBinding.instance.platformDispatcher.implicitView?.devicePixelRatio;
    final colorScheme = widget.settings.colorScheme;
    final images = <AssetImage>[];
    if (colorScheme.lastMove.image != null) images.add(colorScheme.lastMove.image!);
    if (colorScheme.selected.image != null) images.add(colorScheme.selected.image!);
    if (images.isEmpty) return;
    await Future.wait<void>([
      for (final img in images) ChessgroundImages.instance.load(img, devicePixelRatio: dpr),
    ]);
    if (mounted) setState(() => _highlightImagesLoaded = true);
  }

  @override
  void deactivate() {
    _controller.detach();
    _controllerDetached = true;
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    _controller.attachTo(this, widget.settings.animationDuration);
    _controllerDetached = false;
  }

  @override
  void dispose() {
    _controller.drawnShapesNotifier.removeListener(_onDrawnShapesChange);
    _controller.premoveNotifier.removeListener(_onPremoveChange);
    _controller.removeListener(_onControllerChange);
    // deactivate() already called detach(); only call it here if activate()
    // re-attached us (i.e. the widget was temporarily removed then reinserted).
    if (!_controllerDetached) {
      _controller.detach();
    }
    _explosionNotifier.dispose();
    _draggedPieceSquareNotifier.dispose();
    _dragAvatar?.cancel();
    _releaseMoveTarget?.cancel();
    _cancelShapesDoubleTapTimer?.cancel();
    super.dispose();
  }

  void _onDrawnShapesChange() {
    setState(() {});
  }

  void _onPremoveChange() {
    _syncHighlightNotifier();
  }

  void _onControllerChange() {
    if (!_controller.interactive) {
      _currentPointerDownEvent = null;
      _dragAvatar?.cancel();
      _dragAvatar = null;
      _releaseMoveTarget?.cancel();
      _releaseMoveTarget = null;
      _draggedPieceSquareNotifier.value = null;
      selected = null;
      _premoveDests = null;
      _controller.pendingPromotion = null;
      _pendingPromotionViaDragAndDrop = false;
    }
    final currentSideToMove = _controller.game.sideToMove;
    if (currentSideToMove != _lastSideToMove) {
      _premoveDests = null;
      _lastSideToMove = currentSideToMove;
    }
    _syncHighlightNotifier();
    final newExplosions = _controller.pendingExplosionSquares;
    if (newExplosions != null && newExplosions != _lastSeenExplosionSquares) {
      _lastSeenExplosionSquares = newExplosions;
      _explosionNotifier.trigger(newExplosions);
    }
  }

  @override
  void didUpdateWidget(Chessboard oldBoard) {
    super.didUpdateWidget(oldBoard);
    if (oldBoard.settings.drawShape.enable && !widget.settings.drawShape.enable) {
      _drawModeLockOrigin = null;
      _drawOrigin = null;
      _shapeAvatar = null;
    }

    if (oldBoard.controller != widget.controller) {
      oldBoard.controller.removeListener(_onControllerChange);
      oldBoard.controller.drawnShapesNotifier.removeListener(_onDrawnShapesChange);
      oldBoard.controller.premoveNotifier.removeListener(_onPremoveChange);
      oldBoard.controller.detach();
      _controller.attachTo(this, widget.settings.animationDuration);
      _controller.addListener(_onControllerChange);
      _controller.drawnShapesNotifier.addListener(_onDrawnShapesChange);
      _controller.premoveNotifier.addListener(_onPremoveChange);
      _lastSideToMove = _controller.game.sideToMove;
      _pendingPromotionViaDragAndDrop = false;
    }

    _syncHighlightNotifier();

    if (oldBoard.settings.pieceAssets != widget.settings.pieceAssets) {
      _imagesLoaded = ChessgroundImages.instance.isAllLoaded(widget.settings.pieceAssets);
      if (!_imagesLoaded) _loadImages(widget.settings.pieceAssets);
    }

    if (oldBoard.settings.colorScheme != widget.settings.colorScheme) {
      _highlightImagesLoaded = _areHighlightImagesLoaded();
      if (!_highlightImagesLoaded) _loadHighlightImages();
    }

    if (oldBoard.settings.animationDuration != widget.settings.animationDuration) {
      _controller.animationDuration = widget.settings.animationDuration;
    }
  }

  /// Updates the highlight notifier with the current selection state so
  /// [HighlightsPainter] repaints without a full widget rebuild.
  void _syncHighlightNotifier() {
    final game = _controller.game;
    final moveDests =
        widget.settings.showValidMoves && selected != null
            ? game.validMoves[selected] ?? const <Square>{}
            : const <Square>{};
    final premoveDests =
        widget.settings.showValidMoves ? _premoveDests ?? const <Square>{} : const <Square>{};
    final premove = _controller.premove;
    final premoveHighlight =
        premove != null && game.playerSide.name == game.sideToMove.opposite.name ? premove : null;
    _controller.highlightNotifier.update(
      selected: selected,
      moveDests: moveDests,
      premoveDests: premoveDests,
      occupiedSquares: _controller.pieces.keys.toSet(),
      lastMove: _controller.lastMove,
      premove: premoveHighlight,
      checkSquare: game.kingSquareInCheck,
    );
  }

  /// Sets interaction state and triggers a highlights repaint via the notifier.
  void _setSelection(Square? newSelected, {Set<Square>? newPremoveDests}) {
    selected = newSelected;
    _premoveDests = newPremoveDests;
    _syncHighlightNotifier();
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
            _controller.clearDrawnShapes();
            _cancelShapesDoubleTapTimer?.cancel();
            _cancelShapesDoubleTapTimer = null;
          } else {
            _cancelShapesDoubleTapTimer = Timer(_kCancelShapesDoubleTapDelay, () {
              _cancelShapesDoubleTapTimer = null;
            });
          }
        }
        // selecting a piece to move should clear drawn shapes
        else if (_isMovable(piece) || _isPremovable(piece)) {
          _cancelShapesDoubleTapTimer?.cancel();
          if (_controller.drawnShapes.isNotEmpty) {
            _controller.clearDrawnShapes();
          }
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

    if (!_controller.interactive) return;

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
      // When moveOnRelease is enabled, don't move yet: arm the move and show a
      // target following the finger. The move is committed on pointer up.
      if (widget.settings.moveOnRelease) {
        _beginReleaseMove(details);
      } else {
        _moveSelectedOrSelect(square);
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
    else if (_controller.premove != null) {
      _controller.premove = null;
      _setSelection(null);
    }

    // there is a premove set from the touched square:
    // - cancel the premove on the next tap up event
    if (_controller.premove case NormalMove(:final from) when from == square) {
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

    // While a moveOnRelease destination is being chosen, the square target
    // follows the finger; the move is committed on pointer up.
    if (_releaseMoveTarget != null) {
      if (_currentPointerDownEvent != null &&
          _currentPointerDownEvent!.pointer == details.pointer) {
        final bool isMousePointer = details.kind == PointerDeviceKind.mouse;
        _releaseMoveTarget!.updateSquareTarget(
          _squareTargetGlobalOffset(
            details.localPosition,
            _renderBox!,
            isLargeCircle:
                !isMousePointer && widget.settings.dragTargetKind == DragTargetKind.circle,
          ),
        );
      }
      return;
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
      _controller.toggleDrawnShape(_shapeAvatar!.withScale(1.0));
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

    // handle pointer up while choosing a moveOnRelease destination: commit the
    // move on the square under the released pointer
    if (_releaseMoveTarget != null) {
      _endReleaseMoveTarget();
      if (square != null && square != selected) {
        _moveSelectedOrSelect(square);
      } else {
        _setSelection(null);
      }
      _shouldDeselectOnTapUp = false;
      _shouldCancelPremoveOnTapUp = false;
      _currentPointerDownEvent = null;
      return;
    }

    // handle pointer up while dragging a piece
    if (_dragAvatar != null) {
      bool shouldDeselect = true;

      if (square != null) {
        if (square != selected) {
          final couldMove = _tryMoveOrPremoveTo(square, drop: true);
          // if the premove was not possible, cancel the current premove
          if (!couldMove && _controller.premove != null) {
            _controller.premove = null;
          }
        } else {
          // if piece shift method is drag only we always deselect the piece after a drag
          shouldDeselect = widget.settings.pieceShiftMethod == PieceShiftMethod.drag;
        }
      }
      // if the user drags a piece outside the board, cancel the premove
      else if (_controller.premove != null) {
        _controller.premove = null;
      }
      _onDragEnd();
      if (shouldDeselect) _setSelection(null);
      _draggedPieceSquareNotifier.value = null;
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
      if (_controller.premove case NormalMove(:final from) when from == square) {
        _shouldCancelPremoveOnTapUp = false;
        _controller.premove = null;
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
    _endReleaseMoveTarget();
    _draggedPieceSquareNotifier.value = null;
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
      _draggedPieceSquareNotifier.value = square;
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

  /// Tries to move the selected piece to [square]; if that is not possible but a
  /// movable piece sits on [square], selects it instead; otherwise clears the
  /// selection.
  void _moveSelectedOrSelect(Square square) {
    final couldMove = _tryMoveOrPremoveTo(square);
    if (!couldMove && _isMovable(pieces[square])) {
      _setSelection(square);
    } else {
      _setSelection(null);
    }
  }

  /// Starts following the pointer with a square target so the user can choose a
  /// move destination, committed on pointer up (see [ChessboardSettings.moveOnRelease]).
  void _beginReleaseMove(PointerDownEvent origin) {
    _renderBox ??= context.findRenderObject()! as RenderBox;
    final bool isMousePointer = origin.kind == PointerDeviceKind.mouse;
    final targetKind =
        isMousePointer && widget.settings.dragTargetKind != DragTargetKind.none
            ? DragTargetKind.square
            : widget.settings.dragTargetKind;
    _releaseMoveTarget = _DragAvatar(
      overlayState: Overlay.of(context, debugRequiredFor: widget),
      initialPosition: origin.position,
      initialTargetPosition: _squareTargetGlobalOffset(
        origin.localPosition,
        _renderBox!,
        isLargeCircle: targetKind == DragTargetKind.circle,
      ),
      // No piece is shown, only the square target following the finger.
      image: null,
      feedbackSize: widget.squareSize,
      feedbackOffset: Offset.zero,
      upsideDown: false,
      targetKind: targetKind,
      squareSize: widget.squareSize,
    );
  }

  void _endReleaseMoveTarget() {
    _releaseMoveTarget?.end();
    _releaseMoveTarget = null;
    _renderBox = null;
  }

  /// Cancels the current gesture and stops current selection/drag.
  void _cancelGesture() {
    _dragAvatar?.end();
    _dragAvatar = null;
    _releaseMoveTarget?.end();
    _releaseMoveTarget = null;
    _renderBox = null;
    _setSelection(null);
    _draggedPieceSquareNotifier.value = null;
    _currentPointerDownEvent = null;
    _shouldDeselectOnTapUp = false;
    _shouldCancelPremoveOnTapUp = false;
  }

  /// Whether the piece with this color should be displayed upside down, according to the
  /// widget settings.
  bool _isUpsideDown(Side pieceColor) => switch (widget.settings.pieceOrientationBehavior) {
    PieceOrientationBehavior.facingUser => false,
    PieceOrientationBehavior.opponentUpsideDown => pieceColor == widget.orientation.opposite,
    PieceOrientationBehavior.sideToPlay =>
      _controller.game.sideToMove == widget.orientation.opposite,
  };

  /// Whether the piece is movable by the current side to move.
  bool _isMovable(Piece? piece) {
    final game = _controller.game;
    return piece != null &&
        (game.playerSide == PlayerSide.both || game.playerSide.name == piece.color.name) &&
        game.sideToMove == piece.color;
  }

  /// Whether the piece is premovable by the current side to move.
  bool _isPremovable(Piece? piece) {
    final game = _controller.game;
    return piece != null &&
        widget.settings.enablePremoves &&
        game.playerSide.name == piece.color.name &&
        game.sideToMove != piece.color;
  }

  /// Whether the piece is allowed to be moved to the target square.
  bool _canMoveTo(Square orig, Square dest) {
    final validDests = _controller.game.validMoves[orig];
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
      if (_isPromoMove(selectedPiece, square)) {
        if (widget.settings.autoQueenPromotion) {
          final promoted = move.withPromotion(Role.queen);
          if (drop) _controller.recordDropMove(promoted);
          widget.onMove?.call(promoted, viaDragAndDrop: drop);
        } else {
          _pendingPromotionViaDragAndDrop = drop;
          _controller.pendingPromotion = move;
        }
      } else {
        if (drop) _controller.recordDropMove(move);
        widget.onMove?.call(move, viaDragAndDrop: drop);
      }
      return true;
    } else if (_isPremovable(selectedPiece) && _canPremoveTo(selected!, square)) {
      final isPromoPremove = _isPromoMove(selectedPiece!, square);
      final premove =
          widget.settings.autoQueenPromotionOnPremove && isPromoPremove
              ? NormalMove(from: selected!, to: square, promotion: Role.queen)
              : NormalMove(from: selected!, to: square);
      _controller.premove = premove;
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
                painter: DragPiecePainter(
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
                painter: DragSquareTargetPainter(
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
