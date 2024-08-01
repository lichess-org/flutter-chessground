import 'package:chessground/chessground.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:dartchess/dartchess.dart';

void main() {
  test('legalMovesOf with Kh8', () {
    final setup = Setup.parseFen(
      'r1bq1r2/3n2k1/p1p1pp2/3pP2P/8/PPNB2Q1/2P2P2/R3K3 b Q - 1 22',
    );
    final pos = Chess.fromSetup(setup);
    final moves = legalMovesOf(pos);
    expect(moves[Square.g7], contains(Square.h8));
    expect(moves[Square.g7], isNot(contains(Square.g8)));
  });

  test('legalMovesOf with regular castle', () {
    final wtm =
        Chess.fromSetup(Setup.parseFen('r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1'));
    expect(
      legalMovesOf(wtm)[Square.e1],
      equals(
        {
          Square.a1,
          Square.c1,
          Square.d1,
          Square.d2,
          Square.e2,
          Square.f1,
          Square.f2,
          Square.g1,
          Square.h1,
        },
      ),
    );
    expect(legalMovesOf(wtm)[Square.e8], null);

    final btm =
        Chess.fromSetup(Setup.parseFen('r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 1'));
    expect(
      legalMovesOf(btm)[Square.e8],
      equals({
        Square.a8,
        Square.c8,
        Square.d7,
        Square.d8,
        Square.e7,
        Square.f7,
        Square.f8,
        Square.g8,
        Square.h8,
      }),
    );
    expect(legalMovesOf(btm)[Square.e1], null);
  });

  test('legalMovesOf with chess960 castle', () {
    final pos = Chess.fromSetup(
      Setup.parseFen(
        'rk2r3/pppbnppp/3p2n1/P2Pp3/4P2q/R5NP/1PP2PP1/1KNQRB2 b Kkq - 0 1',
      ),
    );
    expect(
      legalMovesOf(pos, isChess960: true)[Square.b8],
      equals(ISet(const {Square.a8, Square.c8, Square.e8})),
    );
  });
}
