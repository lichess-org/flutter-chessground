import 'dart:math' as math;
import 'package:chessground/src/widgets/geometry.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';

import '../models.dart';
import 'positioned_square.dart';

/// A Widget that displays a shape overlay on the board.
///
/// Typically used to display arrows, circles, and piece masks on the board.
class ShapeWidget extends StatelessWidget with ChessboardGeometry {
  const ShapeWidget({
    super.key,
    required this.shape,
    required this.size,
    required this.orientation,
  });

  /// The shape to display on the board.
  ///
  /// Currently supported shapes are [Arrow], [Circle], and [PieceShape].
  final Shape shape;

  @override
  final double size;

  @override
  final Side orientation;

  @override
  Widget build(BuildContext context) {
    return switch (shape) {
      Arrow(
        color: final color,
        orig: final orig,
        dest: final dest,
        scale: final scale,
      ) =>
        SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _ArrowPainter(
              color,
              orientation,
              squareOffset(orig),
              squareOffset(dest),
              scale,
            ),
          ),
        ),
      Circle(color: final color, orig: final orig, scale: final scale) =>
        SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _CirclePainter(
              color,
              orientation,
              squareOffset(orig),
              scale,
            ),
          ),
        ),
      PieceShape(
        orig: final orig,
        role: final role,
        color: final color,
        scale: final scale
      ) =>
        PositionedSquare(
          size: size,
          orientation: orientation,
          square: orig,
          child: Image.asset(
            'assets/piece_sets/mono/${role.uppercaseLetter}.png',
            package: 'chessground',
            color: color,
            width: scale * squareSize,
            height: scale * squareSize,
          ),
        ),
    };
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter(
    this.color,
    this.orientation,
    this.fromOffset,
    this.toOffset,
    this.scale,
  );

  final Color color;
  final Side orientation;
  final Offset fromOffset;
  final Offset toOffset;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final squareSize = size.width / 8;
    final lineWidth = scale * squareSize / 4;
    final paint = Paint()
      ..strokeWidth = lineWidth
      ..color = color
      ..style = PaintingStyle.stroke;

    final shift = Offset(squareSize / 2, squareSize / 2);
    final margin = squareSize / 3;

    final angle =
        math.atan2(toOffset.dy - fromOffset.dy, toOffset.dx - fromOffset.dx);
    final fromMarginOffset =
        Offset(margin * math.cos(angle), margin * math.sin(angle));
    final arrowSize = scale * squareSize * 0.48;
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
        fromOffset != oldDelegate.fromOffset ||
        toOffset != oldDelegate.toOffset ||
        scale != oldDelegate.scale;
  }
}

class _CirclePainter extends CustomPainter {
  _CirclePainter(this.color, this.orientation, this.circleOffset, this.scale);
  final Color color;
  final Side orientation;
  final Offset circleOffset;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final squareSize = size.width / 8;
    final lineWidth = scale * squareSize / 16;
    final paint = Paint()
      ..strokeWidth = lineWidth
      ..color = color
      ..style = PaintingStyle.stroke;

    final circle = Path()
      ..addOval(
        Rect.fromCircle(
          center: circleOffset + Offset(squareSize / 2, squareSize / 2),
          radius: squareSize / 2 - lineWidth / 2,
        ),
      );
    canvas.drawPath(circle, paint);
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) {
    return color != oldDelegate.color ||
        circleOffset != oldDelegate.circleOffset ||
        orientation != oldDelegate.orientation ||
        scale != oldDelegate.scale;
  }
}
