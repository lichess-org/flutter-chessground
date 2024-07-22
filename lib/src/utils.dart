import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'models.dart';

/// Gets all the legal moves of the [Position] in the algebraic coordinate notation.
///
/// Includes both possible representations of castling moves (unless `chess960` is true).
IMap<SquareId, ISet<SquareId>> legalMovesOf(
  Position pos, {
  bool isChess960 = false,
}) {
  final Map<SquareId, ISet<SquareId>> result = {};
  for (final entry in pos.legalMoves.entries) {
    final dests = entry.value.squares;
    if (dests.isNotEmpty) {
      final from = entry.key;
      final destSet = dests.map((e) => SquareId(toAlgebraic(e))).toSet();
      if (!isChess960 &&
          from == pos.board.kingOf(pos.turn) &&
          squareFile(entry.key) == 4) {
        if (dests.contains(0)) {
          destSet.add(const SquareId('c1'));
        } else if (dests.contains(56)) {
          destSet.add(const SquareId('c8'));
        }
        if (dests.contains(7)) {
          destSet.add(const SquareId('g1'));
        } else if (dests.contains(63)) {
          destSet.add(const SquareId('g8'));
        }
      }
      result[SquareId(toAlgebraic(from))] = ISet(destSet);
    }
  }
  return IMap(result);
}
