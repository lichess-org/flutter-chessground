import 'package:flutter/material.dart';
import '../models.dart' as cg;
import '../utils.dart';
import 'piece.dart';

class PromotionSelector extends StatelessWidget {
  const PromotionSelector({
    Key? key,
    required this.move,
    required this.color,
    required this.squareSize,
    required this.orientation,
    required this.onSelect,
    required this.onCancel,
  }) : super(key: key);

  final cg.Move move;
  final cg.Color color;
  final double squareSize;
  final cg.Color orientation;
  final Function(cg.Move, cg.Piece) onSelect;
  final Function(cg.Move) onCancel;

  cg.SquareId get squareId => move.to;

  @override
  Widget build(BuildContext context) {
    final file = squareId[0];
    final rank = squareId[1];
    final offset = (orientation == cg.Color.white && rank == '8' ||
            orientation == cg.Color.black && rank == '1')
        ? coord2Offset(squareId2Coord(squareId), orientation, squareSize)
        : coord2Offset(
            squareId2Coord(file + (orientation == cg.Color.white ? '4' : '5')),
            orientation,
            squareSize);

    return GestureDetector(
      onTap: () => onCancel(move),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xB3161512),
        child: Stack(
          children: [
            Positioned(
              child: Column(
                children: [
                  cg.Piece(
                    color: color,
                    role: cg.PieceRole.queen,
                    promoted: true,
                  ),
                  cg.Piece(
                    color: color,
                    role: cg.PieceRole.knight,
                    promoted: true,
                  ),
                  cg.Piece(
                    color: color,
                    role: cg.PieceRole.rook,
                    promoted: true,
                  ),
                  cg.Piece(
                    color: color,
                    role: cg.PieceRole.bishop,
                    promoted: true,
                  ),
                ].map((cg.Piece piece) {
                  return GestureDetector(
                    onTap: () => onSelect(move, piece),
                    child: Stack(children: [
                      Container(
                        width: squareSize,
                        height: squareSize,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFb0b0b0),
                            ),
                            BoxShadow(
                              color: Color(0xFF808080),
                              blurRadius: 25.0,
                              spreadRadius: -3.0,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 5.0,
                        top: 5.0,
                        child: Piece(piece: piece, size: squareSize - 10.0),
                      ),
                    ]),
                  );
                }).toList(growable: false),
              ),
              width: squareSize,
              height: squareSize * 4,
              left: offset.dx,
              top: offset.dy,
            ),
          ],
        ),
      ),
    );
  }
}
