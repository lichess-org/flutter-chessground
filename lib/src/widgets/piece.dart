import 'package:flutter/widgets.dart';
import '../models.dart';

/// Widget that displays a chess piece
class PieceWidget extends StatelessWidget {
  const PieceWidget({
    super.key,
    required this.piece,
    required this.size,
    required this.pieceSet,
    this.opacity = 1.0,
    this.animatedOpacity,
  });

  /// Specifies the role and color of the piece
  final Piece piece;

  /// Size of the board square the piece will occupy
  final double size;

  /// Piece set
  final PieceSet pieceSet;

  /// Defines an opacity for the piece. By default it is fully opaque
  final double opacity;

  /// Use this value to animate the opacity of the piece
  final Animation<double>? animatedOpacity;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: pieceSet[piece.kind]!,
      color: Color.fromRGBO(255, 255, 255, opacity),
      colorBlendMode: BlendMode.modulate,
      opacity: animatedOpacity,
      width: size,
      height: size,
    );
  }
}
