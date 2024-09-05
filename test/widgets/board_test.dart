import 'dart:async';
import 'package:chessground/src/widgets/promotion.dart';
import 'package:chessground/src/widgets/shape.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartchess/dartchess.dart';
import 'package:chessground/chessground.dart';

const boardSize = 200.0;
const squareSize = boardSize / 8;

void main() {
  group('Non-interactable board', () {
    const viewOnlyBoard = Directionality(
      textDirection: TextDirection.ltr,
      child: Chessboard.fixed(
        size: boardSize,
        orientation: Side.white,
        fen: kInitialFEN,
        settings: ChessboardSettings(
          drawShape: DrawShapeOptions(enable: true),
        ),
      ),
    );

    testWidgets('initial position display', (WidgetTester tester) async {
      await tester.pumpWidget(viewOnlyBoard);

      expect(find.byType(Chessboard), findsOneWidget);
      expect(find.byType(PieceWidget), findsNWidgets(32));
    });

    testWidgets('cannot select piece', (WidgetTester tester) async {
      await tester.pumpWidget(viewOnlyBoard);
      await tester.tap(find.byKey(const Key('e2-whitepawn')));
      await tester.pump();

      expect(find.byKey(const Key('e2-selected')), findsNothing);
    });

    testWidgets('background is constrained to the size of the board', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(viewOnlyBoard);

      final background = tester.widget<SizedBox>(
        find.byKey(const Key('board-background')),
      );
      expect(background.width, boardSize);
      expect(background.height, boardSize);
    });
  });

  group('Interactable board', () {
    testWidgets('selecting and deselecting a square',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(initialPlayerSide: PlayerSide.both),
      );
      await tester.tap(find.byKey(const Key('a2-whitepawn')));
      await tester.pump();

      expect(find.byKey(const Key('a2-selected')), findsOneWidget);
      expect(find.byType(ValidMoveHighlight), findsNWidgets(2));

      // selecting same deselects
      await tester.tap(find.byKey(const Key('a2-whitepawn')));
      await tester.pump();
      expect(find.byKey(const Key('a2-selected')), findsNothing);
      expect(find.byType(ValidMoveHighlight), findsNothing);

      // selecting another square
      await tester.tap(find.byKey(const Key('a1-whiterook')));
      await tester.pump();
      expect(find.byKey(const Key('a1-selected')), findsOneWidget);
      expect(find.byType(ValidMoveHighlight), findsNothing);

      // selecting an opposite piece deselects
      await tester.tap(find.byKey(const Key('e7-blackpawn')));
      await tester.pump();
      expect(find.byKey(const Key('a1-selected')), findsNothing);
      expect(find.byType(ValidMoveHighlight), findsNothing);

      // selecting an empty square deselects
      await tester.tap(find.byKey(const Key('a1-whiterook')));
      await tester.pump();
      expect(find.byKey(const Key('a1-selected')), findsOneWidget);
      await tester.tapAt(squareOffset(Square.c4));
      await tester.pump();
      expect(find.byKey(const Key('a1-selected')), findsNothing);

      // cannot select a piece whose side is not the turn to move
      await tester.tap(find.byKey(const Key('e7-blackpawn')));
      await tester.pump();
      expect(find.byKey(const Key('e7-selected')), findsNothing);
    });

    testWidgets('play e2-e4 move by tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(initialPlayerSide: PlayerSide.both),
      );
      await tester.tap(find.byKey(const Key('e2-whitepawn')));
      await tester.pump();

      expect(find.byKey(const Key('e2-selected')), findsOneWidget);
      expect(find.byType(ValidMoveHighlight), findsNWidgets(2));

      await tester.tapAt(squareOffset(Square.e4));
      await tester.pump();

      expect(find.byKey(const Key('e4-whitepawn-translating')), findsOneWidget);
      expect(find.byKey(const Key('e2-selected')), findsNothing);
      expect(find.byType(ValidMoveHighlight), findsNothing);

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('e4-whitepawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-whitepawn')), findsNothing);
      expect(find.byKey(const Key('e2-lastMove')), findsOneWidget);
      expect(find.byKey(const Key('e4-lastMove')), findsOneWidget);
    });

    testWidgets('Cannot move by tap if piece shift method is drag',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialPlayerSide: PlayerSide.both,
          pieceShiftMethod: PieceShiftMethod.drag,
        ),
      );
      await tester.tap(find.byKey(const Key('e2-whitepawn')));
      await tester.pump();

      // Tapping a square should have no effect...
      expect(find.byKey(const Key('e2-selected')), findsNothing);
      expect(find.byType(ValidMoveHighlight), findsNothing);

      // ... but move by drag should work
      await tester.dragFrom(
        squareOffset(Square.e2),
        const Offset(0, -(squareSize * 2)),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e4-whitepawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-whitepawn')), findsNothing);
      expect(find.byKey(const Key('e2-lastMove')), findsOneWidget);
      expect(find.byKey(const Key('e4-lastMove')), findsOneWidget);
    });

    testWidgets('castling by selecting king then rook is possible',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4',
          initialPlayerSide: PlayerSide.both,
        ),
      );
      await tester.tap(find.byKey(const Key('e1-whiteking')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('h1-whiterook')));
      await tester.pump();

      // wait for the animations to finish
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('e1-whiteking')), findsNothing);
      expect(find.byKey(const Key('h1-whiterook')), findsNothing);
      expect(find.byKey(const Key('g1-whiteking')), findsOneWidget);
      expect(find.byKey(const Key('f1-whiterook')), findsOneWidget);
      expect(find.byKey(const Key('e1-lastMove')), findsOneWidget);
      expect(find.byKey(const Key('h1-lastMove')), findsOneWidget);
    });

    testWidgets('dragging off target', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(initialPlayerSide: PlayerSide.both),
      );

      final e2 = squareOffset(Square.e2);
      await tester.dragFrom(e2, const Offset(0, -(squareSize * 4)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e2-whitepawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-selected')), findsNothing);
      expect(find.byType(ValidMoveHighlight), findsNothing);
    });

    testWidgets('dragging off board', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(initialPlayerSide: PlayerSide.both),
      );

      await tester.dragFrom(
        squareOffset(Square.e2),
        squareOffset(Square.e2) + const Offset(0, -boardSize + squareSize),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e2-whitepawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-selected')), findsNothing);
      expect(find.byType(ValidMoveHighlight), findsNothing);
    });

    testWidgets('e2-e4 drag move', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(initialPlayerSide: PlayerSide.both),
      );
      await tester.dragFrom(
        squareOffset(Square.e2),
        const Offset(0, -(squareSize * 2)),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e4-whitepawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-whitepawn')), findsNothing);
      expect(find.byKey(const Key('e2-lastMove')), findsOneWidget);
      expect(find.byKey(const Key('e4-lastMove')), findsOneWidget);
    });

    testWidgets('Cannot move by drag if piece shift method is tapTwoSquares', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildBoard(
          settings: const ChessboardSettings(
            animationDuration: Duration.zero,
            pieceShiftMethod: PieceShiftMethod.tapTwoSquares,
          ),
          initialPlayerSide: PlayerSide.white,
        ),
      );
      await tester.dragFrom(
        squareOffset(Square.e2),
        const Offset(0, -(squareSize * 2)),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e4-whitepawn')), findsNothing);
      expect(find.byKey(const Key('e2-whitepawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-lastMove')), findsNothing);
      expect(find.byKey(const Key('e4-lastMove')), findsNothing);

      // Original square is still selected after drag attempt
      expect(find.byKey(const Key('e2-selected')), findsOneWidget);
      expect(find.byType(ValidMoveHighlight), findsNWidgets(2));

      // ...so we can still tap to move
      await tester.tapAt(squareOffset(Square.e4));
      await tester.pump();
      expect(find.byKey(const Key('e2-selected')), findsNothing);
      expect(find.byType(ValidMoveHighlight), findsNothing);
      expect(find.byKey(const Key('e4-whitepawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-whitepawn')), findsNothing);
      expect(find.byKey(const Key('e2-lastMove')), findsOneWidget);
      expect(find.byKey(const Key('e4-lastMove')), findsOneWidget);
    });

    testWidgets(
        '2 simultaneous pointer down events will cancel current drag/selection',
        (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildBoard(initialPlayerSide: PlayerSide.both),
      );
      await TestAsyncUtils.guard<void>(() async {
        await tester.startGesture(squareOffset(Square.e2));

        await tester.pump();

        expect(find.byKey(const Key('e2-selected')), findsOneWidget);

        await tester.startGesture(squareOffset(Square.e4));

        await tester.pump();

        // move is cancelled
        expect(find.byKey(const Key('e4-whitepawn')), findsNothing);
        expect(find.byKey(const Key('e2-whitepawn')), findsOneWidget);
        // selection is cancelled
        expect(find.byKey(const Key('e2-selected')), findsNothing);
      });
    });

    testWidgets('while dragging a piece, other pointer events will cancel', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildBoard(initialPlayerSide: PlayerSide.both),
      );

      // drag a piece and tap on another own square while dragging
      await TestAsyncUtils.guard<void>(() async {
        final dragGesture = await tester.startGesture(squareOffset(Square.e2));
        await tester.pump();

        // trigger a piece drag by moving the pointer by 4 pixels
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));

        expect(find.byKey(const Key('e2-selected')), findsOneWidget);

        await tester.tap(find.byKey(const Key('d2-whitepawn')));

        // finish the move as to release the piece
        await dragGesture.moveTo(squareOffset(Square.e4));
        await dragGesture.up();
      });

      await tester.pump();

      // the piece should not have moved
      expect(find.byKey(const Key('e4-whitepawn')), findsNothing);
      expect(find.byKey(const Key('e2-whitepawn')), findsOneWidget);
      // the piece should not be selected
      expect(find.byKey(const Key('e2-selected')), findsNothing);

      // drag a piece and tap on an empty square while dragging
      await TestAsyncUtils.guard<void>(() async {
        final dragGesture = await tester.startGesture(squareOffset(Square.d2));
        await tester.pump();

        // trigger a piece drag by moving the pointer by 4 pixels
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));

        expect(find.byKey(const Key('d2-selected')), findsOneWidget);

        // tap on an empty square
        await tester.tapAt(squareOffset(Square.f5));

        // finish the move as to release the piece
        await dragGesture.moveTo(squareOffset(Square.d4));
        await dragGesture.up();
      });

      await tester.pump();

      // the piece should not have moved
      expect(find.byKey(const Key('d4-whitepawn')), findsNothing);
      expect(find.byKey(const Key('d2-whitepawn')), findsOneWidget);
      // the piece should not be selected
      expect(find.byKey(const Key('d2-selected')), findsNothing);
    });

    testWidgets(
        'dragging an unselected piece to the same square should keep the piece selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(initialPlayerSide: PlayerSide.both),
      );
      final e2 = squareOffset(Square.e2);
      await tester.dragFrom(e2, const Offset(0, -(squareSize / 3)));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('e2-whitepawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-selected')), findsOneWidget);
    });

    testWidgets('dragging an already selected piece should not deselect it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildBoard(initialPlayerSide: PlayerSide.both),
      );
      final e2 = squareOffset(Square.e2);
      await tester.tapAt(e2);
      await tester.pump();
      final dragFuture = tester.timedDragFrom(
        e2,
        const Offset(0, -(squareSize * 2)),
        const Duration(milliseconds: 200),
      );

      expectSync(find.byKey(const Key('e2-whitepawn')), findsOneWidget);
      expectSync(find.byKey(const Key('e2-selected')), findsOneWidget);

      await dragFuture;
      await tester.pumpAndSettle();

      expectSync(find.byKey(const Key('e2-selected')), findsNothing);
    });

    testWidgets('king check square black', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/ppp2ppp/3p4/4p3/3PP3/8/PPP2PPP/RNBQKBNR w KQkq - 0 3',
          initialPlayerSide: PlayerSide.white,
        ),
      );
      await makeMove(tester, Square.f1, Square.b5);
      expect(find.byKey(const Key('e8-check')), findsOneWidget);
    });

    testWidgets('king check square white', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppp1ppp/8/4p3/3P4/4P3/PPP2PPP/RNBQKBNR b KQkq - 0 2',
          initialPlayerSide: PlayerSide.black,
        ),
      );
      await makeMove(tester, Square.f8, Square.b4);
      expect(find.byKey(const Key('e1-check')), findsOneWidget);
    });

    testWidgets(
        'cancel piece selection if board is made non interactable again',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen: kInitialBoardFEN,
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.tapAt(squareOffset(Square.e2));
      await tester.pump();
      expect(find.byKey(const Key('e2-selected')), findsOneWidget);

      await tester.pumpWidget(
        buildBoard(
          initialFen: kInitialBoardFEN,
          initialPlayerSide: PlayerSide.none,
        ),
      );

      expect(find.byKey(const Key('e2-selected')), findsNothing);
    });

    testWidgets(
        'cancel piece current pointer event if board is made non interactable again',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen: kInitialBoardFEN,
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await TestAsyncUtils.guard<void>(() async {
        await tester.startGesture(squareOffset(Square.e2));
        await tester.pump();
        expect(find.byKey(const Key('e2-selected')), findsOneWidget);
      });

      // make board non interactable in the middle of the gesture
      await tester.pumpWidget(
        buildBoard(
          initialFen: kInitialBoardFEN,
          initialPlayerSide: PlayerSide.none,
        ),
      );

      expect(find.byKey(const Key('e2-selected')), findsNothing);

      // board is not interactable, so the piece should not be selected
      await tester.tapAt(squareOffset(Square.e2));
      await tester.pump();
      expect(find.byKey(const Key('e2-selected')), findsNothing);

      // make board interactable again
      await tester.pumpWidget(
        buildBoard(
          initialFen: kInitialBoardFEN,
          initialPlayerSide: PlayerSide.white,
        ),
      );

      // the piece selection should work (which would not be the case if the
      // pointer event was not cancelled)
      await tester.tapAt(squareOffset(Square.e2));
      await tester.pump();
      expect(find.byKey(const Key('e2-selected')), findsOneWidget);
    });
  });

  group('Promotion', () {
    testWidgets('can display the selector', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialPlayerSide: PlayerSide.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
          initialPromotionMove:
              const NormalMove(from: Square.f7, to: Square.f8),
        ),
      );

      // promotion dialog is shown
      expect(find.byType(PromotionSelector), findsOneWidget);
    });

    testWidgets('promote a knight', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialPlayerSide: PlayerSide.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
        ),
      );

      await tester.tap(find.byKey(const Key('f7-whitepawn')));
      await tester.pump();
      await tester.tapAt(squareOffset(Square.f8));
      await tester.pump();

      // wait for promotion selector to show
      await tester.pump();
      expect(find.byType(PromotionSelector), findsOneWidget);

      // promotion pawn is not visible
      expect(find.byKey(const Key('f7-whitepawn')), findsNothing);

      // tap on the knight
      await tester.tapAt(squareOffset(Square.f7));
      await tester.pump();
      expect(find.byKey(const Key('f8-whiteknight')), findsOneWidget);
      expect(find.byKey(const Key('f7-whitepawn')), findsNothing);
    });

    testWidgets('cancels promotion', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialPlayerSide: PlayerSide.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
        ),
      );

      await tester.tap(find.byKey(const Key('f7-whitepawn')));
      await tester.pump();
      await tester.tapAt(squareOffset(Square.f8));
      await tester.pump();

      // wait for promotion selector to show
      await tester.pump();
      expect(find.byType(PromotionSelector), findsOneWidget);

      // tap outside the promotion dialog
      await tester.tapAt(squareOffset(Square.c4));

      await tester.pump();

      // promotion dialog is closed, move is cancelled
      expect(find.byType(PromotionSelector), findsNothing);
      expect(find.byKey(const Key('f7-whitepawn')), findsOneWidget);
    });

    testWidgets('promotion, auto queen enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          settings: const ChessboardSettings(autoQueenPromotion: true),
          initialPlayerSide: PlayerSide.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
        ),
      );

      await tester.tap(find.byKey(const Key('f7-whitepawn')));
      await tester.pump();
      await tester.tapAt(squareOffset(Square.f8));
      await tester.pump();
      expect(find.byKey(const Key('f8-whitequeen')), findsOneWidget);
      expect(find.byKey(const Key('f7-whitepawn')), findsNothing);
    });
  });

  group('premoves', () {
    testWidgets('select and deselect with empty square',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.tapAt(squareOffset(Square.f1));
      await tester.pump();
      expect(find.byKey(const Key('f1-selected')), findsOneWidget);
      expect(find.byType(ValidMoveHighlight), findsNWidgets(7));

      await tester.tapAt(squareOffset(Square.b4));
      await tester.pump();
      expect(find.byKey(const Key('f1-selected')), findsNothing);
      expect(find.byType(ValidMoveHighlight), findsNothing);
    });

    testWidgets('select and deselect with opponent piece',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.tapAt(squareOffset(Square.f1));
      await tester.pump();
      expect(find.byKey(const Key('f1-selected')), findsOneWidget);
      expect(find.byType(ValidMoveHighlight), findsNWidgets(7));

      await tester.tapAt(squareOffset(Square.f8));
      await tester.pump();
      expect(find.byKey(const Key('f1-selected')), findsNothing);
      expect(find.byType(ValidMoveHighlight), findsNothing);
    });

    testWidgets('select and deselect with same piece',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.tapAt(squareOffset(Square.f1));
      await tester.pump();
      expect(find.byKey(const Key('f1-selected')), findsOneWidget);
      expect(find.byType(ValidMoveHighlight), findsNWidgets(7));

      await tester.tapAt(squareOffset(Square.f1));
      await tester.pump();
      expect(find.byKey(const Key('f1-selected')), findsNothing);
      expect(find.byType(ValidMoveHighlight), findsNothing);
    });

    testWidgets(
        'dragging an unselected piece to the same square should keep the piece selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      final f1 = squareOffset(Square.f1);
      await tester.dragFrom(f1, const Offset(0, -(squareSize / 3)));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('f1-selected')), findsOneWidget);
      expect(find.byType(ValidMoveHighlight), findsNWidgets(7));
    });

    testWidgets('dragging off target unselects', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.tapAt(squareOffset(Square.f1));
      await tester.pump();
      expect(find.byKey(const Key('f1-selected')), findsOneWidget);
      expect(find.byType(ValidMoveHighlight), findsNWidgets(7));

      await tester.dragFrom(
        squareOffset(Square.f1),
        squareOffset(Square.f1) + const Offset(0, -squareSize * 3),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('f1-selected')), findsNothing);
      expect(find.byType(ValidMoveHighlight), findsNothing);
    });

    testWidgets('dragging off board unselects', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.tapAt(squareOffset(Square.f1));
      await tester.pump();
      expect(find.byKey(const Key('f1-selected')), findsOneWidget);
      expect(find.byType(ValidMoveHighlight), findsNWidgets(7));

      await tester.dragFrom(
        squareOffset(Square.f1),
        squareOffset(Square.f1) + const Offset(0, -boardSize + squareSize),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('f1-selected')), findsNothing);
      expect(find.byType(ValidMoveHighlight), findsNothing);
    });

    testWidgets('set/unset by tapping empty square or opponent piece',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      // set premove
      await makeMove(tester, Square.e4, Square.f5);
      expect(find.byKey(const Key('e4-premove')), findsOneWidget);
      expect(find.byKey(const Key('f5-premove')), findsOneWidget);

      // unset by tapping empty square
      await tester.tapAt(squareOffset(Square.c5));
      await tester.pump();
      expect(find.byKey(const Key('e4-premove')), findsNothing);
      expect(find.byKey(const Key('f5-premove')), findsNothing);

      // unset by tapping opponent's piece
      await makeMove(tester, Square.d1, Square.f3);
      expect(find.byKey(const Key('d1-premove')), findsOneWidget);
      expect(find.byKey(const Key('f3-premove')), findsOneWidget);
      await tester.tapAt(squareOffset(Square.g8));
      await tester.pump();
      expect(find.byKey(const Key('d1-premove')), findsNothing);
      expect(find.byKey(const Key('f3-premove')), findsNothing);
    });

    testWidgets('unset by dragging off board', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      // set premove
      await makeMove(tester, Square.e4, Square.f5);
      expect(find.byKey(const Key('e4-premove')), findsOneWidget);
      expect(find.byKey(const Key('f5-premove')), findsOneWidget);

      // unset by dragging off board
      await tester.dragFrom(
        squareOffset(Square.e4),
        squareOffset(Square.e4) + const Offset(0, -boardSize + squareSize),
      );
      await tester.pump();
      expect(find.byKey(const Key('e4-premove')), findsNothing);
      expect(find.byKey(const Key('f5-premove')), findsNothing);
    });

    testWidgets('unset by dragging to an empty square',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      // set premove
      await makeMove(tester, Square.e4, Square.f5);
      expect(find.byKey(const Key('e4-premove')), findsOneWidget);
      expect(find.byKey(const Key('f5-premove')), findsOneWidget);

      // unset by dragging to an empty square
      await tester.dragFrom(
        squareOffset(Square.e4),
        squareOffset(Square.e4) + const Offset(0, -squareSize),
      );
      await tester.pump();
      expect(find.byKey(const Key('e4-premove')), findsNothing);
      expect(find.byKey(const Key('f5-premove')), findsNothing);
    });

    testWidgets('unset by tapping same origin square again',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      // set premove
      await makeMove(tester, Square.e4, Square.f5);
      expect(find.byKey(const Key('e4-premove')), findsOneWidget);
      expect(find.byKey(const Key('f5-premove')), findsOneWidget);

      // unset by tapping same origin square again
      await tester.tapAt(squareOffset(Square.e4));
      await tester.pump();
      expect(find.byKey(const Key('e4-premove')), findsNothing);
      expect(find.byKey(const Key('f5-premove')), findsNothing);
    });

    testWidgets('set and change by tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await makeMove(tester, Square.d1, Square.f3);
      expect(find.byKey(const Key('d1-premove')), findsOneWidget);
      expect(find.byKey(const Key('f3-premove')), findsOneWidget);
      await tester.tapAt(squareOffset(Square.d2));
      await tester.pump();
      // premove is still set
      expect(find.byKey(const Key('d1-premove')), findsOneWidget);
      expect(find.byKey(const Key('f3-premove')), findsOneWidget);
      expect(find.byType(ValidMoveHighlight), findsNWidgets(4));
      await tester.tapAt(squareOffset(Square.d4));
      await tester.pump();
      // premove is changed
      expect(find.byKey(const Key('d1-premove')), findsNothing);
      expect(find.byKey(const Key('f3-premove')), findsNothing);
      expect(find.byKey(const Key('d2-premove')), findsOneWidget);
      expect(find.byKey(const Key('d4-premove')), findsOneWidget);
    });

    testWidgets('set and change by drag', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await makeMove(tester, Square.d1, Square.f3);
      expect(find.byKey(const Key('d1-premove')), findsOneWidget);
      expect(find.byKey(const Key('f3-premove')), findsOneWidget);
      await tester.dragFrom(
        squareOffset(Square.d2),
        const Offset(0, -squareSize * 2),
      );
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
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.dragFrom(
        squareOffset(Square.e4),
        const Offset(0, -squareSize),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e4-premove')), findsOneWidget);
      expect(find.byKey(const Key('e5-premove')), findsOneWidget);
      expect(find.byKey(const Key('e4-selected')), findsNothing);
    });

    testWidgets('select another piece from same side does not unset',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialFen:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await makeMove(tester, Square.d1, Square.c2);
      expect(find.byKey(const Key('d1-premove')), findsOneWidget);
      expect(find.byKey(const Key('c2-premove')), findsOneWidget);

      await tester.tapAt(squareOffset(Square.e1));
      await tester.pump();
      expect(find.byKey(const Key('d1-premove')), findsOneWidget);
      expect(find.byKey(const Key('c2-premove')), findsOneWidget);
    });

    testWidgets('play premove', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          settings: const ChessboardSettings(animationDuration: Duration.zero),
          initialPlayerSide: PlayerSide.white,
          shouldPlayOpponentMove: true,
        ),
      );

      await makeMove(tester, Square.e2, Square.e4);

      await makeMove(tester, Square.d1, Square.f3);
      expect(find.byKey(const Key('d1-premove')), findsOneWidget);
      expect(find.byKey(const Key('f3-premove')), findsOneWidget);

      // wait for opponent move to be played
      await tester.pump(const Duration(milliseconds: 200));

      // opponent move is played
      expect(find.byKey(const Key('a5-blackpawn')), findsOneWidget);

      // wait for the premove to be played
      await tester.pump();

      expect(find.byKey(const Key('d1-premove')), findsNothing);
      expect(find.byKey(const Key('f3-premove')), findsNothing);

      // premove has been played
      expect(find.byKey(const Key('d1-whitequeen')), findsNothing);
      expect(find.byKey(const Key('f3-whitequeen')), findsOneWidget);
    });

    testWidgets('play a premove with promotion', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          settings: const ChessboardSettings(animationDuration: Duration.zero),
          initialPlayerSide: PlayerSide.white,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/8 w - - 0 1',
          shouldPlayOpponentMove: true,
        ),
      );

      await makeMove(tester, Square.g6, Square.g7);
      await makeMove(tester, Square.g7, Square.g8);
      expect(find.byKey(const Key('g7-premove')), findsOneWidget);
      expect(find.byKey(const Key('g8-premove')), findsOneWidget);

      // wait for opponent move to be played
      await tester.pump(const Duration(milliseconds: 200));

      // opponent move is played
      expect(find.byKey(const Key('d3-blackking')), findsOneWidget);

      // pawn was promoted to queen
      expect(find.byKey(const Key('g7-premove')), findsNothing);
      expect(find.byKey(const Key('g8-premove')), findsNothing);
      expect(find.byKey(const Key('g7-whitepawn')), findsNothing);
      expect(find.byKey(const Key('g8-whitequeen')), findsOneWidget);
    });

    testWidgets('play a premove with promotion, autoqueen disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          settings: const ChessboardSettings(
            autoQueenPromotionOnPremove: false,
            animationDuration: Duration.zero,
          ),
          initialPlayerSide: PlayerSide.white,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/8 w - - 0 1',
          shouldPlayOpponentMove: true,
        ),
      );

      await makeMove(tester, Square.g6, Square.g7);
      await makeMove(tester, Square.g7, Square.g8);
      expect(find.byKey(const Key('g7-premove')), findsOneWidget);
      expect(find.byKey(const Key('g8-premove')), findsOneWidget);

      // wait for opponent move to be played
      await tester.pump(const Duration(milliseconds: 200));

      // promotion dialog is shown
      expect(find.byType(PromotionSelector), findsOneWidget);

      // premove highlight are not shown anymore
      expect(find.byKey(const Key('g7-premove')), findsNothing);
      expect(find.byKey(const Key('g8-premove')), findsNothing);

      // promotion pawn is not visible
      expect(find.byKey(const Key('g7-whitepawn')), findsNothing);

      // select knight
      await tester.tapAt(squareOffset(Square.g7));
      await tester.pump();

      expect(find.byKey(const Key('g8-whiteknight')), findsOneWidget);
      expect(find.byKey(const Key('g7-whitepawn')), findsNothing);

      // wait for other opponent move to be played
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('cancel a premove promotion', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          settings: const ChessboardSettings(
            autoQueenPromotionOnPremove: false,
            animationDuration: Duration.zero,
          ),
          initialPlayerSide: PlayerSide.white,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/8 w - - 0 1',
          shouldPlayOpponentMove: true,
        ),
      );

      await makeMove(tester, Square.g6, Square.g7);
      await makeMove(tester, Square.g7, Square.g8);
      expect(find.byKey(const Key('g7-premove')), findsOneWidget);
      expect(find.byKey(const Key('g8-premove')), findsOneWidget);

      // wait for opponent move to be played
      await tester.pump(const Duration(milliseconds: 200));

      // promotion dialog is shown
      expect(find.byType(PromotionSelector), findsOneWidget);

      // premove highlight are not shown anymore
      expect(find.byKey(const Key('g7-premove')), findsNothing);
      expect(find.byKey(const Key('g8-premove')), findsNothing);

      // cancel promotion dialog
      await tester.tapAt(squareOffset(Square.c3));
      await tester.pump();

      // promotion dialog is closed
      expect(find.byType(PromotionSelector), findsNothing);

      expect(find.byKey(const Key('g7-whitepawn')), findsOneWidget);
    });
  });

  group('Drawing shapes', () {
    testWidgets('preconfigure board to draw a circle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialPlayerSide: PlayerSide.both,
          initialShapes: ISet(
            {const Circle(orig: Square.e4, color: Color(0xFF0000FF))},
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
          initialPlayerSide: PlayerSide.both,
          initialShapes: ISet({
            const Arrow(
              orig: Square.e2,
              dest: Square.e4,
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
          initialPlayerSide: PlayerSide.both,
          initialShapes: ISet({
            const PieceShape(
              orig: Square.e4,
              piece: Piece.whitePawn,
              pieceAssets: PieceSet.horseyAssets,
            ),
          }),
        ),
      );

      expect(find.byType(ShapeWidget), findsOneWidget);

      final shapeSize = tester.getSize(find.byType(ShapeWidget));
      expect(shapeSize.width, squareSize);
      expect(shapeSize.height, squareSize);
    });

    testWidgets('cannot draw if not enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialPlayerSide: PlayerSide.both,
        ),
      );

      await TestAsyncUtils.guard<void>(() async {
        // keep pressing an empty square to enable drawing shapes
        final pressGesture = await tester.startGesture(squareOffset(Square.a3));

        // drawing a circle with another tap
        final tapGesture = await tester.startGesture(squareOffset(Square.e4));
        await tapGesture.up();

        await pressGesture.up();
      });

      expect(find.byType(ShapeWidget), findsNothing);
    });

    testWidgets('draw a circle by hand', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialPlayerSide: PlayerSide.both,
          enableDrawingShapes: true,
        ),
      );

      await TestAsyncUtils.guard<void>(() async {
        // keep pressing an empty square to enable drawing shapes
        final pressGesture = await tester.startGesture(squareOffset(Square.a3));

        // drawing a circle with another tap
        final tapGesture = await tester.startGesture(squareOffset(Square.e4));
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
          initialPlayerSide: PlayerSide.both,
          enableDrawingShapes: true,
        ),
      );

      // keep pressing an empty square to enable drawing shapes
      final pressGesture = await tester.startGesture(squareOffset(Square.a3));

      await tester.dragFrom(
        squareOffset(Square.e2),
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
          initialPlayerSide: PlayerSide.none,
          enableDrawingShapes: true,
        ),
      );

      // keep pressing an empty square to enable drawing shapes
      final pressGesture = await tester.startGesture(squareOffset(Square.a3));

      await tester.dragFrom(
        squareOffset(Square.e2),
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
          initialPlayerSide: PlayerSide.both,
          enableDrawingShapes: true,
        ),
      );

      await TestAsyncUtils.guard<void>(() async {
        // keep pressing an empty square to enable drawing shapes
        final pressGesture = await tester.startGesture(squareOffset(Square.a3));

        // drawing a circle with another tap
        final tapGesture = await tester.startGesture(squareOffset(Square.e4));
        await tapGesture.up();

        await pressGesture.up();
      });

      // wait for the double tap delay to expire
      await tester.pump(const Duration(milliseconds: 210));

      // keep pressing an empty square to enable drawing shapes
      final pressGesture = await tester.startGesture(squareOffset(Square.a3));

      await tester.dragFrom(
        squareOffset(Square.e2),
        const Offset(0, -(squareSize * 2)),
      );

      await pressGesture.up();

      // wait for the double tap delay to expire
      await tester.pump(const Duration(milliseconds: 210));

      expect(find.byType(ShapeWidget), findsNWidgets(2));

      await tester.tapAt(squareOffset(Square.a3));
      await tester.tapAt(squareOffset(Square.a3));
      await tester.pump();

      expect(find.byType(ShapeWidget), findsNothing);
    });

    testWidgets('selecting one piece should clear shapes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildBoard(
          initialPlayerSide: PlayerSide.both,
          enableDrawingShapes: true,
        ),
      );

      await TestAsyncUtils.guard<void>(() async {
        // keep pressing an empty square to enable drawing shapes
        final pressGesture = await tester.startGesture(squareOffset(Square.a3));

        // drawing a circle with another tap
        final tapGesture = await tester.startGesture(squareOffset(Square.e4));
        await tapGesture.up();

        await pressGesture.up();
      });

      // wait for the double tap delay to expire
      await tester.pump(const Duration(milliseconds: 210));

      expect(find.byType(ShapeWidget), findsOneWidget);

      await tester.tapAt(squareOffset(Square.e2));
      await tester.pump();

      expect(find.byType(ShapeWidget), findsNothing);
    });
  });

  group('piece orientation behavior', () {
    void checkUpsideDownPieces(
      WidgetTester tester, {
      required bool expectWhiteUpsideDown,
      required bool expectBlackUpsideDown,
    }) {
      final pieceWidgets =
          tester.widgetList<PieceWidget>(find.byType(PieceWidget));
      expect(pieceWidgets, hasLength(32));
      for (final pieceWidget in pieceWidgets) {
        if (pieceWidget.piece.color == Side.white) {
          expect(pieceWidget.upsideDown, expectWhiteUpsideDown);
        } else {
          expect(pieceWidget.upsideDown, expectBlackUpsideDown);
        }
      }
    }

    testWidgets('facing user', (WidgetTester tester) async {
      for (final orientation in Side.values) {
        await tester.pumpWidget(
          buildBoard(
            settings: const ChessboardSettings(
              animationDuration: Duration.zero,
            ),
            initialPlayerSide: PlayerSide.both,
            orientation: orientation,
          ),
        );

        checkUpsideDownPieces(
          tester,
          expectWhiteUpsideDown: false,
          expectBlackUpsideDown: false,
        );

        await makeMove(tester, Square.e2, Square.e4);

        checkUpsideDownPieces(
          tester,
          expectWhiteUpsideDown: false,
          expectBlackUpsideDown: false,
        );
      }
    });

    testWidgets('opponent upside down', (WidgetTester tester) async {
      for (final orientation in Side.values) {
        await tester.pumpWidget(
          buildBoard(
            initialPlayerSide: PlayerSide.both,
            orientation: orientation,
            settings: const ChessboardSettings(
              animationDuration: Duration.zero,
              pieceOrientationBehavior:
                  PieceOrientationBehavior.opponentUpsideDown,
            ),
          ),
        );

        checkUpsideDownPieces(
          tester,
          expectWhiteUpsideDown: orientation != Side.white,
          expectBlackUpsideDown: orientation == Side.white,
        );

        await makeMove(tester, Square.e2, Square.e4);

        checkUpsideDownPieces(
          tester,
          expectWhiteUpsideDown: orientation != Side.white,
          expectBlackUpsideDown: orientation == Side.white,
        );
      }
    });

    testWidgets('side to play', (WidgetTester tester) async {
      for (final orientation in Side.values) {
        await tester.pumpWidget(
          buildBoard(
            initialPlayerSide: PlayerSide.both,
            orientation: orientation,
            settings: const ChessboardSettings(
              animationDuration: Duration.zero,
              pieceOrientationBehavior: PieceOrientationBehavior.sideToPlay,
            ),
          ),
        );

        checkUpsideDownPieces(
          tester,
          expectWhiteUpsideDown: orientation != Side.white,
          expectBlackUpsideDown: orientation != Side.white,
        );

        await makeMove(tester, Square.e2, Square.e4);

        checkUpsideDownPieces(
          tester,
          expectWhiteUpsideDown: orientation == Side.white,
          expectBlackUpsideDown: orientation == Side.white,
        );
      }
    });
  });
}

Future<void> makeMove(WidgetTester tester, Square from, Square to) async {
  final orientation =
      tester.widget<Chessboard>(find.byType(Chessboard)).orientation;
  await tester.tapAt(squareOffset(from, orientation: orientation));
  await tester.pump();
  await tester.tapAt(squareOffset(to, orientation: orientation));
  await tester.pump();
}

Widget buildBoard({
  required PlayerSide initialPlayerSide,
  ChessboardSettings? settings,
  Side orientation = Side.white,
  String initialFen = kInitialFEN,
  NormalMove? initialPromotionMove,
  ISet<Shape>? initialShapes,
  bool enableDrawingShapes = false,
  PieceShiftMethod pieceShiftMethod = PieceShiftMethod.either,

  /// play the first available move for the opponent after a delay of 200ms
  bool shouldPlayOpponentMove = false,
}) {
  PlayerSide interactiveSide = initialPlayerSide;
  Position<Chess> position = Chess.fromSetup(Setup.parseFen(initialFen));
  NormalMove? lastMove;
  NormalMove? premoveData;
  NormalMove? promotionMove = initialPromotionMove;
  ISet<Shape> shapes = initialShapes ?? ISet();

  void playMove(NormalMove move) {
    position = position.playUnchecked(move);
    if (position.isGameOver) {
      interactiveSide = PlayerSide.none;
    }
    lastMove = move;
  }

  bool isPromotionPawnMove(NormalMove move) {
    return move.promotion == null &&
        position.board.roleAt(move.from) == Role.pawn &&
        ((move.to.rank == Rank.first && position.turn == Side.black) ||
            (move.to.rank == Rank.eighth && position.turn == Side.white));
  }

  return MaterialApp(
    home: StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        final defaultSettings = ChessboardSettings(
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

        return Align(
          alignment: Alignment.topLeft,
          child: Chessboard(
            size: boardSize,
            settings: settings ?? defaultSettings,
            orientation: orientation,
            fen: position.fen,
            lastMove: lastMove,
            game: GameData(
              playerSide: interactiveSide,
              isCheck: position.isCheck,
              sideToMove: position.turn == Side.white ? Side.white : Side.black,
              validMoves: makeLegalMoves(position),
              promotionMove: promotionMove,
              onMove: (NormalMove move, {isDrop}) {
                setState(() {
                  if (isPromotionPawnMove(move)) {
                    promotionMove = move;
                  } else {
                    playMove(move);
                  }
                });

                if (shouldPlayOpponentMove) {
                  Timer(const Duration(milliseconds: 200), () {
                    final allMoves = [
                      for (final entry in position.legalMoves.entries)
                        for (final dest in entry.value.squares)
                          NormalMove(from: entry.key, to: dest),
                    ];
                    final opponentMove = allMoves.first;
                    setState(() {
                      position = position.playUnchecked(opponentMove);
                      if (position.isGameOver) {
                        interactiveSide = PlayerSide.none;
                      }
                      lastMove = NormalMove.fromUci(opponentMove.uci);
                    });

                    // play premove just after the opponent move
                    if (premoveData != null) {
                      if (position.isLegal(premoveData!)) {
                        if (!isPromotionPawnMove(premoveData!)) {
                          Timer.run(() {
                            setState(() {
                              position = position.playUnchecked(premoveData!);
                              premoveData = null;
                            });
                          });
                        } else {
                          setState(() {
                            promotionMove = premoveData;
                            premoveData = null;
                          });
                        }
                      }
                    }
                  });
                }
              },
              onPromotionSelection: (Role? role) {
                setState(() {
                  if (role != null) {
                    playMove(promotionMove!.withPromotion(role));
                  }
                  promotionMove = null;
                });
              },
              premovable: (
                premove: premoveData,
                onSetPremove: (NormalMove? move) {
                  setState(() {
                    premoveData = move;
                  });
                },
              ),
            ),
            shapes: shapes,
          ),
        );
      },
    ),
  );
}

Offset squareOffset(Square id, {Side orientation = Side.white}) {
  final x = orientation == Side.black ? 7 - id.file : id.file;
  final y = orientation == Side.black ? id.rank : 7 - id.rank;
  final o = Offset(x * squareSize, y * squareSize);
  return Offset(o.dx + squareSize / 2, o.dy + squareSize / 2);
}
