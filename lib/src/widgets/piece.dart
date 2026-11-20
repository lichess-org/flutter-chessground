import 'package:dartchess/dartchess.dart' show Piece;
import 'package:flutter/widgets.dart';
import '../models.dart';
import '../images.dart';

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
    this.colorFilter,
  });

  /// Specifies the role and color of the piece.
  final Piece piece;

  /// Size of the board square the piece will occupy.
  final double size;

  /// Piece set assets.
  final PieceAssets pieceAssets;

  /// Pieces are hidden in blindfold mode.
  final bool blindfoldMode;

  /// If `true` the piece is displayed fliped on Y axis.
  final bool upsideDown;

  /// This value is used to animate the opacity of the piece.
  final Animation<double>? opacity;

  /// Filter applied to the piece image, matching the board's color adjustments.
  final ColorFilter? colorFilter;

  /// [AssetImage] provider for the piece.
  AssetImage get imageProvider => pieceAssets[piece.kind]!;

  @override
  Widget build(BuildContext context) {
    if (blindfoldMode) {
      return SizedBox(width: size, height: size);
    }

    final cachedImage = ChessgroundImages.instance.get(imageProvider);
    if (cachedImage == null) {
      // Transparent but opaque to hit tests, so Draggable children remain
      // interactive while the image loads.
      return SizedBox.square(dimension: size, child: const ColoredBox(color: Color(0x00000000)));
    }

    final image = RawImage(
      image: cachedImage,
      debugImageLabel: 'PieceWidgetCache(${imageProvider.assetName})',
      width: size,
      height: size,
      opacity: opacity,
    );

    final filteredImage =
        colorFilter == null ? image : ColorFiltered(colorFilter: colorFilter!, child: image);
    return upsideDown ? Transform.flip(flipY: true, child: filteredImage) : filteredImage;
  }
}
