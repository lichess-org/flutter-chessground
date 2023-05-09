import 'package:flutter/widgets.dart';
import './widgets/background.dart';
import './models.dart';

/// Describes the color scheme of a [Board].
///
/// Use the static const members to ensure flutter doesn't rebuild the board more
/// than once.
class BoardColorScheme {
  const BoardColorScheme({
    required this.lightSquare,
    required this.darkSquare,
    required this.background,
    required this.whiteCoordBackground,
    required this.blackCoordBackground,
    required this.lastMove,
    required this.selected,
    required this.validMoves,
    required this.validPremoves,
  });

  /// Light square color of the board
  final Color lightSquare;

  /// Dark square color of the board
  final Color darkSquare;

  /// Board background that defines light and dark square colors
  final Background background;

  /// Board background that defines light and dark square colors and with white
  /// facing coordinates included
  final Background whiteCoordBackground;

  /// Board background that defines light and dark square colors and with black
  /// facing coordinates included
  final Background blackCoordBackground;

  /// Color of highlighted last move
  final HighlightDetails lastMove;

  /// Color of highlighted selected square
  final HighlightDetails selected;

  /// Color of squares occupied with valid moves dots
  final Color validMoves;

  /// Color of squares occupied with valid premoves dots
  final Color validPremoves;

  static const brown = BoardColorScheme(
    lightSquare: Color(0xfff0d9b6),
    darkSquare: Color(0xffb58863),
    background: SolidColorBackground(
      lightSquare: Color(0xfff0d9b6),
      darkSquare: Color(0xffb58863),
    ),
    whiteCoordBackground: SolidColorBackground(
      lightSquare: Color(0xfff0d9b6),
      darkSquare: Color(0xffb58863),
      coordinates: true,
    ),
    blackCoordBackground: SolidColorBackground(
      lightSquare: Color(0xfff0d9b6),
      darkSquare: Color(0xffb58863),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const blue = BoardColorScheme(
    lightSquare: Color(0xffdee3e6),
    darkSquare: Color(0xff8ca2ad),
    background: SolidColorBackground(
      lightSquare: Color(0xffdee3e6),
      darkSquare: Color(0xff8ca2ad),
    ),
    whiteCoordBackground: SolidColorBackground(
      lightSquare: Color(0xffdee3e6),
      darkSquare: Color(0xff8ca2ad),
      coordinates: true,
    ),
    blackCoordBackground: SolidColorBackground(
      lightSquare: Color(0xffdee3e6),
      darkSquare: Color(0xff8ca2ad),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809bc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const green = BoardColorScheme(
    lightSquare: Color(0xffffffdd),
    darkSquare: Color(0xff86a666),
    background: SolidColorBackground(
      lightSquare: Color(0xffffffdd),
      darkSquare: Color(0xff86a666),
    ),
    whiteCoordBackground: SolidColorBackground(
      lightSquare: Color(0xffffffdd),
      darkSquare: Color(0xff86a666),
      coordinates: true,
    ),
    blackCoordBackground: SolidColorBackground(
      lightSquare: Color(0xffffffdd),
      darkSquare: Color(0xff86a666),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color.fromRGBO(0, 155, 199, 0.41)),
    selected: HighlightDetails(solidColor: Color.fromRGBO(216, 85, 0, 0.3)),
    validMoves: Color.fromRGBO(0, 0, 0, 0.20),
    validPremoves: Color(0x40203085),
  );

  static const blue2 = BoardColorScheme(
    lightSquare: Color(0xff97b2c7),
    darkSquare: Color(0xff546f82),
    background: ImageBackground(
      lightSquare: Color(0xff97b2c7),
      darkSquare: Color(0xff546f82),
      image: AssetImage('lib/boards/blue2.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xff97b2c7),
      darkSquare: Color(0xff546f82),
      image: AssetImage('lib/boards/blue2.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xff97b2c7),
      darkSquare: Color(0xff546f82),
      image: AssetImage('lib/boards/blue2.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const blue3 = BoardColorScheme(
    lightSquare: Color(0xffd9e0e6),
    darkSquare: Color(0xff315991),
    background: ImageBackground(
      lightSquare: Color(0xffd9e0e6),
      darkSquare: Color(0xff315991),
      image: AssetImage('lib/boards/blue3.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xffd9e0e6),
      darkSquare: Color(0xff315991),
      image: AssetImage('lib/boards/blue3.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xffd9e0e6),
      darkSquare: Color(0xff315991),
      image: AssetImage('lib/boards/blue3.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const blueMarble = BoardColorScheme(
    lightSquare: Color(0xffeae6dd),
    darkSquare: Color(0xff7c7f87),
    background: ImageBackground(
      lightSquare: Color(0xffeae6dd),
      darkSquare: Color(0xff7c7f87),
      image: AssetImage('lib/boards/blue-marble.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xffeae6dd),
      darkSquare: Color(0xff7c7f87),
      image: AssetImage('lib/boards/blue-marble.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xffeae6dd),
      darkSquare: Color(0xff7c7f87),
      image: AssetImage('lib/boards/blue-marble.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const canvas = BoardColorScheme(
    lightSquare: Color(0xffd7daeb),
    darkSquare: Color(0xff547388),
    background: ImageBackground(
      lightSquare: Color(0xffd7daeb),
      darkSquare: Color(0xff547388),
      image: AssetImage('lib/boards/canvas2.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xffd7daeb),
      darkSquare: Color(0xff547388),
      image: AssetImage('lib/boards/canvas2.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xffd7daeb),
      darkSquare: Color(0xff547388),
      image: AssetImage('lib/boards/canvas2.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const greenPlastic = BoardColorScheme(
    lightSquare: Color(0xfff2f9bb),
    darkSquare: Color(0xff59935d),
    background: ImageBackground(
      lightSquare: Color(0xfff2f9bb),
      darkSquare: Color(0xff59935d),
      image: AssetImage('lib/boards/green-plastic.png', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xfff2f9bb),
      darkSquare: Color(0xff59935d),
      image: AssetImage('lib/boards/green-plastic.png', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xfff2f9bb),
      darkSquare: Color(0xff59935d),
      image: AssetImage('lib/boards/green-plastic.png', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color.fromRGBO(0, 155, 199, 0.41)),
    selected: HighlightDetails(solidColor: Color.fromRGBO(216, 85, 0, 0.3)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const grey = BoardColorScheme(
    lightSquare: Color(0xffb8b8b8),
    darkSquare: Color(0xff7d7d7d),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    background: ImageBackground(
      lightSquare: Color(0xffb8b8b8),
      darkSquare: Color(0xff7d7d7d),
      image: AssetImage('lib/boards/grey.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xffb8b8b8),
      darkSquare: Color(0xff7d7d7d),
      image: AssetImage('lib/boards/grey.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xffb8b8b8),
      darkSquare: Color(0xff7d7d7d),
      image: AssetImage('lib/boards/grey.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const horsey = BoardColorScheme(
    lightSquare: Color(0xfff0d9b5),
    darkSquare: Color(0xff946f51),
    background: ImageBackground(
      lightSquare: Color(0xfff0d9b5),
      darkSquare: Color(0xff946f51),
      image: AssetImage('lib/boards/horsey.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xfff0d9b5),
      darkSquare: Color(0xff946f51),
      image: AssetImage('lib/boards/horsey.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xfff0d9b5),
      darkSquare: Color(0xff946f51),
      image: AssetImage('lib/boards/horsey.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(image: AssetImage('lib/boards/horsey.last-move.png', package: 'chessground')),
    selected: HighlightDetails(image: AssetImage('lib/boards/horsey.selected.png', package: 'chessground')),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const leather = BoardColorScheme(
    lightSquare: Color(0xffd1d1c9),
    darkSquare: Color(0xffc28e16),
    background: ImageBackground(
      lightSquare: Color(0xffd1d1c9),
      darkSquare: Color(0xffc28e16),
      image: AssetImage('lib/boards/leather.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xffd1d1c9),
      darkSquare: Color(0xffc28e16),
      image: AssetImage('lib/boards/leather.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xffd1d1c9),
      darkSquare: Color(0xffc28e16),
      image: AssetImage('lib/boards/leather.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const maple = BoardColorScheme(
    lightSquare: Color(0xffe8ceab),
    darkSquare: Color(0xffbc7944),
    background: ImageBackground(
      lightSquare: Color(0xffe8ceab),
      darkSquare: Color(0xffbc7944),
      image: AssetImage('lib/boards/maple.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xffe8ceab),
      darkSquare: Color(0xffbc7944),
      image: AssetImage('lib/boards/maple.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xffe8ceab),
      darkSquare: Color(0xffbc7944),
      image: AssetImage('lib/boards/maple.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const maple2 = BoardColorScheme(
    lightSquare: Color(0xffe2c89f),
    darkSquare: Color(0xff996633),
    background: ImageBackground(
      lightSquare: Color(0xffe2c89f),
      darkSquare: Color(0xff996633),
      image: AssetImage('lib/boards/maple2.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xffe2c89f),
      darkSquare: Color(0xff996633),
      image: AssetImage('lib/boards/maple2.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xffe2c89f),
      darkSquare: Color(0xff996633),
      image: AssetImage('lib/boards/maple2.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const marble = BoardColorScheme(
    lightSquare: Color(0xff93ab91),
    darkSquare: Color(0xff4f644e),
    background: ImageBackground(
      lightSquare: Color(0xff93ab91),
      darkSquare: Color(0xff4f644e),
      image: AssetImage('lib/boards/marble.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xff93ab91),
      darkSquare: Color(0xff4f644e),
      image: AssetImage('lib/boards/marble.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xff93ab91),
      darkSquare: Color(0xff4f644e),
      image: AssetImage('lib/boards/marble.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color.fromRGBO(0, 155, 199, 0.41)),
    selected: HighlightDetails(solidColor: Color.fromRGBO(216, 85, 0, 0.3)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const metal = BoardColorScheme(
    lightSquare: Color(0xffc9c9c9),
    darkSquare: Color(0xff727272),
    background: ImageBackground(
      lightSquare: Color(0xffc9c9c9),
      darkSquare: Color(0xff727272),
      image: AssetImage('lib/boards/metal.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xffc9c9c9),
      darkSquare: Color(0xff727272),
      image: AssetImage('lib/boards/metal.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xffc9c9c9),
      darkSquare: Color(0xff727272),
      image: AssetImage('lib/boards/metal.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const newspaper = BoardColorScheme(
    lightSquare: Color(0xffffffff),
    darkSquare: Color(0xff8d8d8d),
    background: ImageBackground(
      lightSquare: Color(0xffffffff),
      darkSquare: Color(0xff8d8d8d),
      image: AssetImage('lib/boards/newspaper.png', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xffffffff),
      darkSquare: Color(0xff8d8d8d),
      image: AssetImage('lib/boards/newspaper.png', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xffffffff),
      darkSquare: Color(0xff8d8d8d),
      image: AssetImage('lib/boards/newspaper.png', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const olive = BoardColorScheme(
    lightSquare: Color(0xffb8b19f),
    darkSquare: Color(0xff6d6655),
    background: ImageBackground(
      lightSquare: Color(0xffb8b19f),
      darkSquare: Color(0xff6d6655),
      image: AssetImage('lib/boards/olive.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xffb8b19f),
      darkSquare: Color(0xff6d6655),
      image: AssetImage('lib/boards/olive.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xffb8b19f),
      darkSquare: Color(0xff6d6655),
      image: AssetImage('lib/boards/olive.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const pinkPyramid = BoardColorScheme(
    lightSquare: Color(0xffe8e9b7),
    darkSquare: Color(0xffed7272),
    background: ImageBackground(
      lightSquare: Color(0xffe8e9b7),
      darkSquare: Color(0xffed7272),
      image: AssetImage('lib/boards/pink-pyramid.png', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xffe8e9b7),
      darkSquare: Color(0xffed7272),
      image: AssetImage('lib/boards/pink-pyramid.png', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xffe8e9b7),
      darkSquare: Color(0xffed7272),
      image: AssetImage('lib/boards/pink-pyramid.png', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const purpleDiag = BoardColorScheme(
    lightSquare: Color(0xffe5daf0),
    darkSquare: Color(0xff957ab0),
    background: ImageBackground(
      lightSquare: Color(0xffe5daf0),
      darkSquare: Color(0xff957ab0),
      image: AssetImage('lib/boards/purple-diag.png', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xffe5daf0),
      darkSquare: Color(0xff957ab0),
      image: AssetImage('lib/boards/purple-diag.png', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xffe5daf0),
      darkSquare: Color(0xff957ab0),
      image: AssetImage('lib/boards/purple-diag.png', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const wood = BoardColorScheme(
    lightSquare: Color(0xffd8a45b),
    darkSquare: Color(0xff9b4d0f),
    background: ImageBackground(
      lightSquare: Color(0xffd8a45b),
      darkSquare: Color(0xff9b4d0f),
      image: AssetImage('lib/boards/wood.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xffd8a45b),
      darkSquare: Color(0xff9b4d0f),
      image: AssetImage('lib/boards/wood.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xffd8a45b),
      darkSquare: Color(0xff9b4d0f),
      image: AssetImage('lib/boards/wood.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const wood2 = BoardColorScheme(
    lightSquare: Color(0xffa38b5d),
    darkSquare: Color(0xff6c5017),
    background: ImageBackground(
      lightSquare: Color(0xffa38b5d),
      darkSquare: Color(0xff6c5017),
      image: AssetImage('lib/boards/wood2.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xffa38b5d),
      darkSquare: Color(0xff6c5017),
      image: AssetImage('lib/boards/wood2.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xffa38b5d),
      darkSquare: Color(0xff6c5017),
      image: AssetImage('lib/boards/wood2.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const wood3 = BoardColorScheme(
    lightSquare: Color(0xffd0ceca),
    darkSquare: Color(0xff755839),
    background: ImageBackground(
      lightSquare: Color(0xffd0ceca),
      darkSquare: Color(0xff755839),
      image: AssetImage('lib/boards/wood3.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xffd0ceca),
      darkSquare: Color(0xff755839),
      image: AssetImage('lib/boards/wood3.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xffd0ceca),
      darkSquare: Color(0xff755839),
      image: AssetImage('lib/boards/wood3.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const wood4 = BoardColorScheme(
    lightSquare: Color(0xffcaaf7d),
    darkSquare: Color(0xff7b5330),
    background: ImageBackground(
      lightSquare: Color(0xffcaaf7d),
      darkSquare: Color(0xff7b5330),
      image: AssetImage('lib/boards/wood4.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageBackground(
      lightSquare: Color(0xffcaaf7d),
      darkSquare: Color(0xff7b5330),
      image: AssetImage('lib/boards/wood4.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageBackground(
      lightSquare: Color(0xffcaaf7d),
      darkSquare: Color(0xff7b5330),
      image: AssetImage('lib/boards/wood4.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );
}

class HighlightDetails {
  const HighlightDetails({
    this.solidColor,
    this.image,
  });

  final Color? solidColor;
  final AssetImage? image;
}