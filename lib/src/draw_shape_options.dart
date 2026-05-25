import 'package:flutter/widgets.dart';
import 'models.dart';

/// Options that control the shape drawing gesture on the board.
///
/// When [enable] is true, the user can hold an empty square with one finger
/// and tap or drag with another to draw [Circle]s and [Arrow]s. Completed
/// shapes are stored in [ChessboardController.drawnShapes] and can be
/// cleared with [ChessboardController.clearDrawnShapes].
///
/// Externally supplied shapes (engine arrows, analysis annotations, etc.)
/// are passed separately via [Chessboard.shapes]; the board renders the
/// union of both sets.
@immutable
class DrawShapeOptions {
  const DrawShapeOptions({
    this.enable = false,
    this.newShapeColor = const Color(0xAA15781b), // default to lichess.org green
  });

  /// Whether to enable shape drawing.
  final bool enable;

  /// The color of the shape being drawn.
  final Color newShapeColor;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is DrawShapeOptions &&
        other.enable == enable &&
        other.newShapeColor == newShapeColor;
  }

  @override
  int get hashCode => Object.hash(enable, newShapeColor);
}
