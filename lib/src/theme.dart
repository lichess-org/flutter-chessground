import 'package:flutter/widgets.dart';
import './widgets/background.dart';

/// Describes the color scheme of a [Board].
class BoardTheme {
  /// Board background that defines light and dark square colors
  final Background background;

  /// Board background that defines light and dark square colors and with white
  /// facing coordinates included
  final Background whiteCoordBackground;

  /// Board background that defines light and dark square colors and with black
  /// facing coordinates included
  final Background blackCoordBackground;

  /// Color of highlighted last move
  final Color lastMove;

  /// Color of highlighted selected square
  final Color selected;

  /// Color of squares occupied with valid moves dots
  final Color validMoves;

  /// Color of squares occupied with valid premoves dots
  final Color validPremoves;

  const BoardTheme({
    required this.background,
    required this.whiteCoordBackground,
    required this.blackCoordBackground,
    required this.lastMove,
    required this.selected,
    required this.validMoves,
    required this.validPremoves,
  });

  static const brown = BoardTheme(
    background: Background.brown,
    whiteCoordBackground: Background.brownWhiteCoords,
    blackCoordBackground: Background.brownBlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const blue = BoardTheme(
    background: Background.blue,
    whiteCoordBackground: Background.blueWhiteCoords,
    blackCoordBackground: Background.blueBlackCoords,
    lastMove: Color(0x809bc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const green = BoardTheme(
    background: Background.green,
    whiteCoordBackground: Background.greenWhiteCoords,
    blackCoordBackground: Background.greenBlackCoords,
    lastMove: Color(0x809bc700),
    selected: Color.fromRGBO(216, 85, 0, 0.3),
    validMoves: Color.fromRGBO(0, 0, 0, 0.2),
    validPremoves: Color(0x60203085),
  );

  static const blue2 = BoardTheme(
    background: Background.blue2,
    whiteCoordBackground: Background.blue2WhiteCoords,
    blackCoordBackground: Background.blue2BlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const blue3 = BoardTheme(
    background: Background.blue3,
    whiteCoordBackground: Background.blue3WhiteCoords,
    blackCoordBackground: Background.blue3BlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const blueMarble = BoardTheme(
    background: Background.blueMarble,
    whiteCoordBackground: Background.blueMarbleWhiteCoords,
    blackCoordBackground: Background.blueMarbleBlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const canvas2 = BoardTheme(
    background: Background.canvas2,
    whiteCoordBackground: Background.canvas2WhiteCoords,
    blackCoordBackground: Background.canvas2BlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const greenPlastic = BoardTheme(
    background: Background.greenPlastic,
    whiteCoordBackground: Background.greenPlasticWhiteCoords,
    blackCoordBackground: Background.greenPlasticBlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const grey = BoardTheme(
    background: Background.grey,
    whiteCoordBackground: Background.greyWhiteCoords,
    blackCoordBackground: Background.greyBlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const horsey = BoardTheme(
    background: Background.horsey,
    whiteCoordBackground: Background.horseyWhiteCoords,
    blackCoordBackground: Background.horseyBlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const leather = BoardTheme(
    background: Background.leather,
    whiteCoordBackground: Background.leatherWhiteCoords,
    blackCoordBackground: Background.leatherBlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const maple = BoardTheme(
    background: Background.maple,
    whiteCoordBackground: Background.mapleWhiteCoords,
    blackCoordBackground: Background.mapleBlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const maple2 = BoardTheme(
    background: Background.maple2,
    whiteCoordBackground: Background.maple2WhiteCoords,
    blackCoordBackground: Background.maple2BlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const marble = BoardTheme(
    background: Background.marble,
    whiteCoordBackground: Background.marbleWhiteCoords,
    blackCoordBackground: Background.marbleBlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const metal = BoardTheme(
    background: Background.metal,
    whiteCoordBackground: Background.metalWhiteCoords,
    blackCoordBackground: Background.metalBlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const ncf = BoardTheme(
    background: Background.ncf,
    whiteCoordBackground: Background.ncfWhiteCoords,
    blackCoordBackground: Background.ncfBlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const newspaper = BoardTheme(
    background: Background.newspaper,
    whiteCoordBackground: Background.newspaperWhiteCoords,
    blackCoordBackground: Background.newspaperBlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const olive = BoardTheme(
    background: Background.olive,
    whiteCoordBackground: Background.oliveWhiteCoords,
    blackCoordBackground: Background.oliveBlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const pinkPyramid = BoardTheme(
    background: Background.pinkPyramid,
    whiteCoordBackground: Background.pinkPyramidWhiteCoords,
    blackCoordBackground: Background.pinkPyramidBlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const purpleDiag = BoardTheme(
    background: Background.purpleDiag,
    whiteCoordBackground: Background.purpleDiagWhiteCoords,
    blackCoordBackground: Background.purpleDiagBlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const wood = BoardTheme(
    background: Background.wood,
    whiteCoordBackground: Background.woodWhiteCoords,
    blackCoordBackground: Background.woodBlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const wood2 = BoardTheme(
    background: Background.wood2,
    whiteCoordBackground: Background.wood2WhiteCoords,
    blackCoordBackground: Background.wood2BlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const wood3 = BoardTheme(
    background: Background.wood3,
    whiteCoordBackground: Background.wood3WhiteCoords,
    blackCoordBackground: Background.wood3BlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );

  static const wood4 = BoardTheme(
    background: Background.wood4,
    whiteCoordBackground: Background.wood4WhiteCoords,
    blackCoordBackground: Background.wood4BlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
    validPremoves: Color(0x60203085),
  );
}
