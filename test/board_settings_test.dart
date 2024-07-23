import 'package:flutter_test/flutter_test.dart';
import 'package:chessground/chessground.dart';

void main() {
  group('ChessboardSettings', () {
    test('implements hashCode/==', () {
      expect(const ChessboardSettings(), const ChessboardSettings());
      expect(
        const ChessboardSettings().hashCode,
        const ChessboardSettings().hashCode,
      );

      expect(
        const ChessboardSettings(),
        isNot(
          const ChessboardSettings(
            colorScheme: ChessboardColorScheme.blue,
          ),
        ),
      );
    });

    test('copyWith', () {
      expect(
        const ChessboardSettings().copyWith(),
        const ChessboardSettings(),
      );

      expect(
        const ChessboardSettings()
            .copyWith(
              colorScheme: ChessboardColorScheme.blue,
            )
            .colorScheme,
        ChessboardColorScheme.blue,
      );
    });
  });
}
