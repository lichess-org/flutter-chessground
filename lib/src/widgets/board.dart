import 'dart:async';
import 'package:chessground/src/widgets/geometry.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'coordinate.dart';
import 'piece.dart';
import 'highlight.dart';
import 'positioned_square.dart';
import 'animation.dart';
import 'promotion.dart';
import 'shape.dart';
import 'board_annotation.dart';
import 'static_board.dart';
import '../models.dart';
import '../fen.dart';
import '../premove.dart';
import '../board_settings.dart';

/// Number of logical pixels that have to be dragged before a drag starts.
const double _kDragDistanceThreshold = 3.0;

const _kCancelShapesDoubleTapDelay = Duration(milliseconds: 200);

/// A chessboard widget.
///
/// This widget can be used to display a fully interactive board, or a non-interactive
/// board that can be animated.
///
/// For a completely static board, see also [StaticChessboard].
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
    required this.game,
    this.shapes,
    this.annotations,
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
    this.shapes,
    this.annotations,
  })  : _size = size,
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

  /// FEN string describing the position of the board.
  final String fen;

  /// Last move played, used to highlight corresponding squares.
  final Move? lastMove;

  /// Game state of the board.
  ///
  /// If `null`, the board cannot be interacted with.
  final GameData? game;

  /// Optional set of [Shape] to be drawn on the board.
  final ISet<Shape>? shapes;

  /// Move annotations to be displayed on the board.
  final IMap<Square, Annotation>? annotations;

  /// Whether the pieces can be moved by one side or both.
  bool get interactive => game != null && game!.playerSide != PlayerSide.none;

  @override
  // ignore: library_private_types_in_public_api
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Chessboard> {
  /// Pieces on the board.
  Pieces pieces = {};

  /// Pieces that are currently being translated from one square to another.
  ///
  /// The key is the target square of the piece.
  Map<Square, ({Piece piece, Square from})> translatingPieces = {};

  /// Pieces that are currently fading out.
  Map<Square, Piece> fadingPieces = {};

  /// Currently selected square.
  Square? selected;

  /// Last move that was played using drag and drop.
  NormalMove? _lastDrop;

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

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final colorScheme = settings.colorScheme;
    final ISet<Square> moveDests = settings.showValidMoves &&
            selected != null &&
            widget.game?.validMoves != null
        ? widget.game?.validMoves[selected!] ?? _emptyValidMoves
        : _emptyValidMoves;
    final Set<Square> premoveDests =
        settings.showValidMoves ? _premoveDests ?? {} : {};
    final shapes = widget.shapes ?? _emptyShapes;
    final annotations = widget.annotations ?? _emptyAnnotations;
    final checkSquare = widget.game?.isCheck == true ? _getKingSquare() : null;
    final premove = widget.game?.premovable?.premove;

    final background = settings.border == null && settings.enableCoordinates
        ? widget.orientation == Side.white
            ? colorScheme.whiteCoordBackground
            : colorScheme.blackCoordBackground
        : colorScheme.background;

    final List<Widget> highlightedBackground = [
      SizedBox.square(
        key: const ValueKey('board-background'),
        dimension: widget.size,
        child: background,
      ),
      if (settings.showLastMove && widget.lastMove != null)
        for (final square in widget.lastMove!.squares)
          if (premove == null || !premove.hasSquare(square))
            PositionedSquare(
              key: ValueKey('${square.name}-lastMove'),
              size: widget.size,
              orientation: widget.orientation,
              square: square,
              child: SquareHighlight(details: colorScheme.lastMove),
            ),
      if (premove != null &&
          widget.game?.playerSide.name == widget.game?.sideToMove.opposite.name)
        for (final square in premove.squares)
          PositionedSquare(
            key: ValueKey('${square.name}-premove'),
            size: widget.size,
            orientation: widget.orientation,
            square: square,
            child: SquareHighlight(
              details: HighlightDetails(solidColor: colorScheme.validPremoves),
            ),
          ),
      if (selected != null)
        PositionedSquare(
          key: ValueKey('${selected!.name}-selected'),
          size: widget.size,
          orientation: widget.orientation,
          square: selected!,
          child: SquareHighlight(details: colorScheme.selected),
        ),
      for (final dest in moveDests)
        PositionedSquare(
          key: ValueKey('${dest.name}-dest'),
          size: widget.size,
          orientation: widget.orientation,
          square: dest,
          child: ValidMoveHighlight(
            size: widget.squareSize,
            color: colorScheme.validMoves,
            occupied: pieces.containsKey(dest),
          ),
        ),
      for (final dest in premoveDests)
        PositionedSquare(
          key: ValueKey('${dest.name}-premove-dest'),
          size: widget.size,
          orientation: widget.orientation,
          square: dest,
          child: ValidMoveHighlight(
            size: widget.squareSize,
            color: colorScheme.validPremoves,
            occupied: pieces.containsKey(dest),
          ),
        ),
      if (checkSquare != null)
        PositionedSquare(
          key: ValueKey('${checkSquare.name}-check'),
          size: widget.size,
          orientation: widget.orientation,
          square: checkSquare,
          child: CheckHighlight(size: widget.squareSize),
        ),
    ];

    final List<Widget> objects = [
      for (final entry in fadingPieces.entries)
        PositionedSquare(
          key: ValueKey('${entry.key.name}-${entry.value}-fading'),
          size: widget.size,
          orientation: widget.orientation,
          square: entry.key,
          child: AnimatedPieceFadeOut(
            duration: settings.animationDuration,
            piece: entry.value,
            size: widget.squareSize,
            pieceAssets: settings.pieceAssets,
            blindfoldMode: settings.blindfoldMode,
            upsideDown: _isUpsideDown(entry.value.color),
            onComplete: () {
              fadingPieces.remove(entry.key);
            },
          ),
        ),
      for (final entry in pieces.entries)
        if (!translatingPieces.containsKey(entry.key) &&
            entry.key != _draggedPieceSquare &&
            entry.key != widget.game?.promotionMove?.from)
          PositionedSquare(
            key: ValueKey('${entry.key.name}-${entry.value}'),
            size: widget.size,
            orientation: widget.orientation,
            square: entry.key,
            child: PieceWidget(
              piece: entry.value,
              size: widget.squareSize,
              pieceAssets: settings.pieceAssets,
              blindfoldMode: settings.blindfoldMode,
              upsideDown: _isUpsideDown(entry.value.color),
            ),
          ),
      for (final entry in translatingPieces.entries)
        PositionedSquare(
          key: ValueKey('${entry.key.name}-${entry.value.piece}'),
          size: widget.size,
          orientation: widget.orientation,
          square: entry.key,
          child: AnimatedPieceTranslation(
            fromSquare: entry.value.from,
            toSquare: entry.key,
            orientation: widget.orientation,
            duration: settings.animationDuration,
            onComplete: () {
              translatingPieces.remove(entry.key);
            },
            child: PieceWidget(
              piece: entry.value.piece,
              size: widget.squareSize,
              pieceAssets: settings.pieceAssets,
              blindfoldMode: settings.blindfoldMode,
              upsideDown: _isUpsideDown(entry.value.piece.color),
            ),
          ),
        ),
      for (final entry in annotations.entries)
        BoardAnnotation(
          key: ValueKey(
            '${entry.key.name}-${entry.value.symbol}-${entry.value.color}',
          ),
          size: widget.size,
          orientation: widget.orientation,
          square: entry.key,
          annotation: entry.value,
        ),
      for (final shape in shapes)
        ShapeWidget(
          shape: shape,
          size: widget.size,
          orientation: widget.orientation,
        ),
      if (_shapeAvatar != null)
        ShapeWidget(
          shape: _shapeAvatar!,
          size: widget.size,
          orientation: widget.orientation,
        ),
    ];

    final enableListeners = widget.interactive || settings.drawShape.enable;

    final board = Listener(
      onPointerDown: enableListeners ? _onPointerDown : null,
      onPointerMove: enableListeners ? _onPointerMove : null,
      onPointerUp: enableListeners ? _onPointerUp : null,
      onPointerCancel: enableListeners ? _onPointerCancel : null,
      child: SizedBox.square(
        key: const ValueKey('board-container'),
        dimension: widget.size,
        child: Stack(
          alignment: Alignment.topLeft,
          clipBehavior: Clip.none,
          children: [
            if (settings.border == null &&
                (settings.boxShadow.isNotEmpty ||
                    settings.borderRadius != BorderRadius.zero))
              Container(
                key: const ValueKey('background-container'),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: settings.borderRadius,
                  boxShadow: settings.boxShadow,
                ),
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: highlightedBackground,
                ),
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
              ),
          ],
        ),
      ),
    );

    if (settings.border != null) {
      return Container(
        width: widget.size + settings.border!.width * 2,
        height: widget.size + settings.border!.width * 2,
        color: settings.border!.color,
        child: Stack(
          alignment: Alignment.center,
          children: [
            board,
            if (settings.enableCoordinates)
              Positioned(
                top: settings.border!.width,
                left: 0,
                child: BorderRankCoordinates(
                  orientation: widget.orientation,
                  width: settings.border!.width,
                  height: widget.size,
                ),
              ),
            if (settings.enableCoordinates)
              Positioned(
                bottom: 0,
                left: settings.border!.width,
                child: BorderFileCoordinates(
                  orientation: widget.orientation,
                  width: widget.size,
                  height: settings.border!.width,
                ),
              ),
          ],
        ),
      );
    }

    return board;
  }

  @override
  void initState() {
    super.initState();
    pieces = readFen(widget.fen);
  }

  @override
  void dispose() {
    super.dispose();
    _dragAvatar?.cancel();
    _cancelShapesDoubleTapTimer?.cancel();
  }

  @override
  void didUpdateWidget(Chessboard oldBoard) {
    super.didUpdateWidget(oldBoard);
    if (oldBoard.settings.drawShape.enable &&
        !widget.settings.drawShape.enable) {
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
    if (oldBoard.fen == widget.fen) {
      _lastDrop = null;
      // as long as the fen is the same as before let's keep animations
      return;
    }

    translatingPieces = {};
    fadingPieces = {};

    final newPieces = readFen(widget.fen);

    if (widget.settings.animationDuration > Duration.zero) {
      _preparePieceAnimations(newPieces);
    }

    _lastDrop = null;
    pieces = newPieces;
  }

  /// Detects pieces that changed squares and prepares animations for them.
  void _preparePieceAnimations(Pieces newPieces) {
    final List<(Piece, Square)> newOnSquare = [];
    final List<(Piece, Square)> missingOnSquare = [];
    final Set<Square> animatedOrigins = {};
    for (final s in Square.values) {
      if (s == _lastDrop?.from || s == _lastDrop?.to) {
        continue;
      }
      final oldP = pieces[s];
      final newP = newPieces[s];
      if (newP != null) {
        if (oldP != null) {
          if (newP != oldP) {
            missingOnSquare.add((oldP, s));
            newOnSquare.add((newP, s));
          }
        } else {
          newOnSquare.add((newP, s));
        }
      } else if (oldP != null) {
        missingOnSquare.add((oldP, s));
      }
    }
    for (final (newPiece, newPieceSquare) in newOnSquare) {
      // find the closest square that the piece was on before
      final fromSquare = _closestSquare(
        newPieceSquare,
        missingOnSquare.where((m) => m.$1 == newPiece).map((e) => e.$2),
      );
      if (fromSquare != null) {
        translatingPieces[newPieceSquare] = (piece: newPiece, from: fromSquare);
        animatedOrigins.add(fromSquare);
      }
    }
    for (final (missingPiece, missingPieceSquare) in missingOnSquare) {
      if (!animatedOrigins.contains(missingPieceSquare)) {
        fadingPieces[missingPieceSquare] = missingPiece;
      }
    }
  }

  Square? _getKingSquare() {
    for (final square in pieces.keys) {
      if (pieces[square]!.color == widget.game?.sideToMove &&
          pieces[square]!.role == Role.king) {
        return square;
      }
    }
    return null;
  }

  /// Returns the position of the square target during drag as a global offset.
  Offset? _squareTargetGlobalOffset(Offset localPosition, RenderBox box) {
    final square = widget.offsetSquare(localPosition);
    if (square == null) return null;
    final localOffset = widget.squareOffset(square);
    final tmpOffset = box.localToGlobal(localOffset);
    return Offset(
      (widget.settings.border?.width ?? 0) +
          tmpOffset.dx -
          widget.squareSize / 2,
      (widget.settings.border?.width ?? 0) +
          tmpOffset.dy -
          widget.squareSize / 2,
    );
  }

  void _onPointerDown(PointerDownEvent details) {
    if (details.buttons != kPrimaryButton) return;

    final square = widget.offsetSquare(details.localPosition);
    if (square == null) return;

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
            _cancelShapesDoubleTapTimer =
                Timer(_kCancelShapesDoubleTapDelay, () {
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
        setState(() {
          selected = square;
        });
      } else {
        setState(() {
          selected = null;
          _premoveDests = null;
        });
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
      setState(() {
        selected = square;
      });
    }
    // no piece was selected yet and a premovable piece is touched:
    // - select the piece
    // - make the premove destinations
    else if (_isPremovable(piece)) {
      setState(() {
        selected = square;
        _premoveDests = premovesOf(
          square,
          pieces,
          canCastle: widget.settings.enablePremoveCastling,
        );
      });
    }
    // pointer down on empty square:
    // - cancel premove
    // - unselect piece
    else if (widget.game?.premovable?.premove != null) {
      widget.game?.premovable?.onSetPremove.call(null);
      setState(() {
        selected = null;
        _premoveDests = null;
      });
    }

    // there is a premove set from the touched square:
    // - cancel the premove on the next tap up event
    if (widget.game?.premovable?.premove != null &&
        widget.game?.premovable?.premove!.from == square) {
      _shouldCancelPremoveOnTapUp = true;
    }

    // prevent moving the piece by 2 taps when the piece shift method is drag only
    if (widget.settings.pieceShiftMethod == PieceShiftMethod.drag) {
      _shouldDeselectOnTapUp = true;
    }
  }

  void _onPointerMove(PointerMoveEvent details) {
    if (details.buttons != kPrimaryButton) return;

    // draw mode takes priority over play mode when the draw mode lock is set
    if (_shapeAvatar != null &&
        _drawOrigin != null &&
        _drawOrigin!.pointer == details.pointer) {
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

    final distance =
        (details.position - _currentPointerDownEvent!.position).distance;
    if (_dragAvatar == null && distance > _kDragDistanceThreshold) {
      _onDragStart(_currentPointerDownEvent!);
    }

    _dragAvatar?.update(details);
    _dragAvatar?.updateSquareTarget(
      _squareTargetGlobalOffset(details.localPosition, _renderBox!),
    );
  }

  void _onPointerUp(PointerUpEvent details) {
    if (_drawModeLockOrigin != null &&
        _drawModeLockOrigin!.pointer == details.pointer) {
      _drawModeLockOrigin = null;
    } else if (_shapeAvatar != null &&
        _drawOrigin != null &&
        _drawOrigin!.pointer == details.pointer) {
      widget.settings.drawShape.onCompleteShape
          ?.call(_shapeAvatar!.withScale(1.0));
      setState(() {
        _shapeAvatar = null;
      });
      _drawOrigin = null;
      return;
    }

    if (_currentPointerDownEvent == null ||
        _currentPointerDownEvent!.pointer != details.pointer) {
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
          shouldDeselect = false;
        }
      }
      // if the user drags a piece outside the board, cancel the premove
      else if (widget.game?.premovable?.premove != null) {
        widget.game?.premovable?.onSetPremove.call(null);
      }
      _onDragEnd();
      setState(() {
        if (shouldDeselect) {
          selected = null;
          _premoveDests = null;
        }
        _draggedPieceSquare = null;
      });
    }
    // handle pointer up while not dragging a piece
    else if (selected != null) {
      if (square == selected && _shouldDeselectOnTapUp) {
        _shouldDeselectOnTapUp = false;
        setState(() {
          selected = null;
          _premoveDests = null;
        });
      }
    }

    // cancel premove if the user taps on the origin square of the premove
    if (_shouldCancelPremoveOnTapUp &&
        widget.game?.premovable?.premove != null &&
        widget.game?.premovable?.premove!.from == square) {
      _shouldCancelPremoveOnTapUp = false;
      widget.game?.premovable?.onSetPremove.call(null);
    }

    _shouldDeselectOnTapUp = false;
    _shouldCancelPremoveOnTapUp = false;
    _currentPointerDownEvent = null;
  }

  void _onPointerCancel(PointerCancelEvent details) {
    if (_drawModeLockOrigin != null &&
        _drawModeLockOrigin!.pointer == details.pointer) {
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

    if (_currentPointerDownEvent == null ||
        _currentPointerDownEvent!.pointer != details.pointer) {
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
    final square = widget.offsetSquare(origin.localPosition);
    final piece = square != null ? pieces[square] : null;
    final feedbackSize = widget.squareSize * widget.settings.dragFeedbackScale;
    if (square != null &&
        piece != null &&
        (_isMovable(piece) || _isPremovable(piece))) {
      setState(() {
        _draggedPieceSquare = square;
      });
      _renderBox ??= context.findRenderObject()! as RenderBox;

      final dragFeedbackOffsetY = (_isUpsideDown(piece.color) ? -1 : 1) *
          widget.settings.dragFeedbackOffset.dy;

      _dragAvatar = _DragAvatar(
        overlayState: Overlay.of(context, debugRequiredFor: widget),
        initialPosition: origin.position,
        initialTargetPosition:
            _squareTargetGlobalOffset(origin.localPosition, _renderBox!),
        squareTargetFeedback: Container(
          width: widget.squareSize * 2,
          height: widget.squareSize * 2,
          decoration: const BoxDecoration(
            color: Color(0x33000000),
            shape: BoxShape.circle,
          ),
        ),
        pieceFeedback: Transform.translate(
          offset: Offset(
            ((widget.settings.dragFeedbackOffset.dx - 1) * feedbackSize) / 2,
            ((dragFeedbackOffsetY - 1) * feedbackSize) / 2,
          ),
          child: PieceWidget(
            piece: piece,
            size: feedbackSize,
            pieceAssets: widget.settings.pieceAssets,
            blindfoldMode: widget.settings.blindfoldMode,
            upsideDown: _isUpsideDown(piece.color),
          ),
        ),
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
    setState(() {
      _draggedPieceSquare = null;
      selected = null;
    });
    _currentPointerDownEvent = null;
    _shouldDeselectOnTapUp = false;
    _shouldCancelPremoveOnTapUp = false;
  }

  /// Whether the piece with this color should be displayed upside down, according to the
  /// widget settings.
  bool _isUpsideDown(Side pieceColor) =>
      switch (widget.settings.pieceOrientationBehavior) {
        PieceOrientationBehavior.facingUser => false,
        PieceOrientationBehavior.opponentUpsideDown =>
          pieceColor == widget.orientation.opposite,
        PieceOrientationBehavior.sideToPlay =>
          widget.game?.sideToMove == widget.orientation.opposite,
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
        premovesOf(
          orig,
          pieces,
          canCastle: widget.settings.enablePremoveCastling,
        ).contains(dest);
  }

  /// Whether the move is pawn move to the first or eighth rank.
  bool _isPromoMove(Piece piece, Square targetSquare) {
    final rank = targetSquare.rank;
    return piece.role == Role.pawn &&
        (rank == Rank.first || rank == Rank.eighth);
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
          widget.game?.onMove.call(
            move.withPromotion(Role.queen),
            isDrop: drop,
          );
        } else {
          widget.game?.onMove.call(move, isDrop: drop);
        }
      } else {
        widget.game?.onMove.call(move, isDrop: drop);
      }
      return true;
    } else if (_isPremovable(selectedPiece) &&
        _canPremoveTo(selected!, square)) {
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
  final Widget pieceFeedback;
  final Widget squareTargetFeedback;
  final OverlayState overlayState;
  Offset _position;
  Offset? _squareTargetPosition;
  late final OverlayEntry _pieceEntry;
  late final OverlayEntry _squareTargetEntry;

  _DragAvatar({
    required this.overlayState,
    required Offset initialPosition,
    Offset? initialTargetPosition,
    required this.pieceFeedback,
    required this.squareTargetFeedback,
  })  : _position = initialPosition,
        _squareTargetPosition = initialTargetPosition {
    _pieceEntry = OverlayEntry(builder: _buildPieceFeedback);
    _squareTargetEntry = OverlayEntry(builder: _buildSquareTargetFeedback);
    overlayState.insert(_squareTargetEntry);
    overlayState.insert(_pieceEntry);
    _updateDrag();
  }

  void update(PointerEvent details) {
    _position += details.delta;
    _updateDrag();
  }

  void updateSquareTarget(Offset? squareTargetOffset) {
    if (_squareTargetPosition != squareTargetOffset) {
      _squareTargetPosition = squareTargetOffset;
      _squareTargetEntry.markNeedsBuild();
    }
  }

  void end() {
    finishDrag();
  }

  void cancel() {
    finishDrag();
  }

  void _updateDrag() {
    _pieceEntry.markNeedsBuild();
  }

  void finishDrag() {
    _pieceEntry.remove();
    _squareTargetEntry.remove();
  }

  Widget _buildPieceFeedback(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: IgnorePointer(
        child: pieceFeedback,
      ),
    );
  }

  Widget _buildSquareTargetFeedback(BuildContext context) {
    if (_squareTargetPosition != null) {
      return Positioned(
        left: _squareTargetPosition!.dx,
        top: _squareTargetPosition!.dy,
        child: IgnorePointer(
          child: squareTargetFeedback,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

const ISet<Square> _emptyValidMoves = ISetConst({});
const ISet<Shape> _emptyShapes = ISetConst({});
const IMap<Square, Annotation> _emptyAnnotations = IMapConst({});

/// Returns the closest square to the target square from a list of squares.
Square? _closestSquare(Square square, Iterable<Square> squares) {
  if (squares.isEmpty) return null;
  return squares.reduce((a, b) {
    final aDist = _distanceSq(square, a);
    final bDist = _distanceSq(square, b);
    return aDist < bDist ? a : b;
  });
}

int _distanceSq(Square pos1, Square pos2) {
  final dx = pos1.file - pos2.file;
  final dy = pos1.rank - pos2.rank;
  return dx * dx + dy * dy;
}
