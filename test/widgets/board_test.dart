import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartchess/dartchess.dart' as dc;
import 'package:chessground/chessground.dart';

const boardSize = 200.0;
const squareSize = boardSize / 8;

void main() {
  group('Non-interactable board', () {
    const viewOnlyBoard = Directionality(
      textDirection: TextDirection.ltr,
      child: Board(
        size: boardSize,
        data: BoardData(
          interactableSide: InteractableSide.none,
          orientation: Side.white,
          fen: dc.kInitialFEN,
        ),
      ),
    );

    testWidgets('initial position display', (WidgetTester tester) async {
      await tester.pumpWidget(viewOnlyBoard);

      expect(find.byType(Board), findsOneWidget);
      expect(find.byType(PieceWidget), findsNWidgets(32));
    });

    testWidgets('cannot select piece', (WidgetTester tester) async {
      await tester.pumpWidget(viewOnlyBoard);
      await tester.tap(find.byKey(const Key('e2-whitePawn')));
      await tester.pump();

      expect(find.byKey(const Key('e2-selected')), findsNothing);
    });
  });

  group('Interactable board', () {
    testWidgets('selecting and deselecting a square',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildBoard(interactableSide: InteractableSide.both));
      await tester.tap(find.byKey(const Key('a2-whitePawn')));
      await tester.pump();

      expect(find.byKey(const Key('a2-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(2));

      // selecting same deselects
      await tester.tap(find.byKey(const Key('a2-whitePawn')));
      await tester.pump();
      expect(find.byKey(const Key('a2-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);

      // selecting another square
      await tester.tap(find.byKey(const Key('a1-whiteRook')));
      await tester.pump();
      expect(find.byKey(const Key('a1-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNothing);

      // selecting an opposite piece deselects
      await tester.tap(find.byKey(const Key('e7-blackPawn')));
      await tester.pump();
      expect(find.byKey(const Key('a1-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);

      // selecting an empty square deselects
      await tester.tap(find.byKey(const Key('a1-whiteRook')));
      await tester.pump();
      expect(find.byKey(const Key('a1-selected')), findsOneWidget);
      await tester.tapAt(squareOffset('c4'));
      await tester.pump();
      expect(find.byKey(const Key('a1-selected')), findsNothing);

      // cannot select a piece whose side is not the turn to move
      await tester.tap(find.byKey(const Key('e7-blackPawn')));
      await tester.pump();
      expect(find.byKey(const Key('e7-selected')), findsNothing);
    });

    testWidgets('play e2-e4 move by tap', (WidgetTester tester) async {
      await tester
          .pumpWidget(buildBoard(interactableSide: InteractableSide.both));
      await tester.tap(find.byKey(const Key('e2-whitePawn')));
      await tester.pump();

      expect(find.byKey(const Key('e2-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(2));

      await tester.tapAt(squareOffset('e4'));
      await tester.pump();
      expect(find.byKey(const Key('e2-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);
      expect(find.byKey(const Key('e4-whitePawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-whitePawn')), findsNothing);
      expect(find.byKey(const Key('e2-lastMove')), findsOneWidget);
      expect(find.byKey(const Key('e4-lastMove')), findsOneWidget);
    });

    testWidgets('castling by taping king then rook is possible',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4',
          interactableSide: InteractableSide.both,
        ),
      );
      await tester.tap(find.byKey(const Key('e1-whiteKing')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('h1-whiteRook')));
      await tester.pump();
      expect(find.byKey(const Key('e1-whiteKing')), findsNothing);
      expect(find.byKey(const Key('h1-whiteRook')), findsNothing);
      expect(find.byKey(const Key('g1-whiteKing')), findsOneWidget);
      expect(find.byKey(const Key('f1-whiteRook')), findsOneWidget);
      expect(find.byKey(const Key('e1-lastMove')), findsOneWidget);
      expect(find.byKey(const Key('h1-lastMove')), findsOneWidget);
    });

    testWidgets('dragging off target ', (WidgetTester tester) async {
      await tester
          .pumpWidget(buildBoard(interactableSide: InteractableSide.both));

      await tester.drag(
        find.byKey(const Key('e2-whitePawn')),
        const Offset(squareSize * 2, -(squareSize * 2)),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e2-whitePawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);
    });

    testWidgets('e2-e4 drag move', (WidgetTester tester) async {
      await tester
          .pumpWidget(buildBoard(interactableSide: InteractableSide.both));
      await tester.drag(
        find.byKey(const Key('e2-whitePawn')),
        const Offset(0, -(squareSize * 2)),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e4-whitePawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-whitePawn')), findsNothing);
      expect(find.byKey(const Key('e2-lastMove')), findsOneWidget);
      expect(find.byKey(const Key('e4-lastMove')), findsOneWidget);
    });

    testWidgets('promotion', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          interactableSide: InteractableSide.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
        ),
      );

      await tester.tap(find.byKey(const Key('f7-whitePawn')));
      await tester.pump();
      await tester.tapAt(squareOffset('f8'));
      await tester.pump();
      await tester.tapAt(squareOffset('f7'));
      await tester.pump();
      expect(find.byKey(const Key('f8-whiteKnight')), findsOneWidget);
      expect(find.byKey(const Key('f7-whitePawn')), findsNothing);
    });

    testWidgets('promotion, auto queen enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          settings: const BoardSettings(autoQueenPromotion: true),
          interactableSide: InteractableSide.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
        ),
      );

      await tester.tap(find.byKey(const Key('f7-whitePawn')));
      await tester.pump();
      await tester.tapAt(squareOffset('f8'));
      await tester.pump();
      expect(find.byKey(const Key('f8-whiteQueen')), findsOneWidget);
      expect(find.byKey(const Key('f7-whitePawn')), findsNothing);
    });

    testWidgets('premoves: select and deselect with empty square',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          interactableSide: InteractableSide.white,
        ),
      );

      await tester.tapAt(squareOffset('f1'));
      await tester.pump();
      expect(find.byKey(const Key('f1-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(7));

      await tester.tapAt(squareOffset('b4'));
      await tester.pump();
      expect(find.byKey(const Key('e4-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);
    });

    testWidgets('premoves: select and deselect with opponent piece',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          interactableSide: InteractableSide.white,
        ),
      );

      await tester.tapAt(squareOffset('f1'));
      await tester.pump();
      expect(find.byKey(const Key('f1-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(7));

      await tester.tapAt(squareOffset('f8'));
      await tester.pump();
      expect(find.byKey(const Key('e4-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);
    });

    testWidgets('premoves: set/unset', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          interactableSide: InteractableSide.white,
        ),
      );

      // set premove
      await makeMove(tester, 'e4', 'f5');
      expect(find.byKey(const Key('e4-premove')), findsOneWidget);
      expect(find.byKey(const Key('f5-premove')), findsOneWidget);

      // unset by tapping empty square
      await tester.tapAt(squareOffset('c5'));
      await tester.pump();
      expect(find.byKey(const Key('e4-premove')), findsNothing);
      expect(find.byKey(const Key('f5-premove')), findsNothing);

      // unset by tapping opponent's piece
      await makeMove(tester, 'd1', 'f3');
      expect(find.byKey(const Key('d1-premove')), findsOneWidget);
      expect(find.byKey(const Key('f3-premove')), findsOneWidget);
      await tester.tapAt(squareOffset('g8'));
      await tester.pump();
      expect(find.byKey(const Key('d1-premove')), findsNothing);
      expect(find.byKey(const Key('f3-premove')), findsNothing);
    });

    testWidgets('premoves: set and change', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          interactableSide: InteractableSide.white,
        ),
      );

      await makeMove(tester, 'd1', 'f3');
      expect(find.byKey(const Key('d1-premove')), findsOneWidget);
      expect(find.byKey(const Key('f3-premove')), findsOneWidget);
      await tester.tapAt(squareOffset('d2'));
      await tester.pump();
      expect(find.byKey(const Key('d1-premove')), findsOneWidget);
      expect(find.byKey(const Key('f3-premove')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(4));
      await tester.tapAt(squareOffset('d4'));
      await tester.pump();
      expect(find.byKey(const Key('d1-premove')), findsNothing);
      expect(find.byKey(const Key('f3-premove')), findsNothing);
      expect(find.byKey(const Key('d2-premove')), findsOneWidget);
      expect(find.byKey(const Key('d4-premove')), findsOneWidget);
    });

    testWidgets('premoves: drag to set', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          interactableSide: InteractableSide.white,
        ),
      );

      await tester.drag(
        find.byKey(const Key('e4-whitePawn')),
        const Offset(0, -squareSize),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e4-premove')), findsOneWidget);
      expect(find.byKey(const Key('e5-premove')), findsOneWidget);
      expect(find.byKey(const Key('e4-selected')), findsNothing);
    });

    testWidgets('premoves: select pieces from same side',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          interactableSide: InteractableSide.white,
        ),
      );

      await makeMove(tester, 'd1', 'c2');
      expect(find.byKey(const Key('d1-premove')), findsOneWidget);
      expect(find.byKey(const Key('c2-premove')), findsOneWidget);
    });

    testWidgets('king check square black', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/ppp2ppp/3p4/4p3/3PP3/8/PPP2PPP/RNBQKBNR w KQkq - 0 3',
          interactableSide: InteractableSide.white,
        ),
      );
      await makeMove(tester, 'f1', 'b5');
      expect(find.byKey(const Key('e8-check')), findsOneWidget);
    });

    testWidgets('king check square white', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppp1ppp/8/4p3/3P4/4P3/PPP2PPP/RNBQKBNR b KQkq - 0 2',
          interactableSide: InteractableSide.black,
        ),
      );
      await makeMove(tester, 'f8', 'b4');
      expect(find.byKey(const Key('e1-check')), findsOneWidget);
    });
  });
}

Future<void> makeMove(WidgetTester tester, String from, String to) async {
  await tester.tapAt(squareOffset(from));
  await tester.pump();
  await tester.tapAt(squareOffset(to));
  await tester.pump();
}

Widget buildBoard({
  required InteractableSide interactableSide,
  BoardSettings? settings,
  Side orientation = Side.white,
  String initialFen = dc.kInitialFEN,
}) {
  dc.Position<dc.Chess> position =
      dc.Chess.fromSetup(dc.Setup.parseFen(initialFen));
  Move? lastMove;

  return MaterialApp(
    home: StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Board(
          size: boardSize,
          settings: settings ?? const BoardSettings(),
          data: BoardData(
            interactableSide: interactableSide,
            orientation: orientation,
            fen: position.fen,
            lastMove: lastMove,
            isCheck: position.isCheck,
            sideToMove:
                position.turn == dc.Side.white ? Side.white : Side.black,
            validMoves: dc.algebraicLegalMoves(position),
            onMove: (Move move, {bool? isPremove}) {
              setState(() {
                position = position.playUnchecked(dc.Move.fromUci(move.uci)!);
                lastMove = move;
              });
            },
          ),
        );
      },
    ),
  );
}

Offset squareOffset(SquareId id, {Side orientation = Side.white}) {
  final o = Coord.fromSquareId(id).offset(orientation, squareSize);
  return Offset(o.dx + squareSize / 2, o.dy + squareSize / 2);
}
