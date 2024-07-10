import 'dart:async';
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
import '../board_data.dart';

/// Number of logical pixels that have to be dragged before a drag starts.
const double _kDragDistanceThreshold = 3.0;

const _kCancelShapesDoubleTapDelay = Duration(milliseconds: 200);

/// A chessboard widget.
///
/// This widget can be used to display a static board, a dynamic board that
/// shows a live game, or a full user interactable board.
class Board extends StatefulWidget {
  const Board({
    super.key,
    required this.size,
    required this.data,
    this.settings = const BoardSettings(),
    this.onMove,
    this.onPremove,
  });

  /// Visal size of the board.
  final double size;

  /// Settings that control the theme, behavior and purpose of the board.
  final BoardSettings settings;

  /// Data that represents the current state of the board.
  final BoardData data;

  /// Callback called after a move has been made.
  final void Function(Move, {bool? isDrop, bool? isPremove})? onMove;

  /// Callback called after a premove has been set/unset.
  ///
  /// If the callback is null, the board will not allow premoves.
  final void Function(Move?)? onPremove;

  double get squareSize => size / 8;

  Coord? localOffset2Coord(Offset offset) {
    final x = (offset.dx / squareSize).floor();
    final y = (offset.dy / squareSize).floor();
    final orientX = data.orientation == Side.black ? 7 - x : x;
    final orientY = data.orientation == Side.black ? y : 7 - y;
    if (orientX >= 0 && orientX <= 7 && orientY >= 0 && orientY <= 7) {
      return Coord(x: orientX, y: orientY);
    } else {
      return null;
    }
  }

  SquareId? localOffset2SquareId(Offset offset) {
    final coord = localOffset2Coord(offset);
    return coord?.squareId;
  }

  @override
  // ignore: library_private_types_in_public_api
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  Pieces pieces = {};
  Map<String, (PositionedPiece, PositionedPiece)> translatingPieces = {};
  Map<String, Piece> fadingPieces = {};
  SquareId? selected;
  Move? _promotionMove;
  Move? _lastDrop;
  Set<SquareId>? _premoveDests;

  bool _shouldDeselectOnTapUp = false;

  /// Avatar for the piece that is currently being dragged.
  _DragAvatar? _dragAvatar;

  /// Once a piece is dragged, holds the square id of the piece.
  SquareId? _draggedPieceSquareId;

  /// Current pointer down event.
  ///
  /// This field is reset to null when the pointer is released (up or cancel).
  ///
  /// This is used to track board gestures, the pointer that started the drag,
  /// and to prevent other pointers from starting a drag while a piece is being
  /// dragged.
  ///
  /// Other simultaneous pointer events are ignored.
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
    final ISet<SquareId> moveDests = widget.settings.showValidMoves &&
            selected != null &&
            widget.data.validMoves != null
        ? widget.data.validMoves![selected!] ?? _emptyValidMoves
        : _emptyValidMoves;
    final Set<SquareId> premoveDests =
        widget.settings.showValidMoves ? _premoveDests ?? {} : {};
    final shapes = widget.data.shapes ?? _emptyShapes;
    final annotations = widget.data.annotations ?? _emptyAnnotations;
    final checkSquare = widget.data.isCheck == true ? _getKingSquare() : null;
    final premove = widget.data.premove;

    final background = widget.settings.enableCoordinates
        ? widget.data.orientation == Side.white
            ? colorScheme.whiteCoordBackground
            : colorScheme.blackCoordBackground
        : colorScheme.background;

    final List<Widget> highlightedBackground = [
      background,
      if (widget.settings.showLastMove && widget.data.lastMove != null)
        for (final squareId in widget.data.lastMove!.squares)
          if (premove == null || !premove.hasSquare(squareId))
            PositionedSquare(
              key: ValueKey('$squareId-lastMove'),
              size: widget.squareSize,
              orientation: widget.data.orientation,
              squareId: squareId,
              child: Highlight(
                size: widget.squareSize,
                details: colorScheme.lastMove,
              ),
            ),
      if (premove != null &&
          widget.data.interactableSide != InteractableSide.none)
        for (final squareId in premove.squares)
          PositionedSquare(
            key: ValueKey('$squareId-premove'),
            size: widget.squareSize,
            orientation: widget.data.orientation,
            squareId: squareId,
            child: Highlight(
              size: widget.squareSize,
              details: HighlightDetails(solidColor: colorScheme.validPremoves),
            ),
          ),
      if (selected != null)
        PositionedSquare(
          key: ValueKey('${selected!}-selected'),
          size: widget.squareSize,
          orientation: widget.data.orientation,
          squareId: selected!,
          child: Highlight(
            size: widget.squareSize,
            details: colorScheme.selected,
          ),
        ),
      for (final dest in moveDests)
        PositionedSquare(
          key: ValueKey('$dest-dest'),
          size: widget.squareSize,
          orientation: widget.data.orientation,
          squareId: dest,
          child: MoveDest(
            size: widget.squareSize,
            color: colorScheme.validMoves,
            occupied: pieces.containsKey(dest),
          ),
        ),
      for (final dest in premoveDests)
        PositionedSquare(
          key: ValueKey('$dest-premove-dest'),
          size: widget.squareSize,
          orientation: widget.data.orientation,
          squareId: dest,
          child: MoveDest(
            size: widget.squareSize,
            color: colorScheme.validPremoves,
            occupied: pieces.containsKey(dest),
          ),
        ),
      if (checkSquare != null)
        PositionedSquare(
          key: ValueKey('$checkSquare-check'),
          size: widget.squareSize,
          orientation: widget.data.orientation,
          squareId: checkSquare,
          child: CheckHighlight(size: widget.squareSize),
        ),
    ];

    final List<Widget> objects = [
      for (final entry in fadingPieces.entries)
        PositionedSquare(
          key: ValueKey('${entry.key}-${entry.value.kind.name}-fading'),
          size: widget.squareSize,
          orientation: widget.data.orientation,
          squareId: entry.key,
          child: PieceFadeOut(
            duration: widget.settings.animationDuration,
            piece: entry.value,
            size: widget.squareSize,
            pieceAssets: widget.settings.pieceAssets,
            blindfoldMode: widget.settings.blindfoldMode,
            upsideDown: _upsideDown(entry.value),
            onComplete: () {
              fadingPieces.remove(entry.key);
            },
          ),
        ),
      for (final entry in pieces.entries)
        if (!translatingPieces.containsKey(entry.key) &&
            entry.key != _draggedPieceSquareId)
          PositionedSquare(
            key: ValueKey('${entry.key}-${entry.value.kind.name}'),
            size: widget.squareSize,
            orientation: widget.data.orientation,
            squareId: entry.key,
            child: PieceWidget(
              piece: entry.value,
              size: widget.squareSize,
              pieceAssets: widget.settings.pieceAssets,
              blindfoldMode: widget.settings.blindfoldMode,
              upsideDown: _upsideDown(entry.value),
            ),
          ),
      for (final entry in translatingPieces.entries)
        PositionedSquare(
          key: ValueKey('${entry.key}-${entry.value.$1.piece.kind.name}'),
          size: widget.squareSize,
          orientation: widget.data.orientation,
          squareId: entry.key,
          child: PieceTranslation(
            fromCoord: entry.value.$1.coord,
            toCoord: entry.value.$2.coord,
            orientation: widget.data.orientation,
            duration: widget.settings.animationDuration,
            onComplete: () {
              translatingPieces.remove(entry.key);
            },
            child: PieceWidget(
              piece: entry.value.$1.piece,
              size: widget.squareSize,
              pieceAssets: widget.settings.pieceAssets,
              blindfoldMode: widget.settings.blindfoldMode,
              upsideDown: _upsideDown(entry.value.$1.piece),
            ),
          ),
        ),
      for (final entry in annotations.entries)
        BoardAnnotation(
          key: ValueKey(
            '${entry.key}-${entry.value.symbol}-${entry.value.color}',
          ),
          squareSize: widget.squareSize,
          orientation: widget.data.orientation,
          squareId: entry.key,
          annotation: entry.value,
        ),
      for (final shape in shapes)
        ShapeWidget(
          shape: shape,
          boardSize: widget.size,
          orientation: widget.data.orientation,
        ),
      if (_shapeAvatar != null)
        ShapeWidget(
          shape: _shapeAvatar!,
          boardSize: widget.size,
          orientation: widget.data.orientation,
        ),
    ];

    final interactable =
        widget.data.interactableSide != InteractableSide.none ||
            widget.settings.drawShape.enable;

    return Listener(
      onPointerDown: interactable ? _onPointerDown : null,
      onPointerMove: interactable ? _onPointerMove : null,
      onPointerUp: interactable ? _onPointerUp : null,
      onPointerCancel: interactable ? _onPointerCancel : null,
      child: SizedBox.square(
        dimension: widget.size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (widget.settings.boxShadow.isNotEmpty ||
                widget.settings.borderRadius != BorderRadius.zero)
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: widget.settings.borderRadius,
                  boxShadow: widget.settings.boxShadow,
                ),
                child: Stack(children: highlightedBackground),
              )
            else
              ...highlightedBackground,
            ...objects,
            if (_promotionMove != null && widget.data.sideToMove != null)
              PromotionSelector(
                pieceAssets: widget.settings.pieceAssets,
                move: _promotionMove!,
                squareSize: widget.squareSize,
                color: widget.data.sideToMove!,
                orientation: widget.data.orientation,
                piecesUpsideDown: _promotionPiecesUpsideDown(),
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
    pieces = readFen(widget.data.fen);
  }

  @override
  void dispose() {
    super.dispose();
    _dragAvatar?.cancel();
  }

  @override
  void didUpdateWidget(Board oldBoard) {
    super.didUpdateWidget(oldBoard);
    if (oldBoard.settings.drawShape.enable &&
        !widget.settings.drawShape.enable) {
      _drawModeLockOrigin = null;
      _drawOrigin = null;
      _shapeAvatar = null;
    }
    if (widget.data.interactableSide == InteractableSide.none) {
      _currentPointerDownEvent = null;
      _dragAvatar?.cancel();
      _dragAvatar = null;
      _draggedPieceSquareId = null;
      selected = null;
      _premoveDests = null;
    }
    if (oldBoard.data.sideToMove != widget.data.sideToMove) {
      _premoveDests = null;
      _promotionMove = null;
      if (widget.onPremove != null &&
          widget.data.premove != null &&
          widget.data.sideToMove?.name == widget.data.interactableSide.name) {
        Timer.run(() {
          if (mounted) _tryPlayPremove();
        });
      }
    }
    if (oldBoard.data.fen == widget.data.fen) {
      _lastDrop = null;
      // as long as the fen is the same as before let's keep animations
      return;
    }
    translatingPieces = {};
    fadingPieces = {};
    final newPieces = readFen(widget.data.fen);
    final List<PositionedPiece> newOnSquare = [];
    final List<PositionedPiece> missingOnSquare = [];
    final Set<String> animatedOrigins = {};
    for (final s in allSquares) {
      if (s == _lastDrop?.from || s == _lastDrop?.to) {
        continue;
      }
      final oldP = pieces[s];
      final newP = newPieces[s];
      final squareCoord = Coord.fromSquareId(s);
      if (newP != null) {
        if (oldP != null) {
          if (newP != oldP) {
            missingOnSquare.add(
              PositionedPiece(piece: oldP, squareId: s, coord: squareCoord),
            );
            newOnSquare.add(
              PositionedPiece(piece: newP, squareId: s, coord: squareCoord),
            );
          }
        } else {
          newOnSquare.add(
            PositionedPiece(piece: newP, squareId: s, coord: squareCoord),
          );
        }
      } else if (oldP != null) {
        missingOnSquare
            .add(PositionedPiece(piece: oldP, squareId: s, coord: squareCoord));
      }
    }
    for (final newPiece in newOnSquare) {
      final fromP = newPiece.closest(
        missingOnSquare.where((m) => m.piece == newPiece.piece).toList(),
      );
      if (fromP != null) {
        translatingPieces[newPiece.squareId] = (fromP, newPiece);
        animatedOrigins.add(fromP.squareId);
      }
    }
    for (final m in missingOnSquare) {
      if (!animatedOrigins.contains(m.squareId)) {
        fadingPieces[m.squareId] = m.piece;
      }
    }
    _lastDrop = null;
    pieces = newPieces;
  }

  SquareId? _getKingSquare() {
    for (final square in pieces.keys) {
      if (pieces[square]!.color == widget.data.sideToMove &&
          pieces[square]!.role == Role.king) {
        return square;
      }
    }
    return null;
  }

  // returns the position of the square target during drag as a global offset
  Offset? _squareTargetGlobalOffset(Offset localPosition, RenderBox box) {
    final coord = widget.localOffset2Coord(localPosition);
    if (coord == null) return null;
    final localOffset =
        coord.offset(widget.data.orientation, widget.squareSize);
    final tmpOffset = box.localToGlobal(localOffset);
    return Offset(
      tmpOffset.dx - widget.squareSize / 2,
      tmpOffset.dy - widget.squareSize / 2,
    );
  }

  void _onPointerDown(PointerDownEvent details) {
    if (details.buttons != kPrimaryButton) return;

    final squareId = widget.localOffset2SquareId(details.localPosition);
    if (squareId == null) return;

    if (widget.settings.drawShape.enable) {
      if (_drawModeLockOrigin == null) {
        final piece = pieces[squareId];
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
      }

      // draw mode takes priority over play mode when the draw mode lock is set
      else if (_drawModeLockOrigin!.pointer != details.pointer) {
        _drawOrigin = details;
        setState(() {
          _shapeAvatar = Circle(
            color: widget.settings.drawShape.newShapeColor,
            orig: squareId,
          );
        });
        return;
      }
    }

    if (widget.data.interactableSide == InteractableSide.none) return;

    // From here on, we only allow 1 pointer to interact with the board: others are ignored
    if (_currentPointerDownEvent != null) return;

    _currentPointerDownEvent = details;

    if (selected != null && squareId != selected) {
      final canMove = _tryMoveOrPremoveTo(squareId);
      if (!canMove && _isMovable(squareId)) {
        setState(() {
          selected = squareId;
        });
      } else {
        setState(() {
          selected = null;
          _premoveDests = null;
        });
      }
    } else if (selected == squareId) {
      _shouldDeselectOnTapUp = true;
    } else if (_isMovable(squareId)) {
      setState(() {
        selected = squareId;
      });
    } else if (_isPremovable(squareId)) {
      setState(() {
        selected = squareId;
        _premoveDests = premovesOf(
          squareId,
          pieces,
          canCastle: widget.settings.enablePremoveCastling,
        );
      });
    } else if (widget.data.premove != null) {
      widget.onPremove?.call(null);
      setState(() {
        selected = null;
        _premoveDests = null;
      });
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
        final squareId = widget.localOffset2SquareId(details.localPosition);
        if (squareId == null) return;
        setState(() {
          _shapeAvatar = _shapeAvatar!.newDest(squareId);
        });
      }
    }

    if (_currentPointerDownEvent == null ||
        _currentPointerDownEvent!.pointer != details.pointer) return;

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
      widget.settings.drawShape.onCompleteShape?.call(_shapeAvatar!);
      setState(() {
        _shapeAvatar = null;
      });
      _drawOrigin = null;
      return;
    }

    if (_currentPointerDownEvent == null ||
        _currentPointerDownEvent!.pointer != details.pointer) return;

    if (_dragAvatar != null && _renderBox != null) {
      final localPos = _renderBox!.globalToLocal(_dragAvatar!._position);
      final squareId = widget.localOffset2SquareId(localPos);
      if (squareId != null && squareId != selected) {
        _tryMoveOrPremoveTo(squareId, drop: true);
      }
      _onDragEnd(details);
      setState(() {
        selected = null;
        _premoveDests = null;
      });
    } else if (selected != null) {
      final squareId = widget.localOffset2SquareId(details.localPosition);
      if (squareId == selected && _shouldDeselectOnTapUp) {
        _shouldDeselectOnTapUp = false;
        setState(() {
          selected = null;
          _premoveDests = null;
        });
      }
    }

    _shouldDeselectOnTapUp = false;
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

    _onDragEnd(details);
    _currentPointerDownEvent = null;
    _shouldDeselectOnTapUp = false;
  }

  void _onDragStart(PointerEvent origin) {
    final squareId = widget.localOffset2SquareId(origin.localPosition);
    final piece = squareId != null ? pieces[squareId] : null;
    final feedbackSize = widget.squareSize * widget.settings.dragFeedbackSize;
    if (squareId != null &&
        piece != null &&
        (_isMovable(squareId) || _isPremovable(squareId))) {
      setState(() {
        _draggedPieceSquareId = squareId;
      });
      _renderBox = context.findRenderObject()! as RenderBox;
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
            upsideDown: _upsideDown(piece),
          ),
        ),
      );
    }
  }

  void _onDragEnd(PointerEvent details) {
    _dragAvatar?.end();
    _dragAvatar = null;
    _renderBox = null;
    if (_draggedPieceSquareId != null) {
      setState(() {
        _draggedPieceSquareId = null;
      });
    }
  }

  void _onPromotionSelect(Move move, Piece promoted) {
    setState(() {
      pieces[move.to] = promoted;
      _promotionMove = null;
    });
    widget.onMove?.call(move.withPromotion(promoted.role), isDrop: true);
  }

  void _onPromotionCancel(Move move) {
    setState(() {
      pieces = readFen(widget.data.fen);
      _promotionMove = null;
    });
  }

  void _openPromotionSelector(Move move) {
    setState(() {
      final pawn = pieces.remove(move.from);
      pieces[move.to] = pawn!;
      _promotionMove = move;
    });
  }

  bool _upsideDown(Piece piece) {
    return widget.data.opponentsPiecesUpsideDown &&
        piece.color != widget.data.orientation;
  }

  bool _promotionPiecesUpsideDown() {
    return widget.data.opponentsPiecesUpsideDown &&
        widget.data.sideToMove! != widget.data.orientation;
  }

  bool _isMovable(SquareId squareId) {
    final piece = pieces[squareId];
    return piece != null &&
        (widget.data.interactableSide == InteractableSide.both ||
            widget.data.interactableSide.name == piece.color.name) &&
        widget.data.sideToMove == piece.color;
  }

  bool _canMove(SquareId orig, SquareId dest) {
    final validDests = widget.data.validMoves?[orig];
    return orig != dest && validDests != null && validDests.contains(dest);
  }

  bool _isPremovable(SquareId squareId) {
    final piece = pieces[squareId];
    return piece != null &&
        (widget.onPremove != null &&
            widget.data.interactableSide.name == piece.color.name &&
            widget.data.sideToMove != piece.color);
  }

  bool _canPremove(SquareId orig, SquareId dest) {
    return orig != dest &&
        _isPremovable(orig) &&
        premovesOf(
          orig,
          pieces,
          canCastle: widget.settings.enablePremoveCastling,
        ).contains(dest);
  }

  bool _isPromoMove(Piece piece, SquareId targetSquareId) {
    final rank = targetSquareId[1];
    return piece.role == Role.pawn && (rank == '1' || rank == '8');
  }

  bool _tryMoveOrPremoveTo(SquareId squareId, {bool drop = false}) {
    final selectedPiece = selected != null ? pieces[selected] : null;
    if (selectedPiece != null && _canMove(selected!, squareId)) {
      final move = Move(from: selected!, to: squareId);
      if (drop) {
        _lastDrop = move;
      }
      if (_isPromoMove(selectedPiece, squareId)) {
        if (widget.settings.autoQueenPromotion) {
          widget.onMove?.call(move.withPromotion(Role.queen), isDrop: drop);
        } else {
          _openPromotionSelector(move);
        }
      } else {
        widget.onMove?.call(move, isDrop: drop);
      }
      return true;
    } else if (selectedPiece != null && _canPremove(selected!, squareId)) {
      widget.onPremove?.call(Move(from: selected!, to: squareId));
      return true;
    }
    return false;
  }

  void _tryPlayPremove() {
    final premove = widget.data.premove;
    if (premove == null) {
      return;
    }
    final fromPiece = pieces[premove.from];
    if (fromPiece != null && _canMove(premove.from, premove.to)) {
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

const ISet<String> _emptyValidMoves = ISetConst({});
const ISet<Shape> _emptyShapes = ISetConst({});
const IMap<SquareId, Annotation> _emptyAnnotations = IMapConst({});
