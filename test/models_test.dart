import 'package:flutter_test/flutter_test.dart';
import 'package:chessground/chessground.dart';

void main() {
  group('Coord', () {
    test('implements hashCode/==', () {
      expect(const Coord(x: 0, y: 0), const Coord(x: 0, y: 0));
      expect(
        const Coord(x: 0, y: 0).hashCode,
        const Coord(x: 0, y: 0).hashCode,
      );
      expect(const Coord(x: 0, y: 0), isNot(const Coord(x: 0, y: 1)));
      expect(
        const Coord(x: 0, y: 0).hashCode,
        isNot(const Coord(x: 0, y: 1).hashCode),
      );
    });

    test('fromSquareId', () {
      expect(Coord.fromSquareId('a1'), const Coord(x: 0, y: 0));
      expect(Coord.fromSquareId('a5'), const Coord(x: 0, y: 4));
      expect(Coord.fromSquareId('e3'), const Coord(x: 4, y: 2));
      expect(Coord.fromSquareId('h8'), const Coord(x: 7, y: 7));
    });

    test('squareId', () {
      expect(const Coord(x: 0, y: 0).squareId, 'a1');
      expect(const Coord(x: 0, y: 4).squareId, 'a5');
      expect(const Coord(x: 4, y: 2).squareId, 'e3');
      expect(const Coord(x: 7, y: 7).squareId, 'h8');
    });
  });
}
