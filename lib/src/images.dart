import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'chessground.dart';
import 'widgets/piece.dart';

// Inspired by Flame Engine image cache:
// https://github.com/flame-engine/flame/blob/main/packages/flame/lib/src/cache/images.dart

/// A cache for chess piece images.
///
/// A static instance of this class is available as [Chessground.images] and is used
/// by the [PieceWidget] to get images for chess pieces.
///
/// This is useful to avoid using the global flutter image cache and the standard
/// [Image] widget which can be unpredictable, and can cause images to blink.
///
/// The images should be preloaded into the cache using the [load] method before
/// they are used in the [PieceWidget]. This will ensure that the images are
/// available when the [PieceWidget] is built.
/// The name of the cache entry must be the same as the [AssetImage.assetName] in
/// order to be used by the [PieceWidget].
///
/// Example:
/// ```dart
/// // in main.dart
/// for (final asset in pieceSet.assets.values) {
///      final key = await asset
///          .obtainKey(ImageConfiguration(devicePixelRatio: devicePixelRatio));
///      await Chessground.images.load(asset.assetName, key.name);
/// }
/// ```
///
/// Using the cache is optional, and the [PieceWidget] will load images directly
/// from the [AssetBundle] if the cache is not used.
///
/// When the pieces are cached in memory, the [PieceWidget] class will display
/// the piece image using the [RawImage] widget.
///
/// This is the responsibility of the user to dispose of the cache when it is no
/// longer needed, or when changing the piece set, using the [clearCache] method.
class PieceImages {
  PieceImages(this.bundle);

  /// The [AssetBundle] from which images are loaded.
  final AssetBundle bundle;

  final Map<String, _ImageAsset> _assets = {};

  /// Removes the image [name] from the cache.
  ///
  /// No error is raised if the image [name] is not present in the cache.
  ///
  /// This calls [ui.Image.dispose], so make sure that you don't use the previously
  /// cached image once it is cleared (removed) from the cache.
  void clear(String name) {
    final removedAsset = _assets.remove(name);
    removedAsset?.dispose();
  }

  /// Removes all cached images.
  ///
  /// This calls [ui.Image.dispose] for all images in the cache, so make sure that
  /// you don't use any of the previously cached images once [clearCache] has
  /// been called.
  void clearCache() {
    _assets.forEach((_, asset) => asset.dispose());
    _assets.clear();
  }

  /// Returns the image [name] from the cache if it exists.
  ///
  /// The image returned can be used as long as it remains in the cache, but
  /// doesn't need to be explicitly disposed.
  ///
  /// If you want to retain the image even after you remove it from the cache,
  /// then you can call [ui.Image.clone] on it.
  ui.Image? fromCache(String name) {
    return _assets[name]?.image;
  }

  /// Loads the specified image with [fileName] into the cache with the given [name].
  ///
  /// The [name] must be the [AssetImage.assetName] of the piece image in order to
  /// be used by the [PieceWidget].
  Future<ui.Image> load(String name, String fileName) {
    return (_assets[name] ??= _ImageAsset.future(_fetchToMemory(fileName)))
        .retrieveAsync();
  }

  /// Whether the cache contains the specified [key] or not.
  bool containsKey(String key) => _assets.containsKey(key);

  /// Returns the list of keys in the cache.
  List<String> get keys => _assets.keys.toList();

  String? findKeyForImage(ui.Image image) {
    return _assets.keys.firstWhere(
      (k) => _assets[k]?.image?.isCloneOf(image) ?? false,
    );
  }

  /// Waits until all currently pending image loading operations complete.
  Future<void> ready() {
    return Future.wait(_assets.values.map((asset) => asset.retrieveAsync()));
  }

  Future<ui.Image> _fetchToMemory(String name) async {
    final data = await bundle.load(name);
    final bytes = Uint8List.view(data.buffer);
    return decodeImageFromList(bytes);
  }
}

/// Individual entry in the [PieceImages] cache.
///
/// This class owns the [ui.Image] object, which can be disposed of using the
/// [dispose] method.
class _ImageAsset {
  _ImageAsset.future(Future<ui.Image> future) : _future = future {
    _future!.then((image) {
      _image = image;
      _future = null;
    });
  }

  ui.Image? get image => _image;
  ui.Image? _image;

  Future<ui.Image>? _future;

  Future<ui.Image> retrieveAsync() => _future ?? Future.value(_image);

  /// Properly dispose of an image asset.
  void dispose() {
    if (_image != null) {
      _image!.dispose();
      _image = null;
    }
    if (_future != null) {
      _future!.then((image) => image.dispose());
      _future = null;
    }
  }
}
