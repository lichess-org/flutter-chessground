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
  static const blue2 = ImageBackground(
    image: AssetImage('lib/boards/blue2.jpg', package: 'chessground'),
    lightSquare: Color(0xff97b2c7),
    darkSquare: Color(0xff546f82),
  );
  static const blue2WhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/blue2.jpg', package: 'chessground'),
    lightSquare: Color(0xff97b2c7),
    darkSquare: Color(0xff546f82),
    coordinates: true,
  );
  static const blue2BlackCoords = ImageBackground(
    image: AssetImage('lib/boards/blue2.jpg', package: 'chessground'),
    lightSquare: Color(0xff97b2c7),
    darkSquare: Color(0xff546f82),
    coordinates: true,
    orientation: Side.black,
  );
  static const blue3 = ImageBackground(
    image: AssetImage('lib/boards/blue3.jpg', package: 'chessground'),
    lightSquare: Color(0xffd9e0e6),
    darkSquare: Color(0xff315991),
  );
  static const blue3WhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/blue3.jpg', package: 'chessground'),
    lightSquare: Color(0xffd9e0e6),
    darkSquare: Color(0xff315991),
    coordinates: true,
  );
  static const blue3BlackCoords = ImageBackground(
    image: AssetImage('lib/boards/blue3.jpg', package: 'chessground'),
    lightSquare: Color(0xffd9e0e6),
    darkSquare: Color(0xff315991),
    coordinates: true,
    orientation: Side.black,
  );
  static const blueMarble = ImageBackground(
    image: AssetImage('lib/boards/blue-marble.jpg', package: 'chessground'),
    lightSquare: Color(0xffeae6dd),
    darkSquare: Color(0xff7c7f87),
  );
  static const blueMarbleWhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/blue-marble.jpg', package: 'chessground'),
    lightSquare: Color(0xffeae6dd),
    darkSquare: Color(0xff7c7f87),
    coordinates: true,
  );
  static const blueMarbleBlackCoords = ImageBackground(
    image: AssetImage('lib/boards/blue-marble.jpg', package: 'chessground'),
    lightSquare: Color(0xffeae6dd),
    darkSquare: Color(0xff7c7f87),
    coordinates: true,
    orientation: Side.black,
  );
  static const canvas2 = ImageBackground(
    image: AssetImage('lib/boards/canvas2.jpg', package: 'chessground'),
    lightSquare: Color(0xffd7daeb),
    darkSquare: Color(0xff547388),
  );
  static const canvas2WhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/canvas2.jpg', package: 'chessground'),
    lightSquare: Color(0xffd7daeb),
    darkSquare: Color(0xff547388),
    coordinates: true,
  );
  static const canvas2BlackCoords = ImageBackground(
    image: AssetImage('lib/boards/canvas2.jpg', package: 'chessground'),
    lightSquare: Color(0xffd7daeb),
    darkSquare: Color(0xff547388),
    coordinates: true,
    orientation: Side.black,
  );
  static const greenPlastic = ImageBackground(
    image: AssetImage('lib/boards/green-plastic.png', package: 'chessground'),
    lightSquare: Color(0xfff2f9bb),
    darkSquare: Color(0xff59935d),
  );
  static const greenPlasticWhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/green-plastic.png', package: 'chessground'),
    lightSquare: Color(0xfff2f9bb),
    darkSquare: Color(0xff59935d),
    coordinates: true,
  );
  static const greenPlasticBlackCoords = ImageBackground(
    image: AssetImage('lib/boards/green-plastic.png', package: 'chessground'),
    lightSquare: Color(0xfff2f9bb),
    darkSquare: Color(0xff59935d),
    coordinates: true,
    orientation: Side.black,
  );
  static const grey = ImageBackground(
    image: AssetImage('lib/boards/grey.jpg', package: 'chessground'),
    lightSquare: Color(0xffb8b8b8),
    darkSquare: Color(0xff7d7d7d),
  );
  static const greyWhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/grey.jpg', package: 'chessground'),
    lightSquare: Color(0xffb8b8b8),
    darkSquare: Color(0xff7d7d7d),
    coordinates: true,
  );
  static const greyBlackCoords = ImageBackground(
    image: AssetImage('lib/boards/grey.jpg', package: 'chessground'),
    lightSquare: Color(0xffb8b8b8),
    darkSquare: Color(0xff7d7d7d),
    coordinates: true,
    orientation: Side.black,
  );
  static const horsey = ImageBackground(
    image: AssetImage('lib/boards/horsey.jpg', package: 'chessground'),
    lightSquare: Color(0xfff0d9b5),
    darkSquare: Color(0xff946f51),
  );
  static const horseyWhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/horsey.jpg', package: 'chessground'),
    lightSquare: Color(0xfff0d9b5),
    darkSquare: Color(0xff946f51),
    coordinates: true,
  );
  static const horseyBlackCoords = ImageBackground(
    image: AssetImage('lib/boards/horsey.jpg', package: 'chessground'),
    lightSquare: Color(0xfff0d9b5),
    darkSquare: Color(0xff946f51),
    coordinates: true,
    orientation: Side.black,
  );
  static const leather = ImageBackground(
    image: AssetImage('lib/boards/leather.jpg', package: 'chessground'),
    lightSquare: Color(0xffd1d1c9),
    darkSquare: Color(0xffc28e16),
  );
  static const leatherWhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/leather.jpg', package: 'chessground'),
    lightSquare: Color(0xffd1d1c9),
    darkSquare: Color(0xffc28e16),
    coordinates: true,
  );
  static const leatherBlackCoords = ImageBackground(
    image: AssetImage('lib/boards/leather.jpg', package: 'chessground'),
    lightSquare: Color(0xffd1d1c9),
    darkSquare: Color(0xffc28e16),
    coordinates: true,
    orientation: Side.black,
  );
  static const maple = ImageBackground(
    image: AssetImage('lib/boards/maple.jpg', package: 'chessground'),
    lightSquare: Color(0xffe8ceab),
    darkSquare: Color(0xffbc7944),
  );
  static const mapleWhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/maple.jpg', package: 'chessground'),
    lightSquare: Color(0xffe8ceab),
    darkSquare: Color(0xffbc7944),
    coordinates: true,
  );
  static const mapleBlackCoords = ImageBackground(
    image: AssetImage('lib/boards/maple.jpg', package: 'chessground'),
    lightSquare: Color(0xffe8ceab),
    darkSquare: Color(0xffbc7944),
    coordinates: true,
    orientation: Side.black,
  );
  static const maple2 = ImageBackground(
    image: AssetImage('lib/boards/maple2.jpg', package: 'chessground'),
    lightSquare: Color(0xffe2c89f),
    darkSquare: Color(0xff996633),
  );
  static const maple2WhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/maple2.jpg', package: 'chessground'),
    lightSquare: Color(0xffe2c89f),
    darkSquare: Color(0xff996633),
    coordinates: true,
  );
  static const maple2BlackCoords = ImageBackground(
    image: AssetImage('lib/boards/maple2.jpg', package: 'chessground'),
    lightSquare: Color(0xffe2c89f),
    darkSquare: Color(0xff996633),
    coordinates: true,
    orientation: Side.black,
  );
  static const marble = ImageBackground(
    image: AssetImage('lib/boards/marble.jpg', package: 'chessground'),
    lightSquare: Color(0xff93ab91),
    darkSquare: Color(0xff4f644e),
  );
  static const marbleWhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/marble.jpg', package: 'chessground'),
    lightSquare: Color(0xff93ab91),
    darkSquare: Color(0xff4f644e),
    coordinates: true,
  );
  static const marbleBlackCoords = ImageBackground(
    image: AssetImage('lib/boards/marble.jpg', package: 'chessground'),
    lightSquare: Color(0xff93ab91),
    darkSquare: Color(0xff4f644e),
    coordinates: true,
    orientation: Side.black,
  );
  static const metal = ImageBackground(
    image: AssetImage('lib/boards/metal.jpg', package: 'chessground'),
    lightSquare: Color(0xffc9c9c9),
    darkSquare: Color(0xff727272),
  );
  static const metalWhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/metal.jpg', package: 'chessground'),
    lightSquare: Color(0xffc9c9c9),
    darkSquare: Color(0xff727272),
    coordinates: true,
  );
  static const metalBlackCoords = ImageBackground(
    image: AssetImage('lib/boards/metal.jpg', package: 'chessground'),
    lightSquare: Color(0xffc9c9c9),
    darkSquare: Color(0xff727272),
    coordinates: true,
    orientation: Side.black,
  );
  static const ncf = ImageBackground(
    image: AssetImage('lib/boards/ncf-board.png', package: 'chessground'),
    lightSquare: Color(0xffBBCFFF),
    darkSquare: Color(0xff5477CA),
  );
  static const ncfWhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/ncf-board.png', package: 'chessground'),
    lightSquare: Color(0xffBBCFFF),
    darkSquare: Color(0xff5477CA),
    coordinates: true,
  );
  static const ncfBlackCoords = ImageBackground(
    image: AssetImage('lib/boards/ncf-board.png', package: 'chessground'),
    lightSquare: Color(0xffBBCFFF),
    darkSquare: Color(0xff5477CA),
    coordinates: true,
    orientation: Side.black,
  );
  static const newspaper = ImageBackground(
    image: AssetImage('lib/boards/newspaper.png', package: 'chessground'),
    lightSquare: Color(0xffffffff),
    darkSquare: Color(0xff8d8d8d),
  );
  static const newspaperWhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/newspaper.png', package: 'chessground'),
    lightSquare: Color(0xffffffff),
    darkSquare: Color(0xff8d8d8d),
    coordinates: true,
  );
  static const newspaperBlackCoords = ImageBackground(
    image: AssetImage('lib/boards/newspaper.png', package: 'chessground'),
    lightSquare: Color(0xffffffff),
    darkSquare: Color(0xff8d8d8d),
    coordinates: true,
    orientation: Side.black,
  );
  static const olive = ImageBackground(
    image: AssetImage('lib/boards/olive.jpg', package: 'chessground'),
    lightSquare: Color(0xffb8b19f),
    darkSquare: Color(0xff6d6655),
  );
  static const oliveWhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/olive.jpg', package: 'chessground'),
    lightSquare: Color(0xffb8b19f),
    darkSquare: Color(0xff6d6655),
    coordinates: true,
  );
  static const oliveBlackCoords = ImageBackground(
    image: AssetImage('lib/boards/olive.jpg', package: 'chessground'),
    lightSquare: Color(0xffb8b19f),
    darkSquare: Color(0xff6d6655),
    coordinates: true,
    orientation: Side.black,
  );
  static const pinkPyramid = ImageBackground(
    image: AssetImage('lib/boards/pink-pyramid.png', package: 'chessground'),
    lightSquare: Color(0xffe8e9b7),
    darkSquare: Color(0xffed7272),
  );
  static const pinkPyramidWhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/pink-pyramid.png', package: 'chessground'),
    lightSquare: Color(0xffe8e9b7),
    darkSquare: Color(0xffed7272),
    coordinates: true,
  );
  static const pinkPyramidBlackCoords = ImageBackground(
    image: AssetImage('lib/boards/pink-pyramid.png', package: 'chessground'),
    lightSquare: Color(0xffe8e9b7),
    darkSquare: Color(0xffed7272),
    coordinates: true,
    orientation: Side.black,
  );
  static const purpleDiag = ImageBackground(
    image: AssetImage('lib/boards/purple-diag.png', package: 'chessground'),
    lightSquare: Color(0xffe5daf0),
    darkSquare: Color(0xff957ab0),
  );
  static const purpleDiagWhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/purple-diag.png', package: 'chessground'),
    lightSquare: Color(0xffe5daf0),
    darkSquare: Color(0xff957ab0),
    coordinates: true,
  );
  static const purpleDiagBlackCoords = ImageBackground(
    image: AssetImage('lib/boards/purple-diag.png', package: 'chessground'),
    lightSquare: Color(0xffe5daf0),
    darkSquare: Color(0xff957ab0),
    coordinates: true,
    orientation: Side.black,
  );
  static const wood = ImageBackground(
    image: AssetImage('lib/boards/wood.jpg', package: 'chessground'),
    lightSquare: Color(0xffd8a45b),
    darkSquare: Color(0xff9b4d0f),
  );
  static const woodWhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/wood.jpg', package: 'chessground'),
    lightSquare: Color(0xffd8a45b),
    darkSquare: Color(0xff9b4d0f),
    coordinates: true,
  );
  static const woodBlackCoords = ImageBackground(
    image: AssetImage('lib/boards/wood.jpg', package: 'chessground'),
    lightSquare: Color(0xffd8a45b),
    darkSquare: Color(0xff9b4d0f),
    coordinates: true,
    orientation: Side.black,
  );
  static const wood2 = ImageBackground(
    image: AssetImage('lib/boards/wood2.jpg', package: 'chessground'),
    lightSquare: Color(0xffa38b5d),
    darkSquare: Color(0xff6c5017),
  );
  static const wood2WhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/wood2.jpg', package: 'chessground'),
    lightSquare: Color(0xffa38b5d),
    darkSquare: Color(0xff6c5017),
    coordinates: true,
  );
  static const wood2BlackCoords = ImageBackground(
    image: AssetImage('lib/boards/wood2.jpg', package: 'chessground'),
    lightSquare: Color(0xffa38b5d),
    darkSquare: Color(0xff6c5017),
    coordinates: true,
    orientation: Side.black,
  );
  static const wood3 = ImageBackground(
    image: AssetImage('lib/boards/wood3.jpg', package: 'chessground'),
    lightSquare: Color(0xffd0ceca),
    darkSquare: Color(0xff755839),
  );
  static const wood3WhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/wood3.jpg', package: 'chessground'),
    lightSquare: Color(0xffd0ceca),
    darkSquare: Color(0xff755839),
    coordinates: true,
  );
  static const wood3BlackCoords = ImageBackground(
    image: AssetImage('lib/boards/wood3.jpg', package: 'chessground'),
    lightSquare: Color(0xffd0ceca),
    darkSquare: Color(0xff755839),
    coordinates: true,
    orientation: Side.black,
  );
  static const wood4 = ImageBackground(
    image: AssetImage('lib/boards/wood4.jpg', package: 'chessground'),
    lightSquare: Color(0xffcaaf7d),
    darkSquare: Color(0xff7b5330),
  );
  static const wood4WhiteCoords = ImageBackground(
    image: AssetImage('lib/boards/wood4.jpg', package: 'chessground'),
    lightSquare: Color(0xffcaaf7d),
    darkSquare: Color(0xff7b5330),
    coordinates: true,
  );
  static const wood4BlackCoords = ImageBackground(
    image: AssetImage('lib/boards/wood4.jpg', package: 'chessground'),
    lightSquare: Color(0xffcaaf7d),
    darkSquare: Color(0xff7b5330),
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
