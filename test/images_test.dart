import 'dart:ui' as ui;

import 'package:chessground/chessground.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

ChessgroundImages get _cache => ChessgroundImages.instance;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // A simple 1x1 pixel encoded as base64
  const pixel =
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJA'
      'AAAAXNSR0IArs4c6QAAAA1JREFUGFdjWP33/n8ACGUDhwieHSEAAAAASUVORK5CYII=';

  setUp(() {
    _cache.clear();
  });

  test('load image', () async {
    const asset = AssetImage('piece.png');
    final image = await _cache.loadBase64(asset, pixel);
    expect(image, isA<ui.Image>());
    expect(_cache.get(asset), image);
  });

  test('access non-existent image', () {
    expect(_cache.get(const AssetImage('non-existent.png')), null);
  });

  test('clear', () {
    final image = _MockImage();
    const asset = AssetImage('piece.png');
    _cache.add(asset, image);
    expect(image.disposedCount, 0);
    _cache.evict(asset);
    expect(image.disposedCount, 1);
  });

  test('clear', () {
    final images = List.generate(10, (_) => _MockImage());
    for (var i = 0; i < images.length; i++) {
      _cache.add(AssetImage(i.toString()), images[i]);
    }
    expect(images.map((image) => image.disposedCount).fold(0, (prev, v) => prev + v), 0);
    _cache.clear();
    expect(
      images.map((image) => image.disposedCount).fold(0, (prev, v) => prev + v),
      images.length,
    );
  });

  test('contains', () {
    final images = List.generate(10, (_) => _MockImage());
    for (var i = 0; i < images.length; i++) {
      final key = AssetImage(i.toString());
      _cache.add(key, images[i]);
      expect(_cache.containsKey(key), isTrue);
    }
    _cache.clear();
    for (var i = 0; i < images.length; i++) {
      final key = AssetImage(i.toString());
      expect(_cache.containsKey(key), isFalse);
    }
  });

  test('keys', () {
    final images = List.generate(10, (_) => _MockImage());
    for (var i = 0; i < images.length; i++) {
      final key = AssetImage(i.toString());
      _cache.add(key, images[i]);
    }
    expect(_cache.keys.toSet(), {for (var i = 0; i < images.length; i++) AssetImage(i.toString())});
  });

  test('.ready()', () async {
    const asset1 = AssetImage('image1');
    const asset2 = AssetImage('image2');
    _cache.loadBase64(asset1, pixel);
    _cache.loadBase64(asset2, pixel);
    expect(_cache.get(asset1), isNull);
    expect(_cache.get(asset2), isNull);
    await _cache.ready();
    expect(_cache.get(asset1), isNotNull);
    expect(_cache.get(asset2), isNotNull);
  });
}

class _MockImage extends Mock implements ui.Image {
  int disposedCount = 0;

  @override
  void dispose() {
    disposedCount++;
  }
}
