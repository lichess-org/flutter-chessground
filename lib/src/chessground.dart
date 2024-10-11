import 'package:flutter/services.dart';

import 'images.dart';

// ignore: avoid_classes_with_only_static_members
/// Class that provides static access to shared instances used by the package.
class Chessground {
  /// Access to the shared instance of piece images cache.
  ///
  /// By default, the cache is configured to retrieve images using the [rootBundle].
  /// If you need to use a different [AssetBundle], you can create a new instance of [PieceImages].
  static PieceImages images = PieceImages(rootBundle);
}
