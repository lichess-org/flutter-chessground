import 'package:flutter/widgets.dart';
import 'models.dart';

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
}
