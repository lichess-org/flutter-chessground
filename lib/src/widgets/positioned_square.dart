import 'package:flutter/material.dart';
import '../models.dart' as cg;
import '../utils.dart';

/// Board aware Positioned widget
///
/// Use to position things, such as [Piece], [Highlight] on the board.
/// Since it's a wrapper over a [Positioned] widget it must be a descendant of a
/// [Stack].
class PositionedSquare extends StatelessWidget {
  final Widget child;
  final double size;
  final cg.Color orientation;
  final cg.SquareId squareId;

  const PositionedSquare({
    Key? key,
    required this.child,
    required this.size,
    required this.orientation,
    required this.squareId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final offset = coord2Offset(squareId2Coord(squareId), orientation, size);
    return Positioned(
      child: child,
      width: size,
      height: size,
      left: offset.dx,
      top: offset.dy,
    );
  }
}
