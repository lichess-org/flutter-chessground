import 'package:dartchess/dartchess.dart' show Piece, Side;
import 'package:flutter/widgets.dart';

import '../board_editor_settings.dart';
import '../models.dart';
import '../fen.dart';
import 'board.dart';
import 'piece.dart';
import 'positioned_square.dart';

/// Controls the behavior of pointer events on the board editor.
enum EditorPointerMode {
  /// The default mode where pieces can be dragged around the board.
  drag,

  /// The mode where pieces can be put/removed from the board when the pointer
  /// is over a square.
  edit,
}

/// A chessboard widget where pieces can be dragged around freely
/// (including dragging piece off and onto the board).
///
/// This widget can be used as the basis for a fully fledged board editor,
/// similar to https://lichess.org/editor.
///
/// This widget only provides the visual representation of the board and the
/// pieces on it, and responds to pointer events through the [onEditedSquare],
/// [onDroppedPiece], and [onDiscardedPiece] callbacks.
/// The logic for creating a board editor should be implemented by the consumer.
///
/// Use the [pointerMode] property to switch between dragging pieces and
/// adding/removing pieces from the board using pan gestures.
///
/// A [writeFen] method is provided by this package to convert the current state
/// of the board editor to a FEN string.
class ChessBoardEditor extends StatefulWidget with BoardGeometry {
  const ChessBoardEditor({
    super.key,
    required this.size,
    required this.orientation,
    required this.pieces,
    this.pointerMode = EditorPointerMode.drag,
    this.settings = const BoardEditorSettings(),
    this.onEditedSquare,
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
  ///
  /// See [readFen] and [writeFen] for converting between [Pieces] and FEN strings.
  final Pieces pieces;

  /// Settings that control the appearance of the board editor.
  final BoardEditorSettings settings;

  /// The current mode of the pointer tool.
  final EditorPointerMode pointerMode;

  /// Called when the given square was edited by the user.
  ///
  /// This is called when the user touches or hover over a square while in edit
  /// mode (i.e. [pointerMode] is [EditorPointerMode.edit]).
  final void Function(SquareId square)? onEditedSquare;

  /// Called when a piece has been dragged to a new destination square.
  ///
  /// This is active only when [pointerMode] is [EditorPointerMode.drag].
  ///
  /// If `origin` is not `null`, the piece was dragged from that square of the
  /// board editor.
  /// Otherwise, it was dragged from outside the board editor.
  ///
  /// Each square of the board is a [DragTarget<Piece>], so to drop your own
  /// piece widgets onto the board, put them in a [Draggable<Piece>] and set the
  /// data to the piece you want to drop.
  final void Function(SquareId? origin, SquareId destination, Piece piece)?
      onDroppedPiece;

  /// Called when a piece that was originally at the given `square` was dragged
  /// off the board.
  ///
  /// This is active only when [pointerMode] is [EditorPointerMode.drag].
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
                if (widget.pointerMode == EditorPointerMode.drag &&
                    piece != null)
                  Draggable(
                    hitTestBehavior: HitTestBehavior.translucent,
                    data: piece,
                    feedback: PieceDragFeedback(
                      squareSize: widget.squareSize,
                      scale: widget.settings.dragFeedbackScale,
                      offset: widget.settings.dragFeedbackOffset,
                      piece: piece,
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
    if (widget.pointerMode == EditorPointerMode.drag) {
      return;
    }
    final squareId = widget.offsetSquareId(localPosition);
    if (squareId != null) {
      widget.onEditedSquare?.call(squareId);
    }
  }
}

/// The [Piece] to show under the pointer when a drag is under way.
///
/// You can use this to drag pieces onto a [ChessBoardEditor] with the same
/// appearance as when the pieces on the board are dragged.
class PieceDragFeedback extends StatelessWidget {
  const PieceDragFeedback({
    super.key,
    required this.piece,
    required this.squareSize,
    required this.pieceAssets,
    this.scale = 2.0,
    this.offset = const Offset(0.0, -1.0),
  });

  /// The piece that is being dragged.
  final Piece piece;

  /// Size of a square on the board.
  final double squareSize;

  /// Scale factor for the feedback widget.
  final double scale;

  /// Offset the feedback widget from the pointer position.
  final Offset offset;

  /// Piece set
  final PieceAssets pieceAssets;

  @override
  Widget build(BuildContext context) {
    final feedbackSize = squareSize * scale;
    return Transform.translate(
      offset: (offset - const Offset(0.5, 0.5)) * feedbackSize / 2,
      child: PieceWidget(
        piece: piece,
        size: feedbackSize,
        pieceAssets: pieceAssets,
      ),
    );
  }
}
