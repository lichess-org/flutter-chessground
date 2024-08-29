import 'dart:async';
import 'package:chessground/src/widgets/evaluation_bar.dart';
import 'package:chessground/src/widgets/geometry.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'piece.dart';
import 'highlight.dart';
import 'positioned_square.dart';
import 'animation.dart';
import 'promotion.dart';
import 'shape.dart';
import 'board_annotation.dart';
import '../models.dart';
import '../fen.dart';
import '../premove.dart';
import '../board_settings.dart';
import '../board_state.dart';

/// Number of logical pixels that have to be dragged before a drag starts.
const double _kDragDistanceThreshold = 3.0;

const _kCancelShapesDoubleTapDelay = Duration(milliseconds: 200);

/// Aspect ratio of the evaluation bar.
const evaluationBarAspectRatio = 1 / 20;

/// A chessboard widget.
///
/// This widget can be used to display a static board, a dynamic board that
/// shows a live game, or a full user interactable board.
class Chessboard extends StatefulWidget with ChessboardGeometry {
  /// Creates a new chessboard widget.
  const Chessboard({
    super.key,
    required this.size,
    required this.state,
    this.settings = const ChessboardSettings(),
    this.onMove,
    this.onPremove,
  });

  @override
  final double size;

  @override
  Side get orientation => state.orientation;

  /// Settings that control the theme, behavior and purpose of the board.
  final ChessboardSettings settings;

  /// Current state of the board.
  final ChessboardState state;

  /// Callback called after a move has been made.
  final void Function(NormalMove, {bool? isDrop, bool? isPremove})? onMove;

  /// Callback called after a premove has been set/unset.
  ///
  /// If the callback is null, the board will not allow premoves.
  final void Function(NormalMove?)? onPremove;

  @override
  // ignore: library_private_types_in_public_api
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Chessboard> {
  /// Pieces on the board.
  Pieces pieces = {};

  /// Pieces that are currently being translated from one square to another.
  Map<Square, ({(Piece, Square) from, (Piece, Square) to})> translatingPieces =
      {};

  /// Pieces that are currently fading out.
  Map<Square, Piece> fadingPieces = {};

  /// Currently selected square.
  Square? selected;

  /// Move currently being promoted
  NormalMove? _promotionMove;

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
    final colorScheme = widget.settings.colorScheme;
    final ISet<Square> moveDests = widget.settings.showValidMoves &&
            selected != null &&
            widget.state.validMoves != null
        ? widget.state.validMoves![selected!] ?? _emptyValidMoves
        : _emptyValidMoves;
    final Set<Square> premoveDests =
        widget.settings.showValidMoves ? _premoveDests ?? {} : {};
    final shapes = widget.state.shapes ?? _emptyShapes;
    final annotations = widget.state.annotations ?? _emptyAnnotations;
    final checkSquare = widget.state.isCheck == true ? _getKingSquare() : null;
    final premove = widget.state.premove;

    final background = widget.settings.enableCoordinates
        ? widget.state.orientation == Side.white
            ? colorScheme.whiteCoordBackground
            : colorScheme.blackCoordBackground
        : colorScheme.background;

    final List<Widget> highlightedBackground = [
      background,
      if (widget.settings.showLastMove && widget.state.lastMove != null)
        for (final square in widget.state.lastMove!.squares)
          if (premove == null || !premove.hasSquare(square))
            PositionedSquare(
              key: ValueKey('${square.name}-lastMove'),
              size: widget.size,
              orientation: widget.state.orientation,
              square: square,
              child: SquareHighlight(details: colorScheme.lastMove),
            ),
      if (premove != null &&
          widget.state.interactableSide != InteractableSide.none)
        for (final square in premove.squares)
          PositionedSquare(
            key: ValueKey('${square.name}-premove'),
            size: widget.size,
            orientation: widget.state.orientation,
            square: square,
            child: SquareHighlight(
              details: HighlightDetails(solidColor: colorScheme.validPremoves),
            ),
          ),
      if (selected != null)
        PositionedSquare(
          key: ValueKey('${selected!.name}-selected'),
          size: widget.size,
          orientation: widget.state.orientation,
          square: selected!,
          child: SquareHighlight(details: colorScheme.selected),
        ),
      for (final dest in moveDests)
        PositionedSquare(
          key: ValueKey('${dest.name}-dest'),
          size: widget.size,
          orientation: widget.state.orientation,
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
          orientation: widget.state.orientation,
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
          orientation: widget.state.orientation,
          square: checkSquare,
          child: CheckHighlight(size: widget.squareSize),
        ),
    ];

    final List<Widget> objects = [
      for (final entry in fadingPieces.entries)
        PositionedSquare(
          key: ValueKey('${entry.key.name}-${entry.value}-fading'),
          size: widget.size,
          orientation: widget.state.orientation,
          square: entry.key,
          child: AnimatedPieceFadeOut(
            duration: widget.settings.animationDuration,
            piece: entry.value,
            size: widget.squareSize,
            pieceAssets: widget.settings.pieceAssets,
            blindfoldMode: widget.settings.blindfoldMode,
            upsideDown: _isUpsideDown(entry.value),
            onComplete: () {
              fadingPieces.remove(entry.key);
            },
          ),
        ),
      for (final entry in pieces.entries)
        if (!translatingPieces.containsKey(entry.key) &&
            entry.key != _draggedPieceSquare)
          PositionedSquare(
            key: ValueKey('${entry.key.name}-${entry.value}'),
            size: widget.size,
            orientation: widget.state.orientation,
            square: entry.key,
            child: PieceWidget(
              piece: entry.value,
              size: widget.squareSize,
              pieceAssets: widget.settings.pieceAssets,
              blindfoldMode: widget.settings.blindfoldMode,
              upsideDown: _isUpsideDown(entry.value),
            ),
          ),
      for (final entry in translatingPieces.entries)
        PositionedSquare(
          key: ValueKey('${entry.key.name}-${entry.value.from.$1}'),
          size: widget.size,
          orientation: widget.state.orientation,
          square: entry.key,
          child: AnimatedPieceTranslation(
            fromSquare: entry.value.from.$2,
            toSquare: entry.value.to.$2,
            orientation: widget.state.orientation,
            duration: widget.settings.animationDuration,
            onComplete: () {
              translatingPieces.remove(entry.key);
            },
            child: PieceWidget(
              piece: entry.value.from.$1,
              size: widget.squareSize,
              pieceAssets: widget.settings.pieceAssets,
              blindfoldMode: widget.settings.blindfoldMode,
              upsideDown: _isUpsideDown(entry.value.from.$1),
            ),
          ),
        ),
      for (final entry in annotations.entries)
        BoardAnnotation(
          key: ValueKey(
            '${entry.key.name}-${entry.value.symbol}-${entry.value.color}',
          ),
          size: widget.size,
          orientation: widget.state.orientation,
          square: entry.key,
          annotation: entry.value,
        ),
      for (final shape in shapes)
        ShapeWidget(
          shape: shape,
          size: widget.size,
          orientation: widget.state.orientation,
        ),
      if (_shapeAvatar != null)
        ShapeWidget(
          shape: _shapeAvatar!,
          size: widget.size,
          orientation: widget.state.orientation,
        ),
    ];

    final interactable =
        widget.state.interactableSide != InteractableSide.none ||
            widget.settings.drawShape.enable;

    return Listener(
      onPointerDown: interactable ? _onPointerDown : null,
      onPointerMove: interactable ? _onPointerMove : null,
      onPointerUp: interactable ? _onPointerUp : null,
      onPointerCancel: interactable ? _onPointerCancel : null,
      child: SizedBox(
        height: widget.size,
        width: widget.size +
            (widget.settings.evaluationBarWhiteFraction != null
                ? widget.size * evaluationBarAspectRatio
                : 0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              clipBehavior: (widget.settings.borderRadius != BorderRadius.zero)
                  ? Clip.hardEdge
                  : Clip.none,
              decoration: BoxDecoration(
                borderRadius: widget.settings.borderRadius,
                boxShadow: widget.settings.boxShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ...highlightedBackground,
                      ],
                    ),
                  ),
                  if (widget.settings.evaluationBarWhiteFraction != null)
                    EvaluationBar(
                      heigth: widget.size,
                      whiteBarHeight: widget.size *
                          widget.settings.evaluationBarWhiteFraction!,
                    ),
                ],
              ),
            ),
            ...objects,
            if (_promotionMove != null && widget.state.sideToMove != null)
              PromotionSelector(
                pieceAssets: widget.settings.pieceAssets,
                move: _promotionMove!,
                size: widget.size,
                color: widget.state.sideToMove!,
                orientation: widget.state.orientation,
                piecesUpsideDown: widget.state.opponentsPiecesUpsideDown &&
                    widget.state.sideToMove! != widget.state.orientation,
                onSelect: _onPromotionSelect,
                onCancel: _onPromotionCancel,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    pieces = readFen(widget.state.fen);
  }

  @override
  void dispose() {
    super.dispose();
    _dragAvatar?.cancel();
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
    if (widget.state.interactableSide == InteractableSide.none) {
      _currentPointerDownEvent = null;
      _dragAvatar?.cancel();
      _dragAvatar = null;
      _draggedPieceSquare = null;
      selected = null;
      _premoveDests = null;
    }
    if (oldBoard.state.sideToMove != widget.state.sideToMove) {
      _premoveDests = null;
      _promotionMove = null;
      if (widget.onPremove != null &&
          widget.state.premove != null &&
          widget.state.sideToMove?.name == widget.state.interactableSide.name) {
        Timer.run(() {
          if (mounted) _tryPlayPremove();
        });
      }
    }
    if (oldBoard.state.fen == widget.state.fen) {
      _lastDrop = null;
      // as long as the fen is the same as before let's keep animations
      return;
    }
    translatingPieces = {};
    fadingPieces = {};
    final newPieces = readFen(widget.state.fen);
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
    for (final newPiece in newOnSquare) {
      final fromP = _closestPiece(
        newPiece.$2,
        missingOnSquare.where((m) => m.$1 == newPiece.$1).toList(),
      );
      if (fromP != null) {
        translatingPieces[newPiece.$2] = (from: fromP, to: newPiece);
        animatedOrigins.add(fromP.$2);
      }
    }
    for (final m in missingOnSquare) {
      if (!animatedOrigins.contains(m.$2)) {
        fadingPieces[m.$2] = m.$1;
      }
    }
    _lastDrop = null;
    pieces = newPieces;
  }

  Square? _getKingSquare() {
    for (final square in pieces.keys) {
      if (pieces[square]!.color == widget.state.sideToMove &&
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
      tmpOffset.dx - widget.squareSize / 2,
      tmpOffset.dy - widget.squareSize / 2,
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

    if (widget.state.interactableSide == InteractableSide.none) return;

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
    else if (widget.state.premove != null) {
      widget.onPremove?.call(null);
      setState(() {
        selected = null;
        _premoveDests = null;
      });
    }

    // there is a premove set from the touched square:
    // - cancel the premove on the next tap up event
    if (widget.state.premove != null && widget.state.premove!.from == square) {
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
        _currentPointerDownEvent!.pointer != details.pointer) return;

    final square = widget.offsetSquare(details.localPosition);

    if (_dragAvatar != null) {
      // if the user drags a piece to a square, try to move the piece to the
      // target square
      if (square != null && square != selected) {
        final couldMove = _tryMoveOrPremoveTo(square, drop: true);
        // if the premove was not possible, cancel the current premove
        if (!couldMove && widget.state.premove != null) {
          widget.onPremove?.call(null);
        }
      }
      // if the user drags a piece to an empty square, cancel the premove
      else if (widget.state.premove != null) {
        widget.onPremove?.call(null);
      }
      _onDragEnd();
      setState(() {
        _draggedPieceSquare = null;
        selected = null;
        _premoveDests = null;
      });
    } else if (selected != null) {
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
        widget.state.premove != null &&
        widget.state.premove!.from == square) {
      _shouldCancelPremoveOnTapUp = false;
      widget.onPremove?.call(null);
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
        _currentPointerDownEvent!.pointer != details.pointer) return;

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
            ((widget.settings.dragFeedbackOffset.dy - 1) * feedbackSize) / 2,
          ),
          child: PieceWidget(
            piece: piece,
            size: feedbackSize,
            pieceAssets: widget.settings.pieceAssets,
            blindfoldMode: widget.settings.blindfoldMode,
            upsideDown: _isUpsideDown(piece),
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

  void _onPromotionSelect(NormalMove move, Piece promoted) {
    setState(() {
      pieces[move.to] = promoted;
      _promotionMove = null;
    });
    widget.onMove?.call(move.withPromotion(promoted.role), isDrop: true);
  }

  void _onPromotionCancel(Move move) {
    setState(() {
      pieces = readFen(widget.state.fen);
      _promotionMove = null;
    });
  }

  void _openPromotionSelector(NormalMove move) {
    setState(() {
      final pawn = pieces.remove(move.from);
      pieces[move.to] = pawn!;
      _promotionMove = move;
    });
  }

  /// Whether the piece should be displayed upside down, according to the
  /// widget settings.
  bool _isUpsideDown(Piece piece) {
    return widget.state.opponentsPiecesUpsideDown &&
        piece.color != widget.state.orientation;
  }

  /// Whether the piece is movable by the current side to move.
  bool _isMovable(Piece? piece) {
    return piece != null &&
        (widget.state.interactableSide == InteractableSide.both ||
            widget.state.interactableSide.name == piece.color.name) &&
        widget.state.sideToMove == piece.color;
  }

  /// Whether the piece is premovable by the current side to move.
  bool _isPremovable(Piece? piece) {
    return piece != null &&
        (widget.onPremove != null &&
            widget.state.interactableSide.name == piece.color.name &&
            widget.state.sideToMove != piece.color);
  }

  /// Whether the piece is allowed to be moved to the target square.
  bool _canMoveTo(Square orig, Square dest) {
    final validDests = widget.state.validMoves?[orig];
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
          widget.onMove?.call(move.withPromotion(Role.queen), isDrop: drop);
        } else {
          _openPromotionSelector(move);
        }
      } else {
        widget.onMove?.call(move, isDrop: drop);
      }
      return true;
    } else if (_isPremovable(selectedPiece) &&
        _canPremoveTo(selected!, square)) {
      widget.onPremove?.call(NormalMove(from: selected!, to: square));
      return true;
    }
    return false;
  }

  /// Tries to play the premove if it is set and still valid.
  void _tryPlayPremove() {
    final premove = widget.state.premove;
    if (premove == null) {
      return;
    }
    final fromPiece = pieces[premove.from];
    if (fromPiece != null && _canMoveTo(premove.from, premove.to)) {
      if (_isPromoMove(fromPiece, premove.to)) {
        if (widget.settings.autoQueenPromotion ||
            widget.settings.autoQueenPromotionOnPremove) {
          widget.onMove?.call(
            premove.withPromotion(Role.queen),
            isPremove: true,
          );
        } else {
          _openPromotionSelector(premove);
        }
      } else {
        widget.onMove?.call(premove, isPremove: true);
      }
    }
    widget.onPremove?.call(null);
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

(Piece, Square)? _closestPiece(Square square, List<(Piece, Square)> pieces) {
  pieces.sort(
    (p1, p2) => _distanceSq(square, p1.$2) - _distanceSq(square, p2.$2),
  );
  return pieces.isNotEmpty ? pieces[0] : null;
}

int _distanceSq(Square pos1, Square pos2) {
  final dx = pos1.file - pos2.file;
  final dy = pos1.rank - pos2.rank;
  return dx * dx + dy * dy;
}
