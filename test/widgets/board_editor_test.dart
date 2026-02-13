import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:dartchess/dartchess.dart' as dc;
import 'package:flutter_test/flutter_test.dart';
import 'package:chessground/chessground.dart';

const boardSize = 200.0;
const squareSize = boardSize / 8;

void main() {
  group('BoardEditor', () {
    testWidgets('empty board has no pieces', (WidgetTester tester) async {
      await tester.pumpWidget(buildBoard(pieces: {}));
      expect(find.byType(ChessboardEditor), findsOneWidget);
      expect(find.byType(PieceWidget), findsNothing);

      for (final square in Square.values) {
        expect(find.byKey(Key('${square.name}-empty')), findsOneWidget);
      }
    });

    testWidgets('displays pieces on the correct squares', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          pieces: {
            Square.a1: Piece.whiteKing,
            Square.b2: Piece.whiteQueen,
            Square.c3: Piece.whiteRook,
            Square.d4: Piece.whiteBishop,
            Square.e5: Piece.whiteKnight,
            Square.f6: Piece.whitePawn,
            Square.a2: Piece.blackKing,
            Square.a3: Piece.blackQueen,
            Square.a4: Piece.blackRook,
            Square.a5: Piece.blackBishop,
            Square.a6: Piece.blackKnight,
            Square.a7: Piece.blackPawn,
          },
        ),
      );
      expect(find.byKey(const Key('a1-whiteking')), findsOneWidget);
      expect(find.byKey(const Key('b2-whitequeen')), findsOneWidget);
      expect(find.byKey(const Key('c3-whiterook')), findsOneWidget);
      expect(find.byKey(const Key('d4-whitebishop')), findsOneWidget);
      expect(find.byKey(const Key('e5-whiteknight')), findsOneWidget);
      expect(find.byKey(const Key('f6-whitepawn')), findsOneWidget);

      expect(find.byKey(const Key('a2-blackking')), findsOneWidget);
      expect(find.byKey(const Key('a3-blackqueen')), findsOneWidget);
      expect(find.byKey(const Key('a4-blackrook')), findsOneWidget);
      expect(find.byKey(const Key('a5-blackbishop')), findsOneWidget);
      expect(find.byKey(const Key('a6-blackknight')), findsOneWidget);
      expect(find.byKey(const Key('a7-blackpawn')), findsOneWidget);

      expect(find.byType(PieceWidget), findsNWidgets(12));
    });

    testWidgets('displays a border', (WidgetTester tester) async {
      const board = ChessboardEditor(
        size: boardSize,
        orientation: Side.white,
        pieces: {},
        settings: ChessboardSettings(border: BoardBorder(width: 16.0, color: Color(0xFF000000))),
      );

      await tester.pumpWidget(board);

      final size = tester.getSize(find.byType(SolidColorChessboardBackground));
      expect(size.width, boardSize - 32.0);
      expect(size.height, boardSize - 32.0);
    });

    testWidgets('change in hue will use a color filter', (WidgetTester tester) async {
      const board = ChessboardEditor(
        size: boardSize,
        orientation: Side.white,
        pieces: {},
        settings: ChessboardSettings(hue: 100.0),
      );

      await tester.pumpWidget(board);

      expect(find.byType(ColorFiltered), findsOneWidget);
    });

    testWidgets('change in brightness will use a color filter', (WidgetTester tester) async {
      const board = ChessboardEditor(
        size: boardSize,
        orientation: Side.white,
        pieces: {},
        settings: ChessboardSettings(brightness: 0.9),
      );

      await tester.pumpWidget(board);

      expect(find.byType(ColorFiltered), findsOneWidget);
    });

    testWidgets(
      'touching a square triggers the onEditedSquare callback when the board pointer tool mode is `edit`',
      (WidgetTester tester) async {
        for (final orientation in Side.values) {
          Square? tappedSquare;
          await tester.pumpWidget(
            buildBoard(
              pieces: {},
              pointerMode: EditorPointerMode.edit,
              onEditedSquare: (square) => tappedSquare = square,
              orientation: orientation,
            ),
          );

          await tester.tapAt(squareOffset(Square.a1, orientation: orientation));
          expect(tappedSquare, Square.a1);

          await tester.tapAt(squareOffset(Square.g8, orientation: orientation));
          expect(tappedSquare, Square.g8);
        }
      },
    );

    testWidgets(
      'touching a square does not trigger the onEditedSquare callback when the board pointer tool mode is `drag`',
      (WidgetTester tester) async {
        Square? tappedSquare;
        await tester.pumpWidget(
          buildBoard(pieces: {}, onEditedSquare: (square) => tappedSquare = square),
        );

        await tester.tapAt(squareOffset(Square.a1));
        expect(tappedSquare, null);

        await tester.tapAt(squareOffset(Square.g8));
        expect(tappedSquare, null);
      },
    );

    testWidgets('pan movements trigger the onEditedSquare callback', (WidgetTester tester) async {
      final Set<Square> touchedSquares = {};
      await tester.pumpWidget(
        buildBoard(
          pieces: {},
          pointerMode: EditorPointerMode.edit,
          onEditedSquare: (square) => touchedSquares.add(square),
        ),
      );

      // Pan from a1 to a8
      await tester.timedDragFrom(
        squareOffset(Square.a1),
        const Offset(0, -(squareSize * 7)),
        const Duration(seconds: 1),
      );
      expect(touchedSquares, {
        Square.a1,
        Square.a2,
        Square.a3,
        Square.a4,
        Square.a5,
        Square.a6,
        Square.a7,
        Square.a8,
      });

      touchedSquares.clear();
      // Pan from a1 to h1
      await tester.timedDragFrom(
        squareOffset(Square.a1),
        const Offset(squareSize * 7, 0),
        const Duration(seconds: 1),
      );
      expect(touchedSquares, {
        Square.a1,
        Square.b1,
        Square.c1,
        Square.d1,
        Square.e1,
        Square.f1,
        Square.g1,
        Square.h1,
      });
    });

    testWidgets('dragging pieces to a new square calls onDroppedPiece', (
      WidgetTester tester,
    ) async {
      (Square? origin, Square? destination, Piece? piece) callbackParams = (null, null, null);

      await tester.pumpWidget(
        buildBoard(
          pieces: readFen(dc.kInitialFEN),
          onDroppedPiece: (o, d, p) => callbackParams = (o, d, p),
        ),
      );

      // Drag an empty square => nothing happens
      await tester.dragFrom(squareOffset(Square.e4), const Offset(0, -(squareSize * 2)));
      await tester.pumpAndSettle();
      expect(callbackParams, (null, null, null));

      // Play e2-e4 (legal move)
      await tester.dragFrom(squareOffset(Square.e2), const Offset(0, -(squareSize * 2)));
      await tester.pumpAndSettle();
      expect(callbackParams, (Square.e2, Square.e4, Piece.whitePawn));

      // Capture our own piece (illegal move)
      await tester.dragFrom(squareOffset(Square.a1), const Offset(squareSize, 0));
      expect(callbackParams, (Square.a1, Square.b1, Piece.whiteRook));
    });

    testWidgets('dragging a piece onto the board calls onDroppedPiece', (
      WidgetTester tester,
    ) async {
      (Square? origin, Square? destination, Piece? piece) callbackParams = (null, null, null);

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              ChessboardEditor(
                size: boardSize,
                orientation: Side.white,
                pieces: const {},
                onDroppedPiece: (o, d, p) {
                  callbackParams = (o, d, p);
                },
              ),
              Draggable(
                key: const Key('new piece'),
                hitTestBehavior: HitTestBehavior.translucent,
                data: Piece.whitePawn,
                feedback: const SizedBox.shrink(),
                child: PieceWidget(
                  piece: Piece.whitePawn,
                  size: squareSize,
                  pieceAssets: PieceSet.merida.assets,
                ),
              ),
            ],
          ),
        ),
      );

      final pieceDraggable = find.byKey(const Key('new piece'));
      final pieceCenter = tester.getCenter(pieceDraggable);

      final newSquareCenter = tester.getCenter(find.byKey(const Key('e2-empty')));

      await tester.drag(pieceDraggable, newSquareCenter - pieceCenter);
      expect(callbackParams, (null, Square.e2, Piece.whitePawn));
    });

    testWidgets('dragging a piece off the board calls onDiscardedPiece', (
      WidgetTester tester,
    ) async {
      Square? discardedSquare;
      await tester.pumpWidget(
        buildBoard(
          pieces: readFen(dc.kInitialFEN),
          onDiscardedPiece: (square) => discardedSquare = square,
        ),
      );

      await tester.dragFrom(squareOffset(Square.e1), const Offset(0, squareSize));
      await tester.pumpAndSettle();
      expect(discardedSquare, Square.e1);
    });
  });
}

Widget buildBoard({
  required Pieces pieces,
  Side orientation = Side.white,
  EditorPointerMode pointerMode = EditorPointerMode.drag,
  void Function(Square square)? onEditedSquare,
  void Function(Square? origin, Square destination, Piece piece)? onDroppedPiece,
  void Function(Square square)? onDiscardedPiece,
}) {
  return MaterialApp(
    home: ChessboardEditor(
      size: boardSize,
      orientation: orientation,
      pointerMode: pointerMode,
      pieces: pieces,
      onEditedSquare: onEditedSquare,
      onDiscardedPiece: onDiscardedPiece,
      onDroppedPiece: onDroppedPiece,
    ),
  );
}

Offset squareOffset(Square id, {Side orientation = Side.white}) {
  final x = orientation == Side.black ? 7 - id.file : id.file;
  final y = orientation == Side.black ? id.rank : 7 - id.rank;
  final o = Offset(x * squareSize, y * squareSize);
  return Offset(o.dx + squareSize / 2, o.dy + squareSize / 2);
}
