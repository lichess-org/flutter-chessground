import 'package:dartchess/dartchess.dart' show Piece;
import 'package:flutter/widgets.dart';

import 'piece.dart';
import '../models.dart';

/// The [Piece] to show under the pointer when a drag is under way.
///
/// You can use this to drag pieces onto a [BoardEditor] with the same appearance as when the pieces on the board are dragged.
class PieceDragFeedback extends StatelessWidget {
  const PieceDragFeedback({
    super.key,
    required this.piece,
    required this.squareSize,
    required this.pieceAssets,
    this.size = 2,
    this.offset = const Offset(0.0, -1.0),
  });

  /// The piece that is being dragged.
  final Piece piece;

  /// Size of a square on the board.
  final double squareSize;

  /// Size of the feedback widget in units of [squareSize].
  final double size;

  /// Offset the feedback widget from the pointer position.
  final Offset offset;

  /// Piece set
  final PieceAssets pieceAssets;

  @override
  Widget build(BuildContext context) {
    final feedbackSize = squareSize * size;
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
