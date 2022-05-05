import 'package:flutter/material.dart';
import 'models.dart' as cg;

class UIPiece extends StatelessWidget {
  final cg.Piece piece;
  final double size;

  const UIPiece({
    Key? key,
    required this.piece,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image(
      image: pieceSet[piece.kind]!,
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
