import 'package:dartchess/dartchess.dart' show Piece, Side;
import 'package:flutter/widgets.dart';

import '../board_editor_settings.dart';
import '../models.dart';
import 'board.dart';
import 'drag.dart';
import '../fen.dart';
import 'piece.dart';
import 'positioned_square.dart';

/// Controls the behavior of pointer events on the board editor.
enum PointerToolMode {
  /// The default mode where pieces can be dragged around the board.
  drag,

  /// The mode where pieces can be put/removed from the board when the pointer
  /// is over a square.
  edit,
}

/// A chessboard widget where pieces can be dragged around freely (including dragging piece off and onto the board).
///
/// This widget can be used as the basis for a fully fledged board editor, similar to https://lichess.org/editor.
/// The logic for creating a board editor should be implemented by the consumer of this widget.
/// This widget only provides the visual representation of the board and the pieces on it, and responds to pointer events through the [onTouchedSquare], [onDroppedPiece], and [onDiscardedPiece] callbacks.
///
/// Use the [pointerToolMode] property to switch between dragging pieces and adding/removing pieces from the board using pan gestures.
///
/// A [writeFen] method is provided by this package to convert the current state
/// of the board editor to a FEN string.
class ChessBoardEditor extends StatefulWidget with BoardGeometry {
  const ChessBoardEditor({
    super.key,
    required this.size,
    required this.orientation,
    required this.pieces,
    this.pointerToolMode = PointerToolMode.drag,
    this.settings = const BoardEditorSettings(),
    this.onTouchedSquare,
    this.onDroppedPiece,
    this.onDiscardedPiece,
  });

  @override
  final double size;

  @override
  final Side orientation;

  /// The pieces to display on the board.
  ///
  /// This is read-only, it will never be modified by the board editor.
  /// See [readFen] and [writeFen] for converting between [Pieces] and FEN strings.
  final Pieces pieces;

  /// Settings that control the appearance of the board editor.
  final BoardEditorSettings settings;

  /// The current mode of the pointer tool.
  final PointerToolMode pointerToolMode;

  /// Called when the given [square] was touched or hovered over.
  final void Function(SquareId square)? onTouchedSquare;

  /// Called when a [piece] has been dragged to a new [destination] square.
  ///
  /// If [origin] is not `null`, the piece was dragged from that square of the board editor.
  /// Otherwise, it was dragged from outside the board editor.
  /// Each square of the board is a [DragTarget<Piece>], so to drop your own piece widgets
  /// onto the board, put them in a [Draggable<Piece>] and set the data to the piece you want to drop.
  final void Function(SquareId? origin, SquareId destination, Piece piece)?
      onDroppedPiece;

  /// Called when a piece that was originally at the given [square] was dragged off the board.
  final void Function(SquareId square)? onDiscardedPiece;

  @override
  State<ChessBoardEditor> createState() => _BoardEditorState();
}

class _BoardEditorState extends State<ChessBoardEditor> {
  SquareId? draggedPieceOrigin;

  @override
  Widget build(BuildContext context) {
    final List<Widget> squareWidgets = allSquares.map((squareId) {
      final piece = widget.pieces[squareId];

      return PositionedSquare(
        key: ValueKey('$squareId-${piece ?? 'empty'}'),
        size: widget.squareSize,
        orientation: widget.orientation,
        squareId: squareId,
        child: DragTarget<Piece>(
          hitTestBehavior: HitTestBehavior.opaque,
          builder: (context, candidateData, rejectedData) {
            return Stack(
              children: [
                // Show a drop target if a piece is dragged over the square
                if (candidateData.isNotEmpty)
                  Transform.scale(
                    scale: 2,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0x33000000),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                if (widget.pointerToolMode == PointerToolMode.drag &&
                    piece != null)
                  Draggable(
                    hitTestBehavior: HitTestBehavior.translucent,
                    data: piece,
                    feedback: PieceDragFeedback(
                      piece: piece,
                      squareSize: widget.squareSize,
                      size: widget.settings.dragFeedbackSize,
                      offset: widget.settings.dragFeedbackOffset,
                      pieceAssets: widget.settings.pieceAssets,
                    ),
                    childWhenDragging: const SizedBox.shrink(),
                    onDragStarted: () => draggedPieceOrigin = squareId,
                    onDraggableCanceled: (_, __) {
                      widget.onDiscardedPiece?.call(squareId);
                      draggedPieceOrigin = null;
                    },
                    child: PieceWidget(
                      piece: piece,
                      size: widget.squareSize,
                      pieceAssets: widget.settings.pieceAssets,
                    ),
                  )
                else if (piece != null)
                  PieceWidget(
                    piece: piece,
                    size: widget.squareSize,
                    pieceAssets: widget.settings.pieceAssets,
                  ),
              ],
            );
          },
          onAcceptWithDetails: (details) {
            widget.onDroppedPiece?.call(
              draggedPieceOrigin,
              squareId,
              details.data,
            );
            draggedPieceOrigin = null;
          },
        ),
      );
    }).toList();

    final background = widget.settings.enableCoordinates
        ? widget.orientation == Side.white
            ? widget.settings.colorScheme.whiteCoordBackground
            : widget.settings.colorScheme.blackCoordBackground
        : widget.settings.colorScheme.background;

    return SizedBox.square(
      dimension: widget.size,
      child: GestureDetector(
        onTapDown: (details) => _onTouchedEvent(details.localPosition),
        onPanStart: (details) => _onTouchedEvent(details.localPosition),
        onPanUpdate: (details) => _onTouchedEvent(details.localPosition),
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
                child: background,
              )
            else
              background,
            ...squareWidgets,
          ],
        ),
      ),
    );
  }

  void _onTouchedEvent(Offset localPosition) {
    if (widget.pointerToolMode == PointerToolMode.drag) {
      return;
    }
    final squareId = widget.offsetSquareId(localPosition);
    if (squareId != null) {
      widget.onTouchedSquare?.call(squareId);
    }
  }
}
