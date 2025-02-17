import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../models.dart';

/// A square highlight on the board.
///
/// This is useful to indicate interesting squares on the board, such as the last
/// move, a check, or a selected piece.
class SquareHighlight extends StatelessWidget {
  const SquareHighlight({super.key, required this.details});

  final HighlightDetails details;

  @override
  Widget build(BuildContext context) {
    if (details.image != null) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: details.image!, fit: BoxFit.cover),
        ),
        color: details.solidColor,
      );
    }
    return Container(color: details.solidColor);
  }
}

/// A widget that displays a check highlight.
///
/// Check highlights are used to indicate that a king is in check.
class CheckHighlight extends StatelessWidget {
  const CheckHighlight({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: ClipRect(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size),
              gradient: const RadialGradient(
                radius: 0.6,
                colors: [
                  Color(0xFFFF0000),
                  Color(0xFFE70000),
                  Color(0x00A90000),
                  Color(0x009E0000),
                ],
                stops: [0.0, 0.25, 0.90, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A widget that displays a valid move destination highlight.
///
/// This is used to indicate where a piece can move to on the board.
class ValidMoveHighlight extends StatelessWidget {
  const ValidMoveHighlight({
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
    return occupied
        ? OccupiedValidMoveHighlight(color: color, size: size)
        : SizedBox.square(
          dimension: size,
          child: Padding(
            padding: EdgeInsets.all(size / 3),
            child: Container(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        );
  }
}

/// A widget that displays an occupied move destination highlight.
///
/// Occupied move destinations are used to indicate where a piece can move to
/// on a square that is already occupied by a piece.
class OccupiedValidMoveHighlight extends StatelessWidget {
  const OccupiedValidMoveHighlight({
    super.key,
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _OccupiedMoveDestPainter(color)),
    );
  }
}

class _OccupiedMoveDestPainter extends CustomPainter {
  _OccupiedMoveDestPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = size.width / 5
          ..style = PaintingStyle.stroke;

    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width - (size.width / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(_OccupiedMoveDestPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
