import 'dart:async';
import 'dart:convert' show base64;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'widgets/piece.dart';

/// A singleton cache for chess piece images.
///
/// This is useful to avoid using the global flutter image cache and the standard
/// [Image] widget which can be unpredictable, and can cause images to blink.
///
/// The images should be preloaded into the cache using the [load] method before
/// they are used in the [PieceWidget]. This will ensure that the images are
/// available when the [PieceWidget] is built.
///
/// Example:
/// ```dart
/// // in main.dart
/// final PieceAssets assets = getPieceAssets();
/// final devicePixelRatio = WidgetsBinding
///         .instance.platformDispatcher.implicitView?.devicePixelRatio ?? 1.0;
/// for (final asset in assets.values) {
///   await ChessgroundImages.instance.load(asset, devicePixelRatio: devicePixelRatio);
/// }
/// ```
///
/// Using the cache is optional, and the [PieceWidget] will load images directly
/// from the [AssetImage] if the cache is not used.
///
/// When the pieces are cached in memory, the [PieceWidget] class will display
/// the piece image using the [RawImage] widget.
///
/// This is the responsibility of the user to dispose of the cache when it is no
/// longer needed, or when changing the piece set, using the [clear] method.
class ChessgroundImages {
  ChessgroundImages._();

  static final instance = ChessgroundImages._();

  final Map<AssetImage, _ImageEntry> _assets = {};

  /// Adds the [image] into the cache under the key [asset].
  ///
  /// The cache will assume the ownership of the [image], and will properly
  /// dispose of it at the end.
  void add(AssetImage asset, ui.Image image) {
    _assets[asset]?.dispose();
    _assets[asset] = _ImageEntry.fromImage(image);
  }

  /// Removes the image [asset] from the cache.
  ///
  /// No error is raised if the image [asset] is not present in the cache.
  ///
  /// This calls [ui.Image.dispose], so make sure that you don't use the previously
  /// cached image once it is cleared (removed) from the cache.
  void evict(AssetImage asset) {
    final removedAsset = _assets.remove(asset);
    removedAsset?.dispose();
  }

  /// Removes all cached images.
  ///
  /// This calls [ui.Image.dispose] for all images in the cache, so make sure that
  /// you don't use any of the previously cached images once [clear] has
  /// been called.
  void clear() {
    _assets.forEach((_, asset) => asset.dispose());
    _assets.clear();
  }

  /// Returns the image [asset] from the cache if it exists.
  ///
  /// The image returned can be used as long as it remains in the cache, but
  /// doesn't need to be explicitly disposed.
  ///
  /// If you want to retain the image even after you remove it from the cache,
  /// then you can call [ui.Image.clone] on it.
  ui.Image? get(AssetImage asset) {
    return _assets[asset]?.image;
  }

  /// Loads the specified [asset] into the cache.
  ///
  /// The image is loaded using the [AssetBundle] specified in the [asset], or
  /// the [rootBundle] if the [asset] doesn't specify a bundle.
  ///
  /// The [devicePixelRatio] can be specified to load the image at a different
  /// resolution than the default.
  Future<ui.Image> load(
    AssetImage asset, {
    double? devicePixelRatio,
  }) async {
    final key = await asset
        .obtainKey(ImageConfiguration(devicePixelRatio: devicePixelRatio));
    return (_assets[asset] ??= _ImageEntry.future(
      _fetchToMemory(asset.bundle ?? rootBundle, key.name),
    ))
        .retrieveAsync();
  }

  /// Loads the specified [base64] image into the cache.
  Future<ui.Image> loadBase64(AssetImage asset, String base64) {
    return (_assets[asset] ??= _ImageEntry.future(_fetchFromBase64(base64)))
        .retrieveAsync();
  }

  /// Whether the cache contains the specified [key] or not.
  bool containsKey(AssetImage key) => _assets.containsKey(key);

  /// Returns the list of keys in the cache.
  List<AssetImage> get keys => _assets.keys.toList();

  AssetImage? findKeyForImage(ui.Image image) {
    return _assets.keys.firstWhere(
      (k) => _assets[k]?.image?.isCloneOf(image) ?? false,
    );
  }

  /// Waits until all currently pending image loading operations complete.
  Future<void> ready() {
    return Future.wait(_assets.values.map((asset) => asset.retrieveAsync()));
  }

  Future<ui.Image> _fetchFromBase64(String base64Data) {
    final data = base64Data.substring(base64Data.indexOf(',') + 1);
    final bytes = base64.decode(data);
    return decodeImageFromList(bytes);
  }

  Future<ui.Image> _fetchToMemory(AssetBundle bundle, String name) async {
    final data = await bundle.load(name);
    final bytes = Uint8List.view(data.buffer);
    return decodeImageFromList(bytes);
  }
}

/// Individual entry in the [ChessgroundImages] cache.
///
/// This class owns the [ui.Image] object, which can be disposed of using the
/// [dispose] method.
class _ImageEntry {
  _ImageEntry.future(Future<ui.Image> future) : _future = future {
    _future!.then((image) {
      _image = image;
      _future = null;
    });
  }

  _ImageEntry.fromImage(ui.Image image) : _image = image;

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
