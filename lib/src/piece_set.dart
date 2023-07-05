import 'package:flutter/widgets.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'models.dart';

/// The chess piece set that will be displayed on the board.
enum PieceSet {
  cburnett('Colin M.L. Burnett'),
  merida('Merida'),
  pirouetti('Pirouetti'),
  chessnut('Chessnut'),
  chess7('Chess7'),
  alpha('Alpha'),
  reillycraig('Reillycraig'),
  companion('Companion'),
  riohacha('Riohacha'),
  kosal('Kosal'),
  leipzig('Leipzig'),
  fantasy('Fantasy'),
  spatial('Spatial'),
  celtic('Celtic'),
  caliente('Caliente'),
  california('California'),
  pixel('Pixel'),
  maestro('Maestro'),
  fresca('Fresca'),
  cardinal('Cardinal'),
  gioco('Gioco'),
  tatiana('Tatiana'),
  staunty('Staunty'),
  governor('Governor'),
  dubrovny('Dubrovny'),
  icpieces('Icpieces'),
  libra('Libra'),
  shapes('Shapes'),
  horsey('Horsey'),
  anarcandy('Anarcandy'),
  letter('Letter'),
  disguised('Disguised');

  final String label;

  const PieceSet(this.label);

  /// The [PieceAssets] for this [PieceSet].
  PieceAssets get assets {
    switch (this) {
      case PieceSet.alpha:
        return PieceSet.alphaAssets;
      case PieceSet.anarcandy:
        return PieceSet.anarcandyAssets;
      case PieceSet.california:
        return PieceSet.californiaAssets;
      case PieceSet.caliente:
        return PieceSet.calienteAssets;
      case PieceSet.cardinal:
        return PieceSet.cardinalAssets;
      case PieceSet.cburnett:
        return PieceSet.cburnettAssets;
      case PieceSet.celtic:
        return PieceSet.celticAssets;
      case PieceSet.chess7:
        return PieceSet.chess7Assets;
      case PieceSet.chessnut:
        return PieceSet.chessnutAssets;
      case PieceSet.companion:
        return PieceSet.companionAssets;
      case PieceSet.disguised:
        return PieceSet.disguisedAssets;
      case PieceSet.dubrovny:
        return PieceSet.dubrovnyAssets;
      case PieceSet.fantasy:
        return PieceSet.fantasyAssets;
      case PieceSet.fresca:
        return PieceSet.frescaAssets;
      case PieceSet.gioco:
        return PieceSet.giocoAssets;
      case PieceSet.governor:
        return PieceSet.governorAssets;
      case PieceSet.horsey:
        return PieceSet.horseyAssets;
      case PieceSet.icpieces:
        return PieceSet.icpiecesAssets;
      case PieceSet.kosal:
        return PieceSet.kosalAssets;
      case PieceSet.leipzig:
        return PieceSet.leipzigAssets;
      case PieceSet.letter:
        return PieceSet.letterAssets;
      case PieceSet.libra:
        return PieceSet.libraAssets;
      case PieceSet.maestro:
        return PieceSet.maestroAssets;
      case PieceSet.merida:
        return PieceSet.meridaAssets;
      case PieceSet.pirouetti:
        return PieceSet.pirouettiAssets;
      case PieceSet.pixel:
        return PieceSet.pixelAssets;
      case PieceSet.reillycraig:
        return PieceSet.reillycraigAssets;
      case PieceSet.riohacha:
        return PieceSet.riohachaAssets;
      case PieceSet.shapes:
        return PieceSet.shapesAssets;
      case PieceSet.spatial:
        return PieceSet.spatialAssets;
      case PieceSet.staunty:
        return PieceSet.stauntyAssets;
      case PieceSet.tatiana:
        return PieceSet.tatianaAssets;
    }
  }

  static const PieceAssets alphaAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/alpha/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/alpha/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/alpha/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/alpha/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/alpha/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/alpha/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/alpha/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/alpha/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/alpha/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/alpha/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/alpha/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/alpha/wK.png', package: 'chessground'),
  });

  static const PieceAssets anarcandyAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/anarcandy/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/anarcandy/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/anarcandy/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/anarcandy/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/anarcandy/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/anarcandy/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/anarcandy/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/anarcandy/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/anarcandy/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/anarcandy/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/anarcandy/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/anarcandy/wK.png', package: 'chessground'),
  });

  static const PieceAssets californiaAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/california/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/california/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/california/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/california/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/california/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/california/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/california/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/california/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/california/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/california/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/california/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/california/wK.png', package: 'chessground'),
  });

  static const PieceAssets calienteAssets = IMapConst({
    PieceKind.blackRook:
    AssetImage('lib/piece_sets/caliente/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
    AssetImage('lib/piece_sets/caliente/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
    AssetImage('lib/piece_sets/caliente/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
    AssetImage('lib/piece_sets/caliente/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
    AssetImage('lib/piece_sets/caliente/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
    AssetImage('lib/piece_sets/caliente/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
    AssetImage('lib/piece_sets/caliente/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
    AssetImage('lib/piece_sets/caliente/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
    AssetImage('lib/piece_sets/caliente/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
    AssetImage('lib/piece_sets/caliente/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
    AssetImage('lib/piece_sets/caliente/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
    AssetImage('lib/piece_sets/caliente/wK.png', package: 'chessground'),
  });


  static const PieceAssets cardinalAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/cardinal/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/cardinal/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/cardinal/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/cardinal/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/cardinal/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/cardinal/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/cardinal/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/cardinal/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/cardinal/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/cardinal/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/cardinal/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/cardinal/wK.png', package: 'chessground'),
  });

  static const PieceAssets cburnettAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/cburnett/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/cburnett/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/cburnett/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/cburnett/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/cburnett/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/cburnett/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/cburnett/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/cburnett/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/cburnett/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/cburnett/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/cburnett/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/cburnett/wK.png', package: 'chessground'),
  });

  static const PieceAssets celticAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/celtic/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/celtic/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/celtic/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/celtic/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/celtic/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/celtic/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/celtic/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/celtic/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/celtic/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/celtic/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/celtic/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/celtic/wK.png', package: 'chessground'),
  });

  static const PieceAssets chess7Assets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/chess7/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/chess7/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/chess7/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/chess7/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/chess7/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/chess7/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/chess7/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/chess7/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/chess7/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/chess7/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/chess7/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/chess7/wK.png', package: 'chessground'),
  });

  static const PieceAssets chessnutAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/chessnut/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/chessnut/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/chessnut/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/chessnut/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/chessnut/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/chessnut/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/chessnut/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/chessnut/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/chessnut/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/chessnut/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/chessnut/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/chessnut/wK.png', package: 'chessground'),
  });

  static const PieceAssets companionAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/companion/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/companion/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/companion/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/companion/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/companion/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/companion/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/companion/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/companion/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/companion/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/companion/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/companion/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/companion/wK.png', package: 'chessground'),
  });

  static const PieceAssets disguisedAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/disguised/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/disguised/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/disguised/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/disguised/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/disguised/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/disguised/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/disguised/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/disguised/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/disguised/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/disguised/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/disguised/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/disguised/wK.png', package: 'chessground'),
  });

  static const PieceAssets dubrovnyAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/dubrovny/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/dubrovny/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/dubrovny/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/dubrovny/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/dubrovny/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/dubrovny/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/dubrovny/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/dubrovny/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/dubrovny/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/dubrovny/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/dubrovny/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/dubrovny/wK.png', package: 'chessground'),
  });

  static const PieceAssets fantasyAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/fantasy/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/fantasy/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/fantasy/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/fantasy/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/fantasy/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/fantasy/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/fantasy/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/fantasy/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/fantasy/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/fantasy/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/fantasy/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/fantasy/wK.png', package: 'chessground'),
  });

  static const PieceAssets frescaAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/fresca/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/fresca/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/fresca/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/fresca/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/fresca/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/fresca/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/fresca/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/fresca/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/fresca/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/fresca/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/fresca/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/fresca/wK.png', package: 'chessground'),
  });

  static const PieceAssets giocoAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/gioco/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/gioco/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/gioco/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/gioco/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/gioco/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/gioco/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/gioco/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/gioco/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/gioco/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/gioco/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/gioco/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/gioco/wK.png', package: 'chessground'),
  });

  static const PieceAssets governorAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/governor/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/governor/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/governor/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/governor/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/governor/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/governor/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/governor/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/governor/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/governor/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/governor/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/governor/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/governor/wK.png', package: 'chessground'),
  });

  static const PieceAssets horseyAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/horsey/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/horsey/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/horsey/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/horsey/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/horsey/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/horsey/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/horsey/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/horsey/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/horsey/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/horsey/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/horsey/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/horsey/wK.png', package: 'chessground'),
  });

  static const PieceAssets icpiecesAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/icpieces/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/icpieces/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/icpieces/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/icpieces/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/icpieces/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/icpieces/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/icpieces/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/icpieces/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/icpieces/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/icpieces/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/icpieces/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/icpieces/wK.png', package: 'chessground'),
  });

  static const PieceAssets kosalAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/kosal/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/kosal/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/kosal/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/kosal/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/kosal/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/kosal/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/kosal/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/kosal/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/kosal/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/kosal/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/kosal/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/kosal/wK.png', package: 'chessground'),
  });

  static const PieceAssets leipzigAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/leipzig/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/leipzig/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/leipzig/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/leipzig/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/leipzig/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/leipzig/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/leipzig/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/leipzig/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/leipzig/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/leipzig/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/leipzig/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/leipzig/wK.png', package: 'chessground'),
  });

  static const PieceAssets letterAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/letter/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/letter/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/letter/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/letter/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/letter/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/letter/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/letter/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/letter/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/letter/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/letter/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/letter/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/letter/wK.png', package: 'chessground'),
  });

  static const PieceAssets libraAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/libra/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/libra/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/libra/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/libra/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/libra/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/libra/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/libra/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/libra/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/libra/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/libra/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/libra/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/libra/wK.png', package: 'chessground'),
  });

  static const PieceAssets maestroAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/maestro/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/maestro/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/maestro/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/maestro/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/maestro/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/maestro/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/maestro/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/maestro/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/maestro/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/maestro/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/maestro/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/maestro/wK.png', package: 'chessground'),
  });

  static const PieceAssets meridaAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/merida/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/merida/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/merida/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/merida/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/merida/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/merida/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/merida/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/merida/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/merida/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/merida/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/merida/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/merida/wK.png', package: 'chessground'),
  });

  static const PieceAssets pirouettiAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/pirouetti/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/pirouetti/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/pirouetti/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/pirouetti/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/pirouetti/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/pirouetti/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/pirouetti/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/pirouetti/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/pirouetti/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/pirouetti/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/pirouetti/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/pirouetti/wK.png', package: 'chessground'),
  });

  static const PieceAssets pixelAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/pixel/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/pixel/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/pixel/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/pixel/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/pixel/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/pixel/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/pixel/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/pixel/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/pixel/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/pixel/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/pixel/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/pixel/wK.png', package: 'chessground'),
  });

  static const PieceAssets reillycraigAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/reillycraig/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/reillycraig/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/reillycraig/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/reillycraig/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/reillycraig/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/reillycraig/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/reillycraig/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/reillycraig/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/reillycraig/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/reillycraig/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/reillycraig/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/reillycraig/wK.png', package: 'chessground'),
  });

  static const PieceAssets riohachaAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/riohacha/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/riohacha/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/riohacha/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/riohacha/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/riohacha/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/riohacha/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/riohacha/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/riohacha/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/riohacha/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/riohacha/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/riohacha/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/riohacha/wK.png', package: 'chessground'),
  });

  static const PieceAssets shapesAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/shapes/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/shapes/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/shapes/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/shapes/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/shapes/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/shapes/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/shapes/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/shapes/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/shapes/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/shapes/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/shapes/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/shapes/wK.png', package: 'chessground'),
  });

  static const PieceAssets spatialAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/spatial/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/spatial/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/spatial/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/spatial/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/spatial/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/spatial/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/spatial/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/spatial/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/spatial/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/spatial/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/spatial/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/spatial/wK.png', package: 'chessground'),
  });

  static const PieceAssets stauntyAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/staunty/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/staunty/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/staunty/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/staunty/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/staunty/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/staunty/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/staunty/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/staunty/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/staunty/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/staunty/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/staunty/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/staunty/wK.png', package: 'chessground'),
  });

  static const PieceAssets tatianaAssets = IMapConst({
    PieceKind.blackRook:
        AssetImage('lib/piece_sets/tatiana/bR.png', package: 'chessground'),
    PieceKind.blackPawn:
        AssetImage('lib/piece_sets/tatiana/bP.png', package: 'chessground'),
    PieceKind.blackKnight:
        AssetImage('lib/piece_sets/tatiana/bN.png', package: 'chessground'),
    PieceKind.blackBishop:
        AssetImage('lib/piece_sets/tatiana/bB.png', package: 'chessground'),
    PieceKind.blackQueen:
        AssetImage('lib/piece_sets/tatiana/bQ.png', package: 'chessground'),
    PieceKind.blackKing:
        AssetImage('lib/piece_sets/tatiana/bK.png', package: 'chessground'),
    PieceKind.whiteRook:
        AssetImage('lib/piece_sets/tatiana/wR.png', package: 'chessground'),
    PieceKind.whitePawn:
        AssetImage('lib/piece_sets/tatiana/wP.png', package: 'chessground'),
    PieceKind.whiteKnight:
        AssetImage('lib/piece_sets/tatiana/wN.png', package: 'chessground'),
    PieceKind.whiteBishop:
        AssetImage('lib/piece_sets/tatiana/wB.png', package: 'chessground'),
    PieceKind.whiteQueen:
        AssetImage('lib/piece_sets/tatiana/wQ.png', package: 'chessground'),
    PieceKind.whiteKing:
        AssetImage('lib/piece_sets/tatiana/wK.png', package: 'chessground'),
  });
}
