import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/widgets.dart';
import './widgets/background.dart';
import './models.dart';

const _boardsPath = 'assets/boards';

/// Describes the color scheme of a [ChessboardBackground].
///
/// Use the `static const` members to ensure flutter doesn't rebuild the board
/// background more than necessary.
@immutable
class ChessboardColorScheme {
  const ChessboardColorScheme({
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
  final ChessboardBackground background;

  /// Board background that defines light and dark square colors and with white
  /// facing coordinates included
  final ChessboardBackground whiteCoordBackground;

  /// Board background that defines light and dark square colors and with black
  /// facing coordinates included
  final ChessboardBackground blackCoordBackground;

  /// Color of highlighted last move
  final HighlightDetails lastMove;

  /// Color of highlighted selected square
  final HighlightDetails selected;

  /// Color of squares occupied with valid moves dots
  final Color validMoves;

  /// Color of squares occupied with valid premoves dots
  final Color validPremoves;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is ChessboardColorScheme &&
        other.lightSquare == lightSquare &&
        other.darkSquare == darkSquare &&
        other.background == background &&
        other.whiteCoordBackground == whiteCoordBackground &&
        other.blackCoordBackground == blackCoordBackground &&
        other.lastMove == lastMove &&
        other.selected == selected &&
        other.validMoves == validMoves &&
        other.validPremoves == validPremoves;
  }

  @override
  int get hashCode => Object.hash(
    lightSquare,
    darkSquare,
    background,
    whiteCoordBackground,
    blackCoordBackground,
    lastMove,
    selected,
    validMoves,
    validPremoves,
  );

  static const brown = ChessboardColorScheme(
    lightSquare: Color(0xfff0d9b6),
    darkSquare: Color(0xffb58863),
    background: SolidColorChessboardBackground(
      lightSquare: Color(0xfff0d9b6),
      darkSquare: Color(0xffb58863),
    ),
    whiteCoordBackground: SolidColorChessboardBackground(
      lightSquare: Color(0xfff0d9b6),
      darkSquare: Color(0xffb58863),
      coordinates: true,
    ),
    blackCoordBackground: SolidColorChessboardBackground(
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

  static const blue = ChessboardColorScheme(
    lightSquare: Color(0xffdee3e6),
    darkSquare: Color(0xff8ca2ad),
    background: SolidColorChessboardBackground(
      lightSquare: Color(0xffdee3e6),
      darkSquare: Color(0xff8ca2ad),
    ),
    whiteCoordBackground: SolidColorChessboardBackground(
      lightSquare: Color(0xffdee3e6),
      darkSquare: Color(0xff8ca2ad),
      coordinates: true,
    ),
    blackCoordBackground: SolidColorChessboardBackground(
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

  static const green = ChessboardColorScheme(
    lightSquare: Color(0xffffffdd),
    darkSquare: Color(0xff86a666),
    background: SolidColorChessboardBackground(
      lightSquare: Color(0xffffffdd),
      darkSquare: Color(0xff86a666),
    ),
    whiteCoordBackground: SolidColorChessboardBackground(
      lightSquare: Color(0xffffffdd),
      darkSquare: Color(0xff86a666),
      coordinates: true,
    ),
    blackCoordBackground: SolidColorChessboardBackground(
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

  static const ic = ChessboardColorScheme(
    lightSquare: Color(0xffececec),
    darkSquare: Color(0xffc1c18e),
    background: SolidColorChessboardBackground(
      lightSquare: Color(0xffececec),
      darkSquare: Color(0xffc1c18e),
    ),
    whiteCoordBackground: SolidColorChessboardBackground(
      lightSquare: Color(0xffececec),
      darkSquare: Color(0xffc1c18e),
      coordinates: true,
    ),
    blackCoordBackground: SolidColorChessboardBackground(
      lightSquare: Color(0xffececec),
      darkSquare: Color(0xffc1c18e),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const blue2 = ChessboardColorScheme(
    lightSquare: Color(0xff97b2c7),
    darkSquare: Color(0xff546f82),
    background: ImageChessboardBackground(
      lightSquare: Color(0xff97b2c7),
      darkSquare: Color(0xff546f82),
      image: AssetImage('$_boardsPath/blue2.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xff97b2c7),
      darkSquare: Color(0xff546f82),
      image: AssetImage('$_boardsPath/blue2.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xff97b2c7),
      darkSquare: Color(0xff546f82),
      image: AssetImage('$_boardsPath/blue2.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const blue3 = ChessboardColorScheme(
    lightSquare: Color(0xffd9e0e6),
    darkSquare: Color(0xff315991),
    background: ImageChessboardBackground(
      lightSquare: Color(0xffd9e0e6),
      darkSquare: Color(0xff315991),
      image: AssetImage('$_boardsPath/blue3.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffd9e0e6),
      darkSquare: Color(0xff315991),
      image: AssetImage('$_boardsPath/blue3.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffd9e0e6),
      darkSquare: Color(0xff315991),
      image: AssetImage('$_boardsPath/blue3.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const blueMarble = ChessboardColorScheme(
    lightSquare: Color(0xffeae6dd),
    darkSquare: Color(0xff7c7f87),
    background: ImageChessboardBackground(
      lightSquare: Color(0xffeae6dd),
      darkSquare: Color(0xff7c7f87),
      image: AssetImage('$_boardsPath/blue-marble.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffeae6dd),
      darkSquare: Color(0xff7c7f87),
      image: AssetImage('$_boardsPath/blue-marble.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffeae6dd),
      darkSquare: Color(0xff7c7f87),
      image: AssetImage('$_boardsPath/blue-marble.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const canvas = ChessboardColorScheme(
    lightSquare: Color(0xffd7daeb),
    darkSquare: Color(0xff547388),
    background: ImageChessboardBackground(
      lightSquare: Color(0xffd7daeb),
      darkSquare: Color(0xff547388),
      image: AssetImage('$_boardsPath/canvas2.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffd7daeb),
      darkSquare: Color(0xff547388),
      image: AssetImage('$_boardsPath/canvas2.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffd7daeb),
      darkSquare: Color(0xff547388),
      image: AssetImage('$_boardsPath/canvas2.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const greenPlastic = ChessboardColorScheme(
    lightSquare: Color(0xfff2f9bb),
    darkSquare: Color(0xff59935d),
    background: ImageChessboardBackground(
      lightSquare: Color(0xfff2f9bb),
      darkSquare: Color(0xff59935d),
      image: AssetImage(
        '$_boardsPath/green-plastic.png',
        package: 'chessground',
      ),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xfff2f9bb),
      darkSquare: Color(0xff59935d),
      image: AssetImage(
        '$_boardsPath/green-plastic.png',
        package: 'chessground',
      ),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xfff2f9bb),
      darkSquare: Color(0xff59935d),
      image: AssetImage(
        '$_boardsPath/green-plastic.png',
        package: 'chessground',
      ),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color.fromRGBO(0, 155, 199, 0.41)),
    selected: HighlightDetails(solidColor: Color.fromRGBO(216, 85, 0, 0.3)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const grey = ChessboardColorScheme(
    lightSquare: Color(0xffb8b8b8),
    darkSquare: Color(0xff7d7d7d),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    background: ImageChessboardBackground(
      lightSquare: Color(0xffb8b8b8),
      darkSquare: Color(0xff7d7d7d),
      image: AssetImage('$_boardsPath/grey.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffb8b8b8),
      darkSquare: Color(0xff7d7d7d),
      image: AssetImage('$_boardsPath/grey.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffb8b8b8),
      darkSquare: Color(0xff7d7d7d),
      image: AssetImage('$_boardsPath/grey.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const horsey = ChessboardColorScheme(
    lightSquare: Color(0xfff0d9b5),
    darkSquare: Color(0xff946f51),
    background: ImageChessboardBackground(
      lightSquare: Color(0xfff0d9b5),
      darkSquare: Color(0xff946f51),
      image: AssetImage('$_boardsPath/horsey.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xfff0d9b5),
      darkSquare: Color(0xff946f51),
      image: AssetImage('$_boardsPath/horsey.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xfff0d9b5),
      darkSquare: Color(0xff946f51),
      image: AssetImage('$_boardsPath/horsey.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(
      image: AssetImage(
        '$_boardsPath/horsey.last-move.png',
        package: 'chessground',
      ),
    ),
    selected: HighlightDetails(
      image: AssetImage(
        '$_boardsPath/horsey.selected.png',
        package: 'chessground',
      ),
    ),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const leather = ChessboardColorScheme(
    lightSquare: Color(0xffd1d1c9),
    darkSquare: Color(0xffc28e16),
    background: ImageChessboardBackground(
      lightSquare: Color(0xffd1d1c9),
      darkSquare: Color(0xffc28e16),
      image: AssetImage('$_boardsPath/leather.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffd1d1c9),
      darkSquare: Color(0xffc28e16),
      image: AssetImage('$_boardsPath/leather.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffd1d1c9),
      darkSquare: Color(0xffc28e16),
      image: AssetImage('$_boardsPath/leather.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const maple = ChessboardColorScheme(
    lightSquare: Color(0xffe8ceab),
    darkSquare: Color(0xffbc7944),
    background: ImageChessboardBackground(
      lightSquare: Color(0xffe8ceab),
      darkSquare: Color(0xffbc7944),
      image: AssetImage('$_boardsPath/maple.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffe8ceab),
      darkSquare: Color(0xffbc7944),
      image: AssetImage('$_boardsPath/maple.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffe8ceab),
      darkSquare: Color(0xffbc7944),
      image: AssetImage('$_boardsPath/maple.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const maple2 = ChessboardColorScheme(
    lightSquare: Color(0xffe2c89f),
    darkSquare: Color(0xff996633),
    background: ImageChessboardBackground(
      lightSquare: Color(0xffe2c89f),
      darkSquare: Color(0xff996633),
      image: AssetImage('$_boardsPath/maple2.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffe2c89f),
      darkSquare: Color(0xff996633),
      image: AssetImage('$_boardsPath/maple2.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffe2c89f),
      darkSquare: Color(0xff996633),
      image: AssetImage('$_boardsPath/maple2.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const marble = ChessboardColorScheme(
    lightSquare: Color(0xff93ab91),
    darkSquare: Color(0xff4f644e),
    background: ImageChessboardBackground(
      lightSquare: Color(0xff93ab91),
      darkSquare: Color(0xff4f644e),
      image: AssetImage('$_boardsPath/marble.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xff93ab91),
      darkSquare: Color(0xff4f644e),
      image: AssetImage('$_boardsPath/marble.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xff93ab91),
      darkSquare: Color(0xff4f644e),
      image: AssetImage('$_boardsPath/marble.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color.fromRGBO(0, 155, 199, 0.41)),
    selected: HighlightDetails(solidColor: Color.fromRGBO(216, 85, 0, 0.3)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const metal = ChessboardColorScheme(
    lightSquare: Color(0xffc9c9c9),
    darkSquare: Color(0xff727272),
    background: ImageChessboardBackground(
      lightSquare: Color(0xffc9c9c9),
      darkSquare: Color(0xff727272),
      image: AssetImage('$_boardsPath/metal.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffc9c9c9),
      darkSquare: Color(0xff727272),
      image: AssetImage('$_boardsPath/metal.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffc9c9c9),
      darkSquare: Color(0xff727272),
      image: AssetImage('$_boardsPath/metal.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const newspaper = ChessboardColorScheme(
    lightSquare: Color(0xffffffff),
    darkSquare: Color(0xff8d8d8d),
    background: ImageChessboardBackground(
      lightSquare: Color(0xffffffff),
      darkSquare: Color(0xff8d8d8d),
      image: AssetImage('$_boardsPath/newspaper.png', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffffffff),
      darkSquare: Color(0xff8d8d8d),
      image: AssetImage('$_boardsPath/newspaper.png', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffffffff),
      darkSquare: Color(0xff8d8d8d),
      image: AssetImage('$_boardsPath/newspaper.png', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const olive = ChessboardColorScheme(
    lightSquare: Color(0xffb8b19f),
    darkSquare: Color(0xff6d6655),
    background: ImageChessboardBackground(
      lightSquare: Color(0xffb8b19f),
      darkSquare: Color(0xff6d6655),
      image: AssetImage('$_boardsPath/olive.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffb8b19f),
      darkSquare: Color(0xff6d6655),
      image: AssetImage('$_boardsPath/olive.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffb8b19f),
      darkSquare: Color(0xff6d6655),
      image: AssetImage('$_boardsPath/olive.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const pinkPyramid = ChessboardColorScheme(
    lightSquare: Color(0xffe8e9b7),
    darkSquare: Color(0xffed7272),
    background: ImageChessboardBackground(
      lightSquare: Color(0xffe8e9b7),
      darkSquare: Color(0xffed7272),
      image: AssetImage(
        '$_boardsPath/pink-pyramid.png',
        package: 'chessground',
      ),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffe8e9b7),
      darkSquare: Color(0xffed7272),
      image: AssetImage(
        '$_boardsPath/pink-pyramid.png',
        package: 'chessground',
      ),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffe8e9b7),
      darkSquare: Color(0xffed7272),
      image: AssetImage(
        '$_boardsPath/pink-pyramid.png',
        package: 'chessground',
      ),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const purpleDiag = ChessboardColorScheme(
    lightSquare: Color(0xffe5daf0),
    darkSquare: Color(0xff957ab0),
    background: ImageChessboardBackground(
      lightSquare: Color(0xffe5daf0),
      darkSquare: Color(0xff957ab0),
      image: AssetImage('$_boardsPath/purple-diag.png', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffe5daf0),
      darkSquare: Color(0xff957ab0),
      image: AssetImage('$_boardsPath/purple-diag.png', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffe5daf0),
      darkSquare: Color(0xff957ab0),
      image: AssetImage('$_boardsPath/purple-diag.png', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const wood = ChessboardColorScheme(
    lightSquare: Color(0xffd8a45b),
    darkSquare: Color(0xff9b4d0f),
    background: ImageChessboardBackground(
      lightSquare: Color(0xffd8a45b),
      darkSquare: Color(0xff9b4d0f),
      image: AssetImage('$_boardsPath/wood.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffd8a45b),
      darkSquare: Color(0xff9b4d0f),
      image: AssetImage('$_boardsPath/wood.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffd8a45b),
      darkSquare: Color(0xff9b4d0f),
      image: AssetImage('$_boardsPath/wood.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const wood2 = ChessboardColorScheme(
    lightSquare: Color(0xffa38b5d),
    darkSquare: Color(0xff6c5017),
    background: ImageChessboardBackground(
      lightSquare: Color(0xffa38b5d),
      darkSquare: Color(0xff6c5017),
      image: AssetImage('$_boardsPath/wood2.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffa38b5d),
      darkSquare: Color(0xff6c5017),
      image: AssetImage('$_boardsPath/wood2.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffa38b5d),
      darkSquare: Color(0xff6c5017),
      image: AssetImage('$_boardsPath/wood2.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const wood3 = ChessboardColorScheme(
    lightSquare: Color(0xffd0ceca),
    darkSquare: Color(0xff755839),
    background: ImageChessboardBackground(
      lightSquare: Color(0xffd0ceca),
      darkSquare: Color(0xff755839),
      image: AssetImage('$_boardsPath/wood3.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffd0ceca),
      darkSquare: Color(0xff755839),
      image: AssetImage('$_boardsPath/wood3.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffd0ceca),
      darkSquare: Color(0xff755839),
      image: AssetImage('$_boardsPath/wood3.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );

  static const wood4 = ChessboardColorScheme(
    lightSquare: Color(0xffcaaf7d),
    darkSquare: Color(0xff7b5330),
    background: ImageChessboardBackground(
      lightSquare: Color(0xffcaaf7d),
      darkSquare: Color(0xff7b5330),
      image: AssetImage('$_boardsPath/wood4.jpg', package: 'chessground'),
    ),
    whiteCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffcaaf7d),
      darkSquare: Color(0xff7b5330),
      image: AssetImage('$_boardsPath/wood4.jpg', package: 'chessground'),
      coordinates: true,
    ),
    blackCoordBackground: ImageChessboardBackground(
      lightSquare: Color(0xffcaaf7d),
      darkSquare: Color(0xff7b5330),
      image: AssetImage('$_boardsPath/wood4.jpg', package: 'chessground'),
      coordinates: true,
      orientation: Side.black,
    ),
    lastMove: HighlightDetails(solidColor: Color(0x809cc700)),
    selected: HighlightDetails(solidColor: Color(0x6014551e)),
    validMoves: Color(0x4014551e),
    validPremoves: Color(0x40203085),
  );
}
