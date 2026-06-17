import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chessground/chessground.dart';

void main() {
  group('ChessboardColorScheme', () {
    test('implements hashCode/==', () {
      expect(ChessboardColorScheme.brown, ChessboardColorScheme.brown);
      expect(ChessboardColorScheme.brown.hashCode, ChessboardColorScheme.brown.hashCode);

      expect(ChessboardColorScheme.brown, isNot(ChessboardColorScheme.blue));
      expect(ChessboardColorScheme.brown.hashCode, isNot(ChessboardColorScheme.blue.hashCode));
    });

    test('copyWith', () {
      expect(ChessboardColorScheme.brown.copyWith(), ChessboardColorScheme.brown);

      expect(
        ChessboardColorScheme.brown.copyWith(validMoves: const Color(0xFFFFFFFF)).validMoves,
        const Color(0xFFFFFFFF),
      );

      expect(
        ChessboardColorScheme.brown
            .copyWith(lightSquare: ChessboardColorScheme.blue.lightSquare)
            .lightSquare,
        ChessboardColorScheme.blue.lightSquare,
      );

      final copy = ChessboardColorScheme.brown.copyWith(
        darkSquare: const Color(0xFF000000),
        validPremoves: const Color(0xFF123456),
      );
      expect(copy.darkSquare, const Color(0xFF000000));
      expect(copy.validPremoves, const Color(0xFF123456));
      // unchanged fields are preserved
      expect(copy.lightSquare, ChessboardColorScheme.brown.lightSquare);
      expect(copy.lastMove, ChessboardColorScheme.brown.lastMove);
    });
  });
}
