import 'package:chessground/src/widgets/geometry.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';
import '../models.dart';
import 'piece.dart';

/// A widget that allows the user to select a promotion piece.
///
/// This widget should be displayed when a pawn reaches the last rank and must be
/// promoted. The user can select a piece to promote to by tapping on one of
/// the pieces displayed in the widget. Normally there are 4 pieces to choose from (queen, rook, bishop and knight), but a king can also be included as an option if `canPromoteToKing` is true (for example in Antichess).
/// Promotion can be canceled by tapping outside the promotion widget.
class PromotionSelector extends StatelessWidget with ChessboardGeometry {
  const PromotionSelector({
    super.key,
    required this.move,
    required this.color,
    required this.size,
    required this.orientation,
    required this.piecesUpsideDown,
    required this.onSelect,
    required this.onCancel,
    required this.pieceAssets,
    required this.canPromoteToKing,
  });

  /// The move that is being promoted.
  final NormalMove move;

  /// The color of the pieces to display.
  final Side color;

  /// The piece assets to use.
  final PieceAssets pieceAssets;

  /// Whether the pawn can be promoted to a king (possible for example in Antichess).
  final bool canPromoteToKing;

  @override
  final double size;

  @override
  final Side orientation;

  /// If `true` the pieces are displayed rotated by 180 degrees.
  final bool piecesUpsideDown;

  /// Callback when a piece is selected.
  final void Function(Role) onSelect;

  /// Callback when the promotion is canceled.
  final void Function() onCancel;

  /// The square the pawn is moving to.
  Square get square => move.to;

  @override
  Widget build(BuildContext context) {
    final isPromotionSquareAtTop =
        orientation == Side.white && square.rank == Rank.eighth ||
        orientation == Side.black && square.rank == Rank.first;

    final topRoles = [
      Role.queen,
      Role.knight,
      Role.rook,
      Role.bishop,
      if (canPromoteToKing) Role.king,
    ];

    final roles = isPromotionSquareAtTop ? topRoles : topRoles.reversed.toList(growable: false);
    final pieces = roles
        .map((role) => Piece(color: color, role: role, promoted: true))
        .toList(growable: false);

    final anchorSquare =
        isPromotionSquareAtTop
            ? square
            : Square.fromCoords(
              square.file,
              orientation == Side.white
                  ? (pieces.length == 4 ? Rank.fourth : Rank.fifth)
                  : (pieces.length == 4 ? Rank.fifth : Rank.fourth),
            );

    final offset = squareOffset(anchorSquare);

    return GestureDetector(
      onTap: () => onCancel(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xB3161512),
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Positioned(
              width: squareSize,
              height: squareSize * pieces.length,
              left: offset.dx,
              top: offset.dy,
              child: Column(
                children: pieces
                    .map((Piece piece) {
                      return GestureDetector(
                        onTap: () => onSelect(piece.role),
                        child: Stack(
                          alignment: Alignment.topLeft,
                          children: [
                            Container(
                              width: squareSize,
                              height: squareSize,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Color(0xFFb0b0b0)),
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
                    })
                    .toList(growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
