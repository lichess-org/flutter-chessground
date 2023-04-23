import 'dart:math' as math;
import 'package:flutter/widgets.dart';

import '../models.dart';

class ArrowWidget extends StatelessWidget {
  const ArrowWidget({
    super.key,
    required this.color,
    required this.size,
    required this.orientation,
    required this.fromCoord,
    required this.toCoord,
  });

  final Color color;
  final double size;
  final Side orientation;
  final Coord fromCoord;
  final Coord toCoord;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _ArrowPainter(color, orientation, fromCoord, toCoord),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter(this.color, this.orientation, this.fromCoord, this.toCoord);

  final Color color;
  final Side orientation;
  final Coord fromCoord;
  final Coord toCoord;

  @override
  void paint(Canvas canvas, Size size) {
    final squareSize = size.width / 8;
    final lineWidth = squareSize / 4;
    final paint = Paint()
      ..strokeWidth = lineWidth
      ..color = color
      ..style = PaintingStyle.stroke;

    final fromOffset = fromCoord.offset(orientation, squareSize);
    final toOffset = toCoord.offset(orientation, squareSize);
    final shift = Offset(squareSize / 2, squareSize / 2);
    final margin = squareSize / 4;

    final angle =
        math.atan2(toOffset.dy - fromOffset.dy, toOffset.dx - fromOffset.dx);
    final fromMarginOffset =
        Offset(margin * math.cos(angle), margin * math.sin(angle));
    final arrowSize = squareSize * 0.7;
    const arrowAngle = math.pi / 6;

    final from = fromOffset + shift + fromMarginOffset;
    final to = toOffset + shift;

    final path = Path();
    path.moveTo(
      to.dx - arrowSize * math.cos(angle - arrowAngle),
      to.dy - arrowSize * math.sin(angle - arrowAngle),
    );
    path.lineTo(to.dx, to.dy);
    path.lineTo(
      to.dx - arrowSize * math.cos(angle + arrowAngle),
      to.dy - arrowSize * math.sin(angle + arrowAngle),
    );
    path.close();

    final arrowHeight =
        math.sqrt(math.pow(arrowSize, 2) - math.pow(arrowSize / 2, 2));
    final arrowOffset =
        Offset(arrowHeight * math.cos(angle), arrowHeight * math.sin(angle));

    canvas.drawLine(from, to - arrowOffset, paint);

    final pathPaint = paint
      ..strokeWidth = 0
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) {
    return color != oldDelegate.color ||
        fromCoord != oldDelegate.fromCoord ||
        toCoord != oldDelegate.toCoord;
  }
}
