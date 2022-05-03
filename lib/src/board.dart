import 'package:flutter/material.dart';
import 'background.dart';
import 'piece.dart';
import 'models.dart' as cg;
import 'position.dart';

const lightSquare = Color(0xfff0d9b6);
const darkSquare = Color(0xffb58863);

@immutable
class Board extends StatelessWidget {
  final double size;

  // board state
  final cg.Color orientation;
  final Map<String, cg.Piece> pieces;

  const Board({
    Key? key,
    required this.size,
    required this.orientation,
    required this.pieces,
  }) : super(key: key);

  double get squareSize => size / 8;

  @override
  Widget build(BuildContext context) {
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
                position: entry.key,
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
