import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:tuple/tuple.dart';
import 'piece.dart';
import 'highlight.dart';
import 'positioned_square.dart';
import 'animation.dart';
import '../models.dart' as cg;
import '../fen.dart';
import '../utils.dart';
import '../settings.dart';
import '../theme.dart';

/// A chessboard widget
///
/// This widget can be used to display a static board, a dynamic board that
/// shows a live game, or a full user interactable board.
/// All the different behaviors can be controlled with the [settings] parameter.
class Board extends StatefulWidget {
  const Board({
    Key? key,
    this.settings = const Settings(),
    this.theme = BoardTheme.brown,
    required this.size,
    required this.orientation,
    required this.fen,
    this.turnColor = cg.Color.white,
    this.lastMove,
    this.validMoves,
    this.onMove,
  }) : super(key: key);

  // board options (won't change during a game)
  final double size;
  final Settings settings;
  final BoardTheme theme;

  // board state (can/will change during a game)
  final cg.Color orientation;
  final cg.Color turnColor;
  final String fen;
  final cg.Move? lastMove;
  final cg.ValidMoves? validMoves;

  // handlers
  final Function(cg.Move)? onMove;

  double get squareSize => size / 8;

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  late cg.Pieces pieces;
  Map<String, Tuple2<cg.Coord, cg.Coord>> translatingPieces = {};
  Map<String, cg.Piece> fadingPieces = {};
  cg.SquareId? selected;
  cg.Move? _lastDrop;
  _DragAvatar? _dragAvatar;

  @override
  void initState() {
    super.initState();
    pieces = readFen(widget.fen);
  }

  @override
  void didUpdateWidget(Board oldBoard) {
    super.didUpdateWidget(oldBoard);
    translatingPieces = {};
    fadingPieces = {};
    final newPieces = readFen(widget.fen);
    final List<cg.PositionedPiece> newOnSquare = [];
    final List<cg.PositionedPiece> missingOnSquare = [];
    final Set<String> animatedOrigins = {};
    for (final s in allSquares) {
      if (s == _lastDrop?.from || s == _lastDrop?.to) {
        continue;
      }
      final oldP = pieces[s];
      final newP = newPieces[s];
      final squareCoord = squareIdToCoord(s);
      if (newP != null) {
        if (oldP != null) {
          if (newP != oldP) {
            missingOnSquare.add(cg.PositionedPiece(
                piece: oldP, squareId: s, coord: squareCoord));
            newOnSquare.add(cg.PositionedPiece(
                piece: newP, squareId: s, coord: squareCoord));
          }
        } else {
          newOnSquare.add(
              cg.PositionedPiece(piece: newP, squareId: s, coord: squareCoord));
        }
      } else if (oldP != null) {
        missingOnSquare.add(
            cg.PositionedPiece(piece: oldP, squareId: s, coord: squareCoord));
      }
    }
    for (final n in newOnSquare) {
      final fromP = closestPiece(
          n, missingOnSquare.where((m) => m.piece == n.piece).toList());
      if (fromP != null) {
        final t = Tuple2<cg.Coord, cg.Coord>(fromP.coord, n.coord);
        translatingPieces[n.squareId] = t;
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

  cg.Coord? _localOffset2Coord(Offset offset) {
    final x = (offset.dx / widget.squareSize).floor();
    final y = (offset.dy / widget.squareSize).floor();
    final orientX = widget.orientation == cg.Color.black ? 7 - x : x;
    final orientY = widget.orientation == cg.Color.black ? y : 7 - y;
    if (orientX >= 0 && orientX <= 7 && orientY >= 0 && orientY <= 7) {
      return cg.Coord(x: orientX, y: orientY);
    } else {
      return null;
    }
  }

  Offset _coord2LocalOffset(cg.Coord coord) {
    final dx = (widget.orientation == cg.Color.black ? 7 - coord.x : coord.x) *
        widget.squareSize;
    final dy = (widget.orientation == cg.Color.black ? coord.y : 7 - coord.y) *
        widget.squareSize;
    return Offset(dx, dy);
  }

  // returns the position of the square target during drag as a global offset
  Offset? _squareTargetGlobalOffset(Offset localPosition) {
    final coord = _localOffset2Coord(localPosition);
    if (coord != null) {
      final localOffset = _coord2LocalOffset(coord);
      final RenderBox box = context.findRenderObject()! as RenderBox;
      final tmpOffset = box.localToGlobal(localOffset);
      return Offset(tmpOffset.dx - widget.squareSize / 2,
          tmpOffset.dy - widget.squareSize / 2);
    } else {
      return null;
    }
  }

  void _onPanDown(DragDownDetails? details) {
    if (details != null) {
      final coord = _localOffset2Coord(details.localPosition);
      if (coord != null) {
        final squareId = coord2SquareId(coord);
        if (_isMovable(squareId)) {
          setState(() {
            selected = squareId;
          });
        }
      }
    }
  }

  void _onPanStart(DragStartDetails? details) {
    if (details != null) {
      final coord = _localOffset2Coord(details.localPosition);
      final _squareId = coord != null ? coord2SquareId(coord) : null;
      final _piece = _squareId != null ? pieces[_squareId] : null;
      final _feedbackSize =
          widget.squareSize * widget.settings.dragFeedbackSize;
      if (_squareId != null && _piece != null && _isMovable(_squareId)) {
        final _squareTargetOffset =
            _squareTargetGlobalOffset(details.localPosition);
        _dragAvatar = _DragAvatar(
          overlayState: Overlay.of(context, debugRequiredFor: widget)!,
          initialPosition: details.globalPosition,
          initialTargetPosition: _squareTargetOffset,
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
              ((widget.settings.dragFeedbackOffset.dx - 1) * _feedbackSize) / 2,
              ((widget.settings.dragFeedbackOffset.dy - 1) * _feedbackSize) / 2,
            ),
            child: Piece(
              piece: _piece,
              size: _feedbackSize,
            ),
          ),
        );
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails? details) {
    if (details != null) {
      _dragAvatar?.update(details);
      final squareTargetOffset =
          _squareTargetGlobalOffset(details.localPosition);
      _dragAvatar?.updateSquareTarget(squareTargetOffset);
    }
  }

  void _onPanEnd(DragEndDetails? details) {
    if (_dragAvatar != null) {
      final RenderBox box = context.findRenderObject()! as RenderBox;
      final localPos = box.globalToLocal(_dragAvatar!._position);
      final coord = _localOffset2Coord(localPos);
      final squareId = coord != null ? coord2SquareId(coord) : null;
      if (squareId != null && squareId != selected) {
        _tryMoveTo(squareId, drop: true);
      }
    }
    _dragAvatar?.end();
    _dragAvatar = null;
  }

  void _onPanCancel() {
    _dragAvatar?.cancel();
    _dragAvatar = null;
  }

  void _onTapUp(TapUpDetails? details) {
    if (details != null) {
      final coord = _localOffset2Coord(details.localPosition);
      final squareId = coord != null ? coord2SquareId(coord) : null;
      if (squareId != null && squareId != selected) {
        _tryMoveTo(squareId);
      }
    }
  }

  bool _isMovable(cg.SquareId squareId) {
    final piece = pieces[squareId];
    return piece != null &&
        (widget.settings.interactableColor == null ||
            (widget.settings.interactableColor == piece.color &&
                widget.turnColor == piece.color));
  }

  bool _canMove(cg.SquareId orig, cg.SquareId dest) {
    final validDests = widget.validMoves?[orig];
    return orig != dest && validDests != null && validDests.contains(dest);
  }

  void _tryMoveTo(cg.SquareId squareId, {drop = false}) {
    final selectedPiece = selected != null ? pieces[selected] : null;
    if (selectedPiece != null && _canMove(selected!, squareId)) {
      final move = cg.Move(from: selected!, to: squareId);
      if (drop) {
        _lastDrop = move;
      }
      widget.onMove?.call(move);
    }
    setState(() {
      selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Set<cg.SquareId> moveDests =
        selected != null && widget.validMoves != null
            ? widget.validMoves![selected] ?? {}
            : {};
    final Widget _board = SizedBox.square(
      dimension: widget.size,
      child: Stack(
        children: [
          widget.settings.enableCoordinates
              ? widget.orientation == cg.Color.white
                  ? widget.theme.whiteCoordBackground
                  : widget.theme.blackCoordBackground
              : widget.theme.background,
          Stack(
            children: [
              if (widget.settings.showLastMove && widget.lastMove != null)
                for (final squareId in widget.lastMove!.squares)
                  PositionedSquare(
                    key: ValueKey('lastMove' + squareId),
                    size: widget.squareSize,
                    orientation: widget.orientation,
                    squareId: squareId,
                    child: Highlight(
                      size: widget.squareSize,
                      color: widget.theme.lastMove,
                    ),
                  ),
              if (selected != null)
                PositionedSquare(
                  key: ValueKey('selected' + selected!),
                  size: widget.squareSize,
                  orientation: widget.orientation,
                  squareId: selected!,
                  child: Highlight(
                    size: widget.squareSize,
                    color: widget.theme.selected,
                  ),
                ),
              for (final entry in fadingPieces.entries)
                PositionedSquare(
                  key: ValueKey('fading' + entry.key + entry.value.kind),
                  size: widget.squareSize,
                  orientation: widget.orientation,
                  squareId: entry.key,
                  child: PieceFade(
                    curve: Curves.easeInCubic,
                    duration: widget.settings.animationDuration,
                    child: Piece(
                      piece: entry.value,
                      size: widget.squareSize,
                    ),
                  ),
                ),
              for (final entry in pieces.entries)
                PositionedSquare(
                  key: ValueKey(entry.key + entry.value.kind),
                  size: widget.squareSize,
                  orientation: widget.orientation,
                  squareId: entry.key,
                  child: translatingPieces.containsKey(entry.key)
                      ? PieceTranslation(
                          child: Piece(
                            piece: entry.value,
                            size: widget.squareSize,
                          ),
                          fromCoord: translatingPieces[entry.key]!.item1,
                          toCoord: translatingPieces[entry.key]!.item2,
                          orientation: widget.orientation,
                          duration: widget.settings.animationDuration,
                        )
                      : Piece(
                          piece: entry.value,
                          size: widget.squareSize,
                        ),
                ),
              // we want move dests highlights to be over pieces
              for (final dest in moveDests)
                PositionedSquare(
                  key: ValueKey('dest' + dest),
                  size: widget.squareSize,
                  orientation: widget.orientation,
                  squareId: dest,
                  child: MoveDest(
                    size: widget.squareSize,
                    color: widget.theme.validMoves,
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    return widget.settings.interactable
        // TODO consider using Listener instead as we don't control the drag start threshold with GestureDetector
        ? GestureDetector(
            // registering onTapDown is needed to prevent the panStart event to win the competition too early
            // there is no need to implement the callback since we handle the selection login in onPanDown; plus this way we avoid the timeout before onTapDown is called
            onTapDown: (TapDownDetails? details) {},
            onTapUp: _onTapUp,
            onPanDown: _onPanDown,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onPanCancel: _onPanCancel,
            dragStartBehavior: DragStartBehavior.down,
            child: _board,
          )
        : _board;
  }
}

// For the login behind this see:
// https://github.com/flutter/flutter/blob/stable/packages/flutter/lib/src/widgets/drag_target.dart#L805
// and:
// https://github.com/flutter/flutter/blob/ee4e09cce01d6f2d7f4baebd247fde02e5008851/packages/flutter/lib/src/widgets/overlay.dart#L58
class _DragAvatar {
  final Widget pieceFeedback;
  final Widget squareTargetFeedback;
  final OverlayState overlayState;
  Offset _position;
  Offset? _squareTargetPosition;
  late OverlayEntry _pieceEntry;
  late OverlayEntry _squareTargetEntry;

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
    // final Offset oldPosition = _position;
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
