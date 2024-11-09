import 'package:board_example/board_theme.dart';
import 'package:flutter/material.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:collection/collection.dart';

class BoardEditorPage extends StatefulWidget {
  const BoardEditorPage({super.key});

  @override
  State<StatefulWidget> createState() => _BoardEditorPageState();
}

class _BoardEditorPageState extends State<BoardEditorPage> {
  Pieces pieces = readFen(kInitialFEN);

  /// The piece to add when a square is touched. If null, will delete the piece.
  Piece? pieceToAddOnTouch;

  EditorPointerMode pointerMode = EditorPointerMode.drag;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    const PieceSet pieceSet = PieceSet.merida;

    final settings = ChessboardSettings(
      pieceAssets: pieceSet.assets,
      colorScheme: BoardTheme.blue.colors,
      enableCoordinates: true,
    );
    final boardEditor = ChessboardEditor(
      size: screenWidth,
      orientation: Side.white,
      pieces: pieces,
      settings: settings,
      pointerMode: pointerMode,
      onEditedSquare: (squareId) => setState(() {
        if (pieceToAddOnTouch != null) {
          pieces[squareId] = pieceToAddOnTouch!;
        } else {
          pieces.remove(squareId);
        }
      }),
      onDiscardedPiece: (squareId) => setState(() {
        pieces.remove(squareId);
      }),
      onDroppedPiece: (origin, destination, piece) => setState(() {
        pieces[destination] = piece;
        if (origin != null && origin != destination) {
          pieces.remove(origin);
        }
      }),
    );

    makePieceMenu(side) => PieceMenu(
          side: side,
          pieceSet: pieceSet,
          squareSize: boardEditor.squareSize,
          settings: settings,
          pieceEdition:
              pointerMode == EditorPointerMode.edit ? pieceToAddOnTouch : null,
          pieceTapped: (role) => setState(() {
            pieceToAddOnTouch = Piece(role: role, color: side);
            pointerMode = EditorPointerMode.edit;
          }),
          pointerMode: pointerMode,
          deleteTapped: () => setState(() {
            pieceToAddOnTouch = null;
            pointerMode = EditorPointerMode.edit;
          }),
          pointerModeTapped: () => setState(() {
            pointerMode = EditorPointerMode.drag;
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
            makePieceMenu(Side.black),
            boardEditor,
            makePieceMenu(Side.white),
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
    required this.pieceEdition,
    required this.pointerMode,
    required this.settings,
    required this.pieceTapped,
    required this.deleteTapped,
    required this.pointerModeTapped,
  });

  final Side side;
  final PieceSet pieceSet;
  final double squareSize;

  /// The piece that is currently being edited.
  ///
  /// If null while [pointerMode] is [EditorPointerMode.edit], the user is in delete mode.
  final Piece? pieceEdition;

  final EditorPointerMode pointerMode;
  final ChessboardSettings settings;
  final Function(Role role) pieceTapped;
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
            color: pointerMode == EditorPointerMode.drag
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
          ...Role.values.mapIndexed(
            (i, role) {
              final piece = Piece(role: role, color: side);
              final pieceWidget = PieceWidget(
                piece: piece,
                size: squareSize,
                pieceAssets: pieceSet.assets,
              );

              return Container(
                color: pieceEdition == piece ? Colors.blue : Colors.transparent,
                child: GestureDetector(
                  onTap: () => pieceTapped(role),
                  child: Draggable(
                      data: piece,
                      feedback: PieceDragFeedback(
                        scale: settings.dragFeedbackScale,
                        squareSize: squareSize,
                        piece: piece,
                        pieceAssets: pieceSet.assets,
                      ),
                      child: pieceWidget),
                ),
              );
            },
          ).toList(),
          Container(
            color: pointerMode == EditorPointerMode.edit && pieceEdition == null
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
