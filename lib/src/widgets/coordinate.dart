import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';

const _coordStyle = TextStyle(
  inherit: false,
  fontWeight: FontWeight.bold,
  fontSize: 12.0,
  fontFamily: 'Roboto',
  height: 1.0,
  color: Color(0x99FFFFFF),
);

/// A widget that displays the rank coordinates of a chess board.
class BorderRankCoordinates extends StatelessWidget {
  const BorderRankCoordinates({
    required this.orientation,
    required this.width,
    required this.height,
    super.key,
  });

  final Side orientation;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ranks = orientation == Side.white ? '87654321' : '12345678';
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        textDirection: TextDirection.ltr,
        children: [
          for (final rank in ranks.split(''))
            Expanded(
              child: Center(
                child: Text(
                  rank,
                  style: _coordStyle,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A widget that displays the file coordinates of a chess board.
class BorderFileCoordinates extends StatelessWidget {
  const BorderFileCoordinates({
    required this.orientation,
    required this.width,
    required this.height,
    super.key,
  });

  final Side orientation;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final files = orientation == Side.white ? 'abcdefgh' : 'hgfedcba';
    return SizedBox(
      height: height,
      width: width,
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          for (final file in files.split(''))
            Expanded(
              child: Center(
                child: Text(
                  file,
                  style: _coordStyle,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
