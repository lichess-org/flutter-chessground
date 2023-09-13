import 'package:flutter_test/flutter_test.dart';
import 'package:chessground/chessground.dart';

const initialFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR';

void main() {
  test('pawn premoves', () {
    expect(
      premovesOf('e2', readFen(initialFen)),
      equals({'d3', 'e3', 'e4', 'f3'}),
    );
  });

  test('knight premoves', () {
    expect(premovesOf('b1', readFen(initialFen)), equals({'a3', 'c3', 'd2'}));
  });

  test('bishop premoves', () {
    expect(
      premovesOf('c1', readFen(initialFen)),
      equals({'a3', 'b2', 'd2', 'e3', 'f4', 'g5', 'h6'}),
    );
  });

  test('rook premoves', () {
    expect(
      premovesOf('a1', readFen(initialFen)),
      equals({
        'a2',
        'a3',
        'a4',
        'a5',
        'a6',
        'a7',
        'a8',
        'b1',
        'c1',
        'd1',
        'e1',
        'f1',
        'g1',
        'h1',
      }),
    );
  });

  test('queen premoves', () {
    expect(
      premovesOf('d1', readFen(initialFen)),
      equals({
        'a1',
        'b1',
        'c1',
        'e1',
        'f1',
        'g1',
        'h1',
        'd2',
        'd3',
        'd4',
        'd5',
        'd6',
        'd7',
        'd8',
        'c2',
        'b3',
        'a4',
        'e2',
        'f3',
        'g4',
        'h5',
      }),
    );
  });

  test('king premoves', () {
    expect(
      premovesOf('e1', readFen(initialFen), canCastle: true),
      equals({'a1', 'c1', 'd1', 'd2', 'e2', 'f2', 'f1', 'g1', 'h1'}),
    );

    expect(
      premovesOf('e1', readFen(initialFen)),
      equals({'d1', 'd2', 'e2', 'f2', 'f1'}),
    );
  });
}
