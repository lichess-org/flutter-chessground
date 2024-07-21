import 'dart:async';
import 'package:chessground/src/widgets/shape.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
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
        settings: BoardSettings(
          drawShape: DrawShapeOptions(enable: true),
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
      await tester.pumpWidget(
        buildBoard(initialInteractableSide: InteractableSide.both),
      );
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
      await tester.tapAt(squareOffset(const SquareId('c4')));
      await tester.pump();
      expect(find.byKey(const Key('a1-selected')), findsNothing);

      // cannot select a piece whose side is not the turn to move
      await tester.tap(find.byKey(const Key('e7-blackPawn')));
      await tester.pump();
      expect(find.byKey(const Key('e7-selected')), findsNothing);
    });

    testWidgets('play e2-e4 move by tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(initialInteractableSide: InteractableSide.both),
      );
      await tester.tap(find.byKey(const Key('e2-whitePawn')));
      await tester.pump();

      expect(find.byKey(const Key('e2-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(2));

      await tester.tapAt(squareOffset(const SquareId('e4')));
      await tester.pump();
      expect(find.byKey(const Key('e2-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);
      expect(find.byKey(const Key('e4-whitePawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-whitePawn')), findsNothing);
      expect(find.byKey(const Key('e2-lastMove')), findsOneWidget);
      expect(find.byKey(const Key('e4-lastMove')), findsOneWidget);
    });

    testWidgets('Cannot move by tap if piece shift method is drag',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialInteractableSide: InteractableSide.both,
          pieceShiftMethod: PieceShiftMethod.drag,
        ),
      );
      await tester.tap(find.byKey(const Key('e2-whitePawn')));
      await tester.pump();

      // Tapping a square should have no effect...
      expect(find.byKey(const Key('e2-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);

      // ... but move by drag should work
      await tester.dragFrom(
        squareOffset(const SquareId('e2')),
        const Offset(0, -(squareSize * 2)),
      );
      await tester.pumpAndSettle();
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
          initialInteractableSide: InteractableSide.both,
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

    testWidgets('dragging off target', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(initialInteractableSide: InteractableSide.both),
      );

      final e2 = squareOffset(const SquareId('e2'));
      await tester.dragFrom(e2, const Offset(0, -(squareSize * 4)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e2-whitePawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);
    });

    testWidgets('dragging off board', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(initialInteractableSide: InteractableSide.both),
      );

      await tester.dragFrom(
        squareOffset(const SquareId('e2')),
        squareOffset(const SquareId('e2')) +
            const Offset(0, -boardSize + squareSize),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e2-whitePawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);
    });

    testWidgets('e2-e4 drag move', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(initialInteractableSide: InteractableSide.both),
      );
      await tester.dragFrom(
        squareOffset(const SquareId('e2')),
        const Offset(0, -(squareSize * 2)),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e4-whitePawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-whitePawn')), findsNothing);
      expect(find.byKey(const Key('e2-lastMove')), findsOneWidget);
      expect(find.byKey(const Key('e4-lastMove')), findsOneWidget);
    });

    testWidgets('Cannot move by drag if piece shift method is tapTwoSquares', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildBoard(
          initialInteractableSide: InteractableSide.both,
          pieceShiftMethod: PieceShiftMethod.tapTwoSquares,
        ),
      );
      await tester.dragFrom(
        squareOffset(const SquareId('e2')),
        const Offset(0, -(squareSize * 2)),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e4-whitePawn')), findsNothing);
      expect(find.byKey(const Key('e2-whitePawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-lastMove')), findsNothing);
      expect(find.byKey(const Key('e4-lastMove')), findsNothing);

      // Original square is still selected after drag attempt
      expect(find.byKey(const Key('e2-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(2));

      // ...so we can still tap to move
      await tester.tapAt(squareOffset(const SquareId('e4')));
      await tester.pump();
      expect(find.byKey(const Key('e2-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);
      expect(find.byKey(const Key('e4-whitePawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-whitePawn')), findsNothing);
      expect(find.byKey(const Key('e2-lastMove')), findsOneWidget);
      expect(find.byKey(const Key('e4-lastMove')), findsOneWidget);
    });

    testWidgets(
        '2 simultaneous pointer down events will cancel current drag/selection',
        (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildBoard(initialInteractableSide: InteractableSide.both),
      );
      await TestAsyncUtils.guard<void>(() async {
        await tester.startGesture(squareOffset(const SquareId('e2')));

        await tester.pump();

        expect(find.byKey(const Key('e2-selected')), findsOneWidget);

        await tester.startGesture(squareOffset(const SquareId('e4')));

        await tester.pump();

        // move is cancelled
        expect(find.byKey(const Key('e4-whitePawn')), findsNothing);
        expect(find.byKey(const Key('e2-whitePawn')), findsOneWidget);
        // selection is cancelled
        expect(find.byKey(const Key('e2-selected')), findsNothing);
      });
    });

    testWidgets('while dragging a piece, other pointer events will cancel', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildBoard(initialInteractableSide: InteractableSide.both),
      );

      // drag a piece and tap on another own square while dragging
      await TestAsyncUtils.guard<void>(() async {
        final dragGesture =
            await tester.startGesture(squareOffset(const SquareId('e2')));
        await tester.pump();

        // trigger a piece drag by moving the pointer by 4 pixels
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));

        expect(find.byKey(const Key('e2-selected')), findsOneWidget);

        await tester.tap(find.byKey(const Key('d2-whitePawn')));

        // finish the move as to release the piece
        await dragGesture.moveTo(squareOffset(const SquareId('e4')));
        await dragGesture.up();
      });

      await tester.pump();

      // the piece should not have moved
      expect(find.byKey(const Key('e4-whitePawn')), findsNothing);
      expect(find.byKey(const Key('e2-whitePawn')), findsOneWidget);
      // the piece should not be selected
      expect(find.byKey(const Key('e2-selected')), findsNothing);

      // drag a piece and tap on an empty square while dragging
      await TestAsyncUtils.guard<void>(() async {
        final dragGesture =
            await tester.startGesture(squareOffset(const SquareId('d2')));
        await tester.pump();

        // trigger a piece drag by moving the pointer by 4 pixels
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));

        expect(find.byKey(const Key('d2-selected')), findsOneWidget);

        // tap on an empty square
        await tester.tapAt(squareOffset(const SquareId('f5')));

        // finish the move as to release the piece
        await dragGesture.moveTo(squareOffset(const SquareId('d4')));
        await dragGesture.up();
      });

      await tester.pump();

      // the piece should not have moved
      expect(find.byKey(const Key('d4-whitePawn')), findsNothing);
      expect(find.byKey(const Key('d2-whitePawn')), findsOneWidget);
      // the piece should not be selected
      expect(find.byKey(const Key('d2-selected')), findsNothing);
    });

    testWidgets('dragging an already selected piece should not deselect it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildBoard(initialInteractableSide: InteractableSide.both),
      );
      final e2 = squareOffset(const SquareId('e2'));
      await tester.tapAt(e2);
      await tester.pump();
      final dragFuture = tester.timedDragFrom(
        e2,
        const Offset(0, -(squareSize * 2)),
        const Duration(milliseconds: 200),
      );

      expectSync(find.byKey(const Key('e2-whitePawn')), findsOneWidget);
      expectSync(find.byKey(const Key('e2-selected')), findsOneWidget);

      await dragFuture;
      await tester.pumpAndSettle();

      expectSync(find.byKey(const Key('e2-selected')), findsNothing);
    });

    testWidgets('promotion', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialInteractableSide: InteractableSide.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
        ),
      );

      await tester.tap(find.byKey(const Key('f7-whitePawn')));
      await tester.pump();
      await tester.tapAt(squareOffset(const SquareId('f8')));
      await tester.pump();
      await tester.tapAt(squareOffset(const SquareId('f7')));
      await tester.pump();
      expect(find.byKey(const Key('f8-whiteKnight')), findsOneWidget);
      expect(find.byKey(const Key('f7-whitePawn')), findsNothing);
    });

    testWidgets('promotion, auto queen enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          settings: const BoardSettings(autoQueenPromotion: true),
          initialInteractableSide: InteractableSide.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
        ),
      );

      await tester.tap(find.byKey(const Key('f7-whitePawn')));
      await tester.pump();
      await tester.tapAt(squareOffset(const SquareId('f8')));
      await tester.pump();
      expect(find.byKey(const Key('f8-whiteQueen')), findsOneWidget);
      expect(find.byKey(const Key('f7-whitePawn')), findsNothing);
    });

    testWidgets('king check square black', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/ppp2ppp/3p4/4p3/3PP3/8/PPP2PPP/RNBQKBNR w KQkq - 0 3',
          initialInteractableSide: InteractableSide.white,
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
          initialInteractableSide: InteractableSide.black,
        ),
      );
      await makeMove(tester, 'f8', 'b4');
      expect(find.byKey(const Key('e1-check')), findsOneWidget);
    });

    testWidgets(
        'cancel piece selection if board is made non interactable again',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen: dc.kInitialBoardFEN,
          initialInteractableSide: InteractableSide.white,
        ),
      );

      await tester.tapAt(squareOffset(const SquareId('e2')));
      await tester.pump();
      expect(find.byKey(const Key('e2-selected')), findsOneWidget);

      await tester.pumpWidget(
        buildBoard(
          initialFen: dc.kInitialBoardFEN,
          initialInteractableSide: InteractableSide.none,
        ),
      );

      expect(find.byKey(const Key('e2-selected')), findsNothing);
    });

    testWidgets(
        'cancel piece current pointer event if board is made non interactable again',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen: dc.kInitialBoardFEN,
          initialInteractableSide: InteractableSide.white,
        ),
      );

      await TestAsyncUtils.guard<void>(() async {
        await tester.startGesture(squareOffset(const SquareId('e2')));
        await tester.pump();
        expect(find.byKey(const Key('e2-selected')), findsOneWidget);
      });

      // make board non interactable in the middle of the gesture
      await tester.pumpWidget(
        buildBoard(
          initialFen: dc.kInitialBoardFEN,
          initialInteractableSide: InteractableSide.none,
        ),
      );

      expect(find.byKey(const Key('e2-selected')), findsNothing);

      // board is not interactable, so the piece should not be selected
      await tester.tapAt(squareOffset(const SquareId('e2')));
      await tester.pump();
      expect(find.byKey(const Key('e2-selected')), findsNothing);

      // make board interactable again
      await tester.pumpWidget(
        buildBoard(
          initialFen: dc.kInitialBoardFEN,
          initialInteractableSide: InteractableSide.white,
        ),
      );

      // the piece selection should work (which would not be the case if the
      // pointer event was not cancelled)
      await tester.tapAt(squareOffset(const SquareId('e2')));
      await tester.pump();
      expect(find.byKey(const Key('e2-selected')), findsOneWidget);
    });
  });

  group('premoves', () {
    testWidgets('select and deselect with empty square',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialInteractableSide: InteractableSide.white,
        ),
      );

      await tester.tapAt(squareOffset(const SquareId('f1')));
      await tester.pump();
      expect(find.byKey(const Key('f1-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(7));

      await tester.tapAt(squareOffset(const SquareId('b4')));
      await tester.pump();
      expect(find.byKey(const Key('e4-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);
    });

    testWidgets('select and deselect with opponent piece',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialInteractableSide: InteractableSide.white,
        ),
      );

      await tester.tapAt(squareOffset(const SquareId('f1')));
      await tester.pump();
      expect(find.byKey(const Key('f1-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(7));

      await tester.tapAt(squareOffset(const SquareId('f8')));
      await tester.pump();
      expect(find.byKey(const Key('e4-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);
    });

    testWidgets('select and deselect with same piece',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialInteractableSide: InteractableSide.white,
        ),
      );

      await tester.tapAt(squareOffset(const SquareId('f1')));
      await tester.pump();
      expect(find.byKey(const Key('f1-selected')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(7));

      await tester.tapAt(squareOffset(const SquareId('f1')));
      await tester.pump();
      expect(find.byKey(const Key('e4-selected')), findsNothing);
      expect(find.byType(MoveDest), findsNothing);
    });

    testWidgets('set/unset', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialInteractableSide: InteractableSide.white,
        ),
      );

      // set premove
      await makeMove(tester, 'e4', 'f5');
      expect(find.byKey(const Key('e4-premove')), findsOneWidget);
      expect(find.byKey(const Key('f5-premove')), findsOneWidget);

      // unset by tapping empty square
      await tester.tapAt(squareOffset(const SquareId('c5')));
      await tester.pump();
      expect(find.byKey(const Key('e4-premove')), findsNothing);
      expect(find.byKey(const Key('f5-premove')), findsNothing);

      // unset by tapping opponent's piece
      await makeMove(tester, 'd1', 'f3');
      expect(find.byKey(const Key('d1-premove')), findsOneWidget);
      expect(find.byKey(const Key('f3-premove')), findsOneWidget);
      await tester.tapAt(squareOffset(const SquareId('g8')));
      await tester.pump();
      expect(find.byKey(const Key('d1-premove')), findsNothing);
      expect(find.byKey(const Key('f3-premove')), findsNothing);
    });

    testWidgets('set and change', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialInteractableSide: InteractableSide.white,
        ),
      );

      await makeMove(tester, 'd1', 'f3');
      expect(find.byKey(const Key('d1-premove')), findsOneWidget);
      expect(find.byKey(const Key('f3-premove')), findsOneWidget);
      await tester.tapAt(squareOffset(const SquareId('d2')));
      await tester.pump();
      // premove is still set
      expect(find.byKey(const Key('d1-premove')), findsOneWidget);
      expect(find.byKey(const Key('f3-premove')), findsOneWidget);
      expect(find.byType(MoveDest), findsNWidgets(4));
      await tester.tapAt(squareOffset(const SquareId('d4')));
      await tester.pump();
      // premove is changed
      expect(find.byKey(const Key('d1-premove')), findsNothing);
      expect(find.byKey(const Key('f3-premove')), findsNothing);
      expect(find.byKey(const Key('d2-premove')), findsOneWidget);
      expect(find.byKey(const Key('d4-premove')), findsOneWidget);
    });

    testWidgets('drag to set', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialInteractableSide: InteractableSide.white,
        ),
      );

      await tester.dragFrom(
        squareOffset(const SquareId('e4')),
        const Offset(0, -squareSize),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e4-premove')), findsOneWidget);
      expect(find.byKey(const Key('e5-premove')), findsOneWidget);
      expect(find.byKey(const Key('e4-selected')), findsNothing);
    });

    testWidgets('select pieces from same side', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialInteractableSide: InteractableSide.white,
        ),
      );

      await makeMove(tester, 'd1', 'c2');
      expect(find.byKey(const Key('d1-premove')), findsOneWidget);
      expect(find.byKey(const Key('c2-premove')), findsOneWidget);
    });

    testWidgets('play premove', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialInteractableSide: InteractableSide.white,
          shouldPlayOpponentMove: true,
        ),
      );

      await makeMove(tester, 'e2', 'e4');

      await makeMove(tester, 'd1', 'f3');
      expect(find.byKey(const Key('d1-premove')), findsOneWidget);
      expect(find.byKey(const Key('f3-premove')), findsOneWidget);

      // wait for opponent move to be played
      await tester.pump(const Duration(milliseconds: 200));

      // opponent move is played
      expect(find.byKey(const Key('a5-blackPawn')), findsOneWidget);

      // wait for the premove to be played
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('d1-premove')), findsNothing);
      expect(find.byKey(const Key('f3-premove')), findsNothing);

      // premove has been played
      expect(find.byKey(const Key('d1-whiteQueen')), findsNothing);
      expect(find.byKey(const Key('f3-whiteQueen')), findsOneWidget);
    });
  });

  group('drawing shapes', () {
    testWidgets('preconfigure board to draw a circle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialInteractableSide: InteractableSide.both,
          initialShapes: ISet(
            {const Circle(orig: SquareId('e4'), color: Color(0xFF0000FF))},
          ),
        ),
      );

      expect(
        find.byType(ShapeWidget),
        paints..path(color: const Color(0xFF0000FF)),
      );
    });

    testWidgets('preconfigure board to draw an arrow',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialInteractableSide: InteractableSide.both,
          initialShapes: ISet({
            const Arrow(
              orig: SquareId('e2'),
              dest: SquareId('e4'),
              color: Color(0xFF0000FF),
            ),
          }),
        ),
      );

      expect(
        find.byType(ShapeWidget),
        paints
          ..line(color: const Color(0xFF0000FF))
          ..path(color: const Color(0xFF0000FF)),
      );
    });

    testWidgets('preconfigure board to draw a piece shape',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialInteractableSide: InteractableSide.both,
          initialShapes: ISet({
            const PieceShape(
              orig: SquareId('e4'),
              role: Role.pawn,
              color: Color(0xFF0000FF),
            ),
          }),
        ),
      );

      expect(find.byType(ShapeWidget), findsOneWidget);
    });

    testWidgets('cannot draw if not enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialInteractableSide: InteractableSide.both,
        ),
      );

      await TestAsyncUtils.guard<void>(() async {
        // keep pressing an empty square to enable drawing shapes
        final pressGesture =
            await tester.startGesture(squareOffset(const SquareId('a3')));

        // drawing a circle with another tap
        final tapGesture =
            await tester.startGesture(squareOffset(const SquareId('e4')));
        await tapGesture.up();

        await pressGesture.up();
      });

      expect(find.byType(ShapeWidget), findsNothing);
    });

    testWidgets('draw a circle by hand', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialInteractableSide: InteractableSide.both,
          enableDrawingShapes: true,
        ),
      );

      await TestAsyncUtils.guard<void>(() async {
        // keep pressing an empty square to enable drawing shapes
        final pressGesture =
            await tester.startGesture(squareOffset(const SquareId('a3')));

        // drawing a circle with another tap
        final tapGesture =
            await tester.startGesture(squareOffset(const SquareId('e4')));
        await tapGesture.up();

        await pressGesture.up();
      });

      // wait for the double tap delay to expire
      await tester.pump(const Duration(milliseconds: 210));

      expect(
        find.byType(ShapeWidget),
        paints..path(color: const Color(0xFF0000FF)),
      );
    });

    testWidgets('draw an arrow by hand', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialInteractableSide: InteractableSide.both,
          enableDrawingShapes: true,
        ),
      );

      // keep pressing an empty square to enable drawing shapes
      final pressGesture =
          await tester.startGesture(squareOffset(const SquareId('a3')));

      await tester.dragFrom(
        squareOffset(const SquareId('e2')),
        const Offset(0, -(squareSize * 2)),
      );

      await pressGesture.up();

      // wait for the double tap delay to expire
      await tester.pump(const Duration(milliseconds: 210));

      expect(
        find.byType(ShapeWidget),
        paints
          ..line(color: const Color(0xFF0000FF))
          ..path(color: const Color(0xFF0000FF)),
      );
    });

    testWidgets('can draw shapes on an non-interactable board',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialInteractableSide: InteractableSide.none,
          enableDrawingShapes: true,
        ),
      );

      // keep pressing an empty square to enable drawing shapes
      final pressGesture =
          await tester.startGesture(squareOffset(const SquareId('a3')));

      await tester.dragFrom(
        squareOffset(const SquareId('e2')),
        const Offset(0, -(squareSize * 2)),
      );

      await pressGesture.up();

      // wait for the double tap delay to expire
      await tester.pump(const Duration(milliseconds: 210));

      expect(
        find.byType(ShapeWidget),
        paints
          ..line(color: const Color(0xFF0000FF))
          ..path(color: const Color(0xFF0000FF)),
      );
    });

    testWidgets('double tap to clear shapes', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialInteractableSide: InteractableSide.both,
          enableDrawingShapes: true,
        ),
      );

      await TestAsyncUtils.guard<void>(() async {
        // keep pressing an empty square to enable drawing shapes
        final pressGesture =
            await tester.startGesture(squareOffset(const SquareId('a3')));

        // drawing a circle with another tap
        final tapGesture =
            await tester.startGesture(squareOffset(const SquareId('e4')));
        await tapGesture.up();

        await pressGesture.up();
      });

      // wait for the double tap delay to expire
      await tester.pump(const Duration(milliseconds: 210));

      // keep pressing an empty square to enable drawing shapes
      final pressGesture =
          await tester.startGesture(squareOffset(const SquareId('a3')));

      await tester.dragFrom(
        squareOffset(const SquareId('e2')),
        const Offset(0, -(squareSize * 2)),
      );

      await pressGesture.up();

      // wait for the double tap delay to expire
      await tester.pump(const Duration(milliseconds: 210));

      expect(find.byType(ShapeWidget), findsNWidgets(2));

      await tester.tapAt(squareOffset(const SquareId('a3')));
      await tester.tapAt(squareOffset(const SquareId('a3')));
      await tester.pump();

      expect(find.byType(ShapeWidget), findsNothing);
    });

    testWidgets('selecting one piece should clear shapes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialInteractableSide: InteractableSide.both,
          enableDrawingShapes: true,
        ),
      );

      await TestAsyncUtils.guard<void>(() async {
        // keep pressing an empty square to enable drawing shapes
        final pressGesture =
            await tester.startGesture(squareOffset(const SquareId('a3')));

        // drawing a circle with another tap
        final tapGesture =
            await tester.startGesture(squareOffset(const SquareId('e4')));
        await tapGesture.up();

        await pressGesture.up();
      });

      // wait for the double tap delay to expire
      await tester.pump(const Duration(milliseconds: 210));

      expect(find.byType(ShapeWidget), findsOneWidget);

      await tester.tapAt(squareOffset(const SquareId('e2')));
      await tester.pump();

      expect(find.byType(ShapeWidget), findsNothing);
    });
  });
}

Future<void> makeMove(WidgetTester tester, String from, String to) async {
  await tester.tapAt(squareOffset(SquareId(from)));
  await tester.pump();
  await tester.tapAt(squareOffset(SquareId(to)));
  await tester.pump();
}

Widget buildBoard({
  required InteractableSide initialInteractableSide,
  BoardSettings? settings,
  Side orientation = Side.white,
  String initialFen = dc.kInitialFEN,
  ISet<Shape>? initialShapes,
  bool enableDrawingShapes = false,
  PieceShiftMethod pieceShiftMethod = PieceShiftMethod.either,

  /// play the first available move for the opponent after a delay of 200ms
  bool shouldPlayOpponentMove = false,
}) {
  InteractableSide interactableSide = initialInteractableSide;
  dc.Position<dc.Chess> position =
      dc.Chess.fromSetup(dc.Setup.parseFen(initialFen));
  Move? lastMove;
  Move? premove;
  ISet<Shape> shapes = initialShapes ?? ISet();

  return MaterialApp(
    home: StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        final defaultSettings = BoardSettings(
          drawShape: DrawShapeOptions(
            enable: enableDrawingShapes,
            onCompleteShape: (shape) {
              setState(() => shapes = shapes.add(shape));
            },
            onClearShapes: () {
              setState(() => shapes = ISet());
            },
            newShapeColor: const Color(0xFF0000FF),
          ),
          pieceShiftMethod: pieceShiftMethod,
        );

        return Board(
          size: boardSize,
          settings: settings ?? defaultSettings,
          data: BoardData(
            interactableSide: interactableSide,
            orientation: orientation,
            fen: position.fen,
            lastMove: lastMove,
            isCheck: position.isCheck,
            sideToMove:
                position.turn == dc.Side.white ? Side.white : Side.black,
            validMoves: algebraicLegalMoves(position),
            premove: premove,
            shapes: shapes,
          ),
          onMove: (Move move, {bool? isDrop, bool? isPremove}) {
            setState(() {
              position = position.playUnchecked(dc.Move.fromUci(move.uci)!);
              if (position.isGameOver) {
                interactableSide = InteractableSide.none;
              }
              lastMove = move;
            });

            if (shouldPlayOpponentMove) {
              Timer(const Duration(milliseconds: 200), () {
                setState(() {
                  final allMoves = [
                    for (final entry in position.legalMoves.entries)
                      for (final dest in entry.value.squares)
                        dc.NormalMove(from: entry.key, to: dest),
                  ];
                  final opponentMove = allMoves.first;
                  position = position.playUnchecked(opponentMove);
                  if (position.isGameOver) {
                    interactableSide = InteractableSide.none;
                  }
                  lastMove = Move.fromUci(opponentMove.uci);
                });
              });
            }
          },
          onPremove: (Move? move) {
            setState(() {
              premove = move;
            });
          },
        );
      },
    ),
  );
}

Offset squareOffset(SquareId id, {Side orientation = Side.white}) {
  final o = id.coord.offset(orientation, squareSize);
  return Offset(o.dx + squareSize / 2, o.dy + squareSize / 2);
}

/// Gets all the legal moves of this position in the algebraic coordinate notation.
///
/// Includes both possible representations of castling moves (unless `chess960` is true).
IMap<SquareId, ISet<SquareId>> algebraicLegalMoves(
  dc.Position pos, {
  bool isChess960 = false,
}) {
  final Map<SquareId, ISet<SquareId>> result = {};
  for (final entry in pos.legalMoves.entries) {
    final dests = entry.value.squares;
    if (dests.isNotEmpty) {
      final from = entry.key;
      final destSet = dests.map((e) => SquareId(dc.toAlgebraic(e))).toSet();
      if (!isChess960 &&
          from == pos.board.kingOf(pos.turn) &&
          dc.squareFile(entry.key) == 4) {
        if (dests.contains(0)) {
          destSet.add(const SquareId('c1'));
        } else if (dests.contains(56)) {
          destSet.add(const SquareId('c8'));
        }
        if (dests.contains(7)) {
          destSet.add(const SquareId('g1'));
        } else if (dests.contains(63)) {
          destSet.add(const SquareId('g8'));
        }
      }
      result[SquareId(dc.toAlgebraic(from))] = ISet(destSet);
    }
  }
  return IMap(result);
}
