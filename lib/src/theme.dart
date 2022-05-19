import 'package:flutter/material.dart';
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

  const BoardTheme({
    required this.background,
    required this.whiteCoordBackground,
    required this.blackCoordBackground,
    required this.lastMove,
    required this.selected,
    required this.validMoves,
  });

  static const brown = BoardTheme(
    background: Background.brown,
    whiteCoordBackground: Background.brownWhiteCoords,
    blackCoordBackground: Background.brownBlackCoords,
    lastMove: Color(0x809cc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
  );

  static const blue = BoardTheme(
    background: Background.blue,
    whiteCoordBackground: Background.blueWhiteCoords,
    blackCoordBackground: Background.blueBlackCoords,
    lastMove: Color(0x809bc700),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
  );

  static const green = BoardTheme(
    background: Background.green,
    whiteCoordBackground: Background.greenWhiteCoords,
    blackCoordBackground: Background.greenBlackCoords,
    lastMove: Color(0x69009bc7),
    selected: Color(0x8014551e),
    validMoves: Color(0x6014551e),
  );
}
