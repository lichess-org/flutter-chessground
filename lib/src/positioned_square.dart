import 'package:flutter/material.dart';
import 'models.dart' as cg;

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

  String get file => squareId.substring(0, 1);
  String get rank => squareId.substring(1);
  int get xCoord {
    final i = file.codeUnitAt(0) - 97;
    return orientation == cg.Color.black ? 7 - i : i;
  }

  int get yCoord {
    final i = int.parse(rank) - 1;
    return orientation == cg.Color.black ? i : 7 - i;
  }

  double get x => xCoord * size;
  double get y => yCoord * size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: child,
      width: size,
      height: size,
      left: x,
      top: y,
    );
  }
}
