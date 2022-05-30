import 'package:flutter_test/flutter_test.dart';

import 'package:chessground/src/models.dart';

void main() {
  test('Coord.fromSquareId', () {
    expect(Coord.fromSquareId('a1'), const Coord(x: 0, y: 0));
    expect(Coord.fromSquareId('a5'), const Coord(x: 0, y: 4));
    expect(Coord.fromSquareId('e3'), const Coord(x: 4, y: 2));
    expect(Coord.fromSquareId('h8'), const Coord(x: 7, y: 7));
  });

  test('Coord.squareId', () {
    expect(const Coord(x: 0, y: 0).squareId(), 'a1');
    expect(const Coord(x: 0, y: 4).squareId(), 'a5');
    expect(const Coord(x: 4, y: 2).squareId(), 'e3');
    expect(const Coord(x: 7, y: 7).squareId(), 'h8');
  });
}
