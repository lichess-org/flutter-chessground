import 'package:flutter/material.dart';

class Highlight extends StatelessWidget {
  const Highlight({
    Key? key,
    required this.color,
    required this.size,
  }) : super(key: key);

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
    Key? key,
    required this.color,
    required this.size,
    this.occupied = false,
  }) : super(key: key);

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
                borderRadius: BorderRadius.circular(size / 2),
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
