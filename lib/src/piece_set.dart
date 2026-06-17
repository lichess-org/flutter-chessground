import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';
import 'models.dart';

const _pieceSetsPath = 'assets/piece_sets';

/// A piece set and its corresponding piece assets.
enum PieceSet {
  cburnett('Colin M.L. Burnett', PieceSet.cburnettAssets),
  merida('Merida', PieceSet.meridaAssets),
  pirouetti('Pirouetti', PieceSet.pirouettiAssets),
  chessnut('Chessnut', PieceSet.chessnutAssets),
  chess7('Chess7', PieceSet.chess7Assets),
  alpha('Alpha', PieceSet.alphaAssets),
  reillycraig('Reillycraig', PieceSet.reillycraigAssets),
  companion('Companion', PieceSet.companionAssets),
  riohacha('Riohacha', PieceSet.riohachaAssets),
  kosal('Kosal', PieceSet.kosalAssets),
  leipzig('Leipzig', PieceSet.leipzigAssets),
  fantasy('Fantasy', PieceSet.fantasyAssets),
  spatial('Spatial', PieceSet.spatialAssets),
  celtic('Celtic', PieceSet.celticAssets),
  california('California', PieceSet.californiaAssets),
  caliente('Caliente', PieceSet.calienteAssets),
  pixel('Pixel', PieceSet.pixelAssets),
  firi('Firi', PieceSet.firiAssets),
  rhosgfx('RhosGFX', PieceSet.rhosgfxAssets),
  maestro('Maestro', PieceSet.maestroAssets),
  fresca('Fresca', PieceSet.frescaAssets),
  cardinal('Cardinal', PieceSet.cardinalAssets),
  gioco('Gioco', PieceSet.giocoAssets),
  tatiana('Tatiana', PieceSet.tatianaAssets),
  staunty('Staunty', PieceSet.stauntyAssets),
  governor('Governor', PieceSet.governorAssets),
  dubrovny('Dubrovny', PieceSet.dubrovnyAssets),
  icpieces('Icpieces', PieceSet.icpiecesAssets),
  mpchess('Mpchess', PieceSet.mpchessAssets),
  monarchy('Monarchy', PieceSet.monarchyAssets),
  cooke('Cooke', PieceSet.cookeAssets),
  shapes('Shapes', PieceSet.shapesAssets),
  kiwenSuwi('Kiwen-suwi', PieceSet.kiwenSuwiAssets),
  horsey('Horsey', PieceSet.horseyAssets),
  anarcandy('Anarcandy', PieceSet.anarcandyAssets),
  xkcd('xkcd', PieceSet.xkcdAssets),
  letter('Letter', PieceSet.letterAssets),
  disguised('Disguised', PieceSet.disguisedAssets),
  symmetric('Symmetric', PieceSet.symmetricAssets),
  totoy('Totoy', PieceSet.totoyAssets);

  const PieceSet(this.label, this.assets);

  /// The label of this [PieceSet].
  final String label;

  /// The [PieceAssets] for this [PieceSet].
  final PieceAssets assets;

  /// The [PieceAssets] for the 'Alpha' piece set.
  static const PieceAssets alphaAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/alpha/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/alpha/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/alpha/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/alpha/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/alpha/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/alpha/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/alpha/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/alpha/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/alpha/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/alpha/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/alpha/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/alpha/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Caliente' piece set.
  static const PieceAssets calienteAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/caliente/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/caliente/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/caliente/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/caliente/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/caliente/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/caliente/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/caliente/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/caliente/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/caliente/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/caliente/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/caliente/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/caliente/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Anarcandy' piece set.
  static const PieceAssets anarcandyAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/anarcandy/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/anarcandy/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/anarcandy/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/anarcandy/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/anarcandy/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/anarcandy/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/anarcandy/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/anarcandy/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/anarcandy/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/anarcandy/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/anarcandy/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/anarcandy/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'California' piece set.
  static const PieceAssets californiaAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/california/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/california/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/california/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/california/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/california/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/california/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/california/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/california/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/california/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/california/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/california/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/california/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Cardinal' piece set.
  static const PieceAssets cardinalAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/cardinal/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/cardinal/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/cardinal/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/cardinal/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/cardinal/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/cardinal/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/cardinal/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/cardinal/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/cardinal/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/cardinal/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/cardinal/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/cardinal/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Colin M.L. Burnett' piece set.
  static const PieceAssets cburnettAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/cburnett/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/cburnett/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/cburnett/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/cburnett/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/cburnett/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/cburnett/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/cburnett/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/cburnett/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/cburnett/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/cburnett/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/cburnett/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/cburnett/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Celtic' piece set.
  static const PieceAssets celticAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/celtic/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/celtic/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/celtic/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/celtic/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/celtic/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/celtic/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/celtic/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/celtic/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/celtic/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/celtic/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/celtic/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/celtic/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Chess7' piece set.
  static const PieceAssets chess7Assets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/chess7/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/chess7/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/chess7/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/chess7/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/chess7/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/chess7/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/chess7/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/chess7/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/chess7/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/chess7/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/chess7/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/chess7/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Chessnut' piece set.
  static const PieceAssets chessnutAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/chessnut/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/chessnut/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/chessnut/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/chessnut/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/chessnut/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/chessnut/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/chessnut/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/chessnut/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/chessnut/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/chessnut/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/chessnut/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/chessnut/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Companion' piece set.
  static const PieceAssets companionAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/companion/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/companion/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/companion/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/companion/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/companion/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/companion/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/companion/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/companion/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/companion/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/companion/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/companion/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/companion/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Disguised' piece set.
  static const PieceAssets disguisedAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/disguised/b.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/disguised/b.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/disguised/b.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/disguised/b.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/disguised/b.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/disguised/b.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/disguised/w.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/disguised/w.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/disguised/w.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/disguised/w.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/disguised/w.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/disguised/w.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Dubrovny' piece set.
  static const PieceAssets dubrovnyAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/dubrovny/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/dubrovny/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/dubrovny/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/dubrovny/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/dubrovny/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/dubrovny/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/dubrovny/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/dubrovny/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/dubrovny/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/dubrovny/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/dubrovny/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/dubrovny/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Fantasy' piece set.
  static const PieceAssets fantasyAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/fantasy/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/fantasy/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/fantasy/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/fantasy/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/fantasy/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/fantasy/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/fantasy/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/fantasy/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/fantasy/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/fantasy/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/fantasy/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/fantasy/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Fresca' piece set.
  static const PieceAssets frescaAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/fresca/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/fresca/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/fresca/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/fresca/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/fresca/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/fresca/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/fresca/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/fresca/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/fresca/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/fresca/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/fresca/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/fresca/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Gioco' piece set.
  static const PieceAssets giocoAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/gioco/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/gioco/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/gioco/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/gioco/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/gioco/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/gioco/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/gioco/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/gioco/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/gioco/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/gioco/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/gioco/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/gioco/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Governor' piece set.
  static const PieceAssets governorAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/governor/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/governor/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/governor/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/governor/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/governor/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/governor/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/governor/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/governor/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/governor/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/governor/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/governor/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/governor/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Horsey' piece set.
  static const PieceAssets horseyAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/horsey/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/horsey/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/horsey/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/horsey/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/horsey/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/horsey/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/horsey/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/horsey/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/horsey/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/horsey/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/horsey/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/horsey/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Icpieces' piece set.
  static const PieceAssets icpiecesAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/icpieces/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/icpieces/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/icpieces/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/icpieces/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/icpieces/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/icpieces/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/icpieces/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/icpieces/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/icpieces/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/icpieces/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/icpieces/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/icpieces/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Kiwen-suwi' piece set.
  static const PieceAssets kiwenSuwiAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/kiwen-suwi/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/kiwen-suwi/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/kiwen-suwi/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/kiwen-suwi/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/kiwen-suwi/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/kiwen-suwi/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/kiwen-suwi/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/kiwen-suwi/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/kiwen-suwi/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/kiwen-suwi/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/kiwen-suwi/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/kiwen-suwi/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Kosal' piece set.
  static const PieceAssets kosalAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/kosal/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/kosal/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/kosal/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/kosal/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/kosal/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/kosal/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/kosal/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/kosal/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/kosal/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/kosal/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/kosal/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/kosal/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Leipzig' piece set.
  static const PieceAssets leipzigAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/leipzig/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/leipzig/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/leipzig/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/leipzig/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/leipzig/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/leipzig/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/leipzig/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/leipzig/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/leipzig/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/leipzig/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/leipzig/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/leipzig/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Letter' piece set.
  static const PieceAssets letterAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/letter/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/letter/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/letter/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/letter/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/letter/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/letter/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/letter/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/letter/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/letter/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/letter/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/letter/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/letter/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Maestro' piece set.
  static const PieceAssets maestroAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/maestro/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/maestro/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/maestro/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/maestro/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/maestro/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/maestro/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/maestro/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/maestro/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/maestro/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/maestro/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/maestro/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/maestro/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Merida' piece set.
  static const PieceAssets meridaAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/merida/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/merida/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/merida/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/merida/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/merida/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/merida/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/merida/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/merida/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/merida/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/merida/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/merida/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/merida/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Pirouetti' piece set.
  static const PieceAssets pirouettiAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/pirouetti/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/pirouetti/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/pirouetti/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/pirouetti/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/pirouetti/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/pirouetti/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/pirouetti/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/pirouetti/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/pirouetti/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/pirouetti/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/pirouetti/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/pirouetti/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Mpchess' piece set.
  static const PieceAssets mpchessAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/mpchess/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/mpchess/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/mpchess/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/mpchess/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/mpchess/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/mpchess/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/mpchess/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/mpchess/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/mpchess/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/mpchess/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/mpchess/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/mpchess/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Cooke' piece set.
  static const PieceAssets cookeAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/cooke/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/cooke/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/cooke/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/cooke/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/cooke/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/cooke/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/cooke/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/cooke/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/cooke/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/cooke/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/cooke/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/cooke/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Monarchy' piece set.
  static const PieceAssets monarchyAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/monarchy/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/monarchy/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/monarchy/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/monarchy/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/monarchy/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/monarchy/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/monarchy/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/monarchy/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/monarchy/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/monarchy/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/monarchy/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/monarchy/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Pixel' piece set.
  static const PieceAssets pixelAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/pixel/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/pixel/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/pixel/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/pixel/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/pixel/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/pixel/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/pixel/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/pixel/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/pixel/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/pixel/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/pixel/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/pixel/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Firi' piece set.
  static const PieceAssets firiAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/firi/bR.png', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/firi/bP.png', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/firi/bN.png', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/firi/bB.png', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/firi/bQ.png', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/firi/bK.png', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/firi/wR.png', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/firi/wP.png', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/firi/wN.png', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/firi/wB.png', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/firi/wQ.png', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/firi/wK.png', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Reillycraig' piece set.
  static const PieceAssets reillycraigAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/reillycraig/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/reillycraig/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/reillycraig/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/reillycraig/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/reillycraig/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/reillycraig/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/reillycraig/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/reillycraig/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/reillycraig/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/reillycraig/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/reillycraig/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/reillycraig/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Riohacha' piece set.
  static const PieceAssets riohachaAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/riohacha/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/riohacha/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/riohacha/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/riohacha/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/riohacha/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/riohacha/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/riohacha/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/riohacha/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/riohacha/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/riohacha/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/riohacha/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/riohacha/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'xkcd' piece set.
  static const PieceAssets xkcdAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/xkcd/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/xkcd/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/xkcd/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/xkcd/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/xkcd/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/xkcd/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/xkcd/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/xkcd/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/xkcd/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/xkcd/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/xkcd/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/xkcd/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Shapes' piece set.
  static const PieceAssets shapesAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/shapes/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/shapes/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/shapes/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/shapes/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/shapes/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/shapes/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/shapes/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/shapes/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/shapes/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/shapes/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/shapes/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/shapes/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Spatial' piece set.
  static const PieceAssets spatialAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/spatial/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/spatial/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/spatial/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/spatial/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/spatial/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/spatial/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/spatial/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/spatial/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/spatial/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/spatial/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/spatial/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/spatial/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Staunty' piece set.
  static const PieceAssets stauntyAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/staunty/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/staunty/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/staunty/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/staunty/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/staunty/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/staunty/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/staunty/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/staunty/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/staunty/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/staunty/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/staunty/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/staunty/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Tatiana' piece set.
  static const PieceAssets tatianaAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/tatiana/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/tatiana/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/tatiana/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/tatiana/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/tatiana/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/tatiana/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/tatiana/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/tatiana/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/tatiana/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/tatiana/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/tatiana/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/tatiana/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Symmetric' piece set.
  static const PieceAssets symmetricAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/symmetric/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/symmetric/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/symmetric/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/symmetric/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/symmetric/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/symmetric/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/symmetric/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/symmetric/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/symmetric/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/symmetric/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/symmetric/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/symmetric/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'RhosGFX' piece set.
  static const PieceAssets rhosgfxAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/rhosgfx/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/rhosgfx/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/rhosgfx/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/rhosgfx/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/rhosgfx/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/rhosgfx/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/rhosgfx/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/rhosgfx/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/rhosgfx/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/rhosgfx/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/rhosgfx/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/rhosgfx/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Totoy' piece set.
  static const PieceAssets totoyAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/totoy/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/totoy/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/totoy/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/totoy/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/totoy/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/totoy/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/totoy/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/totoy/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/totoy/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/totoy/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/totoy/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/totoy/wK.webp', package: 'chessground'),
  };
}
