import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'models.dart';

const _pieceSetsPath = 'assets/piece_sets';

/// The chess piece set that will be displayed on the board.
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
  libra('Libra', PieceSet.libraAssets),
  mpchess('Mpchess', PieceSet.mpchessAssets),
  shapes('Shapes', PieceSet.shapesAssets),
  kiwenSuwi('Kiwen-suwi', PieceSet.kiwenSuwiAssets),
  horsey('Horsey', PieceSet.horseyAssets),
  anarcandy('Anarcandy', PieceSet.anarcandyAssets),
  letter('Letter', PieceSet.letterAssets),
  disguised('Disguised', PieceSet.disguisedAssets);

  final String label;

  /// The [PieceAssets] for this [PieceSet].
  final PieceAssets assets;

  const PieceSet(this.label, this.assets);

  static const PieceAssets alphaAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/alpha/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/alpha/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/alpha/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/alpha/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/alpha/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/alpha/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/alpha/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/alpha/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/alpha/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/alpha/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/alpha/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/alpha/wK.png', package: 'chessground'),
  });

  static const PieceAssets calienteAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/caliente/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/caliente/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/caliente/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/caliente/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/caliente/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/caliente/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/caliente/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/caliente/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/caliente/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/caliente/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/caliente/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/caliente/wK.png', package: 'chessground'),
  });

  static const PieceAssets anarcandyAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/anarcandy/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/anarcandy/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/anarcandy/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/anarcandy/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/anarcandy/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/anarcandy/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/anarcandy/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/anarcandy/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/anarcandy/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/anarcandy/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/anarcandy/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/anarcandy/wK.png', package: 'chessground'),
  });

  static const PieceAssets californiaAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/california/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/california/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/california/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/california/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/california/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/california/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/california/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/california/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/california/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/california/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/california/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/california/wK.png', package: 'chessground'),
  });

  static const PieceAssets cardinalAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/cardinal/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/cardinal/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/cardinal/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/cardinal/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/cardinal/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/cardinal/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/cardinal/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/cardinal/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/cardinal/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/cardinal/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/cardinal/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/cardinal/wK.png', package: 'chessground'),
  });

  static const PieceAssets cburnettAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/cburnett/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/cburnett/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/cburnett/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/cburnett/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/cburnett/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/cburnett/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/cburnett/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/cburnett/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/cburnett/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/cburnett/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/cburnett/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/cburnett/wK.png', package: 'chessground'),
  });

  static const PieceAssets celticAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/celtic/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/celtic/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/celtic/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/celtic/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/celtic/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/celtic/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/celtic/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/celtic/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/celtic/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/celtic/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/celtic/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/celtic/wK.png', package: 'chessground'),
  });

  static const PieceAssets chess7Assets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/chess7/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/chess7/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/chess7/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/chess7/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/chess7/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/chess7/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/chess7/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/chess7/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/chess7/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/chess7/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/chess7/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/chess7/wK.png', package: 'chessground'),
  });

  static const PieceAssets chessnutAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/chessnut/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/chessnut/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/chessnut/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/chessnut/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/chessnut/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/chessnut/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/chessnut/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/chessnut/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/chessnut/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/chessnut/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/chessnut/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/chessnut/wK.png', package: 'chessground'),
  });

  static const PieceAssets companionAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/companion/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/companion/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/companion/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/companion/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/companion/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/companion/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/companion/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/companion/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/companion/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/companion/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/companion/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/companion/wK.png', package: 'chessground'),
  });

  static const PieceAssets disguisedAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/disguised/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/disguised/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/disguised/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/disguised/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/disguised/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/disguised/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/disguised/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/disguised/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/disguised/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/disguised/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/disguised/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/disguised/wK.png', package: 'chessground'),
  });

  static const PieceAssets dubrovnyAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/dubrovny/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/dubrovny/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/dubrovny/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/dubrovny/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/dubrovny/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/dubrovny/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/dubrovny/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/dubrovny/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/dubrovny/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/dubrovny/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/dubrovny/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/dubrovny/wK.png', package: 'chessground'),
  });

  static const PieceAssets fantasyAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/fantasy/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/fantasy/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/fantasy/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/fantasy/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/fantasy/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/fantasy/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/fantasy/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/fantasy/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/fantasy/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/fantasy/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/fantasy/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/fantasy/wK.png', package: 'chessground'),
  });

  static const PieceAssets frescaAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/fresca/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/fresca/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/fresca/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/fresca/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/fresca/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/fresca/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/fresca/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/fresca/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/fresca/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/fresca/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/fresca/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/fresca/wK.png', package: 'chessground'),
  });

  static const PieceAssets giocoAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/gioco/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/gioco/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/gioco/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/gioco/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/gioco/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/gioco/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/gioco/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/gioco/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/gioco/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/gioco/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/gioco/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/gioco/wK.png', package: 'chessground'),
  });

  static const PieceAssets governorAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/governor/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/governor/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/governor/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/governor/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/governor/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/governor/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/governor/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/governor/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/governor/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/governor/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/governor/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/governor/wK.png', package: 'chessground'),
  });

  static const PieceAssets horseyAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/horsey/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/horsey/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/horsey/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/horsey/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/horsey/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/horsey/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/horsey/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/horsey/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/horsey/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/horsey/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/horsey/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/horsey/wK.png', package: 'chessground'),
  });

  static const PieceAssets icpiecesAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/icpieces/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/icpieces/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/icpieces/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/icpieces/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/icpieces/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/icpieces/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/icpieces/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/icpieces/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/icpieces/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/icpieces/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/icpieces/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/icpieces/wK.png', package: 'chessground'),
  });

  static const PieceAssets kiwenSuwiAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/kiwen-suwi/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/kiwen-suwi/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/kiwen-suwi/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/kiwen-suwi/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/kiwen-suwi/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/kiwen-suwi/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/kiwen-suwi/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/kiwen-suwi/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/kiwen-suwi/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/kiwen-suwi/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/kiwen-suwi/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/kiwen-suwi/wK.png', package: 'chessground'),
  });

  static const PieceAssets kosalAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/kosal/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/kosal/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/kosal/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/kosal/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/kosal/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/kosal/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/kosal/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/kosal/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/kosal/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/kosal/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/kosal/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/kosal/wK.png', package: 'chessground'),
  });

  static const PieceAssets leipzigAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/leipzig/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/leipzig/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/leipzig/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/leipzig/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/leipzig/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/leipzig/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/leipzig/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/leipzig/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/leipzig/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/leipzig/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/leipzig/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/leipzig/wK.png', package: 'chessground'),
  });

  static const PieceAssets letterAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/letter/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/letter/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/letter/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/letter/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/letter/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/letter/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/letter/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/letter/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/letter/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/letter/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/letter/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/letter/wK.png', package: 'chessground'),
  });

  static const PieceAssets libraAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/libra/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/libra/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/libra/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/libra/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/libra/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/libra/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/libra/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/libra/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/libra/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/libra/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/libra/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/libra/wK.png', package: 'chessground'),
  });

  static const PieceAssets maestroAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/maestro/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/maestro/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/maestro/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/maestro/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/maestro/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/maestro/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/maestro/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/maestro/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/maestro/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/maestro/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/maestro/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/maestro/wK.png', package: 'chessground'),
  });

  static const PieceAssets meridaAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/merida/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/merida/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/merida/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/merida/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/merida/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/merida/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/merida/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/merida/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/merida/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/merida/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/merida/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/merida/wK.png', package: 'chessground'),
  });

  static const PieceAssets pirouettiAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/pirouetti/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/pirouetti/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/pirouetti/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/pirouetti/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/pirouetti/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/pirouetti/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/pirouetti/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/pirouetti/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/pirouetti/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/pirouetti/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/pirouetti/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/pirouetti/wK.png', package: 'chessground'),
  });

  static const PieceAssets mpchessAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/mpchess/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/mpchess/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/mpchess/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/mpchess/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/mpchess/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/mpchess/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/mpchess/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/mpchess/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/mpchess/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/mpchess/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/mpchess/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/mpchess/wK.png', package: 'chessground'),
  });

  static const PieceAssets pixelAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/pixel/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/pixel/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/pixel/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/pixel/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/pixel/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/pixel/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/pixel/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/pixel/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/pixel/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/pixel/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/pixel/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/pixel/wK.png', package: 'chessground'),
  });

  static const PieceAssets reillycraigAssets = IMapConst({
    kBlackRookKind: AssetImage(
      '$_pieceSetsPath/reillycraig/bR.png',
      package: 'chessground',
    ),
    kBlackPawnKind: AssetImage(
      '$_pieceSetsPath/reillycraig/bP.png',
      package: 'chessground',
    ),
    kBlackKnightKind: AssetImage(
      '$_pieceSetsPath/reillycraig/bN.png',
      package: 'chessground',
    ),
    kBlackBishopKind: AssetImage(
      '$_pieceSetsPath/reillycraig/bB.png',
      package: 'chessground',
    ),
    kBlackQueenKind: AssetImage(
      '$_pieceSetsPath/reillycraig/bQ.png',
      package: 'chessground',
    ),
    kBlackKingKind: AssetImage(
      '$_pieceSetsPath/reillycraig/bK.png',
      package: 'chessground',
    ),
    kWhiteRookKind: AssetImage(
      '$_pieceSetsPath/reillycraig/wR.png',
      package: 'chessground',
    ),
    kWhitePawnKind: AssetImage(
      '$_pieceSetsPath/reillycraig/wP.png',
      package: 'chessground',
    ),
    kWhiteKnightKind: AssetImage(
      '$_pieceSetsPath/reillycraig/wN.png',
      package: 'chessground',
    ),
    kWhiteBishopKind: AssetImage(
      '$_pieceSetsPath/reillycraig/wB.png',
      package: 'chessground',
    ),
    kWhiteQueenKind: AssetImage(
      '$_pieceSetsPath/reillycraig/wQ.png',
      package: 'chessground',
    ),
    kWhiteKingKind: AssetImage(
      '$_pieceSetsPath/reillycraig/wK.png',
      package: 'chessground',
    ),
  });

  static const PieceAssets riohachaAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/riohacha/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/riohacha/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/riohacha/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/riohacha/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/riohacha/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/riohacha/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/riohacha/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/riohacha/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/riohacha/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/riohacha/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/riohacha/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/riohacha/wK.png', package: 'chessground'),
  });

  static const PieceAssets shapesAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/shapes/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/shapes/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/shapes/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/shapes/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/shapes/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/shapes/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/shapes/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/shapes/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/shapes/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/shapes/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/shapes/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/shapes/wK.png', package: 'chessground'),
  });

  static const PieceAssets spatialAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/spatial/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/spatial/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/spatial/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/spatial/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/spatial/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/spatial/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/spatial/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/spatial/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/spatial/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/spatial/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/spatial/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/spatial/wK.png', package: 'chessground'),
  });

  static const PieceAssets stauntyAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/staunty/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/staunty/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/staunty/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/staunty/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/staunty/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/staunty/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/staunty/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/staunty/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/staunty/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/staunty/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/staunty/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/staunty/wK.png', package: 'chessground'),
  });

  static const PieceAssets tatianaAssets = IMapConst({
    kBlackRookKind:
        AssetImage('$_pieceSetsPath/tatiana/bR.png', package: 'chessground'),
    kBlackPawnKind:
        AssetImage('$_pieceSetsPath/tatiana/bP.png', package: 'chessground'),
    kBlackKnightKind:
        AssetImage('$_pieceSetsPath/tatiana/bN.png', package: 'chessground'),
    kBlackBishopKind:
        AssetImage('$_pieceSetsPath/tatiana/bB.png', package: 'chessground'),
    kBlackQueenKind:
        AssetImage('$_pieceSetsPath/tatiana/bQ.png', package: 'chessground'),
    kBlackKingKind:
        AssetImage('$_pieceSetsPath/tatiana/bK.png', package: 'chessground'),
    kWhiteRookKind:
        AssetImage('$_pieceSetsPath/tatiana/wR.png', package: 'chessground'),
    kWhitePawnKind:
        AssetImage('$_pieceSetsPath/tatiana/wP.png', package: 'chessground'),
    kWhiteKnightKind:
        AssetImage('$_pieceSetsPath/tatiana/wN.png', package: 'chessground'),
    kWhiteBishopKind:
        AssetImage('$_pieceSetsPath/tatiana/wB.png', package: 'chessground'),
    kWhiteQueenKind:
        AssetImage('$_pieceSetsPath/tatiana/wQ.png', package: 'chessground'),
    kWhiteKingKind:
        AssetImage('$_pieceSetsPath/tatiana/wK.png', package: 'chessground'),
  });
}
