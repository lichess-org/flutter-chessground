import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:android_gesture_exclusion/android_gesture_exclusion.dart';

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

  /// Visal size of the board
  final double size;

  /// Settings that control the theme, behavior and purpose of the board.
  final BoardSettings settings;

  /// Data that represents the current state of the board
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
  bool _shouldDeselectOnTapUp = false;
  Move? _promotionMove;
  Move? _lastDrop;
  Set<SquareId>? _premoveDests;
  _DragAvatar? _dragAvatar;
  SquareId? _dragOrigin;
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
    final checkSquare = widget.data.isCheck ? _getKingSquare() : null;
    final premove = widget.data.premove;
    final Widget board = Stack(
      children: [
        if (widget.settings.enableCoordinates)
          widget.data.orientation == Side.white
              ? colorScheme.whiteCoordBackground
              : colorScheme.blackCoordBackground
        else
          colorScheme.background,
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
        if (premove != null)
          for (final squareId in premove.squares)
            PositionedSquare(
              key: ValueKey('$squareId-premove'),
              size: widget.squareSize,
              orientation: widget.data.orientation,
              squareId: squareId,
              child: Highlight(
                size: widget.squareSize,
                details:
                    HighlightDetails(solidColor: colorScheme.validPremoves),
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
              onComplete: () {
                fadingPieces.remove(entry.key);
              },
            ),
          ),
        for (final entry in pieces.entries)
          if (!translatingPieces.containsKey(entry.key) &&
              entry.key != _dragOrigin)
            PositionedSquare(
              key: ValueKey('${entry.key}-${entry.value.kind.name}'),
              size: widget.squareSize,
              orientation: widget.data.orientation,
              squareId: entry.key,
              child: PieceWidget(
                piece: entry.value,
                size: widget.squareSize,
                pieceAssets: widget.settings.pieceAssets,
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
            size: widget.size,
            orientation: widget.data.orientation,
          ),
        if (_shapeAvatar != null)
          ShapeWidget(
            shape: _shapeAvatar!,
            size: widget.size,
            orientation: widget.data.orientation,
          ),
      ],
    );

    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        children: [
          // Consider using Listener instead as we don't control the drag start threshold with
          // GestureDetector (TODO)
          if (widget.data.interactableSide != InteractableSide.none &&
              !widget.settings.drawShape
                  .enable) // Disable moving pieces when drawing is enabled
            GestureDetector(
              // registering onTapDown is needed to prevent the panStart event to win the
              // competition too early
              // there is no need to implement the callback since we handle the selection login
              // in onPanDown; plus this way we avoid the timeout before onTapDown is called
              onTapDown: (TapDownDetails? details) {},
              onTapUp: _onTapUpPiece,
              onPanDown: _onPanDownPiece,
              onPanStart: _onPanStartPiece,
              onPanUpdate: _onPanUpdatePiece,
              onPanEnd: _onPanEndPiece,
              onPanCancel: _onPanCancelPiece,
              dragStartBehavior: DragStartBehavior.down,
              child: board,
            )
          else if (widget.settings.drawShape.enable)
            GestureDetector(
              onTapDown: (TapDownDetails? details) {},
              onTapUp: _onTapUpShape,
              onPanDown: _onPanDownShape,
              onPanStart: _onPanStartShape,
              onPanUpdate: _onPanUpdateShape,
              onPanEnd: _onPanEndShape,
              onPanCancel: _onPanCancelShape,
              dragStartBehavior: DragStartBehavior.down,
              child: board,
            )
          else
            board,
          if (_promotionMove != null)
            PromotionSelector(
              pieceAssets: widget.settings.pieceAssets,
              move: _promotionMove!,
              squareSize: widget.squareSize,
              color: widget.data.sideToMove,
              orientation: widget.data.orientation,
              onSelect: _onPromotionSelect,
              onCancel: _onPromotionCancel,
            ),
        ],
      ),
    );
  }

  void _setAndroidGesturesExclusion(BuildContext context) {
    final box = context.findRenderObject();
    if (box != null && box is RenderBox) {
      final position = box.localToGlobal(Offset.zero);
      final ratio = MediaQuery.devicePixelRatioOf(context);
      final verticalThreshold = 10 * ratio;
      final left = position.dx * ratio;
      final top = position.dy * ratio;
      final right = left + box.size.width * ratio;
      final bottom = top + box.size.height * ratio;
      final rect = Rect.fromLTRB(
        left,
        top - verticalThreshold,
        right,
        bottom + verticalThreshold,
      );
      AndroidGestureExclusion.instance.setRects([rect]);
    }
  }

  void _clearAndroidGesturesExclusion() {
    AndroidGestureExclusion.instance.clear();
  }

  @override
  void initState() {
    super.initState();
    pieces = readFen(widget.data.fen);

    if (defaultTargetPlatform == TargetPlatform.android &&
        widget.data.interactableSide != InteractableSide.none) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setAndroidGesturesExclusion(context);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _dragAvatar?.cancel();
    if (defaultTargetPlatform == TargetPlatform.android) {
      _clearAndroidGesturesExclusion();
    }
  }

  @override
  void didUpdateWidget(Board oldBoard) {
    super.didUpdateWidget(oldBoard);
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (oldBoard.data.interactableSide == InteractableSide.none &&
          widget.data.interactableSide != InteractableSide.none) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _setAndroidGesturesExclusion(context);
        });
      } else if (oldBoard.data.interactableSide != InteractableSide.none &&
          widget.data.interactableSide == InteractableSide.none) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _clearAndroidGesturesExclusion();
        });
      }
    }
    if (widget.data.interactableSide == InteractableSide.none) {
      _dragAvatar?.cancel();
      _dragAvatar = null;
      _dragOrigin = null;
      selected = null;
      _premoveDests = null;
    }
    if (oldBoard.data.sideToMove != widget.data.sideToMove) {
      _premoveDests = null;
      _promotionMove = null;
      if (widget.data.sideToMove.name == widget.data.interactableSide.name) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _tryPlayPremove());
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
  Offset? _squareTargetGlobalOffset(Offset localPosition) {
    final coord = widget.localOffset2Coord(localPosition);
    if (coord == null) return null;
    final localOffset =
        coord.offset(widget.data.orientation, widget.squareSize);
    final RenderBox box = context.findRenderObject()! as RenderBox;
    final tmpOffset = box.localToGlobal(localOffset);
    return Offset(
      tmpOffset.dx - widget.squareSize / 2,
      tmpOffset.dy - widget.squareSize / 2,
    );
  }

  void _onPanDownPiece(DragDownDetails? details) {
    if (details == null) return;

    final squareId = widget.localOffset2SquareId(details.localPosition);
    if (squareId == null) return;

    // if a movable piece is already selected, we want to allow castling by
    // selecting the king and then the rook, so `canMove` check must be false
    // to ensure we can select another piece
    if (_isMovable(squareId) &&
        (selected == null || !_canMove(selected!, squareId))) {
      _shouldDeselectOnTapUp = selected == squareId;
      setState(() {
        selected = squareId;
      });
    }
    // same as above comment, but for premoves
    else if (_isPremovable(squareId) &&
        (selected == null || !_canPremove(selected!, squareId))) {
      _shouldDeselectOnTapUp = selected == squareId;
      widget.onPremove?.call(null);
      setState(() {
        selected = squareId;
        _premoveDests = premovesOf(
          squareId,
          pieces,
          canCastle: widget.settings.enablePremoveCastling,
        );
      });
    } else {
      widget.onPremove?.call(null);
      setState(() {
        _premoveDests = null;
      });
    }
  }

  void _onPanStartPiece(DragStartDetails? details) {
    if (details == null) return;

    final squareId = widget.localOffset2SquareId(details.localPosition);
    final piece = squareId != null ? pieces[squareId] : null;
    final feedbackSize = widget.squareSize * widget.settings.dragFeedbackSize;
    if (squareId != null &&
        piece != null &&
        (_isMovable(squareId) || _isPremovable(squareId))) {
      setState(() {
        _dragOrigin = squareId;
      });
      final squareTargetOffset =
          _squareTargetGlobalOffset(details.localPosition);
      _dragAvatar = _DragAvatar(
        overlayState: Overlay.of(context, debugRequiredFor: widget),
        initialPosition: details.globalPosition,
        initialTargetPosition: squareTargetOffset,
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
          ),
        ),
      );
    }
  }

  void _onPanUpdatePiece(DragUpdateDetails? details) {
    if (details == null || _dragAvatar == null) return;
    final squareTargetOffset = _squareTargetGlobalOffset(details.localPosition);
    _dragAvatar?.update(details);
    _dragAvatar?.updateSquareTarget(squareTargetOffset);
  }

  void _onPanEndPiece(DragEndDetails? details) {
    if (_dragAvatar != null) {
      final RenderBox box = context.findRenderObject()! as RenderBox;
      final localPos = box.globalToLocal(_dragAvatar!._position);
      final squareId = widget.localOffset2SquareId(localPos);
      if (squareId != null && squareId != selected) {
        _tryMoveTo(squareId, drop: true);
      }
    }
    _dragAvatar?.end();
    _dragAvatar = null;
    setState(() {
      _dragOrigin = null;
    });
  }

  void _onPanCancelPiece() {
    _dragAvatar?.cancel();
    _dragAvatar = null;
    setState(() {
      _dragOrigin = null;
    });
  }

  void _onTapUpPiece(TapUpDetails? details) {
    if (details == null) return;
    final squareId = widget.localOffset2SquareId(details.localPosition);
    if (squareId != null && squareId != selected) {
      _tryMoveTo(squareId);
    } else if (squareId != null &&
        selected == squareId &&
        _shouldDeselectOnTapUp) {
      _shouldDeselectOnTapUp = false;
      setState(() {
        selected = null;
        _premoveDests = null;
      });
    }
  }

  void _onPanDownShape(DragDownDetails? details) {
    if (details == null || widget.settings.drawShape.enable == false) return;
    final squareId = widget.localOffset2SquareId(details.localPosition);
    if (squareId == null) return;
    setState(() {
      // Initialize shapeAvatar on tap down (Analogous to website)
      _shapeAvatar = Circle(
        color: widget.settings.drawShape.newShapeColor,
        orig: squareId,
      );
    });
  }

  void _onPanStartShape(DragStartDetails? details) {
    if (details == null ||
        _shapeAvatar == null ||
        widget.settings.drawShape.enable == false) return;
    final squareId = widget.localOffset2SquareId(details.localPosition);
    if (squareId == null) return;
    setState(() {
      // Update shapeAvatar on starting pan
      _shapeAvatar = _shapeAvatar!.newDest(squareId);
    });
  }

  void _onPanUpdateShape(DragUpdateDetails? details) {
    if (details == null ||
        _shapeAvatar == null ||
        widget.settings.drawShape.enable == false) return;
    final squareId = widget.localOffset2SquareId(details.localPosition);
    if (squareId == null ||
        (_shapeAvatar! is Arrow && squareId == (_shapeAvatar! as Arrow).dest)) {
      return;
    }
    setState(() {
      // Update shapeAvatar on panning once a new square is reached
      _shapeAvatar = _shapeAvatar!.newDest(squareId);
    });
  }

  void _onPanEndShape(DragEndDetails? details) {
    if (_shapeAvatar == null || widget.settings.drawShape.enable == false) {
      return;
    }
    widget.settings.drawShape.onCompleteShape?.call(_shapeAvatar!);
    setState(() {
      _shapeAvatar = null;
    });
  }

  void _onPanCancelShape() {
    setState(() {
      _shapeAvatar = null;
    });
  }

  void _onTapUpShape(TapUpDetails? details) {
    if (details == null || widget.settings.drawShape.enable == false) return;
    final squareId = widget.localOffset2SquareId(details.localPosition);
    if (squareId == null) return;
    widget.settings.drawShape.onCompleteShape?.call(
      Circle(
        color: widget.settings.drawShape.newShapeColor,
        orig: squareId,
      ),
    );
    setState(() {
      _shapeAvatar = null;
    });
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

  void _tryMoveTo(SquareId squareId, {bool drop = false}) {
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
    } else if (selectedPiece != null && _canPremove(selected!, squareId)) {
      widget.onPremove?.call(Move(from: selected!, to: squareId));
    }
    setState(() {
      selected = null;
      _premoveDests = null;
    });
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

  void update(DragUpdateDetails details) {
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
