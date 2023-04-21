import 'dart:math' as math;
import 'package:flutter/widgets.dart';

import '../models.dart';

class Highlight extends StatelessWidget {
  const Highlight({
    super.key,
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: color,
    );
  }
}

class MoveDest extends StatelessWidget {
  const MoveDest({
    super.key,
    required this.color,
    required this.size,
    this.occupied = false,
  });

  final Color color;
  final double size;
  final bool occupied;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: occupied
          ? Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size / 3),
                border: Border.all(
                  color: color,
                  width: size / 12,
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.all(size / 3),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
    );
  }
}

class Arrow extends StatelessWidget {
  const Arrow({
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
    final lineWidth = size.width / 28;
    final paint = Paint()
      ..strokeWidth = lineWidth
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final squareSize = size.width / 8;
    final shift = Offset(squareSize / 2, squareSize / 2);
    final from = fromCoord.offset(orientation, squareSize) + shift;
    final to = toCoord.offset(orientation, squareSize) + shift;

    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    final arrowSize = 1.5 * lineWidth;
    const arrowAngle = math.pi / 6;

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

    final transparentPaint = Paint()..color = color.withOpacity(0.35);
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      transparentPaint,
    );

    canvas.drawLine(from, to, paint);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) {
    return color != oldDelegate.color ||
        fromCoord != oldDelegate.fromCoord ||
        toCoord != oldDelegate.toCoord;
  }
}
