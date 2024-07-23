import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/widgets.dart';
import '../models.dart';
import './highlight.dart';
import './piece.dart';

/// Board aware [Positioned] widget.
///
/// Use to position things, such as a [PieceWidget] or [SquareHighlight] on the
/// board.
///
/// It must be a descendant of a [Stack] since it's a wrapper over [Positioned].
class PositionedSquare extends StatelessWidget {
  const PositionedSquare({
    super.key,
    required this.child,
    required this.size,
    required this.orientation,
    required this.squareId,
  });

  final Widget child;
  final double size;
  final Side orientation;
  final SquareId squareId;

  @override
  Widget build(BuildContext context) {
    final offset = squareId.coord.offset(orientation, size);
    return Positioned(
      width: size,
      height: size,
      left: offset.dx,
      top: offset.dy,
      child: child,
    );
  }
}
