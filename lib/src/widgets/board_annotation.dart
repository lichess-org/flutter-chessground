import 'package:flutter/widgets.dart';
import '../models.dart';

class BoardAnnotation extends StatelessWidget {
  final Annotation annotation;

  const BoardAnnotation({
    required this.annotation,
    required this.squareSize,
    required this.orientation,
    required this.squareId,
    super.key,
  });

  final double squareSize;
  final Side orientation;
  final SquareId squareId;

  @override
  Widget build(BuildContext context) {
    final squareOffset =
        Coord.fromSquareId(squareId).offset(orientation, squareSize);
    final size = squareSize * 0.4;
    final offset = squareOffset.translate(
      squareSize - (size * 0.5),
      -(size * 0.5),
    );
    return Positioned(
      width: size,
      height: size,
      left: offset.dx,
      top: offset.dy,
      child: Container(
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: annotation.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.5),
              blurRadius: 1,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: FittedBox(
          child: Center(
            child: Text(
              annotation.symbol,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
