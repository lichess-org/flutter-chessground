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
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/alpha/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/alpha/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/alpha/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/alpha/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/alpha/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/alpha/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/alpha/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/alpha/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/alpha/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/alpha/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/alpha/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/alpha/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Caliente' piece set.
  static const PieceAssets calienteAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/caliente/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/caliente/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/caliente/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/caliente/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/caliente/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/caliente/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/caliente/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/caliente/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/caliente/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/caliente/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/caliente/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/caliente/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Anarcandy' piece set.
  static const PieceAssets anarcandyAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/anarcandy/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/anarcandy/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/anarcandy/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/anarcandy/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/anarcandy/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/anarcandy/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/anarcandy/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/anarcandy/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/anarcandy/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/anarcandy/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/anarcandy/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/anarcandy/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'California' piece set.
  static const PieceAssets californiaAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/california/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/california/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/california/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/california/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/california/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/california/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/california/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/california/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/california/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/california/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/california/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/california/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Cardinal' piece set.
  static const PieceAssets cardinalAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/cardinal/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/cardinal/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/cardinal/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/cardinal/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/cardinal/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/cardinal/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/cardinal/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/cardinal/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/cardinal/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/cardinal/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/cardinal/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/cardinal/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Colin M.L. Burnett' piece set.
  static const PieceAssets cburnettAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/cburnett/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/cburnett/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/cburnett/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/cburnett/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/cburnett/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/cburnett/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/cburnett/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/cburnett/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/cburnett/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/cburnett/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/cburnett/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/cburnett/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Celtic' piece set.
  static const PieceAssets celticAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/celtic/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/celtic/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/celtic/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/celtic/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/celtic/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/celtic/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/celtic/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/celtic/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/celtic/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/celtic/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/celtic/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/celtic/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Chess7' piece set.
  static const PieceAssets chess7Assets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/chess7/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/chess7/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/chess7/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/chess7/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/chess7/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/chess7/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/chess7/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/chess7/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/chess7/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/chess7/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/chess7/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/chess7/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Chessnut' piece set.
  static const PieceAssets chessnutAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/chessnut/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/chessnut/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/chessnut/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/chessnut/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/chessnut/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/chessnut/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/chessnut/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/chessnut/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/chessnut/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/chessnut/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/chessnut/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/chessnut/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Companion' piece set.
  static const PieceAssets companionAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/companion/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/companion/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/companion/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/companion/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/companion/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/companion/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/companion/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/companion/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/companion/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/companion/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/companion/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/companion/wK.webp', package: 'chessground'),
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
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/dubrovny/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/dubrovny/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/dubrovny/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/dubrovny/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/dubrovny/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/dubrovny/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/dubrovny/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/dubrovny/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/dubrovny/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/dubrovny/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/dubrovny/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/dubrovny/wK.webp', package: 'chessground'),
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
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/fresca/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/fresca/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/fresca/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/fresca/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/fresca/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/fresca/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/fresca/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/fresca/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/fresca/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/fresca/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/fresca/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/fresca/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Gioco' piece set.
  static const PieceAssets giocoAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/gioco/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/gioco/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/gioco/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/gioco/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/gioco/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/gioco/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/gioco/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/gioco/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/gioco/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/gioco/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/gioco/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/gioco/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Governor' piece set.
  static const PieceAssets governorAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/governor/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/governor/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/governor/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/governor/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/governor/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/governor/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/governor/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/governor/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/governor/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/governor/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/governor/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/governor/wK.webp', package: 'chessground'),
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
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/icpieces/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/icpieces/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/icpieces/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/icpieces/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/icpieces/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/icpieces/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/icpieces/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/icpieces/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/icpieces/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/icpieces/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/icpieces/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/icpieces/wK.webp', package: 'chessground'),
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
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/kosal/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/kosal/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/kosal/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/kosal/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/kosal/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/kosal/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/kosal/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/kosal/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/kosal/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/kosal/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/kosal/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/kosal/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Leipzig' piece set.
  static const PieceAssets leipzigAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/leipzig/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/leipzig/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/leipzig/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/leipzig/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/leipzig/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/leipzig/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/leipzig/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/leipzig/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/leipzig/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/leipzig/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/leipzig/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/leipzig/wK.webp', package: 'chessground'),
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
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/maestro/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/maestro/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/maestro/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/maestro/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/maestro/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/maestro/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/maestro/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/maestro/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/maestro/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/maestro/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/maestro/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/maestro/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Merida' piece set.
  static const PieceAssets meridaAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/merida/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/merida/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/merida/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/merida/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/merida/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/merida/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/merida/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/merida/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/merida/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/merida/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/merida/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/merida/wK.webp', package: 'chessground'),
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
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/mpchess/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/mpchess/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/mpchess/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/mpchess/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/mpchess/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/mpchess/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/mpchess/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/mpchess/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/mpchess/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/mpchess/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/mpchess/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/mpchess/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Cooke' piece set.
  static const PieceAssets cookeAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/cooke/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/cooke/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/cooke/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/cooke/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/cooke/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/cooke/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/cooke/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/cooke/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/cooke/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/cooke/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/cooke/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/cooke/wK.webp', package: 'chessground'),
  };

  /// The [PieceAssets] for the 'Monarchy' piece set.
  static const PieceAssets monarchyAssets = {
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/monarchy/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/monarchy/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/monarchy/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/monarchy/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/monarchy/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/monarchy/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/monarchy/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/monarchy/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/monarchy/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/monarchy/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/monarchy/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/monarchy/wK.webp', package: 'chessground'),
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
    PieceKind.blackRook: AssetImage('$_pieceSetsPath/firi/bR.webp', package: 'chessground'),
    PieceKind.blackPawn: AssetImage('$_pieceSetsPath/firi/bP.webp', package: 'chessground'),
    PieceKind.blackKnight: AssetImage('$_pieceSetsPath/firi/bN.webp', package: 'chessground'),
    PieceKind.blackBishop: AssetImage('$_pieceSetsPath/firi/bB.webp', package: 'chessground'),
    PieceKind.blackQueen: AssetImage('$_pieceSetsPath/firi/bQ.webp', package: 'chessground'),
    PieceKind.blackKing: AssetImage('$_pieceSetsPath/firi/bK.webp', package: 'chessground'),
    PieceKind.whiteRook: AssetImage('$_pieceSetsPath/firi/wR.webp', package: 'chessground'),
    PieceKind.whitePawn: AssetImage('$_pieceSetsPath/firi/wP.webp', package: 'chessground'),
    PieceKind.whiteKnight: AssetImage('$_pieceSetsPath/firi/wN.webp', package: 'chessground'),
    PieceKind.whiteBishop: AssetImage('$_pieceSetsPath/firi/wB.webp', package: 'chessground'),
    PieceKind.whiteQueen: AssetImage('$_pieceSetsPath/firi/wQ.webp', package: 'chessground'),
    PieceKind.whiteKing: AssetImage('$_pieceSetsPath/firi/wK.webp', package: 'chessground'),
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
