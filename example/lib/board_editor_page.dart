import 'package:board_example/board_theme.dart';
import 'package:flutter/material.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart' as dc;
import 'package:collection/collection.dart';

class BoardEditorPage extends StatefulWidget {
  const BoardEditorPage({super.key});

  @override
  State<StatefulWidget> createState() => _BoardEditorPageState();
}

class _BoardEditorPageState extends State<BoardEditorPage> {
  Pieces pieces = readFen(dc.kInitialFEN);

  Piece? pieceToAddOnTap;
  bool deleteOnTap = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    const PieceSet pieceSet = PieceSet.merida;

    final settings = BoardEditorSettings(
      pieceAssets: pieceSet.assets,
      colorScheme: BoardTheme.blue.colors,
      enableCoordinates: true,
    );
    final boardEditor = BoardEditor(
      size: screenWidth,
      orientation: Side.white,
      pieces: pieces,
      settings: settings,
      onTappedSquare: (squareId) => setState(() {
        if (deleteOnTap) {
          pieces.remove(squareId);
        } else if (pieceToAddOnTap != null) {
          pieces[squareId] = pieceToAddOnTap!;
        }
      }),
      onDiscardedPiece: (squareId) => setState(() {
        pieces.remove(squareId);
      }),
      onDroppedPiece: (origin, destination, piece) => setState(() {
        pieces[destination] = piece;
        if (origin != null) {
          pieces.remove(origin);
        }
      }),
    );

    makePieceMenu(side) => PieceMenu(
          side: side,
          pieceSet: pieceSet,
          squareSize: boardEditor.squareSize,
          settings: settings,
          selectedPiece: pieceToAddOnTap,
          pieceTapped: (role) => setState(() {
            pieceToAddOnTap = Piece(role: role, color: side);
            deleteOnTap = false;
          }),
          deleteSelected: deleteOnTap,
          deleteTapped: () => setState(() {
            pieceToAddOnTap = null;
            deleteOnTap = !deleteOnTap;
          }),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Board Editor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            makePieceMenu(Side.white),
            boardEditor,
            makePieceMenu(Side.black),
            Text('FEN: ${writeFen(pieces)}'),
          ],
        ),
      ),
    );
  }
}

class PieceMenu extends StatelessWidget {
  const PieceMenu({
    super.key,
    required this.side,
    required this.pieceSet,
    required this.squareSize,
    required this.selectedPiece,
    required this.deleteSelected,
    required this.settings,
    required this.pieceTapped,
    required this.deleteTapped,
  });

  final Side side;
  final PieceSet pieceSet;
  final double squareSize;
  final Piece? selectedPiece;
  final bool deleteSelected;
  final BoardEditorSettings settings;
  final Function(Role role) pieceTapped;
  final Function() deleteTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...Role.values.mapIndexed(
            (i, role) {
              final piece = Piece(role: role, color: side);
              final pieceWidget = PieceWidget(
                piece: piece,
                size: squareSize,
                pieceAssets: pieceSet.assets,
              );

              return Container(
                color:
                    selectedPiece == piece ? Colors.blue : Colors.transparent,
                child: GestureDetector(
                  onTap: () => pieceTapped(role),
                  child: Draggable(
                      data: piece,
                      feedback: PieceDragFeedback(
                        piece: piece,
                        pieceAssets: pieceSet.assets,
                        squareSize: squareSize,
                      ),
                      child: pieceWidget),
                ),
              );
            },
          ).toList(),
          Container(
            color: deleteSelected ? Colors.red : Colors.transparent,
            child: GestureDetector(
              onTap: () => deleteTapped(),
              child: Icon(
                Icons.delete,
                size: squareSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
