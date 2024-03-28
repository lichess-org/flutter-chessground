import 'package:flutter/widgets.dart';
import '../models.dart';
import 'piece.dart';

class PromotionSelector extends StatelessWidget {
  const PromotionSelector({
    super.key,
    required this.move,
    required this.color,
    required this.squareSize,
    required this.orientation,
    required this.piecesUpsideDown,
    required this.onSelect,
    required this.onCancel,
    required this.pieceAssets,
  });

  final PieceAssets pieceAssets;
  final Move move;
  final Side color;
  final double squareSize;
  final Side orientation;
  final bool piecesUpsideDown;
  final void Function(Move, Piece) onSelect;
  final void Function(Move) onCancel;

  SquareId get squareId => move.to;

  @override
  Widget build(BuildContext context) {
    final file = squareId[0];
    final rank = squareId[1];
    final coord = (orientation == Side.white && rank == '8' ||
            orientation == Side.black && rank == '1')
        ? Coord.fromSquareId(squareId)
        : Coord.fromSquareId(file + (orientation == Side.white ? '4' : '5'));
    final offset = coord.offset(orientation, squareSize);

    return GestureDetector(
      onTap: () => onCancel(move),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xB3161512),
        child: Stack(
          children: [
            Positioned(
              width: squareSize,
              height: squareSize * 4,
              left: offset.dx,
              top: offset.dy,
              child: Column(
                children: [
                  Piece(
                    color: color,
                    role: Role.queen,
                    promoted: true,
                  ),
                  Piece(
                    color: color,
                    role: Role.knight,
                    promoted: true,
                  ),
                  Piece(
                    color: color,
                    role: Role.rook,
                    promoted: true,
                  ),
                  Piece(
                    color: color,
                    role: Role.bishop,
                    promoted: true,
                  ),
                ].map((Piece piece) {
                  return GestureDetector(
                    onTap: () => onSelect(move, piece),
                    child: Stack(
                      children: [
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
                          child: PieceWidget(
                            piece: piece,
                            size: squareSize - 10.0,
                            pieceAssets: pieceAssets,
                            upsideDown: piecesUpsideDown,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
