import 'package:flutter/material.dart';
import '../models.dart';

/// Widget that displays a chess piece
class PieceWidget extends StatelessWidget {
  const PieceWidget({
    super.key,
    required this.piece,
    required this.size,
    this.pieceSet,
    this.opacity = 1.0,
    this.animatedOpacity,
  });

  /// Specifies the role and color of the piece
  final Piece piece;

  /// Size of the board square the piece will occupy
  final double size;

  /// Piece set. If you don't provide one, Merida will be used
  final PieceSet? pieceSet;

  /// Defines an opacity for the piece. By default it is fully opaque
  final double opacity;

  /// Use this value to animate the opacity of the piece
  final Animation<double>? animatedOpacity;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: (pieceSet ?? meridaPieceSet)[piece.kind]!,
      color: Color.fromRGBO(255, 255, 255, opacity),
      colorBlendMode: BlendMode.modulate,
      opacity: animatedOpacity,
      width: size,
      height: size,
    );
  }
}

const PieceSet meridaPieceSet = {
  'blackrook': AssetImage('lib/piece_sets/merida/bR.png', package: 'chessground'),
  'blackpawn': AssetImage('lib/piece_sets/merida/bP.png', package: 'chessground'),
  'blackknight': AssetImage('lib/piece_sets/merida/bN.png', package: 'chessground'),
  'blackbishop': AssetImage('lib/piece_sets/merida/bB.png', package: 'chessground'),
  'blackqueen': AssetImage('lib/piece_sets/merida/bQ.png', package: 'chessground'),
  'blackking': AssetImage('lib/piece_sets/merida/bK.png', package: 'chessground'),
  'whiterook': AssetImage('lib/piece_sets/merida/wR.png', package: 'chessground'),
  'whiteknight': AssetImage('lib/piece_sets/merida/wN.png', package: 'chessground'),
  'whitebishop': AssetImage('lib/piece_sets/merida/wB.png', package: 'chessground'),
  'whitequeen': AssetImage('lib/piece_sets/merida/wQ.png', package: 'chessground'),
  'whiteking': AssetImage('lib/piece_sets/merida/wK.png', package: 'chessground'),
  'whitepawn': AssetImage('lib/piece_sets/merida/wP.png', package: 'chessground'),
};
