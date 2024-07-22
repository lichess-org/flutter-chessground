import 'package:dartchess/dartchess.dart' show Piece, Role, Side;
import 'package:flutter/widgets.dart';
import '../models.dart';
import 'piece.dart';

/// A widget that allows the user to select a promotion piece.
///
/// This widget should be displayed when a pawn reaches the last rank and must be
/// promoted. The user can select a piece to promote to by tapping on one of
/// the four pieces displayed.
/// Promotion can be canceled by tapping outside the promotion widget.
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
  final BoardMove move;
  final Side color;
  final double squareSize;
  final Side orientation;
  final bool piecesUpsideDown;
  final void Function(BoardMove, Piece) onSelect;
  final void Function(BoardMove) onCancel;

  SquareId get squareId => move.to;

  @override
  Widget build(BuildContext context) {
    final coord = (orientation == Side.white && squareId.rank == '8' ||
            orientation == Side.black && squareId.rank == '1')
        ? squareId.coord
        : SquareId(squareId.file + (orientation == Side.white ? '4' : '5'))
            .coord;
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
