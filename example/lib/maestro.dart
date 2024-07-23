import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:chessground/chessground.dart' as cg;

const cg.PieceAssets maestroPieceSet = IMapConst({
  kBlackRookKind: AssetImage('lib/piece_set/maestro/bR.png'),
  kBlackPawnKind: AssetImage('lib/piece_set/maestro/bP.png'),
  kBlackKnightKind: AssetImage('lib/piece_set/maestro/bN.png'),
  kBlackBishopKind: AssetImage('lib/piece_set/maestro/bB.png'),
  kBlackQueenKind: AssetImage('lib/piece_set/maestro/bQ.png'),
  kBlackKingKind: AssetImage('lib/piece_set/maestro/bK.png'),
  kWhiteRookKind: AssetImage('lib/piece_set/maestro/wR.png'),
  kWhiteKnightKind: AssetImage('lib/piece_set/maestro/wN.png'),
  kWhiteBishopKind: AssetImage('lib/piece_set/maestro/wB.png'),
  kWhiteQueenKind: AssetImage('lib/piece_set/maestro/wQ.png'),
  kWhiteKingKind: AssetImage('lib/piece_set/maestro/wK.png'),
  kWhitePawnKind: AssetImage('lib/piece_set/maestro/wP.png'),
});
