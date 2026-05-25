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

    return upsideDown ? Transform.flip(flipY: true, child: image) : image;
  }
}
