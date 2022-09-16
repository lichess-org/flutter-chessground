import 'package:flutter/material.dart';
import '../models.dart' as cg;

/// Widget that displays a chess piece
class PieceWidget extends StatelessWidget {
  const PieceWidget({
    Key? key,
    required this.piece,
    required this.size,
    this.pieceSet,
    this.opacity = 1.0,
    this.animatedOpacity,
  }) : super(key: key);

  /// Specifies the role and color of the piece
  final cg.Piece piece;

  /// Size of the board square the piece will occupy
  final double size;

  /// Piece set. If you don't provide one, Merida will be used
  final cg.PieceSet? pieceSet;

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

const cg.PieceSet meridaPieceSet = {
  'blackrook': AssetImage('lib/piece_sets/merida/bR.png'),
  'blackpawn': AssetImage('lib/piece_sets/merida/bP.png'),
  'blackknight': AssetImage('lib/piece_sets/merida/bN.png'),
  'blackbishop': AssetImage('lib/piece_sets/merida/bB.png'),
  'blackqueen': AssetImage('lib/piece_sets/merida/bQ.png'),
  'blackking': AssetImage('lib/piece_sets/merida/bK.png'),
  'whiterook': AssetImage('lib/piece_sets/merida/wR.png'),
  'whiteknight': AssetImage('lib/piece_sets/merida/wN.png'),
  'whitebishop': AssetImage('lib/piece_sets/merida/wB.png'),
  'whitequeen': AssetImage('lib/piece_sets/merida/wQ.png'),
  'whiteking': AssetImage('lib/piece_sets/merida/wK.png'),
  'whitepawn': AssetImage('lib/piece_sets/merida/wP.png'),
};
