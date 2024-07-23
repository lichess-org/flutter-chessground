import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/widgets.dart';

/// Base widget for the background of the chessboard.
///
/// See [SolidColorBackground] and [ImageBackground] for concrete implementations.
abstract class Background extends StatelessWidget {
  const Background({
    super.key,
    this.coordinates = false,
    this.orientation = Side.white,
    required this.lightSquare,
    required this.darkSquare,
  });

  final bool coordinates;
  final Side orientation;
  final Color lightSquare;
  final Color darkSquare;
}

/// A chessboard background with solid color squares.
class SolidColorBackground extends Background {
  const SolidColorBackground({
    super.key,
    super.coordinates,
    super.orientation,
    required super.lightSquare,
    required super.darkSquare,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox.expand(
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
                      color: (rank + file).isEven ? lightSquare : darkSquare,
                      child: coordinates && (file == 7 || rank == 7)
                          ? _Coordinate(
                              rank: rank,
                              file: file,
                              orientation: orientation,
                              color: (rank + file).isEven
                                  ? darkSquare
                                  : lightSquare,
                            )
                          : null,
                    ),
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

/// A chessboard background made of an image.
class ImageBackground extends Background {
  const ImageBackground({
    super.key,
    super.coordinates,
    super.orientation,
    required super.lightSquare,
    required super.darkSquare,
    required this.image,
  });

  final AssetImage image;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox.expand(
        child: Stack(
          children: [
            Image(image: image),
            if (coordinates)
              Column(
                children: List.generate(
                  8,
                  (rank) => Expanded(
                    child: Row(
                      children: List.generate(
                        8,
                        (file) => Expanded(
                          child: SizedBox.expand(
                            child: rank == 7 || file == 7
                                ? _Coordinate(
                                    rank: rank,
                                    file: file,
                                    orientation: orientation,
                                    color: (rank + file).isEven
                                        ? darkSquare
                                        : lightSquare,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Coordinate extends StatelessWidget {
  const _Coordinate({
    required this.rank,
    required this.file,
    required this.color,
    required this.orientation,
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
      children: [
        if (file == 7)
          Positioned(
            top: 2.0,
            right: 2.0,
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
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
