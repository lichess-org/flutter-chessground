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

class InnerBoardCoordinate extends StatelessWidget {
  const InnerBoardCoordinate({
    required this.rank,
    required this.file,
    required this.color,
    required this.orientation,
    super.key,
  });

  final int rank;
  final int file;
  final Color color;
  final Side orientation;

  @override
  Widget build(BuildContext context) {
    final coordStyle = TextStyle(
      inherit: false,
      fontWeight: FontWeight.bold,
      fontSize: 10.0,
      color: color,
      fontFamily: 'Roboto',
      height: 1.0,
    );
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        if (file == 7)
          Positioned(
            top: 2.0,
            right: 2.0,
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                textDirection: TextDirection.ltr,
                orientation == Side.white ? '${8 - rank}' : '${rank + 1}',
                style: coordStyle,
                textScaler: TextScaler.noScaling,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (rank == 7)
          Positioned(
            bottom: 2.0,
            left: 2.0,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                textDirection: TextDirection.ltr,
                orientation == Side.white
                    ? String.fromCharCode(97 + file)
                    : String.fromCharCode(97 + 7 - file),
                style: coordStyle,
                textScaler: TextScaler.noScaling,
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
