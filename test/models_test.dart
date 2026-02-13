import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chessground/chessground.dart';

void main() {
  group('Shape', () {
    test('implements hashCode/==', () {
      expect(
        const Arrow(color: Color(0xFF000000), orig: Square.a1, dest: Square.a2),
        const Arrow(color: Color(0xFF000000), orig: Square.a1, dest: Square.a2),
      );
      expect(
        const Arrow(color: Color(0xFF000000), orig: Square.a1, dest: Square.a2).hashCode,
        const Arrow(color: Color(0xFF000000), orig: Square.a1, dest: Square.a2).hashCode,
      );
      expect(
        const Arrow(color: Color(0xFF000000), orig: Square.a1, dest: Square.a2),
        isNot(const Arrow(color: Color(0xFF000000), orig: Square.a1, dest: Square.a3, scale: 0.9)),
      );
      expect(
        const Arrow(color: Color(0xFF000000), orig: Square.a1, dest: Square.a2).hashCode,
        isNot(
          const Arrow(
            color: Color(0xFF000000),
            orig: Square.a1,
            dest: Square.a3,
            scale: 0.2,
          ).hashCode,
        ),
      );

      expect(
        const Circle(color: Color(0xFF000000), orig: Square.a1),
        const Circle(color: Color(0xFF000000), orig: Square.a1),
      );

      expect(
        const Circle(color: Color(0xFF000000), orig: Square.a1).hashCode,
        const Circle(color: Color(0xFF000000), orig: Square.a1).hashCode,
      );

      expect(
        const Circle(color: Color(0xFF000000), orig: Square.a1),
        isNot(const Circle(color: Color(0xFF000000), orig: Square.a1, scale: 0.1)),
      );

      expect(
        const PieceShape(
          orig: Square.a1,
          piece: Piece.whiteKnight,
          pieceAssets: PieceSet.horseyAssets,
          opacity: 0.1,
          color: Color(0xFF000000),
        ),
        const PieceShape(
          orig: Square.a1,
          piece: Piece.whiteKnight,
          pieceAssets: PieceSet.horseyAssets,
          opacity: 0.1,
          color: Color(0xFF000000),
        ),
      );

      expect(
        const PieceShape(
          orig: Square.a1,
          piece: Piece.whiteKnight,
          pieceAssets: PieceSet.horseyAssets,
          opacity: 0.1,
          color: Color(0xFF000000),
        ).hashCode,
        const PieceShape(
          orig: Square.a1,
          piece: Piece.whiteKnight,
          pieceAssets: PieceSet.horseyAssets,
          opacity: 0.1,
          color: Color(0xFF000000),
        ).hashCode,
      );

      expect(
        const PieceShape(
          orig: Square.a1,
          piece: Piece.whiteKnight,
          pieceAssets: PieceSet.horseyAssets,
          color: Color(0xFF000000),
        ),
        isNot(
          const PieceShape(
            orig: Square.a1,
            piece: Piece.whiteKnight,
            pieceAssets: PieceSet.horseyAssets,
            color: Color(0xFF000000),
            scale: 0.123,
          ),
        ),
      );
    });

    test('Circle.newDest', () {
      const circle = Circle(color: Color(0xFF000000), orig: Square.a1);

      expect(
        circle.newDest(Square.a2),
        const Arrow(color: Color(0xFF000000), orig: Square.a1, dest: Square.a2),
      );

      expect(circle.newDest(Square.a1), const Circle(color: Color(0xFF000000), orig: Square.a1));
    });

    test('Arrow.newDest', () {
      const arrow = Arrow(color: Color(0xFF000000), orig: Square.a1, dest: Square.a2);

      expect(
        arrow.newDest(Square.a3),
        const Arrow(color: Color(0xFF000000), orig: Square.a1, dest: Square.a3),
      );

      expect(arrow.newDest(Square.a1), const Circle(color: Color(0xFF000000), orig: Square.a1));
    });

    test('copyWith', () {
      const arrow = Arrow(color: Color(0xFF000000), orig: Square.a1, dest: Square.a2);

      expect(
        arrow.copyWith(color: const Color(0xFF000001), orig: Square.a3, dest: Square.a4),
        const Arrow(color: Color(0xFF000001), orig: Square.a3, dest: Square.a4),
      );

      const circle = Circle(color: Color(0xFF000000), orig: Square.a1);

      expect(
        circle.copyWith(color: const Color(0xFF000001), orig: Square.a2),
        const Circle(color: Color(0xFF000001), orig: Square.a2),
      );

      const pieceShape = PieceShape(
        orig: Square.a1,
        piece: Piece.whiteKnight,
        pieceAssets: PieceSet.horseyAssets,
        color: Color(0xFF000000),
      );

      expect(
        pieceShape.copyWith(orig: Square.a2, opacity: 0.123, color: const Color(0xFF000001)),
        const PieceShape(
          orig: Square.a2,
          piece: Piece.whiteKnight,
          pieceAssets: PieceSet.horseyAssets,
          opacity: 0.123,
          color: Color(0xFF000001),
        ),
      );
    });
  });

  group('Annotation', () {
    test('implements hashCode/==', () {
      expect(
        const Annotation(symbol: '!', color: Color(0xFF000000)),
        const Annotation(symbol: '!', color: Color(0xFF000000)),
      );

      expect(
        const Annotation(symbol: '!', color: Color(0xFF000000)).hashCode,
        const Annotation(symbol: '!', color: Color(0xFF000000)).hashCode,
      );

      expect(
        const Annotation(symbol: '!', color: Color(0xFF000000)),
        isNot(const Annotation(symbol: '?', color: Color(0xFF000000))),
      );

      expect(
        const Annotation(symbol: '!', color: Color(0xFF000000)).hashCode,
        isNot(const Annotation(symbol: '?', color: Color(0xFF000000)).hashCode),
      );

      expect(
        const Annotation(symbol: '!', color: Color(0xFF000000)),
        isNot(const Annotation(symbol: '!', color: Color(0xFF000001))),
      );

      expect(
        const Annotation(symbol: '!', color: Color(0xFF000000)).hashCode,
        isNot(const Annotation(symbol: '!', color: Color(0xFF000001)).hashCode),
      );
    });
  });
}
