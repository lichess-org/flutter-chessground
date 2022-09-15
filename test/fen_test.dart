import 'package:flutter_test/flutter_test.dart';
import 'package:chessground/chessground.dart';

const initialFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR';

void main() {
  test('read fen', () {
    final pieces = readFen(initialFen);
    expect(pieces.length, 32);
  });
}
