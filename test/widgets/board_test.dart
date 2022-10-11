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
            interactableColor: InteractableColor.none,
            orientation: Color.white,
            size: boardSize,
            fen: dc.kInitialFEN));

    testWidgets('initial position display', (WidgetTester tester) async {
      await tester.pumpWidget(viewOnlyBoard);

      expect(find.byType(Board), findsOneWidget);
      expect(find.byType(PieceWidget), findsNWidgets(32));
    });

    testWidgets('cannot select piece', (WidgetTester tester) async {
      await tester.pumpWidget(viewOnlyBoard);
      await tester.tap(find.byKey(const Key('e2-whitepawn')));
      await tester.pump();

      expect(find.byKey(const Key('e2-selected')), findsNothing);
    });
  });

  group('Interactable board', () {
    testWidgets('selecting and deselecting a square', (WidgetTester tester) async {
      await tester.pumpWidget(buildBoard(interactableColor: InteractableColor.both));
      await tester.tap(find.byKey(const Key('a2-whitepawn')));
      await tester.pump();

      expect(find.byKey(const Key('a2-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(2));

      // selecting same keeps it selected
      await tester.tap(find.byKey(const Key('a2-whitepawn')));
      await tester.pump();
      expect(find.byKey(const Key('a2-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(2));

      // selecting another square
      await tester.tap(find.byKey(const Key('a1-whiterook')));
      await tester.pump();
      expect(find.byKey(const Key('a1-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNothing);

      // selecting an opposite piece deselects
      await tester.tap(find.byKey(const Key('e7-blackpawn')));
      await tester.pump();
      expect(find.byKey(const Key('a1-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);

      // selecting an empty square deselects
      await tester.tap(find.byKey(const Key('a1-whiterook')));
      await tester.pump();
      expect(find.byKey(const Key('a1-selected')), findsOneWidget);
      await tester.tapAt(squareOffset('c4'));
      await tester.pump();
      expect(find.byKey(const Key('a1-selected')), findsNothing);
    });

    testWidgets('play e2-e4 move by tap', (WidgetTester tester) async {
      await tester.pumpWidget(buildBoard(interactableColor: InteractableColor.both));
      await tester.tap(find.byKey(const Key('e2-whitepawn')));
      await tester.pump();

      expect(find.byKey(const Key('e2-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(2));

      await tester.tapAt(squareOffset('e4'));
      await tester.pump();
      expect(find.byKey(const Key('e2-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);
      expect(find.byKey(const Key('e4-whitepawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-whitepawn')), findsNothing);
      expect(find.byKey(const Key('e2-lastMove')), findsOneWidget);
      expect(find.byKey(const Key('e4-lastMove')), findsOneWidget);
    });

    testWidgets('castling by taping king then rook is possible', (WidgetTester tester) async {
      await tester.pumpWidget(buildBoard(
          initialFen: 'r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4',
          interactableColor: InteractableColor.both));
      await tester.tap(find.byKey(const Key('e1-whiteking')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('h1-whiterook')));
      await tester.pump();
      expect(find.byKey(const Key('e1-whiteking')), findsNothing);
      expect(find.byKey(const Key('h1-whiterook')), findsNothing);
      expect(find.byKey(const Key('g1-whiteking')), findsOneWidget);
      expect(find.byKey(const Key('f1-whiterook')), findsOneWidget);
      expect(find.byKey(const Key('e1-lastMove')), findsOneWidget);
      expect(find.byKey(const Key('h1-lastMove')), findsOneWidget);
    });

    testWidgets('dragging off target ', (WidgetTester tester) async {
      await tester.pumpWidget(buildBoard(interactableColor: InteractableColor.both));

      await tester.drag(
          find.byKey(const Key('e2-whitepawn')), const Offset(squareSize * 2, -(squareSize * 2)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e2-whitepawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);
    });

    testWidgets('e2-e4 drag move', (WidgetTester tester) async {
      await tester.pumpWidget(buildBoard(interactableColor: InteractableColor.both));
      await tester.drag(find.byKey(const Key('e2-whitepawn')), const Offset(0, -(squareSize * 2)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e4-whitepawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-whitepawn')), findsNothing);
      expect(find.byKey(const Key('e2-lastMove')), findsOneWidget);
      expect(find.byKey(const Key('e4-lastMove')), findsOneWidget);
    });

    testWidgets('promotion', (WidgetTester tester) async {
      await tester.pumpWidget(buildBoard(
          interactableColor: InteractableColor.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1'));

      await tester.tap(find.byKey(const Key('f7-whitepawn')));
      await tester.pump();
      await tester.tapAt(squareOffset('f8'));
      await tester.pump();
      await tester.tapAt(squareOffset('f7'));
      await tester.pump();
      expect(find.byKey(const Key('f8-whiteknight')), findsOneWidget);
      expect(find.byKey(const Key('f7-whitepawn')), findsNothing);
    });

    testWidgets('promotion, auto queen enabled', (WidgetTester tester) async {
      await tester.pumpWidget(buildBoard(
          settings: const Settings(autoQueenPromotion: true),
          interactableColor: InteractableColor.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1'));

      await tester.tap(find.byKey(const Key('f7-whitepawn')));
      await tester.pump();
      await tester.tapAt(squareOffset('f8'));
      await tester.pump();
      expect(find.byKey(const Key('f8-whitequeen')), findsOneWidget);
      expect(find.byKey(const Key('f7-whitepawn')), findsNothing);
    });

    testWidgets('premoves: select and deselect', (WidgetTester tester) async {
      await tester.pumpWidget(buildBoard(
        initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
        interactableColor: InteractableColor.white,
      ));

      await tester.tapAt(squareOffset('f1'));
      await tester.pump();
      expect(find.byKey(const Key('f1-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(7));

      // deselects by tapping empty square
      await tester.tapAt(squareOffset('f8'));
      await tester.pump();
      expect(find.byKey(const Key('e4-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);
    });

    testWidgets('premoves: set/unset', (WidgetTester tester) async {
      await tester.pumpWidget(buildBoard(
        initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
        interactableColor: InteractableColor.white,
      ));

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
      await tester.pumpWidget(buildBoard(
        initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
        interactableColor: InteractableColor.white,
      ));

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
      await tester.pumpWidget(buildBoard(
        initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
        interactableColor: InteractableColor.white,
      ));

      await tester.drag(find.byKey(const Key('e4-whitepawn')), const Offset(0, -squareSize));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e4-premove')), findsOneWidget);
      expect(find.byKey(const Key('e5-premove')), findsOneWidget);
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
  required InteractableColor interactableColor,
  Settings? settings,
  orientation = Color.white,
  initialFen = dc.kInitialFEN,
}) {
  dc.Position<dc.Chess> position = dc.Chess.fromSetup(dc.Setup.parseFen(initialFen));
  Move? lastMove;

  return MaterialApp(home: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    return Board(
      interactableColor: interactableColor,
      orientation: orientation,
      size: boardSize,
      fen: position.fen,
      settings: settings ?? const Settings(),
      lastMove: lastMove,
      turnColor: position.turn == dc.Color.white ? Color.white : Color.black,
      validMoves: dc.algebraicLegalMoves(position),
      onMove: (Move move, {bool? isPremove}) {
        setState(() {
          position = position.playUnchecked(dc.Move.fromUci(move.uci));
          lastMove = move;
        });
      },
    );
  }));
}

Offset squareOffset(SquareId id, {Color orientation = Color.white}) {
  final o = Coord.fromSquareId(id).offset(orientation, squareSize);
  return Offset(o.dx + squareSize / 2, o.dy + squareSize / 2);
}
