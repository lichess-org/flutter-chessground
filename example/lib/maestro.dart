import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:chessground/chessground.dart' as cg;

const cg.PieceAssets maestroPieceSet = IMapConst({
  PieceKind.blackRook: AssetImage('lib/piece_set/maestro/bR.png'),
  PieceKind.blackPawn: AssetImage('lib/piece_set/maestro/bP.png'),
  PieceKind.blackKnight: AssetImage('lib/piece_set/maestro/bN.png'),
  PieceKind.blackBishop: AssetImage('lib/piece_set/maestro/bB.png'),
  PieceKind.blackQueen: AssetImage('lib/piece_set/maestro/bQ.png'),
  PieceKind.blackKing: AssetImage('lib/piece_set/maestro/bK.png'),
  PieceKind.whiteRook: AssetImage('lib/piece_set/maestro/wR.png'),
  PieceKind.whiteKnight: AssetImage('lib/piece_set/maestro/wN.png'),
  PieceKind.whiteBishop: AssetImage('lib/piece_set/maestro/wB.png'),
  PieceKind.whiteQueen: AssetImage('lib/piece_set/maestro/wQ.png'),
  PieceKind.whiteKing: AssetImage('lib/piece_set/maestro/wK.png'),
  PieceKind.whitePawn: AssetImage('lib/piece_set/maestro/wP.png'),
});
