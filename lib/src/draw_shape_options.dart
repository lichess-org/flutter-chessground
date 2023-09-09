import 'package:flutter/widgets.dart';
import 'models.dart';

@immutable
class DrawShapeOptions {
  const DrawShapeOptions({
    // onCompletion should default to an empty function
    this.onCompleteShape,
    this.newShapeColor = const Color(0xAA15781b), // default to lichess.org green
    this.drawShapes = false,
  });

  /// A callback for when shape drawing gesture is completed.
  final void Function(Shape shape)? onCompleteShape;

  /// The color of the shape being drawn.
  final Color newShapeColor;

  /// Whether or not to draw shapes.
  final bool drawShapes;
}
