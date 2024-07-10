import 'package:flutter/widgets.dart';
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

  group('Shape', () {
    test('implements hashCode/==', () {
      expect(
        const Arrow(
          color: Color(0xFF000000),
          orig: 'a1',
          dest: 'a2',
        ),
        const Arrow(
          color: Color(0xFF000000),
          orig: 'a1',
          dest: 'a2',
        ),
      );
      expect(
        const Arrow(
          color: Color(0xFF000000),
          orig: 'a1',
          dest: 'a2',
        ).hashCode,
        const Arrow(
          color: Color(0xFF000000),
          orig: 'a1',
          dest: 'a2',
        ).hashCode,
      );
      expect(
        const Arrow(
          color: Color(0xFF000000),
          orig: 'a1',
          dest: 'a2',
        ),
        isNot(
          const Arrow(
            color: Color(0xFF000000),
            orig: 'a1',
            dest: 'a3',
            scale: 0.9,
          ),
        ),
      );
      expect(
        const Arrow(
          color: Color(0xFF000000),
          orig: 'a1',
          dest: 'a2',
        ).hashCode,
        isNot(
          const Arrow(
            color: Color(0xFF000000),
            orig: 'a1',
            dest: 'a3',
            scale: 0.2,
          ).hashCode,
        ),
      );

      expect(
        const Circle(color: Color(0xFF000000), orig: 'a1'),
        const Circle(color: Color(0xFF000000), orig: 'a1'),
      );

      expect(
        const Circle(color: Color(0xFF000000), orig: 'a1').hashCode,
        const Circle(color: Color(0xFF000000), orig: 'a1').hashCode,
      );

      expect(
        const Circle(color: Color(0xFF000000), orig: 'a1'),
        isNot(const Circle(color: Color(0xFF000000), orig: 'a1', scale: 0.1)),
      );

      expect(
        const PieceShape(
          orig: 'a1',
          role: Role.knight,
          color: Color(0xFF000000),
        ),
        const PieceShape(
          orig: 'a1',
          role: Role.knight,
          color: Color(0xFF000000),
        ),
      );

      expect(
        const PieceShape(
          orig: 'a1',
          role: Role.knight,
          color: Color(0xFF000000),
        ).hashCode,
        const PieceShape(
          orig: 'a1',
          role: Role.knight,
          color: Color(0xFF000000),
        ).hashCode,
      );

      expect(
        const PieceShape(
          orig: 'a1',
          role: Role.knight,
          color: Color(0xFF000000),
        ),
        isNot(
          const PieceShape(
            orig: 'a1',
            role: Role.knight,
            color: Color(0xFF000000),
            scale: 0.9,
          ),
        ),
      );
    });

    test('copyWith', () {
      const arrow = Arrow(
        color: Color(0xFF000000),
        orig: 'a1',
        dest: 'a2',
      );

      expect(
        arrow.copyWith(
          color: const Color(0xFF000001),
          orig: 'a3',
          dest: 'a4',
        ),
        const Arrow(
          color: Color(0xFF000001),
          orig: 'a3',
          dest: 'a4',
        ),
      );

      const circle = Circle(
        color: Color(0xFF000000),
        orig: 'a1',
      );

      expect(
        circle.copyWith(
          color: const Color(0xFF000001),
          orig: 'a2',
        ),
        const Circle(
          color: Color(0xFF000001),
          orig: 'a2',
        ),
      );

      const pieceShape = PieceShape(
        orig: 'a1',
        role: Role.knight,
        color: Color(0xFF000000),
      );

      expect(
        pieceShape.copyWith(
          orig: 'a2',
          role: Role.bishop,
          color: const Color(0xFF000001),
        ),
        const PieceShape(
          orig: 'a2',
          role: Role.bishop,
          color: Color(0xFF000001),
        ),
      );
    });
  });
}
