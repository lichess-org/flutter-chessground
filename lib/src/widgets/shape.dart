import 'dart:math' as math;
import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/widgets.dart';

import '../models.dart';
import 'positioned_square.dart';

/// A Widget that displays a shape overlay on the board.
///
/// Typically used to display arrows, circles, and piece masks on the board.
class ShapeWidget extends StatelessWidget {
  const ShapeWidget({
    super.key,
    required this.shape,
    required this.boardSize,
    required this.orientation,
  });

  /// The shape to display on the board.
  ///
  /// Currently supported shapes are [Arrow], [Circle], and [PieceShape].
  final Shape shape;

  /// Size of the board the shape will overlay.
  final double boardSize;

  /// Orientation of the board.
  final Side orientation;

  double get squareSize => boardSize / 8;

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
          dimension: boardSize,
          child: CustomPaint(
            painter: _ArrowPainter(
              color,
              orientation,
              orig.coord,
              dest.coord,
              scale,
            ),
          ),
        ),
      Circle(color: final color, orig: final orig, scale: final scale) =>
        SizedBox.square(
          dimension: boardSize,
          child: CustomPaint(
            painter: _CirclePainter(
              color,
              orientation,
              orig.coord,
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
          size: squareSize,
          orientation: orientation,
          squareId: orig,
          child: Image.asset(
            'assets/piece_sets/mono/${role.letter}.png',
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
    this.fromCoord,
    this.toCoord,
    this.scale,
  );

  final Color color;
  final Side orientation;
  final Coord fromCoord;
  final Coord toCoord;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final squareSize = size.width / 8;
    final lineWidth = scale * squareSize / 4;
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
        fromCoord != oldDelegate.fromCoord ||
        toCoord != oldDelegate.toCoord ||
        scale != oldDelegate.scale;
  }
}

class _CirclePainter extends CustomPainter {
  _CirclePainter(this.color, this.orientation, this.circleCoord, this.scale);
  final Color color;
  final Side orientation;
  final Coord circleCoord;
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
          center: circleCoord.offset(orientation, squareSize) +
              Offset(squareSize / 2, squareSize / 2),
          radius: squareSize / 2 - lineWidth / 2,
        ),
      );
    canvas.drawPath(circle, paint);
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) {
    return color != oldDelegate.color ||
        circleCoord != oldDelegate.circleCoord ||
        orientation != oldDelegate.orientation ||
        scale != oldDelegate.scale;
  }
}
