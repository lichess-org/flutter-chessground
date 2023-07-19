import 'package:flutter/widgets.dart';
import 'models.dart';

@immutable
class ShapeData {
  const ShapeData({
    // onCompletion should default to an empty function
    this.onCompleteShape,
    this.newShapeColor = const Color(0xAA15781b), // default to lichess.org green
    this.drawShapes = false,
    this.snapToValidMoves = true,
  });

  /// A callback for when shape drawing gesture is completed.
  final void Function(Shape shape)? onCompleteShape;

  /// The color of the shape being drawn.
  final Color newShapeColor;

  /// Whether or not to draw shapes.
  final bool drawShapes;

  /// Whether or not to snap to valid moves.
  final bool snapToValidMoves;
}