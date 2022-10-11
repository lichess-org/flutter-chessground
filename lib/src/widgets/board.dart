import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:tuple/tuple.dart';
import 'piece.dart';
import 'highlight.dart';
import 'positioned_square.dart';
import 'animation.dart';
import 'promotion.dart';
import '../models.dart';
import '../fen.dart';
import '../premove.dart';
import '../settings.dart';
import '../theme.dart';

/// A chessboard widget
///
/// This widget can be used to display a static board, a dynamic board that
/// shows a live game, or a full user interactable board.
///
/// Fine control over visual and behavior settings can be achieved by passing a [Settings] object.
class Board extends StatefulWidget {
  const Board({
    super.key,
    this.theme = BoardTheme.brown,
    this.pieceSet,
    required this.interactableSide,
    required this.size,
    required this.orientation,
    required this.fen,
    this.settings = const Settings(),
    this.turnColor = Side.white,
    this.lastMove,
    this.validMoves,
    this.onMove,
  });

  /// Which color is allowed to move? It can be both, none, white or black
  ///
  /// If `none` is chosen the board will be non interactable.
  final InteractableSide interactableSide;

  final double size;
  final BoardTheme theme;
  final PieceSet? pieceSet;
  final Settings settings;

  /// Side by which the board is oriented.
  final Side orientation;

  /// Side which is to move.
  final Side turnColor;

  /// FEN string describing the position of the board.
  final String fen;

  /// Last move played, used to highlight corresponding squares.
  final Move? lastMove;

  /// Set of [Move] allowed to be played by current side to move.
  final ValidMoves? validMoves;

  /// Callback called after a move has been made.
  final Function(Move, {bool? isPremove})? onMove;

  double get squareSize => size / 8;

  Coord? localOffset2Coord(Offset offset) {
    final x = (offset.dx / squareSize).floor();
    final y = (offset.dy / squareSize).floor();
    final orientX = orientation == Side.black ? 7 - x : x;
    final orientY = orientation == Side.black ? y : 7 - y;
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
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  Pieces pieces = {};
  Map<String, Tuple2<Coord, Coord>> translatingPieces = {};
  Map<String, Piece> fadingPieces = {};
  SquareId? selected;
  Move? _promotionMove;
  Move? _lastDrop;
  Move? _premove;
  Set<SquareId>? _premoveDests;
  _DragAvatar? _dragAvatar;
  SquareId? _dragOrigin;

  @override
  Widget build(BuildContext context) {
    final Set<SquareId> moveDests =
        widget.settings.showValidMoves && selected != null && widget.validMoves != null
            ? widget.validMoves![selected] ?? {}
            : {};
    final premoveDests = _premoveDests ?? {};
    final Widget _board = Stack(
      children: [
        widget.settings.enableCoordinates
            ? widget.orientation == Side.white
                ? widget.theme.whiteCoordBackground
                : widget.theme.blackCoordBackground
            : widget.theme.background,
        if (widget.settings.showLastMove && widget.lastMove != null)
          for (final squareId in widget.lastMove!.squares)
            PositionedSquare(
              key: ValueKey('$squareId-lastMove'),
              size: widget.squareSize,
              orientation: widget.orientation,
              squareId: squareId,
              child: Highlight(
                size: widget.squareSize,
                color: widget.theme.lastMove,
              ),
            ),
        if (_premove != null)
          for (final squareId in _premove!.squares)
            PositionedSquare(
              key: ValueKey('$squareId-premove'),
              size: widget.squareSize,
              orientation: widget.orientation,
              squareId: squareId,
              child: Highlight(
                size: widget.squareSize,
                color: widget.theme.validPremoves,
              ),
            ),
        if (selected != null)
          PositionedSquare(
            key: ValueKey('${selected!}-selected'),
            size: widget.squareSize,
            orientation: widget.orientation,
            squareId: selected!,
            child: Highlight(
              size: widget.squareSize,
              color: widget.theme.selected,
            ),
          ),
        for (final dest in moveDests)
          PositionedSquare(
            key: ValueKey('$dest-dest'),
            size: widget.squareSize,
            orientation: widget.orientation,
            squareId: dest,
            child: MoveDest(
              size: widget.squareSize,
              color: widget.theme.validMoves,
              occupied: pieces.containsKey(dest),
            ),
          ),
        for (final dest in premoveDests)
          PositionedSquare(
            key: ValueKey('$dest-premove-dest'),
            size: widget.squareSize,
            orientation: widget.orientation,
            squareId: dest,
            child: MoveDest(
              size: widget.squareSize,
              color: widget.theme.validPremoves,
              occupied: pieces.containsKey(dest),
            ),
          ),
        for (final entry in fadingPieces.entries)
          PositionedSquare(
            key: ValueKey('${entry.key}-${entry.value.kind}-fading'),
            size: widget.squareSize,
            orientation: widget.orientation,
            squareId: entry.key,
            child: PieceFade(
              duration: widget.settings.animationDuration,
              piece: entry.value,
              size: widget.squareSize,
              pieceSet: widget.pieceSet,
              onComplete: () {
                fadingPieces.remove(entry.key);
              },
            ),
          ),
        for (final entry in pieces.entries)
          PositionedSquare(
            key: ValueKey('${entry.key}-${entry.value.kind}'),
            size: widget.squareSize,
            orientation: widget.orientation,
            squareId: entry.key,
            child: translatingPieces.containsKey(entry.key)
                ? PieceTranslation(
                    child: PieceWidget(
                      piece: entry.value,
                      size: widget.squareSize,
                      pieceSet: widget.pieceSet,
                    ),
                    fromCoord: translatingPieces[entry.key]!.item1,
                    toCoord: translatingPieces[entry.key]!.item2,
                    orientation: widget.orientation,
                    duration: widget.settings.animationDuration,
                    onComplete: () {
                      translatingPieces.remove(entry.key);
                    },
                  )
                : PieceWidget(
                    piece: entry.value,
                    size: widget.squareSize,
                    pieceSet: widget.pieceSet,
                    opacity: _dragOrigin == entry.key ? 0.2 : 1.0,
                  ),
          ),
      ],
    );

    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        children: [
          // Consider using Listener instead as we don't control the drag start threshold with
          // GestureDetector (TODO)
          widget.interactableSide != InteractableSide.none
              ? GestureDetector(
                  // registering onTapDown is needed to prevent the panStart event to win the
                  // competition too early
                  // there is no need to implement the callback since we handle the selection login
                  // in onPanDown; plus this way we avoid the timeout before onTapDown is called
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
              : _board,
          if (_promotionMove != null)
            PromotionSelector(
              pieceSet: widget.pieceSet,
              move: _promotionMove!,
              squareSize: widget.squareSize,
              color: widget.turnColor,
              orientation: widget.orientation,
              onSelect: _onPromotionSelect,
              onCancel: _onPromotionCancel,
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    pieces = readFen(widget.fen);
  }

  @override
  void didUpdateWidget(Board oldBoard) {
    super.didUpdateWidget(oldBoard);
    if (widget.interactableSide == InteractableSide.none) {
      // remove highlights if board is made not interactable again (like at the end of a game)
      selected = null;
      _premoveDests = null;
      _premove = null;
    }
    if (oldBoard.turnColor != widget.turnColor) {
      _premoveDests = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryPlayPremove());
    }
    if (oldBoard.fen == widget.fen) {
      _lastDrop = null;
      // as long as the fen is the same as before let's keep animations
      return;
    }
    translatingPieces = {};
    fadingPieces = {};
    final newPieces = readFen(widget.fen);
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
            missingOnSquare.add(PositionedPiece(piece: oldP, squareId: s, coord: squareCoord));
            newOnSquare.add(PositionedPiece(piece: newP, squareId: s, coord: squareCoord));
          }
        } else {
          newOnSquare.add(PositionedPiece(piece: newP, squareId: s, coord: squareCoord));
        }
      } else if (oldP != null) {
        missingOnSquare.add(PositionedPiece(piece: oldP, squareId: s, coord: squareCoord));
      }
    }
    for (final n in newOnSquare) {
      final fromP = n.closest(missingOnSquare.where((m) => m.piece == n.piece).toList());
      if (fromP != null) {
        final t = Tuple2<Coord, Coord>(fromP.coord, n.coord);
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

  // returns the position of the square target during drag as a global offset
  Offset? _squareTargetGlobalOffset(Offset localPosition) {
    final coord = widget.localOffset2Coord(localPosition);
    if (coord != null) {
      final localOffset = coord.offset(widget.orientation, widget.squareSize);
      final RenderBox box = context.findRenderObject()! as RenderBox;
      final tmpOffset = box.localToGlobal(localOffset);
      return Offset(tmpOffset.dx - widget.squareSize / 2, tmpOffset.dy - widget.squareSize / 2);
    } else {
      return null;
    }
  }

  void _onPanDown(DragDownDetails? details) {
    if (details != null) {
      final squareId = widget.localOffset2SquareId(details.localPosition);
      if (squareId != null) {
        // allow to castle by selecting the king and then the rook, so we must prevent the
        // re-selection of the rook
        if (_isMovable(squareId) && (selected == null || !_canMove(selected!, squareId))) {
          setState(() {
            selected = squareId;
          });
        } else if (_isPremovable(squareId) &&
            (selected == null || !_canPremove(selected!, squareId))) {
          setState(() {
            selected = squareId;
            _premoveDests =
                premovesOf(squareId, pieces, canCastle: widget.settings.enablePremoveCastling);
          });
        } else {
          setState(() {
            _premove = null;
            _premoveDests = null;
          });
        }
      }
    }
  }

  void _onPanStart(DragStartDetails? details) {
    if (details != null) {
      final _squareId = widget.localOffset2SquareId(details.localPosition);
      final _piece = _squareId != null ? pieces[_squareId] : null;
      final _feedbackSize = widget.squareSize * widget.settings.dragFeedbackSize;
      if (_squareId != null &&
          _piece != null &&
          (_isMovable(_squareId) || _isPremovable(_squareId))) {
        setState(() {
          _dragOrigin = _squareId;
        });
        final _squareTargetOffset = _squareTargetGlobalOffset(details.localPosition);
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
            child: PieceWidget(
              piece: _piece,
              size: _feedbackSize,
              pieceSet: widget.pieceSet,
            ),
          ),
        );
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails? details) {
    if (details != null && _dragAvatar != null) {
      final squareTargetOffset = _squareTargetGlobalOffset(details.localPosition);
      _dragAvatar?.update(details);
      _dragAvatar?.updateSquareTarget(squareTargetOffset);
    }
  }

  void _onPanEnd(DragEndDetails? details) {
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

  void _onPanCancel() {
    _dragAvatar?.cancel();
    _dragAvatar = null;
    setState(() {
      _dragOrigin = null;
    });
  }

  void _onTapUp(TapUpDetails? details) {
    if (details != null) {
      final squareId = widget.localOffset2SquareId(details.localPosition);
      if (squareId != null && squareId != selected) {
        _tryMoveTo(squareId);
      }
    }
  }

  void _onPromotionSelect(Move move, Piece promoted) {
    setState(() {
      pieces[move.to] = promoted;
      _promotionMove = null;
    });
    widget.onMove?.call(move.withPromotion(promoted.role));
  }

  void _onPromotionCancel(Move move) {
    setState(() {
      pieces = readFen(widget.fen);
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
        (widget.interactableSide == InteractableSide.both ||
            (widget.interactableSide.name == piece.color.name && widget.turnColor == piece.color));
  }

  bool _canMove(SquareId orig, SquareId dest) {
    final validDests = widget.validMoves?[orig];
    return orig != dest && validDests != null && validDests.contains(dest);
  }

  bool _isPremovable(SquareId squareId) {
    final piece = pieces[squareId];
    return piece != null &&
        (widget.settings.enablePremoves &&
            widget.interactableSide.name == piece.color.name &&
            widget.turnColor != piece.color);
  }

  bool _canPremove(SquareId orig, SquareId dest) {
    return (orig != dest &&
        _isPremovable(orig) &&
        premovesOf(orig, pieces, canCastle: widget.settings.enablePremoveCastling).contains(dest));
  }

  bool _isPromoMove(Piece piece, SquareId targetSquareId) {
    final rank = targetSquareId[1];
    return piece.role == PieceRole.pawn && (rank == '1' || rank == '8');
  }

  void _tryMoveTo(SquareId squareId, {drop = false}) {
    final selectedPiece = selected != null ? pieces[selected] : null;
    if (selectedPiece != null && _canMove(selected!, squareId)) {
      final move = Move(from: selected!, to: squareId);
      if (drop) {
        _lastDrop = move;
      }
      if (_isPromoMove(selectedPiece, squareId)) {
        if (widget.settings.autoQueenPromotion) {
          widget.onMove?.call(move.withPromotion(PieceRole.queen));
        } else {
          _openPromotionSelector(move);
        }
      } else {
        widget.onMove?.call(move);
      }
    } else if (selectedPiece != null && _canPremove(selected!, squareId)) {
      setState(() {
        _premove = Move(from: selected!, to: squareId);
      });
    }
    setState(() {
      selected = null;
      _premoveDests = null;
    });
  }

  void _tryPlayPremove() {
    if (_premove == null) {
      return;
    }
    final fromPiece = pieces[_premove!.from];
    if (fromPiece != null && _canMove(_premove!.from, _premove!.to)) {
      if (_isPromoMove(fromPiece, _premove!.to)) {
        if (widget.settings.autoQueenPromotion) {
          widget.onMove?.call(_premove!.withPromotion(PieceRole.queen), isPremove: true);
        } else {
          _openPromotionSelector(_premove!);
        }
      } else {
        widget.onMove?.call(_premove!, isPremove: true);
      }
    }
    setState(() {
      _premove = null;
    });
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
