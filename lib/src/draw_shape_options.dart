import 'package:flutter/widgets.dart';
import 'models.dart';

/// Settings for drawing shapes on the board.
@immutable
class DrawShapeOptions {
  const DrawShapeOptions({
    this.enable = false,
    this.onCompleteShape,
    this.onClearShapes,
    this.newShapeColor =
        const Color(0xAA15781b), // default to lichess.org green
  });

  /// Whether to enable shape drawing.
  final bool enable;

  /// A callback for when shape drawing gesture is completed.
  final void Function(Shape shape)? onCompleteShape;

  /// A callback for when the user clears all shapes.
  final void Function()? onClearShapes;

  /// The color of the shape being drawn.
  final Color newShapeColor;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is DrawShapeOptions &&
        other.enable == enable &&
        other.newShapeColor == newShapeColor &&
        other.onCompleteShape == onCompleteShape &&
        other.onClearShapes == onClearShapes;
  }

  @override
  int get hashCode =>
      Object.hash(enable, newShapeColor, onCompleteShape, onClearShapes);
}
