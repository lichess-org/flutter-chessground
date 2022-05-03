import 'package:flutter/material.dart';

@immutable
class Background extends StatelessWidget {
  final Color lightSquare;
  final Color darkSquare;

  const Background({
    Key? key,
    required this.lightSquare,
    required this.darkSquare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        children: List.generate(
          8,
          (rank) => Expanded(
            child: Row(
              children: List.generate(
                8,
                (file) => Expanded(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                        color: ((rank + file) % 2 == 0)
                            ? lightSquare
                            : darkSquare),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
