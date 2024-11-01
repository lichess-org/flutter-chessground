import 'package:chessground/src/widgets/coordinate.dart';
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
    return CustomPaint(
      painter: _SolidColorChessboardPainter(
        lightSquare: lightSquare,
        darkSquare: darkSquare,
        coordinates: coordinates,
        orientation: orientation,
      ),
    );
  }
}

class _SolidColorChessboardPainter extends CustomPainter {
  _SolidColorChessboardPainter({
    required this.lightSquare,
    required this.darkSquare,
    required this.coordinates,
    required this.orientation,
  });

  final Color lightSquare;
  final Color darkSquare;
  final bool coordinates;
  final Side orientation;

  @override
  void paint(Canvas canvas, Size size) {
    final squareSize = size.shortestSide / 8;
    for (var rank = 0; rank < 8; rank++) {
      for (var file = 0; file < 8; file++) {
        final square = Rect.fromLTWH(
          file * squareSize,
          rank * squareSize,
          squareSize,
          squareSize,
        );
        final paint = Paint()
          ..color = (rank + file).isEven ? lightSquare : darkSquare;
        canvas.drawRect(square, paint);
        if (coordinates && (file == 7 || rank == 7)) {
          final coordStyle = TextStyle(
            inherit: false,
            fontWeight: FontWeight.bold,
            fontSize: 10.0,
            color: (rank + file).isEven ? darkSquare : lightSquare,
            fontFamily: 'Roboto',
            height: 1.0,
          );
          if (file == 7) {
            final coord = TextPainter(
              text: TextSpan(
                text: orientation == Side.white ? '${8 - rank}' : '${rank + 1}',
                style: coordStyle,
              ),
              textDirection: TextDirection.ltr,
            );
            coord.layout();
            const edgeOffset = 2.0;
            final offset = Offset(
              file * squareSize + (squareSize - coord.width) - edgeOffset,
              rank * squareSize + edgeOffset,
            );
            coord.paint(canvas, offset);
          }
          if (rank == 7) {
            final coord = TextPainter(
              text: TextSpan(
                text: orientation == Side.white
                    ? String.fromCharCode(97 + file)
                    : String.fromCharCode(97 + 7 - file),
                style: coordStyle,
              ),
              textDirection: TextDirection.ltr,
            );
            coord.layout();
            const edgeOffset = 2.0;
            final offset = Offset(
              file * squareSize + edgeOffset,
              rank * squareSize + (squareSize - coord.height) - edgeOffset,
            );
            coord.paint(canvas, offset);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
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
            alignment: Alignment.topLeft,
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
                        child: InnerBoardCoordinate(
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
