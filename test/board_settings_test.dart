import 'package:flutter_test/flutter_test.dart';
import 'package:chessground/chessground.dart';

void main() {
  group('BoardSettings', () {
    test('implements hashCode/==', () {
      expect(const BoardSettings(), const BoardSettings());
      expect(const BoardSettings().hashCode, const BoardSettings().hashCode);

      expect(
        const BoardSettings(),
        isNot(
          const BoardSettings(
            colorScheme: BoardColorScheme.blue,
          ),
        ),
      );
    });

    test('copyWith', () {
      expect(
        const BoardSettings().copyWith(),
        const BoardSettings(),
      );

      expect(
        const BoardSettings()
            .copyWith(
              colorScheme: BoardColorScheme.blue,
            )
            .colorScheme,
        BoardColorScheme.blue,
      );
    });
  });
}
