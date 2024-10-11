import 'dart:async';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

// Inspired by Flame Engine image cache:
// https://github.com/flame-engine/flame/blob/main/packages/flame/lib/src/cache/images.dart

/// A cache for chess piece images.
///
/// This class is used to load and cache images for chess pieces.
class PieceImages {
  PieceImages(this.bundle);

  /// The [AssetBundle] from which images are loaded.
  final AssetBundle bundle;

  final Map<String, _ImageAsset> _assets = {};

  /// Removes the image [name] from the cache.
  ///
  /// No error is raised if the image [name] is not present in the cache.
  ///
  /// This calls [Image.dispose], so make sure that you don't use the previously
  /// cached image once it is cleared (removed) from the cache.
  void clear(String name) {
    final removedAsset = _assets.remove(name);
    removedAsset?.dispose();
  }

  /// Removes all cached images.
  ///
  /// This calls [Image.dispose] for all images in the cache, so make sure that
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
  /// then you can call `Image.clone()` on it.
  Image? fromCache(String name) {
    return _assets[name]?.image;
  }

  /// Loads the specified image with [fileName] into the cache with the given [name].
  Future<Image> load(String name, String fileName) {
    return (_assets[name] ??= _ImageAsset.future(_fetchToMemory(fileName)))
        .retrieveAsync();
  }

  /// Whether the cache contains the specified [key] or not.
  bool containsKey(String key) => _assets.containsKey(key);

  /// Returns the list of keys in the cache.
  List<String> get keys => _assets.keys.toList();

  String? findKeyForImage(Image image) {
    return _assets.keys.firstWhere(
      (k) => _assets[k]?.image?.isCloneOf(image) ?? false,
    );
  }

  /// Waits until all currently pending image loading operations complete.
  Future<void> ready() {
    return Future.wait(_assets.values.map((asset) => asset.retrieveAsync()));
  }

  Future<Image> _fetchToMemory(String name) async {
    final data = await bundle.load(name);
    final bytes = Uint8List.view(data.buffer);
    return decodeImageFromList(bytes);
  }
}

/// Individual entry in the [Images] cache.
///
/// This class owns the [Image] object, which can be disposed of using the
/// [dispose] method.
class _ImageAsset {
  _ImageAsset.future(Future<Image> future) : _future = future {
    _future!.then((image) {
      _image = image;
      _future = null;
    });
  }

  Image? get image => _image;
  Image? _image;

  Future<Image>? _future;

  Future<Image> retrieveAsync() => _future ?? Future.value(_image);

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
