import 'package:flutter/widgets.dart';
import 'models.dart';

@immutable
class DrawShapeOptions {
  const DrawShapeOptions({
    this.enable = false,
    this.onCompleteShape,
    this.newShapeColor =
        const Color(0xAA15781b), // default to lichess.org green
  });

  /// Whether to enable shape drawing.
  final bool enable;

  /// A callback for when shape drawing gesture is completed.
  final void Function(Shape shape)? onCompleteShape;

  /// The color of the shape being drawn.
  final Color newShapeColor;
}
