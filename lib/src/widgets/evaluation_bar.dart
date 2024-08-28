import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';

class EvaluationBar extends StatelessWidget {
  final double heigth;
  final double whiteBarHeight;

  const EvaluationBar({
    super.key,
    required this.heigth,
    required this.whiteBarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              height: heigth - whiteBarHeight,
              width: heigth * evaluationBarAspectRatio,
              child: ColoredBox(color: Colors.black.withOpacity(0.6)),
            ),
            SizedBox(
              height: whiteBarHeight,
              width: heigth * evaluationBarAspectRatio,
              child: ColoredBox(color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
        Center(
          child: SizedBox(
            height: heigth / 100,
            width: heigth * evaluationBarAspectRatio,
            child: const ColoredBox(color: Colors.red),
          ),
        )
      ],
    );
  }
}
