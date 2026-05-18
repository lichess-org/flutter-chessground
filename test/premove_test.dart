import 'package:flutter_test/flutter_test.dart';
import 'package:dartchess/dartchess.dart';
import 'package:chessground/chessground.dart';

const fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR';

void main() {
  test('white pawn premoves from starting rank', () {
    expect(
      premovesOf(Square.e2, readFen(fen)),
      equals({Square.d3, Square.e3, Square.e4, Square.f3}),
    );
  });

  test('white pawn premoves from non-starting rank', () {
    // no double push allowed from rank 3
    expect(
      premovesOf(Square.e3, readFen('8/8/8/8/8/4P3/8/8')),
      equals({Square.d4, Square.e4, Square.f4}),
    );
  });

  test('black pawn premoves from starting rank', () {
    expect(
      premovesOf(Square.e7, readFen(fen)),
      equals({Square.d6, Square.e5, Square.e6, Square.f6}),
    );
  });

  test('black pawn premoves from non-starting rank', () {
    // no double push allowed from rank 6
    expect(
      premovesOf(Square.e6, readFen('8/8/4p3/8/8/8/8/8')),
      equals({Square.d5, Square.e5, Square.f5}),
    );
  });

  test('knight premoves', () {
    expect(premovesOf(Square.b1, readFen(fen)), equals({Square.a3, Square.c3, Square.d2}));
  });

  test('bishop premoves', () {
    expect(
      premovesOf(Square.c1, readFen(fen)),
      equals({Square.a3, Square.b2, Square.d2, Square.e3, Square.f4, Square.g5, Square.h6}),
    );
  });

  test('rook premoves', () {
    expect(
      premovesOf(Square.a1, readFen(fen)),
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
      premovesOf(Square.d1, readFen(fen)),
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

  test('white king premoves', () {
    expect(
      premovesOf(Square.e1, readFen(fen), canCastle: true),
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
      premovesOf(Square.e1, readFen(fen)),
      equals({Square.d1, Square.d2, Square.e2, Square.f2, Square.f1}),
    );
  });

  test('black king premoves', () {
    expect(
      premovesOf(Square.e8, readFen('r3k2r/8/8/8/8/8/8/8'), canCastle: true),
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

    expect(
      premovesOf(Square.e8, readFen('r3k2r/8/8/8/8/8/8/8')),
      equals({Square.d7, Square.d8, Square.e7, Square.f7, Square.f8}),
    );
  });

  test('chess960 king castling premoves', () {
    // king at d1 can premove to rook on a1 (Chess960 castling)
    expect(
      premovesOf(Square.d1, readFen('8/8/8/8/8/8/8/R2K4'), canCastle: true),
      equals({Square.a1, Square.c1, Square.c2, Square.d2, Square.e1, Square.e2}),
    );
  });
}
