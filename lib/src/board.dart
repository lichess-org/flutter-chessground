import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'piece.dart';
import 'highlight.dart';
import 'models.dart' as cg;
import 'positioned_square.dart';
import 'animation.dart';
import 'fen.dart';
import 'utils.dart';
import 'settings.dart';
import 'theme.dart';

const dragFeedbackSize = 1.5;
const dragFeedbackOffset = Offset(0.0, -1.0);

@immutable
class Board extends StatefulWidget {
  final double size;
  final Settings settings;
  final BoardTheme theme;

  final cg.Color orientation;
  final cg.Color turnColor;
  final String fen;
  final cg.Move? lastMove;

  const Board({
    Key? key,
    this.settings = const Settings(),
    this.theme = BoardTheme.brown,
    required this.size,
    required this.orientation,
    required this.fen,
    this.turnColor = cg.Color.white,
    this.lastMove,
  }) : super(key: key);

  double get squareSize => size / 8;

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  late cg.Pieces pieces;
  Map<String, Tuple2<cg.Coord, cg.Coord>> translatingPieces = {};
  Map<String, cg.Piece> fadingPieces = {};
  cg.SquareId? selected;
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

  Offset _coord2LocalOffset(
      cg.Coord coord, double squareSize, cg.Color orientation) {
    final dx =
        (orientation == cg.Color.black ? 7 - coord.x : coord.x) * squareSize;
    final dy =
        (orientation == cg.Color.black ? coord.y : 7 - coord.y) * squareSize;
    return Offset(dx, dy);
  }

  Offset? _globalSquareTargetOffset(Offset localPosition) {
    final coord = _localOffset2Coord(localPosition);
    if (coord != null) {
      final localOffset =
          _coord2LocalOffset(coord, widget.squareSize, widget.orientation);
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
        debugPrint('square id: $squareId');
        setState(() {
          selected = _isMovable(squareId) ? squareId : null;
        });
      }
    }
  }

  void _onPanStart(DragStartDetails? details) {
    debugPrint('drag started: ${details?.localPosition}');
    if (details != null) {
      final _piece = selected != null ? pieces[selected] : null;
      final _feedbackSize = widget.squareSize * dragFeedbackSize;
      if (_piece != null) {
        final _squareTargetOffset =
            _globalSquareTargetOffset(details.localPosition);
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
              ((dragFeedbackOffset.dx - 1) * _feedbackSize) / 2,
              ((dragFeedbackOffset.dy - 1) * _feedbackSize) / 2,
            ),
            child: UIPiece(
              piece: _piece,
              size: _feedbackSize,
            ),
          ),
        );
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails? details) {
    // debugPrint('drag updated: ${details?.localPosition}');
    if (details != null) {
      _dragAvatar?.update(details);
      final squareTargetOffset =
          _globalSquareTargetOffset(details.localPosition);
      _dragAvatar?.updateSquareTarget(squareTargetOffset);
    }
  }

  void _onPanEnd(DragEndDetails? details) {
    if (_dragAvatar != null) {
      final RenderBox box = context.findRenderObject()! as RenderBox;
      final localPos = box.globalToLocal(_dragAvatar!._position);
      final coord = _localOffset2Coord(localPos);
      if (coord != null) {
        debugPrint('drag end squareId: ${coord2SquareId(coord)}');
      }
    }
    _dragAvatar?.end();
    _dragAvatar = null;
    debugPrint('drag ended');
  }

  void _onPanCancel() {
    debugPrint('drag canceled');
    _dragAvatar?.cancel();
    _dragAvatar = null;
  }

  bool _isMovable(cg.SquareId squareId) {
    final piece = pieces[squareId];
    return piece != null &&
        (widget.settings.interactableColor == null ||
            (widget.settings.interactableColor == piece.color &&
                widget.turnColor == piece.color));
  }

  @override
  Widget build(BuildContext context) {
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
                    child: UIPiece(
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
                          child: UIPiece(
                            piece: entry.value,
                            size: widget.squareSize,
                          ),
                          fromCoord: translatingPieces[entry.key]!.item1,
                          toCoord: translatingPieces[entry.key]!.item2,
                          orientation: widget.orientation,
                          duration: widget.settings.animationDuration,
                        )
                      : UIPiece(
                          piece: entry.value,
                          size: widget.squareSize,
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
            onPanDown: _onPanDown,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onPanCancel: _onPanCancel,
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
