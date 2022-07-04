import 'package:flutter/material.dart';
import '../models.dart' as cg;

/// Board aware Positioned widget
///
/// Use to position things, such as [Piece], [Highlight] on the board.
/// Since it's a wrapper over a [Positioned] widget it must be a descendant of a
/// [Stack].
class PositionedSquare extends StatelessWidget {
  const PositionedSquare({
    Key? key,
    required this.child,
    required this.size,
    required this.orientation,
    required this.squareId,
  }) : super(key: key);

  final Widget child;
  final double size;
  final cg.Color orientation;
  final cg.SquareId squareId;

  @override
  Widget build(BuildContext context) {
    final offset = cg.Coord.fromSquareId(squareId).offset(orientation, size);
    return Positioned(
      child: child,
      width: size,
      height: size,
      left: offset.dx,
      top: offset.dy,
    );
  }
}
