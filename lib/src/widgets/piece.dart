import 'package:flutter/material.dart';
import '../models.dart' as cg;

/// Widget that displays a chess piece
class Piece extends StatelessWidget {
  const Piece({
    Key? key,
    required this.piece,
    required this.size,
    this.opacity = 1.0,
    this.animatedOpacity,
  }) : super(key: key);

  /// Specifies the role and color of the piece
  final cg.Piece piece;

  /// Size of the board square the piece will occupy
  final double size;

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

const Map<String, AssetImage> pieceSet = {
  'black_rook': AssetImage(
    'lib/piece_sets/merida/bR.png',
    package: 'chessground',
  ),
  'black_pawn': AssetImage(
    'lib/piece_sets/merida/bP.png',
    package: 'chessground',
  ),
  'black_knight': AssetImage(
    'lib/piece_sets/merida/bN.png',
    package: 'chessground',
  ),
  'black_bishop': AssetImage(
    'lib/piece_sets/merida/bB.png',
    package: 'chessground',
  ),
  'black_queen': AssetImage(
    'lib/piece_sets/merida/bQ.png',
    package: 'chessground',
  ),
  'black_king': AssetImage(
    'lib/piece_sets/merida/bK.png',
    package: 'chessground',
  ),
  'white_rook': AssetImage(
    'lib/piece_sets/merida/wR.png',
    package: 'chessground',
  ),
  'white_knight': AssetImage(
    'lib/piece_sets/merida/wN.png',
    package: 'chessground',
  ),
  'white_bishop': AssetImage(
    'lib/piece_sets/merida/wB.png',
    package: 'chessground',
  ),
  'white_queen': AssetImage(
    'lib/piece_sets/merida/wQ.png',
    package: 'chessground',
  ),
  'white_king': AssetImage(
    'lib/piece_sets/merida/wK.png',
    package: 'chessground',
  ),
  'white_pawn': AssetImage(
    'lib/piece_sets/merida/wP.png',
    package: 'chessground',
  ),
};
