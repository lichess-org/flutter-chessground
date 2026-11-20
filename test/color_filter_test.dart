import 'package:chessground/chessground.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('colorAdjustFilter', () {
    test('is null when no adjustment is set', () {
      expect(colorAdjustFilter(), isNull);
    });

    test('is set when any adjustment is applied', () {
      expect(colorAdjustFilter(brightness: 0.5), isNotNull);
      expect(colorAdjustFilter(contrast: 0.5), isNotNull);
      expect(colorAdjustFilter(hue: 90), isNotNull);
    });
  });

  group('colorAdjustMatrix', () {
    test('brightness scales the RGB channels', () {
      final matrix = colorAdjustMatrix(brightness: 0.5);
      expect(matrix[0], closeTo(0.5, 1e-6));
      expect(matrix[6], closeTo(0.5, 1e-6));
      expect(matrix[12], closeTo(0.5, 1e-6));
      expect(matrix[18], 1.0);
    });

    test('zero contrast neutralizes the RGB channels with a half-range offset', () {
      final matrix = colorAdjustMatrix(contrast: 0.0);
      expect(matrix[0], closeTo(0, 1e-6));
      expect(matrix[4], closeTo(127.5, 1e-6));
      expect(matrix[9], closeTo(127.5, 1e-6));
      expect(matrix[14], closeTo(127.5, 1e-6));
    });
  });
}
