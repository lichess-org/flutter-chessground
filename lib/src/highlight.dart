import 'package:flutter/material.dart';

class Highlight extends StatelessWidget {
  final Color color;
  final double size;

  const Highlight({
    Key? key,
    required this.color,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: color,
    );
  }
}
