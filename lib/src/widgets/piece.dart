import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../models.dart';

/// Widget that displays a chess piece.
class PieceWidget extends StatelessWidget {
  const PieceWidget({
    super.key,
    required this.piece,
    required this.size,
    required this.pieceAssets,
    this.opacity,
    this.blindfoldMode = false,
    this.upsideDown = false,
  });

  /// Specifies the role and color of the piece.
  final Piece piece;

  /// Size of the board square the piece will occupy.
  final double size;

  /// Piece set.
  final PieceAssets pieceAssets;

  /// Pieces are hidden in blindfold mode.
  final bool blindfoldMode;

  /// If `true` the piece is displayed rotated by 180 degrees.
  final bool upsideDown;

  /// This value is used to animate the opacity of the piece.
  final Animation<double>? opacity;

  @override
  Widget build(BuildContext context) {
    if (blindfoldMode) {
      return SizedBox(width: size, height: size);
    }

    final asset = pieceAssets[piece.kind]!;
    final deviceRatio = MediaQuery.devicePixelRatioOf(context);
    // the ratio is defined by the resolution aware image assets defined in
    // assets/piece_sets/
    // that's why 4 is the maximum ratio
    final ratio = math.min(deviceRatio.ceilToDouble(), 4.0);
    final cacheSize = (size * ratio).ceil();
    final image = Image.asset(
      asset.assetName,
      bundle: asset.bundle,
      package: asset.package,
      opacity: opacity,
      width: size,
      height: size,
      cacheWidth: cacheSize,
      cacheHeight: cacheSize,
    );
    return upsideDown ? Transform.rotate(angle: math.pi, child: image) : image;
  }
}
