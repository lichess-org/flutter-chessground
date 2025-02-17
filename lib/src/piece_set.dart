import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
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
  letter('Letter', PieceSet.letterAssets),
  disguised('Disguised', PieceSet.disguisedAssets),
  symmetric('Symmetric', PieceSet.symmetricAssets);

  const PieceSet(this.label, this.assets);

  /// The label of this [PieceSet].
  final String label;

  /// The [PieceAssets] for this [PieceSet].
  final PieceAssets assets;

  /// The [PieceAssets] for the 'Alpha' piece set.
  static const PieceAssets alphaAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/alpha/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/alpha/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/alpha/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/alpha/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/alpha/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/alpha/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/alpha/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/alpha/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/alpha/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/alpha/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/alpha/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/alpha/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Caliente' piece set.
  static const PieceAssets calienteAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/caliente/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/caliente/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/caliente/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/caliente/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/caliente/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/caliente/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/caliente/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/caliente/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/caliente/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/caliente/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/caliente/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/caliente/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Anarcandy' piece set.
  static const PieceAssets anarcandyAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/anarcandy/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/anarcandy/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/anarcandy/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/anarcandy/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/anarcandy/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/anarcandy/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/anarcandy/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/anarcandy/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/anarcandy/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/anarcandy/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/anarcandy/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/anarcandy/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'California' piece set.
  static const PieceAssets californiaAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/california/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/california/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/california/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/california/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/california/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/california/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/california/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/california/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/california/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/california/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/california/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/california/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Cardinal' piece set.
  static const PieceAssets cardinalAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/cardinal/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/cardinal/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/cardinal/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/cardinal/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/cardinal/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/cardinal/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/cardinal/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/cardinal/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/cardinal/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/cardinal/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/cardinal/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/cardinal/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Colin M.L. Burnett' piece set.
  static const PieceAssets cburnettAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/cburnett/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/cburnett/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/cburnett/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/cburnett/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/cburnett/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/cburnett/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/cburnett/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/cburnett/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/cburnett/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/cburnett/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/cburnett/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/cburnett/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Celtic' piece set.
  static const PieceAssets celticAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/celtic/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/celtic/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/celtic/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/celtic/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/celtic/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/celtic/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/celtic/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/celtic/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/celtic/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/celtic/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/celtic/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/celtic/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Chess7' piece set.
  static const PieceAssets chess7Assets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/chess7/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/chess7/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/chess7/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/chess7/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/chess7/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/chess7/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/chess7/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/chess7/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/chess7/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/chess7/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/chess7/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/chess7/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Chessnut' piece set.
  static const PieceAssets chessnutAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/chessnut/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/chessnut/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/chessnut/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/chessnut/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/chessnut/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/chessnut/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/chessnut/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/chessnut/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/chessnut/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/chessnut/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/chessnut/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/chessnut/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Companion' piece set.
  static const PieceAssets companionAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/companion/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/companion/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/companion/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/companion/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/companion/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/companion/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/companion/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/companion/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/companion/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/companion/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/companion/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/companion/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Disguised' piece set.
  static const PieceAssets disguisedAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/disguised/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/disguised/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/disguised/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/disguised/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/disguised/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/disguised/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/disguised/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/disguised/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/disguised/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/disguised/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/disguised/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/disguised/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Dubrovny' piece set.
  static const PieceAssets dubrovnyAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/dubrovny/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/dubrovny/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/dubrovny/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/dubrovny/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/dubrovny/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/dubrovny/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/dubrovny/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/dubrovny/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/dubrovny/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/dubrovny/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/dubrovny/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/dubrovny/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Fantasy' piece set.
  static const PieceAssets fantasyAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/fantasy/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/fantasy/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/fantasy/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/fantasy/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/fantasy/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/fantasy/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/fantasy/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/fantasy/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/fantasy/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/fantasy/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/fantasy/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/fantasy/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Fresca' piece set.
  static const PieceAssets frescaAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/fresca/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/fresca/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/fresca/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/fresca/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/fresca/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/fresca/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/fresca/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/fresca/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/fresca/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/fresca/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/fresca/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/fresca/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Gioco' piece set.
  static const PieceAssets giocoAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/gioco/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/gioco/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/gioco/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/gioco/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/gioco/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/gioco/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/gioco/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/gioco/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/gioco/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/gioco/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/gioco/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/gioco/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Governor' piece set.
  static const PieceAssets governorAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/governor/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/governor/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/governor/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/governor/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/governor/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/governor/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/governor/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/governor/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/governor/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/governor/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/governor/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/governor/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Horsey' piece set.
  static const PieceAssets horseyAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/horsey/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/horsey/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/horsey/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/horsey/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/horsey/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/horsey/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/horsey/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/horsey/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/horsey/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/horsey/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/horsey/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/horsey/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Icpieces' piece set.
  static const PieceAssets icpiecesAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/icpieces/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/icpieces/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/icpieces/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/icpieces/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/icpieces/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/icpieces/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/icpieces/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/icpieces/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/icpieces/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/icpieces/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/icpieces/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/icpieces/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Kiwen-suwi' piece set.
  static const PieceAssets kiwenSuwiAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/kiwen-suwi/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/kiwen-suwi/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/kiwen-suwi/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/kiwen-suwi/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/kiwen-suwi/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/kiwen-suwi/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/kiwen-suwi/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/kiwen-suwi/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/kiwen-suwi/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/kiwen-suwi/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/kiwen-suwi/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/kiwen-suwi/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Kosal' piece set.
  static const PieceAssets kosalAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/kosal/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/kosal/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/kosal/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/kosal/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/kosal/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/kosal/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/kosal/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/kosal/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/kosal/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/kosal/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/kosal/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/kosal/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Leipzig' piece set.
  static const PieceAssets leipzigAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/leipzig/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/leipzig/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/leipzig/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/leipzig/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/leipzig/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/leipzig/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/leipzig/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/leipzig/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/leipzig/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/leipzig/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/leipzig/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/leipzig/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Letter' piece set.
  static const PieceAssets letterAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/letter/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/letter/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/letter/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/letter/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/letter/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/letter/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/letter/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/letter/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/letter/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/letter/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/letter/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/letter/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Maestro' piece set.
  static const PieceAssets maestroAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/maestro/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/maestro/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/maestro/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/maestro/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/maestro/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/maestro/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/maestro/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/maestro/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/maestro/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/maestro/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/maestro/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/maestro/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Merida' piece set.
  static const PieceAssets meridaAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/merida/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/merida/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/merida/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/merida/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/merida/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/merida/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/merida/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/merida/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/merida/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/merida/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/merida/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/merida/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Pirouetti' piece set.
  static const PieceAssets pirouettiAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/pirouetti/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/pirouetti/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/pirouetti/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/pirouetti/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/pirouetti/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/pirouetti/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/pirouetti/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/pirouetti/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/pirouetti/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/pirouetti/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/pirouetti/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/pirouetti/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Mpchess' piece set.
  static const PieceAssets mpchessAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/mpchess/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/mpchess/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/mpchess/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/mpchess/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/mpchess/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/mpchess/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/mpchess/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/mpchess/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/mpchess/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/mpchess/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/mpchess/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/mpchess/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Cooke' piece set.
  static const PieceAssets cookeAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/cooke/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/cooke/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/cooke/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/cooke/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/cooke/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/cooke/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/cooke/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/cooke/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/cooke/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/cooke/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/cooke/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/cooke/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Monarchy' piece set.
  static const PieceAssets monarchyAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/monarchy/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/monarchy/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/monarchy/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/monarchy/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/monarchy/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/monarchy/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/monarchy/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/monarchy/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/monarchy/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/monarchy/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/monarchy/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/monarchy/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Pixel' piece set.
  static const PieceAssets pixelAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/pixel/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/pixel/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/pixel/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/pixel/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/pixel/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/pixel/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/pixel/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/pixel/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/pixel/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/pixel/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/pixel/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/pixel/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Reillycraig' piece set.
  static const PieceAssets reillycraigAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/reillycraig/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/reillycraig/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/reillycraig/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/reillycraig/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/reillycraig/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/reillycraig/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/reillycraig/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/reillycraig/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/reillycraig/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/reillycraig/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/reillycraig/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/reillycraig/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Riohacha' piece set.
  static const PieceAssets riohachaAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/riohacha/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/riohacha/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/riohacha/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/riohacha/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/riohacha/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/riohacha/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/riohacha/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/riohacha/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/riohacha/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/riohacha/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/riohacha/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/riohacha/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Shapes' piece set.
  static const PieceAssets shapesAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/shapes/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/shapes/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/shapes/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/shapes/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/shapes/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/shapes/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/shapes/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/shapes/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/shapes/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/shapes/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/shapes/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/shapes/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Spatial' piece set.
  static const PieceAssets spatialAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/spatial/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/spatial/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/spatial/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/spatial/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/spatial/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/spatial/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/spatial/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/spatial/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/spatial/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/spatial/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/spatial/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/spatial/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Staunty' piece set.
  static const PieceAssets stauntyAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/staunty/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/staunty/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/staunty/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/staunty/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/staunty/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/staunty/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/staunty/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/staunty/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/staunty/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/staunty/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/staunty/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/staunty/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Tatiana' piece set.
  static const PieceAssets tatianaAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/tatiana/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/tatiana/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/tatiana/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/tatiana/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/tatiana/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/tatiana/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/tatiana/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/tatiana/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/tatiana/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/tatiana/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/tatiana/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/tatiana/wK.png',
      package: 'chessground',
    ),
  });

  /// The [PieceAssets] for the 'Symmetric' piece set.
  static const PieceAssets symmetricAssets = IMapConst({
    PieceKind.blackRook: AssetImage(
      '$_pieceSetsPath/symmetric/bR.png',
      package: 'chessground',
    ),
    PieceKind.blackPawn: AssetImage(
      '$_pieceSetsPath/symmetric/bP.png',
      package: 'chessground',
    ),
    PieceKind.blackKnight: AssetImage(
      '$_pieceSetsPath/symmetric/bN.png',
      package: 'chessground',
    ),
    PieceKind.blackBishop: AssetImage(
      '$_pieceSetsPath/symmetric/bB.png',
      package: 'chessground',
    ),
    PieceKind.blackQueen: AssetImage(
      '$_pieceSetsPath/symmetric/bQ.png',
      package: 'chessground',
    ),
    PieceKind.blackKing: AssetImage(
      '$_pieceSetsPath/symmetric/bK.png',
      package: 'chessground',
    ),
    PieceKind.whiteRook: AssetImage(
      '$_pieceSetsPath/symmetric/wR.png',
      package: 'chessground',
    ),
    PieceKind.whitePawn: AssetImage(
      '$_pieceSetsPath/symmetric/wP.png',
      package: 'chessground',
    ),
    PieceKind.whiteKnight: AssetImage(
      '$_pieceSetsPath/symmetric/wN.png',
      package: 'chessground',
    ),
    PieceKind.whiteBishop: AssetImage(
      '$_pieceSetsPath/symmetric/wB.png',
      package: 'chessground',
    ),
    PieceKind.whiteQueen: AssetImage(
      '$_pieceSetsPath/symmetric/wQ.png',
      package: 'chessground',
    ),
    PieceKind.whiteKing: AssetImage(
      '$_pieceSetsPath/symmetric/wK.png',
      package: 'chessground',
    ),
  });
}
