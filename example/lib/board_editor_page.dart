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

  dc.Piece? pieceToAddOnTouch;
  bool deleteOnTouch = false;
  PointerToolMode pointerMode = PointerToolMode.drag;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    const PieceSet pieceSet = PieceSet.merida;

    final settings = BoardEditorSettings(
      pieceAssets: pieceSet.assets,
      colorScheme: BoardTheme.blue.colors,
      enableCoordinates: true,
    );
    final boardEditor = ChessBoardEditor(
      size: screenWidth,
      orientation: dc.Side.white,
      pieces: pieces,
      settings: settings,
      pointerToolMode: pointerMode,
      onTouchedSquare: (squareId) => setState(() {
        if (deleteOnTouch) {
          pieces.remove(squareId);
        } else if (pieceToAddOnTouch != null) {
          pieces[squareId] = pieceToAddOnTouch!;
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
          selectedPiece:
              pointerMode == PointerToolMode.edit ? pieceToAddOnTouch : null,
          pieceTapped: (role) => setState(() {
            pieceToAddOnTouch = dc.Piece(role: role, color: side);
            deleteOnTouch = false;
            pointerMode = PointerToolMode.edit;
          }),
          deleteOnTouch: deleteOnTouch,
          pointerMode: pointerMode,
          deleteTapped: () => setState(() {
            pieceToAddOnTouch = null;
            deleteOnTouch = !deleteOnTouch;
            pointerMode = PointerToolMode.edit;
          }),
          pointerModeTapped: () => setState(() {
            pointerMode = PointerToolMode.drag;
            deleteOnTouch = false;
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
            makePieceMenu(dc.Side.black),
            boardEditor,
            makePieceMenu(dc.Side.white),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child:
                  SizedBox(height: 50, child: Text('FEN: ${writeFen(pieces)}')),
            ),
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
    required this.deleteOnTouch,
    required this.pointerMode,
    required this.settings,
    required this.pieceTapped,
    required this.deleteTapped,
    required this.pointerModeTapped,
  });

  final dc.Side side;
  final PieceSet pieceSet;
  final double squareSize;
  final dc.Piece? selectedPiece;
  final bool deleteOnTouch;
  final PointerToolMode pointerMode;
  final BoardEditorSettings settings;
  final Function(dc.Role role) pieceTapped;
  final Function() deleteTapped;
  final Function() pointerModeTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: pointerMode == PointerToolMode.drag
                ? Colors.green
                : Colors.transparent,
            child: GestureDetector(
              onTap: () => pointerModeTapped(),
              child: Icon(
                Icons.pan_tool_alt_outlined,
                size: squareSize,
              ),
            ),
          ),
          ...dc.Role.values.mapIndexed(
            (i, role) {
              final piece = dc.Piece(role: role, color: side);
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
            color: pointerMode == PointerToolMode.edit && deleteOnTouch
                ? Colors.red
                : Colors.transparent,
            child: GestureDetector(
              onTap: () => deleteTapped(),
              child: Icon(
                Icons.delete_outline,
                size: squareSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
