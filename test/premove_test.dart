import 'package:flutter_test/flutter_test.dart';
import 'package:dartchess/dartchess.dart';
import 'package:chessground/chessground.dart';

const initialFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR';

void main() {
  test('pawn premoves', () {
    expect(
      premovesOf(Square.e2, readFen(initialFen)),
      equals({Square.d3, Square.e3, Square.e4, Square.f3}),
    );
  });

  test('knight premoves', () {
    expect(premovesOf(Square.b1, readFen(initialFen)), equals({Square.a3, Square.c3, Square.d2}));
  });

  test('bishop premoves', () {
    expect(
      premovesOf(Square.c1, readFen(initialFen)),
      equals({Square.a3, Square.b2, Square.d2, Square.e3, Square.f4, Square.g5, Square.h6}),
    );
  });

  test('rook premoves', () {
    expect(
      premovesOf(Square.a1, readFen(initialFen)),
      equals({
        Square.a2,
        Square.a3,
        Square.a4,
        Square.a5,
        Square.a6,
        Square.a7,
        Square.a8,
        Square.b1,
        Square.c1,
        Square.d1,
        Square.e1,
        Square.f1,
        Square.g1,
        Square.h1,
      }),
    );
  });

  test('queen premoves', () {
    expect(
      premovesOf(Square.d1, readFen(initialFen)),
      equals({
        Square.a1,
        Square.b1,
        Square.c1,
        Square.e1,
        Square.f1,
        Square.g1,
        Square.h1,
        Square.d2,
        Square.d3,
        Square.d4,
        Square.d5,
        Square.d6,
        Square.d7,
        Square.d8,
        Square.c2,
        Square.b3,
        Square.a4,
        Square.e2,
        Square.f3,
        Square.g4,
        Square.h5,
      }),
    );
  });

  test('king premoves', () {
    expect(
      premovesOf(Square.e1, readFen(initialFen), canCastle: true),
      equals({
        Square.a1,
        Square.c1,
        Square.d1,
        Square.d2,
        Square.e2,
        Square.f2,
        Square.f1,
        Square.g1,
        Square.h1,
      }),
    );

    expect(
      premovesOf(Square.e1, readFen(initialFen)),
      equals({Square.d1, Square.d2, Square.e2, Square.f2, Square.f1}),
    );
  });
}
