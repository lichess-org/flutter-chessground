import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/widgets.dart';

/// Base widget for the background of the chessboard.
///
/// See [SolidColorChessboardBackground] and [ImageChessboardBackground] for concrete implementations.
abstract class ChessboardBackground extends StatelessWidget {
  const ChessboardBackground({
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
class SolidColorChessboardBackground extends ChessboardBackground {
  const SolidColorChessboardBackground({
    super.key,
    super.coordinates,
    super.orientation,
    required super.lightSquare,
    required super.darkSquare,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final squareSize = constraints.biggest.shortestSide / 8;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (var rank = 0; rank < 8; rank++)
              for (var file = 0; file < 8; file++)
                Positioned(
                  left: file * squareSize,
                  top: rank * squareSize,
                  child: Container(
                    width: squareSize,
                    height: squareSize,
                    color: (rank + file).isEven ? lightSquare : darkSquare,
                    child: coordinates && (file == 7 || rank == 7)
                        ? _Coordinate(
                            rank: rank,
                            file: file,
                            orientation: orientation,
                            color:
                                (rank + file).isEven ? darkSquare : lightSquare,
                          )
                        : null,
                  ),
                ),
          ],
        );
      },
    );
  }
}

/// A chessboard background made of an image.
class ImageChessboardBackground extends ChessboardBackground {
  const ImageChessboardBackground({
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
    if (coordinates) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final squareSize = constraints.biggest.shortestSide / 8;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Image(image: image),
              for (var rank = 0; rank < 8; rank++)
                for (var file = 0; file < 8; file++)
                  if (file == 7 || rank == 7)
                    Positioned(
                      left: file * squareSize,
                      top: rank * squareSize,
                      child: SizedBox(
                        width: squareSize,
                        height: squareSize,
                        child: _Coordinate(
                          rank: rank,
                          file: file,
                          orientation: orientation,
                          color:
                              (rank + file).isEven ? darkSquare : lightSquare,
                        ),
                      ),
                    ),
            ],
          );
        },
      );
    } else {
      return Image(image: image);
    }
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
