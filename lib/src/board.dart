import 'package:flutter/material.dart';
import 'background.dart';
import 'piece.dart';
import 'models.dart' as cg;
import 'position.dart';
import 'fen.dart';

const lightSquare = Color(0xfff0d9b6);
const darkSquare = Color(0xffb58863);

@immutable
class Board extends StatelessWidget {
  final double size;

  // board state
  final cg.Color orientation;
  final String fen;

  const Board({
    Key? key,
    required this.size,
    required this.orientation,
    required this.fen,
  }) : super(key: key);

  double get squareSize => size / 8;

  @override
  Widget build(BuildContext context) {
    final pieces = readFen(fen);
    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: [
          const Background(lightSquare: lightSquare, darkSquare: darkSquare),
          Stack(
            children: pieces.entries.map((entry) {
              return BoardPositioned(
                size: squareSize,
                orientation: orientation,
                squareId: entry.key,
                child: UIPiece(
                  piece: entry.value,
                  size: squareSize,
                ),
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }
}
