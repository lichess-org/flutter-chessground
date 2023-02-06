import 'package:flutter/widgets.dart';
import '../models.dart';

/// Board background
///
/// Use the static const members to ensure flutter doesn't rebuild the board more
/// than once
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

  static const brown = SolidColorBackground(
    lightSquare: Color(0xfff0d9b6),
    darkSquare: Color(0xffb58863),
  );
  static const brownWhiteCoords = SolidColorBackground(
    lightSquare: Color(0xfff0d9b6),
    darkSquare: Color(0xffb58863),
    coordinates: true,
  );
  static const brownBlackCoords = SolidColorBackground(
    lightSquare: Color(0xfff0d9b6),
    darkSquare: Color(0xffb58863),
    coordinates: true,
    orientation: Side.black,
  );
  static const blue = SolidColorBackground(
    lightSquare: Color(0xffdee3e6),
    darkSquare: Color(0xff8ca2ad),
  );
  static const blueWhiteCoords = SolidColorBackground(
    lightSquare: Color(0xffdee3e6),
    darkSquare: Color(0xff8ca2ad),
    coordinates: true,
  );
  static const blueBlackCoords = SolidColorBackground(
    lightSquare: Color(0xffdee3e6),
    darkSquare: Color(0xff8ca2ad),
    coordinates: true,
    orientation: Side.black,
  );
  static const green = SolidColorBackground(
    lightSquare: Color(0xffffffdd),
    darkSquare: Color(0xff86a666),
  );
  static const greenWhiteCoords = SolidColorBackground(
    lightSquare: Color(0xffffffdd),
    darkSquare: Color(0xff86a666),
    coordinates: true,
  );
  static const greenBlackCoords = SolidColorBackground(
    lightSquare: Color(0xffffffdd),
    darkSquare: Color(0xff86a666),
    coordinates: true,
    orientation: Side.black,
  );
  static const horsey = ImageBackground(
    image: AssetImage('lib/boards/horsey.jpg', package: 'chessground'),
    lightSquare: Color(0xfff6eedb),
    darkSquare: Color(0xff8e6547),
  );
  static const horseyWhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/horsey.jpg', package: 'chessground'),
    lightSquare: Color(0xfff6eedb),
    darkSquare: Color(0xff8e6547),
    coordinates: true,
  );
  static const horseyBlackCoords = ImageBackground(
    image: AssetImage('lib/boards/horsey.jpg', package: 'chessground'),
    lightSquare: Color(0xfff6eedb),
    darkSquare: Color(0xff8e6547),
    coordinates: true,
    orientation: Side.black,
  );
  static const wood4 = ImageBackground(
    image: AssetImage('lib/boards/wood4.jpg', package: 'chessground'),
    lightSquare: Color(0xffcbad79),
    darkSquare: Color(0xff895d36),
  );
  static const wood4WhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/wood4.jpg', package: 'chessground'),
    lightSquare: Color(0xffcbad79),
    darkSquare: Color(0xff895d36),
    coordinates: true,
  );
  static const wood4BlackCoords = ImageBackground(
    image: AssetImage('lib/boards/wood4.jpg', package: 'chessground'),
    lightSquare: Color(0xffcbad79),
    darkSquare: Color(0xff895d36),
    coordinates: true,
    orientation: Side.black,
  );
}

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
                      color: (rank + file).isEven ? lightSquare : darkSquare,
                    ),
                    child: coordinates
                        ? Coordinate(
                            rank: rank,
                            file: file,
                            orientation: orientation,
                            color:
                                (rank + file).isEven ? darkSquare : lightSquare,
                          )
                        : null,
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
    return SizedBox.expand(
      child: Stack(
        children: [
          Image(image: image),
          Column(
            children: List.generate(
              8,
              (rank) => Expanded(
                child: Row(
                  children: List.generate(
                    8,
                    (file) => Expanded(
                      child: SizedBox.expand(
                        child: coordinates
                            ? Coordinate(
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
    );
  }
}

class Coordinate extends StatelessWidget {
  const Coordinate({
    super.key,
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
      fontWeight: FontWeight.bold,
      fontSize: 11.0,
      color: color,
      fontFamily: 'Roboto',
    );
    return Stack(
      children: [
        if (file == 7)
          Align(
            alignment: Alignment.topRight,
            child: Text(
              orientation == Side.white ? '${8 - rank}' : '${rank + 1}',
              style: coordStyle,
            ),
          ),
        if (rank == 7)
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              orientation == Side.white
                  ? String.fromCharCode(97 + file)
                  : String.fromCharCode(97 + 7 - file),
              style: coordStyle,
            ),
          ),
      ],
    );
  }
}
