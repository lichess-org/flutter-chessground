import 'package:flutter_test/flutter_test.dart';

import 'package:chessground/src/utils.dart';
import 'package:chessground/src/models.dart';

void main() {
  test('squareId2Coord', () {
    expect(squareId2Coord('a1'), const Coord(x: 0, y: 0));
    expect(squareId2Coord('a5'), const Coord(x: 0, y: 4));
    expect(squareId2Coord('e3'), const Coord(x: 4, y: 2));
    expect(squareId2Coord('h8'), const Coord(x: 7, y: 7));
  });

  test('coord2SquareId', () {
    expect(coord2SquareId(const Coord(x: 0, y: 0)), 'a1');
    expect(coord2SquareId(const Coord(x: 0, y: 4)), 'a5');
    expect(coord2SquareId(const Coord(x: 4, y: 2)), 'e3');
    expect(coord2SquareId(const Coord(x: 7, y: 7)), 'h8');
  });
}
