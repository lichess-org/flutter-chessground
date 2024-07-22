import 'package:flutter/widgets.dart';

import 'piece.dart';

/// Drag feedback to show under the pointer when a drag is under way.
///
/// You can use this to drag pieces onto a [BoardEditor] with the same appearance as when the pieces on the board are dragged.
class BoardDragFeedback extends StatelessWidget {
  const BoardDragFeedback({
    super.key,
    required this.child,
    required this.squareSize,
    this.scale = 2.0,
    this.offset = const Offset(0.0, -1.0),
  });

  /// The widget to show under the pointer.
  ///
  /// Typically a [PieceWidget].
  final Widget child;

  /// Size of a square on the board.
  final double squareSize;

  /// Scale factor for the feedback widget.
  final double scale;

  /// Offset the feedback widget from the pointer position.
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final feedbackSize = squareSize * scale;
    return Transform.translate(
      offset: Offset(
        ((offset.dx - 1) * feedbackSize) / 2,
        ((offset.dy - 1) * feedbackSize) / 2,
      ),
      child: child,
    );
  }
}
