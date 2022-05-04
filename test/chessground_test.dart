import 'package:flutter_test/flutter_test.dart';

import 'package:chessground/chessground.dart';

void main() {
  test('read fen', () {
    const initialFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR';
    final pieces = readFen(initialFen);
    expect(pieces.length, 32);
  });
}
