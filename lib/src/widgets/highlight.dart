import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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

class CheckHighlight extends StatelessWidget {
  const CheckHighlight({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size),
          border: Border.all(
            color: const Color(0xFFFF0000).withOpacity(0.25),
            width: size,
          ),
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
