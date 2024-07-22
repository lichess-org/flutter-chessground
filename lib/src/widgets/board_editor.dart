import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart' show Piece, Side;
import 'package:flutter/widgets.dart';

import 'positioned_square.dart';

/// A chessboard widget where pieces can be dragged around freely (including dragging piece off and onto the board).
///
/// This widget can be used as the basis for a fully fledged board editor, similar to https://lichess.org/editor.
class ChessBoardEditor extends StatefulWidget {
  const ChessBoardEditor({
    super.key,
    required this.size,
    required this.orientation,
    required this.pieces,
    this.settings = const BoardEditorSettings(),
    this.onTappedSquare,
    this.onDroppedPiece,
    this.onDiscardedPiece,
  });

  /// Visual size of the board.
  final double size;

  double get squareSize => size / 8;

  /// The pieces to display on the board.
  ///
  /// This is read-only, it will never be modified by the board editor.
  /// See [readFen] and [writeFen] for converting between [Pieces] and FEN strings.
  final Pieces pieces;

  /// Settings that control the appearance of the board editor.
  final BoardEditorSettings settings;

  /// Side by which the board is oriented.
  final Side orientation;

  /// Called when the given [square] was tapped.
  final void Function(SquareId square)? onTappedSquare;

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
    final List<Widget> pieceWidgets = allSquares.map((squareId) {
      final piece = widget.pieces[squareId];

      return PositionedSquare(
        key: ValueKey('$squareId-${piece ?? 'empty'}'),
        size: widget.squareSize,
        orientation: widget.orientation,
        squareId: squareId,
        child: GestureDetector(
          onTap: () => widget.onTappedSquare?.call(squareId),
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
                  if (piece != null)
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
          ...pieceWidgets,
        ],
      ),
    );
  }
}
