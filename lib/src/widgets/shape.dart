import 'dart:math' as math;
import 'package:flutter/widgets.dart';

import '../models.dart';
import 'positioned_square.dart';

class ShapeWidget extends StatelessWidget {
  const ShapeWidget({
    super.key,
    required this.shape,
    required this.boardSize,
    required this.orientation,
  });

  final Shape shape;
  final double boardSize;
  final Side orientation;

  double get squareSize => boardSize / 8;

  @override
  Widget build(BuildContext context) {
    return switch (shape) {
      Arrow(
        color: final color,
        orig: final orig,
        dest: final dest,
      ) =>
        SizedBox.square(
          dimension: boardSize,
          child: CustomPaint(
            painter: _ArrowPainter(
              color,
              orientation,
              Coord.fromSquareId(orig),
              Coord.fromSquareId(dest),
            ),
          ),
        ),
      Circle(color: final color, orig: final orig) => SizedBox.square(
          dimension: boardSize,
          child: CustomPaint(
            painter:
                _CirclePainter(color, orientation, Coord.fromSquareId(orig)),
          ),
        ),
      PieceShape(orig: final orig, role: final role, color: final color) =>
        PositionedSquare(
          size: squareSize,
          orientation: orientation,
          squareId: orig,
          child: Image.asset(
            'assets/piece_sets/mono/${role.letter}.png',
            package: 'chessground',
            color: color,
            width: squareSize,
            height: squareSize,
          ),
        ),
    };
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
    final margin = squareSize / 3;

    final angle =
        math.atan2(toOffset.dy - fromOffset.dy, toOffset.dx - fromOffset.dx);
    final fromMarginOffset =
        Offset(margin * math.cos(angle), margin * math.sin(angle));
    final arrowSize = squareSize * 0.48;
    const arrowAngle = math.pi / 5;

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

    final arrowHeight = arrowSize * math.sin((math.pi - (arrowAngle * 2)) / 2);
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
        orientation != oldDelegate.orientation ||
        fromCoord != oldDelegate.fromCoord ||
        toCoord != oldDelegate.toCoord;
  }
}

class _CirclePainter extends CustomPainter {
  _CirclePainter(this.color, this.orientation, this.circleCoord);
  final Color color;
  final Side orientation;
  final Coord circleCoord;

  @override
  void paint(Canvas canvas, Size size) {
    final squareSize = size.width / 8;
    final lineWidth = squareSize / 16;
    final paint = Paint()
      ..strokeWidth = lineWidth
      ..color = color
      ..style = PaintingStyle.stroke;

    final circle = Path()
      ..addOval(
        Rect.fromCircle(
          center: circleCoord.offset(orientation, squareSize) +
              Offset(squareSize / 2, squareSize / 2),
          radius: squareSize / 2 - lineWidth / 2,
        ),
      );
    canvas.drawPath(circle, paint);
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) {
    return color != oldDelegate.color || orientation != oldDelegate.orientation;
  }
}
