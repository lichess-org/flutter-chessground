import 'package:flutter_test/flutter_test.dart';
import 'package:chessground/chessground.dart';

const fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR';

void main() {
  test('read fen', () {
    final pieces = readFen(fen);
    expect(pieces.length, 32);
  });
}
