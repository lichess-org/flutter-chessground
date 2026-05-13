import 'dart:async';
import 'dart:ui' as ui;
import 'package:chessground/src/widgets/animation.dart';
import 'package:chessground/src/widgets/board_painter.dart';
import 'package:chessground/src/widgets/promotion.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartchess/dartchess.dart';
import 'package:chessground/chessground.dart';
import 'package:mocktail/mocktail.dart';

const boardSize = 200.0;
const squareSize = boardSize / 8;

HighlightsPainter _highlightsPainter(WidgetTester tester) {
  for (final element in find.byType(CustomPaint).evaluate()) {
    final widget = element.widget as CustomPaint;
    if (widget.painter is HighlightsPainter) {
      return widget.painter! as HighlightsPainter;
    }
  }
  throw StateError('HighlightsPainter not found');
}

bool _isSelected(WidgetTester tester, Square square) {
  return _highlightsPainter(tester).interactionNotifier.selected == square;
}

bool _isLastMove(WidgetTester tester, Square square) {
  final p = _highlightsPainter(tester);
  return p.showLastMove &&
      p.lastMove != null &&
      p.lastMove!.hasSquare(square) &&
      (p.premove == null || !p.premove!.hasSquare(square));
}

bool _isPremove(WidgetTester tester, Square square) {
  final p = _highlightsPainter(tester);
  return p.premove != null && p.premove!.hasSquare(square);
}

bool _isCheckSquare(WidgetTester tester, Square square) {
  return _highlightsPainter(tester).checkSquare == square;
}

int _moveDestCount(WidgetTester tester) {
  return _highlightsPainter(tester).interactionNotifier.moveDests.length;
}

int _premoveDestCount(WidgetTester tester) {
  return _highlightsPainter(tester).interactionNotifier.premoveDests.length;
}

class OnTappedSquareMock extends Mock {
  void call(Square square);
}

void main() {
  group('Non-interactive board', () {
    final onTouchedSquare = OnTappedSquareMock();
    tearDown(() {
      reset(onTouchedSquare);
    });

    final viewOnlyBoard = Chessboard.fixed(
      size: boardSize,
      orientation: Side.white,
      fen: kInitialFEN,
      settings: const ChessboardSettings(drawShape: DrawShapeOptions(enable: true)),
      onTouchedSquare: onTouchedSquare.call,
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

      expect(_isSelected(tester, Square.e2), isFalse);

      verify(() => onTouchedSquare.call(Square.e2)).called(1);
      verifyNoMoreInteractions(onTouchedSquare);
    });

    testWidgets('moved piece is animated when the position change', (WidgetTester tester) async {
      const board = Chessboard.fixed(size: boardSize, orientation: Side.white, fen: kInitialFEN);

      await tester.pumpWidget(board);

      expect(find.byType(AnimatedPieceTranslation), findsNothing);
      expect(find.byType(PieceWidget), findsNWidgets(32));

      const board2 = Chessboard.fixed(
        size: boardSize,
        orientation: Side.white,
        fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
      );

      await tester.pumpWidget(board2);

      expect(find.byType(PieceWidget), findsNWidgets(32));
      expect(find.byType(AnimatedPieceTranslation), findsOneWidget);

      final translation =
          tester.firstWidget(find.byType(AnimatedPieceTranslation)) as AnimatedPieceTranslation;
      expect(translation.fromSquare, Square.e2);
      expect(translation.toSquare, Square.e4);
      expect(translation.orientation, Side.white);
      expect(translation.duration, const Duration(milliseconds: 250));

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('e2-whitepawn')), findsNothing);
      expect(find.byKey(const Key('e4-whitepawn')), findsOneWidget);

      expect(find.byType(AnimatedPieceTranslation), findsNothing);
    });

    testWidgets('several pieces can be animated when the position change', (
      WidgetTester tester,
    ) async {
      const board = Chessboard.fixed(
        size: boardSize,
        orientation: Side.white,
        fen: 'rnbqk2r/pppp1ppp/5n2/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4',
      );

      await tester.pumpWidget(board);

      expect(find.byType(AnimatedPieceTranslation), findsNothing);
      expect(find.byType(PieceWidget), findsNWidgets(32));

      const board2 = Chessboard.fixed(
        size: boardSize,
        orientation: Side.white,
        fen: 'rnbqk2r/pppp1ppp/5n2/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQ1RK1 b kq - 5 4',
      );

      await tester.pumpWidget(board2);

      expect(find.byType(PieceWidget), findsNWidgets(32));
      expect(find.byType(AnimatedPieceTranslation), findsNWidgets(2));

      await tester.pumpAndSettle();

      expect(find.byType(AnimatedPieceTranslation), findsNothing);
    });

    testWidgets('background is constrained to the size of the board', (WidgetTester tester) async {
      await tester.pumpWidget(viewOnlyBoard);

      final size = tester.getSize(find.byType(SolidColorChessboardBackground));
      expect(size.width, boardSize);
      expect(size.height, boardSize);
    });

    testWidgets('displays a border', (WidgetTester tester) async {
      const board = Chessboard.fixed(
        size: boardSize,
        orientation: Side.white,
        fen: kInitialFEN,
        settings: ChessboardSettings(
          drawShape: DrawShapeOptions(enable: true),
          border: BoardBorder(width: 16.0, color: Color(0xFF000000)),
        ),
      );

      await tester.pumpWidget(board);

      final size = tester.getSize(find.byType(SolidColorChessboardBackground));
      expect(size.width, boardSize - 32.0);
      expect(size.height, boardSize - 32.0);
    });

    testWidgets('change in hue will use a color filter', (WidgetTester tester) async {
      const board = Chessboard.fixed(
        size: boardSize,
        orientation: Side.white,
        fen: kInitialFEN,
        settings: ChessboardSettings(hue: 100.0),
      );

      await tester.pumpWidget(board);

      expect(find.byType(ColorFiltered), findsOneWidget);
    });

    testWidgets('change in brightness will use a color filter', (WidgetTester tester) async {
      const board = Chessboard.fixed(
        size: boardSize,
        orientation: Side.white,
        fen: kInitialFEN,
        settings: ChessboardSettings(brightness: 0.9),
      );

      await tester.pumpWidget(board);

      expect(find.byType(ColorFiltered), findsOneWidget);
    });
  });

  group('Interactive board', () {
    testWidgets('selecting and deselecting a square', (WidgetTester tester) async {
      for (final settings in [
        const ChessboardSettings(),
        const ChessboardSettings(border: BoardBorder(width: 16.0, color: Color(0xFF000000))),
      ]) {
        final onTouchedSquare = OnTappedSquareMock();
        await tester.pumpWidget(
          _TestApp(
            initialPlayerSide: PlayerSide.both,
            settings: settings,
            key: ValueKey(settings.hashCode),
            onTouchedSquare: onTouchedSquare.call,
          ),
        );
        await tester.tap(find.byKey(const Key('a2-whitepawn')));
        await tester.pump();

        expect(_isSelected(tester, Square.a2), isTrue);
        expect(_moveDestCount(tester) + _premoveDestCount(tester), 2);

        // selecting same deselects
        await tester.tap(find.byKey(const Key('a2-whitepawn')));
        await tester.pump();
        expect(_isSelected(tester, Square.a2), isFalse);
        expect(_moveDestCount(tester) + _premoveDestCount(tester), 0);

        // selecting another square
        await tester.tap(find.byKey(const Key('a1-whiterook')));
        await tester.pump();
        expect(_isSelected(tester, Square.a1), isTrue);
        expect(_moveDestCount(tester) + _premoveDestCount(tester), 0);

        // selecting an opposite piece deselects
        await tester.tap(find.byKey(const Key('e7-blackpawn')));
        await tester.pump();
        expect(_isSelected(tester, Square.a1), isFalse);
        expect(_moveDestCount(tester) + _premoveDestCount(tester), 0);

        // selecting an empty square deselects
        await tester.tap(find.byKey(const Key('a1-whiterook')));
        await tester.pump();
        expect(_isSelected(tester, Square.a1), isTrue);
        await tester.tapAt(squareOffset(tester, Square.c4));
        await tester.pump();
        expect(_isSelected(tester, Square.a1), isFalse);

        // cannot select a piece whose side is not the turn to move
        await tester.tap(find.byKey(const Key('e7-blackpawn')));
        await tester.pump();
        expect(_isSelected(tester, Square.e7), isFalse);

        verifyInOrder([
          () => onTouchedSquare.call(Square.a2),
          () => onTouchedSquare.call(Square.a2),
          () => onTouchedSquare.call(Square.a1),
          () => onTouchedSquare.call(Square.e7),
          () => onTouchedSquare.call(Square.a1),
          () => onTouchedSquare.call(Square.c4),
          () => onTouchedSquare.call(Square.e7),
        ]);
        verifyNoMoreInteractions(onTouchedSquare);
      }
    });

    testWidgets('play e2-e4 move by tap', (WidgetTester tester) async {
      for (final settings in [
        const ChessboardSettings(),
        const ChessboardSettings(border: BoardBorder(width: 16.0, color: Color(0xFF000000))),
      ]) {
        await tester.pumpWidget(
          _TestApp(
            initialPlayerSide: PlayerSide.both,
            settings: settings,
            key: ValueKey(settings.hashCode),
          ),
        );
        await tester.tap(find.byKey(const Key('e2-whitepawn')));
        await tester.pump();

        expect(_isSelected(tester, Square.e2), isTrue);
        expect(_moveDestCount(tester) + _premoveDestCount(tester), 2);

        await tester.tapAt(squareOffset(tester, Square.e4));
        await tester.pump();

        expect(find.byKey(const Key('e4-whitepawn')), findsOneWidget);
        expect(_isSelected(tester, Square.e2), isFalse);
        expect(_moveDestCount(tester) + _premoveDestCount(tester), 0);

        // wait for the animations to finish
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('e4-whitepawn')), findsOneWidget);
        expect(find.byKey(const Key('e2-whitepawn')), findsNothing);
        expect(_isLastMove(tester, Square.e2), isTrue);
        expect(_isLastMove(tester, Square.e4), isTrue);
      }
    });

    testWidgets('Cannot move by tap if piece shift method is drag', (WidgetTester tester) async {
      for (final settings in [
        const ChessboardSettings(pieceShiftMethod: PieceShiftMethod.drag),
        const ChessboardSettings(
          pieceShiftMethod: PieceShiftMethod.drag,
          border: BoardBorder(width: 16.0, color: Color(0xFF000000)),
        ),
      ]) {
        final onTouchedSquare = OnTappedSquareMock();
        await tester.pumpWidget(
          _TestApp(
            initialPlayerSide: PlayerSide.both,
            settings: settings,
            key: ValueKey(settings.hashCode),
            onTouchedSquare: onTouchedSquare.call,
          ),
        );
        await tester.tap(find.byKey(const Key('e2-whitepawn')));
        await tester.pump();

        // Tapping a square should have no effect...
        expect(_isSelected(tester, Square.e2), isFalse);
        expect(_moveDestCount(tester) + _premoveDestCount(tester), 0);

        // ... but move by drag should work
        await tester.dragFrom(squareOffset(tester, Square.e2), const Offset(0, -(squareSize * 2)));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('e4-whitepawn')), findsOneWidget);
        expect(find.byKey(const Key('e2-whitepawn')), findsNothing);
        expect(_isLastMove(tester, Square.e2), isTrue);
        expect(_isLastMove(tester, Square.e4), isTrue);

        verifyInOrder([
          () => onTouchedSquare.call(Square.e2),
          () => onTouchedSquare.call(Square.e2),
        ]);
        verifyNoMoreInteractions(onTouchedSquare);
      }
    });

    testWidgets('Square is always deselected after drag if piece shift method is drag', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          settings: ChessboardSettings(pieceShiftMethod: PieceShiftMethod.drag),
        ),
      );
      await tester.tap(find.byKey(const Key('e2-whitepawn')));
      await tester.pump();

      // simluate a drag that leaves the piece on the same square
      await tester.dragFrom(squareOffset(tester, Square.e2), const Offset(0, -(squareSize / 2)));
      await tester.pumpAndSettle();
      expect(_isSelected(tester, Square.e2), isFalse);
    });

    testWidgets('castling by selecting king then rook is possible', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialFen: 'r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4',
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
      expect(_isLastMove(tester, Square.e1), isTrue);
      expect(_isLastMove(tester, Square.h1), isTrue);
    });

    testWidgets('dragging off target', (WidgetTester tester) async {
      for (final settings in [
        const ChessboardSettings(),
        const ChessboardSettings(border: BoardBorder(width: 16.0, color: Color(0xFF000000))),
      ]) {
        await tester.pumpWidget(
          _TestApp(
            initialPlayerSide: PlayerSide.both,
            settings: settings,
            key: ValueKey(settings.hashCode),
          ),
        );

        final e2 = squareOffset(tester, Square.e2);
        await tester.dragFrom(e2, const Offset(0, -(squareSize * 4)));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('e2-whitepawn')), findsOneWidget);
        expect(_isSelected(tester, Square.e2), isFalse);
        expect(_moveDestCount(tester) + _premoveDestCount(tester), 0);
      }
    });

    testWidgets('dragging off board', (WidgetTester tester) async {
      for (final settings in [
        const ChessboardSettings(),
        const ChessboardSettings(border: BoardBorder(width: 16.0, color: Color(0xFF000000))),
      ]) {
        await tester.pumpWidget(
          _TestApp(initialPlayerSide: PlayerSide.both, key: ValueKey(settings.hashCode)),
        );

        await tester.dragFrom(
          squareOffset(tester, Square.e2),
          squareOffset(tester, Square.e2) + const Offset(0, -boardSize + squareSize),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('e2-whitepawn')), findsOneWidget);
        expect(_isSelected(tester, Square.e2), isFalse);
        expect(_moveDestCount(tester) + _premoveDestCount(tester), 0);
      }
    });

    testWidgets('e2-e4 drag move', (WidgetTester tester) async {
      for (final settings in [
        const ChessboardSettings(),
        const ChessboardSettings(border: BoardBorder(width: 16.0, color: Color(0xFF000000))),
      ]) {
        await tester.pumpWidget(
          _TestApp(initialPlayerSide: PlayerSide.both, key: ValueKey(settings.hashCode)),
        );
        await tester.dragFrom(squareOffset(tester, Square.e2), const Offset(0, -(squareSize * 2)));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('e4-whitepawn')), findsOneWidget);
        expect(find.byKey(const Key('e2-whitepawn')), findsNothing);
        expect(_isLastMove(tester, Square.e2), isTrue);
        expect(_isLastMove(tester, Square.e4), isTrue);
      }
    });

    testWidgets('dragging a piece onto the board triggers DropMove', (WidgetTester tester) async {
      final pos = Position.setupPosition(
        Rule.crazyhouse,
        Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR[Pn] w KQkq - 0 1'),
      );
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.both,
          rule: Rule.crazyhouse,
          initialFen: pos.fen,
          droppable: (validDropSquares: pos.legalDrops.squares.toISet()),
          bottomWidget: Column(
            children: [
              Draggable(
                key: const Key('whitePawn'),
                data: Piece.whitePawn,
                feedback: const SizedBox.shrink(),
                child: PieceWidget(
                  piece: Piece.whitePawn,
                  size: squareSize,
                  pieceAssets: PieceSet.merida.assets,
                ),
              ),
              Draggable(
                key: const Key('blackKnight'),
                data: Piece.blackKnight,
                feedback: const SizedBox.shrink(),
                child: PieceWidget(
                  piece: Piece.blackKnight,
                  size: squareSize,
                  pieceAssets: PieceSet.merida.assets,
                ),
              ),
            ],
          ),
        ),
      );

      final whitePawnDraggable = find.byKey(const Key('whitePawn'));

      await tester.drag(
        whitePawnDraggable,
        tester.getCenter(find.byKey(const Key('e4-drag-target'))) -
            tester.getCenter(whitePawnDraggable),
      );

      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e4-whitepawn')), findsOneWidget);
      // Just to make sure we didn't play a normal move
      expect(find.byKey(const Key('e2-whitepawn')), findsOneWidget);

      final blackKnightDraggable = find.byKey(const Key('blackKnight'));
      await tester.drag(
        blackKnightDraggable,
        tester.getCenter(find.byKey(const Key('e5-drag-target'))) -
            tester.getCenter(blackKnightDraggable),
      );

      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e4-whitepawn')), findsOneWidget);
      expect(find.byKey(const Key('e5-blackknight')), findsOneWidget);
    });

    testWidgets('Cannot move pawns onto the back rank', (WidgetTester tester) async {
      final pos = Position.setupPosition(
        Rule.crazyhouse,
        Setup.parseFen('8/8/3K4/8/3k4/8/8/8[PNp] w - - 0 1'),
      );
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialFen: pos.fen,
          rule: Rule.crazyhouse,
          droppable: (validDropSquares: pos.legalDrops.squares.toISet()),
          bottomWidget: Column(
            children: [
              Draggable(
                key: const Key('whitePawn'),
                data: Piece.whitePawn,
                feedback: const SizedBox.shrink(),
                child: PieceWidget(
                  piece: Piece.whitePawn,
                  size: squareSize,
                  pieceAssets: PieceSet.merida.assets,
                ),
              ),
              Draggable(
                key: const Key('whiteKnight'),
                data: Piece.whiteKnight,
                feedback: const SizedBox.shrink(),
                child: PieceWidget(
                  piece: Piece.whiteKnight,
                  size: squareSize,
                  pieceAssets: PieceSet.merida.assets,
                ),
              ),
            ],
          ),
        ),
      );

      final whitePawnDraggable = find.byKey(const Key('whitePawn'));

      await tester.drag(
        whitePawnDraggable,
        tester.getCenter(find.byKey(const Key('a1-drag-target'))) -
            tester.getCenter(whitePawnDraggable),
      );
      await tester.drag(
        whitePawnDraggable,
        tester.getCenter(find.byKey(const Key('a8-drag-target'))) -
            tester.getCenter(whitePawnDraggable),
      );

      await tester.pumpAndSettle();
      expect(find.byKey(const Key('a8-whitepawn')), findsNothing);
      expect(find.byKey(const Key('a1-whitepawn')), findsNothing);

      // Dragging other pieces onto the back rank should work though
      final whiteKnightDraggable = find.byKey(const Key('whiteKnight'));
      await tester.drag(
        whiteKnightDraggable,
        tester.getCenter(find.byKey(const Key('a8-drag-target'))) -
            tester.getCenter(whiteKnightDraggable),
      );

      await tester.pumpAndSettle();
      expect(find.byKey(const Key('a8-whiteknight')), findsOneWidget);
    });

    testWidgets('Cannot play illegal drop moves', (WidgetTester tester) async {
      final pos = Position.setupPosition(
        Rule.crazyhouse,
        Setup.parseFen('rnb1kbnr/pppp2pp/8/4p3/8/2q2N2/PP2PPPP/R1B1KB1R[P] w - - 8 8'),
      );
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.both,
          // white is in check, so we can't drag the pawn onto a square that doesn't block the check.
          initialFen: pos.fen,
          rule: Rule.crazyhouse,
          droppable: (validDropSquares: pos.legalDrops.squares.toISet()),
          bottomWidget: Column(
            children: [
              Draggable(
                key: const Key('whitePawn'),
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

      final whitePawnDraggable = find.byKey(const Key('whitePawn'));

      // This square is empty, but this move wouldn't block the check, so it should not be allowed
      await tester.drag(
        whitePawnDraggable,
        tester.getCenter(find.byKey(const Key('a4-drag-target'))) -
            tester.getCenter(whitePawnDraggable),
      );

      await tester.pumpAndSettle();
      expect(find.byKey(const Key('a4-whitepawn')), findsNothing);

      // Only square that blocks the check
      await tester.drag(
        whitePawnDraggable,
        tester.getCenter(find.byKey(const Key('d2-drag-target'))) -
            tester.getCenter(whitePawnDraggable),
      );

      await tester.pumpAndSettle();
      expect(find.byKey(const Key('d2-whitepawn')), findsOneWidget);
    });

    testWidgets('no drag targets if drop moves not explicitly enabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));

      expect(find.byKey(const Key('e4-drag-target')), findsNothing);
    });

    testWidgets('Cannot move by drag if piece shift method is tapTwoSquares', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestApp(
          settings: ChessboardSettings(
            animationDuration: Duration.zero,
            pieceShiftMethod: PieceShiftMethod.tapTwoSquares,
          ),
          initialPlayerSide: PlayerSide.white,
        ),
      );
      await tester.dragFrom(squareOffset(tester, Square.e2), const Offset(0, -(squareSize * 2)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('e4-whitepawn')), findsNothing);
      expect(find.byKey(const Key('e2-whitepawn')), findsOneWidget);
      expect(_isLastMove(tester, Square.e2), isFalse);
      expect(_isLastMove(tester, Square.e4), isFalse);

      // Original square is still selected after drag attempt
      expect(_isSelected(tester, Square.e2), isTrue);
      expect(_moveDestCount(tester) + _premoveDestCount(tester), 2);

      // ...so we can still tap to move
      await tester.tapAt(squareOffset(tester, Square.e4));
      await tester.pump();
      expect(_isSelected(tester, Square.e2), isFalse);
      expect(_moveDestCount(tester) + _premoveDestCount(tester), 0);
      expect(find.byKey(const Key('e4-whitepawn')), findsOneWidget);
      expect(find.byKey(const Key('e2-whitepawn')), findsNothing);
      expect(_isLastMove(tester, Square.e2), isTrue);
      expect(_isLastMove(tester, Square.e4), isTrue);
    });

    testWidgets('2 simultaneous pointer down events will cancel current drag/selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));
      await TestAsyncUtils.guard<void>(() async {
        await tester.startGesture(squareOffset(tester, Square.e2));

        await tester.pump();

        expect(_isSelected(tester, Square.e2), isTrue);

        await tester.startGesture(squareOffset(tester, Square.e4));

        await tester.pump();

        // move is cancelled
        expect(find.byKey(const Key('e4-whitepawn')), findsNothing);
        expect(find.byKey(const Key('e2-whitepawn')), findsOneWidget);
        // selection is cancelled
        expect(_isSelected(tester, Square.e2), isFalse);
      });
    });

    testWidgets('while dragging a piece, other pointer events will cancel', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));

      // drag a piece and tap on another own square while dragging
      await TestAsyncUtils.guard<void>(() async {
        final dragGesture = await tester.startGesture(squareOffset(tester, Square.e2));
        await tester.pump();

        // trigger a piece drag by moving the pointer by 4 pixels
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));

        expect(_isSelected(tester, Square.e2), isTrue);

        await tester.tap(find.byKey(const Key('d2-whitepawn')));

        // finish the move as to release the piece
        await dragGesture.moveTo(squareOffset(tester, Square.e4));
        await dragGesture.up();
      });

      await tester.pump();

      // the piece should not have moved
      expect(find.byKey(const Key('e4-whitepawn')), findsNothing);
      expect(find.byKey(const Key('e2-whitepawn')), findsOneWidget);
      // the piece should not be selected
      expect(_isSelected(tester, Square.e2), isFalse);

      // drag a piece and tap on an empty square while dragging
      await TestAsyncUtils.guard<void>(() async {
        final dragGesture = await tester.startGesture(squareOffset(tester, Square.d2));
        await tester.pump();

        // trigger a piece drag by moving the pointer by 4 pixels
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));

        expect(_isSelected(tester, Square.d2), isTrue);

        // tap on an empty square
        await tester.tapAt(squareOffset(tester, Square.f5));

        // finish the move as to release the piece
        await dragGesture.moveTo(squareOffset(tester, Square.d4));
        await dragGesture.up();
      });

      await tester.pump();

      // the piece should not have moved
      expect(find.byKey(const Key('d4-whitepawn')), findsNothing);
      expect(find.byKey(const Key('d2-whitepawn')), findsOneWidget);
      // the piece should not be selected
      expect(_isSelected(tester, Square.d2), isFalse);
    });

    testWidgets('dragging an unselected piece to the same square should keep the piece selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));
      final e2 = squareOffset(tester, Square.e2);
      await tester.dragFrom(e2, const Offset(0, -(squareSize / 3)));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('e2-whitepawn')), findsOneWidget);
      expect(_isSelected(tester, Square.e2), isTrue);
    });

    testWidgets('dragging an already selected piece should not deselect it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));
      final e2 = squareOffset(tester, Square.e2);
      await tester.tapAt(e2);
      await tester.pump();
      final dragFuture = tester.timedDragFrom(
        e2,
        const Offset(0, -(squareSize * 2)),
        const Duration(milliseconds: 200),
      );

      expectSync(find.byKey(const Key('e2-whitepawn')), findsOneWidget);
      expectSync(_isSelected(tester, Square.e2), isTrue);

      await dragFuture;
      await tester.pumpAndSettle();

      expectSync(_isSelected(tester, Square.e2), isFalse);
    });

    testWidgets('king check square black', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialFen: 'rnbqkbnr/ppp2ppp/3p4/4p3/3PP3/8/PPP2PPP/RNBQKBNR w KQkq - 0 3',
          initialPlayerSide: PlayerSide.white,
        ),
      );
      await makeMove(tester, Square.f1, Square.b5);
      expect(_isCheckSquare(tester, Square.e8), isTrue);
    });

    testWidgets('king check square white', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialFen: 'rnbqkbnr/pppp1ppp/8/4p3/3P4/4P3/PPP2PPP/RNBQKBNR b KQkq - 0 2',
          initialPlayerSide: PlayerSide.black,
        ),
      );
      await makeMove(tester, Square.f8, Square.b4);
      expect(_isCheckSquare(tester, Square.e1), isTrue);
    });

    testWidgets('piece is still selected when fen changes externally', (WidgetTester tester) async {
      final controller = StreamController<GameEvent>.broadcast();

      addTearDown(() {
        controller.close();
      });

      await tester.pumpWidget(
        _TestApp(
          initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
          gameEventStream: controller.stream,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.d2));
      await tester.pump();
      expect(_isSelected(tester, Square.d2), isTrue);
      // 4 premoves destinations are highlighted
      expect(_moveDestCount(tester) + _premoveDestCount(tester), 4);

      controller.add(GameEvent.externalMove);
      await tester.pump(const Duration(milliseconds: 1));

      // Selection should not be cleared
      expect(_isSelected(tester, Square.d2), isTrue);
      // now 2 moves destinations are highlighted instead of 4
      expect(_moveDestCount(tester) + _premoveDestCount(tester), 2);
    });

    testWidgets('cancel piece selection if board is made non interactive again', (
      WidgetTester tester,
    ) async {
      final controller = StreamController<GameEvent>.broadcast();

      addTearDown(() {
        controller.close();
      });

      await tester.pumpWidget(
        _TestApp(
          initialFen: kInitialBoardFEN,
          initialPlayerSide: PlayerSide.white,
          gameEventStream: controller.stream,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.e2));
      await tester.pump();
      expect(_isSelected(tester, Square.e2), isTrue);

      controller.add(GameEvent.nonInteractiveBoardEvent);
      await tester.pump(const Duration(milliseconds: 1));

      expect(_isSelected(tester, Square.e2), isFalse);
    });

    testWidgets('cancel piece current pointer event if board is made non interactive again', (
      WidgetTester tester,
    ) async {
      final controller = StreamController<GameEvent>.broadcast();

      addTearDown(() {
        controller.close();
      });

      await tester.pumpWidget(
        _TestApp(
          initialFen: 'r1bqkbnr/ppp2ppp/2np4/4p3/2B1P3/5Q2/PPPP1PPP/RNB1K1NR w KQkq - 0 4',
          initialPlayerSide: PlayerSide.white,
          gameEventStream: controller.stream,
        ),
      );

      await TestAsyncUtils.guard<void>(() async {
        await tester.startGesture(squareOffset(tester, Square.f3));
        await tester.pump();
        expect(_isSelected(tester, Square.f3), isTrue);
      });

      // make board non interactive in the middle of the gesture
      controller.add(GameEvent.nonInteractiveBoardEvent);
      await tester.pump(const Duration(milliseconds: 1));

      expect(_isSelected(tester, Square.f3), isFalse);

      // board is not interactive
      await tester.tapAt(squareOffset(tester, Square.f3));
      await tester.pump();
      expect(_isSelected(tester, Square.f3), isFalse);

      // make board interactive again
      controller.add(GameEvent.interactiveBoardEvent);
      await tester.pump(const Duration(milliseconds: 1));

      // the piece selection should work (which would not be the case if the
      // pointer event was not cancelled)
      await tester.tapAt(squareOffset(tester, Square.f3));
      await tester.pump();
      expect(_isSelected(tester, Square.f3), isTrue);
    });
  });

  testWidgets('onTouchedSquare callback', (WidgetTester tester) async {
    final controller = StreamController<GameEvent>.broadcast();

    addTearDown(() {
      controller.close();
    });

    final onTouchedSquare = OnTappedSquareMock();
    await tester.pumpWidget(
      _TestApp(
        initialPlayerSide: PlayerSide.white,
        gameEventStream: controller.stream,
        onTouchedSquare: onTouchedSquare.call,
      ),
    );

    // Trigger callback by tapping a square with a piece on it
    await tester.tapAt(squareOffset(tester, Square.a1));

    // Trigger callback by tapping an empty square
    await tester.tapAt(squareOffset(tester, Square.e4));

    // Drag a piece to the same square -> should trigger callback
    await tester.dragFrom(squareOffset(tester, Square.a2), const Offset(0, -(squareSize / 2)));

    // Drag from a empty square to the same square -> should trigger callback
    await tester.dragFrom(squareOffset(tester, Square.a4), const Offset(0, -(squareSize / 2)));

    // Drag from an empty square another empty square -> should trigger callback on 1st square
    await tester.dragFrom(squareOffset(tester, Square.a4), const Offset(0, -squareSize));

    // Drag piece to a different square (i.e. make a move) -> should trigger callback on 1st square
    await tester.dragFrom(squareOffset(tester, Square.a2), const Offset(0, -squareSize));

    // Callback should be triggered even if the board is non-interactive
    controller.add(GameEvent.nonInteractiveBoardEvent);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.tapAt(squareOffset(tester, Square.e3));

    verifyInOrder([
      () => onTouchedSquare(Square.a1),
      () => onTouchedSquare(Square.e4),
      () => onTouchedSquare(Square.a2),
      () => onTouchedSquare(Square.a4),
      () => onTouchedSquare(Square.a4),
      () => onTouchedSquare(Square.a2),
      () => onTouchedSquare(Square.e3),
    ]);
    verifyNoMoreInteractions(onTouchedSquare);
  });

  group('Promotion', () {
    testWidgets('can display the selector', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
          initialPromotionMove: NormalMove(from: Square.f7, to: Square.f8),
        ),
      );

      // promotion dialog is shown
      expect(find.byType(PromotionSelector), findsOneWidget);
    });

    testWidgets('promote a knight', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
        ),
      );

      await tester.tap(find.byKey(const Key('f7-whitepawn')));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.f8));
      await tester.pump();

      // wait for promotion selector to show
      await tester.pump();
      expect(find.byType(PromotionSelector), findsOneWidget);

      // promotion pawn is not visible
      expect(find.byKey(const Key('f7-whitepawn')), findsNothing);

      // tap on the knight
      await tester.tapAt(squareOffset(tester, Square.f7));
      await tester.pump();
      expect(find.byKey(const Key('f8-whiteknight')), findsOneWidget);
      expect(find.byKey(const Key('f7-whitepawn')), findsNothing);
    });
    testWidgets('Player on top promotes a bishop', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialFen: 'K7/8/k7/8/8/8/p7/1Q4n1 b - - 0 1',
        ),
      );

      await tester.tap(find.byKey(const Key('a2-blackpawn')));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.b1));
      await tester.pump();

      // wait for promotion selector to show
      await tester.pump();
      expect(find.byType(PromotionSelector), findsOneWidget);

      // promotion pawn is not visible
      expect(find.byKey(const Key('a2-blackpawn')), findsNothing);

      // tap on the bishop
      await tester.tapAt(squareOffset(tester, Square.b4));
      await tester.pump();
      expect(find.byKey(const Key('b1-blackbishop')), findsOneWidget);
      expect(find.byKey(const Key('a2-blackpawn')), findsNothing);
    });

    testWidgets('default promotion shows 4 pieces without king', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
        ),
      );

      await tester.tap(find.byKey(const Key('f7-whitepawn')));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.f8));
      await tester.pump();

      // wait for promotion selector to show
      await tester.pump();
      expect(find.byType(PromotionSelector), findsOneWidget);

      // Find all PieceWidget instances within the PromotionSelector
      final promotionSelector = find.byType(PromotionSelector);
      final piecesInSelector = find.descendant(
        of: promotionSelector,
        matching: find.byType(PieceWidget),
      );

      // Should have exactly 4 pieces (queen, knight, rook, bishop)
      expect(piecesInSelector, findsNWidgets(4));

      // Verify no king piece is present
      final pieceWidgets = tester.widgetList<PieceWidget>(piecesInSelector);
      final hasKing = pieceWidgets.any((widget) => widget.piece.role == Role.king);
      expect(hasKing, false);
    });
    testWidgets('promotion with canPromoteToKing shows 5 pieces including king', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
          canPromoteToKing: true,
        ),
      );

      await tester.tap(find.byKey(const Key('f7-whitepawn')));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.f8));
      await tester.pump();

      // wait for promotion selector to show
      await tester.pump();
      expect(find.byType(PromotionSelector), findsOneWidget);

      // Find all PieceWidget instances within the PromotionSelector
      final promotionSelector = find.byType(PromotionSelector);
      final piecesInSelector = find.descendant(
        of: promotionSelector,
        matching: find.byType(PieceWidget),
      );

      // has exactly 5 pieces (queen, knight, rook, bishop, king)
      expect(piecesInSelector, findsNWidgets(5));

      // Verify king piece is present
      final pieceWidgets = tester.widgetList<PieceWidget>(piecesInSelector);
      final hasKing = pieceWidgets.any((widget) => widget.piece.role == Role.king);
      expect(hasKing, true);
    });

    testWidgets('can promote to king when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
          canPromoteToKing: true,
        ),
      );

      await tester.tap(find.byKey(const Key('f7-whitepawn')));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.f8));
      await tester.pump();

      // wait for promotion selector to show
      await tester.pump();
      expect(find.byType(PromotionSelector), findsOneWidget);

      // tap on the king is the last option in the promotion selector
      await tester.tapAt(squareOffset(tester, Square.f4));
      await tester.pump();

      expect(find.byKey(const Key('f8-whiteking')), findsOneWidget);
      expect(find.byKey(const Key('f7-whitepawn')), findsNothing);
    });

    testWidgets('Player on top can promote to King', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialFen: 'K7/8/k7/8/8/8/p7/1Q4n1 b - - 0 1',
          canPromoteToKing: true,
        ),
      );
      await tester.tap(find.byKey(const Key('a2-blackpawn')));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.b1));
      await tester.pump();

      expect(find.byType(PromotionSelector), findsOneWidget);
      final promotionSelector = find.byType(PromotionSelector);
      final piecesInSelector = find.descendant(
        of: promotionSelector,
        matching: find.byType(PieceWidget),
      );

      // has exactly 5 pieces (queen, knight, rook, bishop, king)
      expect(piecesInSelector, findsNWidgets(5));

      // tap on the king is the last option in the promotion selector
      await tester.tapAt(squareOffset(tester, Square.b5));
      await tester.pump();

      expect(find.byKey(const Key('b1-blackking')), findsOneWidget);
      expect(find.byKey(const Key('a2-blackpawn')), findsNothing);
    });
    testWidgets('promote a piece on flipped board (orientation black)', (
      WidgetTester tester,
    ) async {
      const orientation = Side.black;
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
          orientation: orientation,
        ),
      );

      await tester.tap(find.byKey(const Key('f7-whitepawn')));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.f8, orientation: orientation));
      await tester.pump();

      // wait for promotion selector to show
      await tester.pump();
      expect(find.byType(PromotionSelector), findsOneWidget);
      final promotionSelector = find.byType(PromotionSelector);
      final piecesInSelector = find.descendant(
        of: promotionSelector,
        matching: find.byType(PieceWidget),
      );

      // has exactly 4 pieces (queen, knight, rook, bishop)
      expect(piecesInSelector, findsNWidgets(4));

      // promotion pawn is not visible
      expect(find.byKey(const Key('f7-whitepawn')), findsNothing);

      await tester.tapAt(squareOffset(tester, Square.f7, orientation: orientation));
      await tester.pump();
      expect(find.byKey(const Key('f8-whiteknight')), findsOneWidget);
      expect(find.byKey(const Key('f7-whitepawn')), findsNothing);
    });

    testWidgets('player at bottom promotes a bishop on flipped board (orientation black)', (
      WidgetTester tester,
    ) async {
      const orientation = Side.black;
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialFen: 'K7/8/k7/8/8/8/p7/1Q4n1 b - - 0 1',
          orientation: orientation,
        ),
      );

      await tester.tap(find.byKey(const Key('a2-blackpawn')));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.b1, orientation: orientation));
      await tester.pump();

      // wait for promotion selector to show
      await tester.pump();
      expect(find.byType(PromotionSelector), findsOneWidget);
      final promotionSelector = find.byType(PromotionSelector);
      final piecesInSelector = find.descendant(
        of: promotionSelector,
        matching: find.byType(PieceWidget),
      );

      // has exactly 4 pieces (queen, knight, rook, bishop)
      expect(piecesInSelector, findsNWidgets(4));

      // promotion pawn is not visible
      expect(find.byKey(const Key('a2-blackpawn')), findsNothing);

      // selector opens downward from b1 (rank 1 at top); queen, knight, rook, bishop
      await tester.tapAt(squareOffset(tester, Square.b4, orientation: orientation));
      await tester.pump();
      expect(find.byKey(const Key('b1-blackbishop')), findsOneWidget);
      expect(find.byKey(const Key('a2-blackpawn')), findsNothing);
    });

    testWidgets('can promote to king on flipped board (orientation black)', (
      WidgetTester tester,
    ) async {
      const orientation = Side.black;
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
          orientation: orientation,
          canPromoteToKing: true,
        ),
      );

      await tester.tap(find.byKey(const Key('f7-whitepawn')));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.f8, orientation: orientation));
      await tester.pump();

      // wait for promotion selector to show
      await tester.pump();
      expect(find.byType(PromotionSelector), findsOneWidget);
      final promotionSelector = find.byType(PromotionSelector);
      final piecesInSelector = find.descendant(
        of: promotionSelector,
        matching: find.byType(PieceWidget),
      );

      // has exactly 5 pieces (queen, knight, rook, bishop,king)
      expect(piecesInSelector, findsNWidgets(5));

      await tester.tapAt(squareOffset(tester, Square.f4, orientation: orientation));
      await tester.pump();

      expect(find.byKey(const Key('f8-whiteking')), findsOneWidget);
      expect(find.byKey(const Key('f7-whitepawn')), findsNothing);
    });

    testWidgets('player at bottom can promote to King on flipped board (orientation black)', (
      WidgetTester tester,
    ) async {
      const orientation = Side.black;
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialFen: 'K7/8/k7/8/8/8/p7/1Q4n1 b - - 0 1',
          orientation: orientation,
          canPromoteToKing: true,
        ),
      );
      await tester.tap(find.byKey(const Key('a2-blackpawn')));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.b1, orientation: orientation));
      await tester.pump();

      expect(find.byType(PromotionSelector), findsOneWidget);
      final promotionSelector = find.byType(PromotionSelector);
      final piecesInSelector = find.descendant(
        of: promotionSelector,
        matching: find.byType(PieceWidget),
      );

      // has exactly 5 pieces (queen, knight, rook, bishop, king)
      expect(piecesInSelector, findsNWidgets(5));

      await tester.tapAt(squareOffset(tester, Square.b5, orientation: orientation));
      await tester.pump();

      expect(find.byKey(const Key('b1-blackking')), findsOneWidget);
      expect(find.byKey(const Key('a2-blackpawn')), findsNothing);
    });

    testWidgets('cancels promotion', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
        ),
      );

      await tester.tap(find.byKey(const Key('f7-whitepawn')));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.f8));
      await tester.pump();

      // wait for promotion selector to show
      await tester.pump();
      expect(find.byType(PromotionSelector), findsOneWidget);

      // tap outside the promotion dialog
      await tester.tapAt(squareOffset(tester, Square.c4));

      await tester.pump();

      // promotion dialog is closed, move is cancelled
      expect(find.byType(PromotionSelector), findsNothing);
      expect(find.byKey(const Key('f7-whitepawn')), findsOneWidget);
    });

    testWidgets('promotion, auto queen enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          settings: ChessboardSettings(autoQueenPromotion: true),
          initialPlayerSide: PlayerSide.both,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
        ),
      );

      await tester.tap(find.byKey(const Key('f7-whitepawn')));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.f8));
      await tester.pump();
      expect(find.byKey(const Key('f8-whitequeen')), findsOneWidget);
      expect(find.byKey(const Key('f7-whitepawn')), findsNothing);
    });
  });

  group('premoves', () {
    testWidgets('select and deselect with empty square', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f1));
      await tester.pump();
      expect(_isSelected(tester, Square.f1), isTrue);
      expect(_moveDestCount(tester) + _premoveDestCount(tester), 7);

      await tester.tapAt(squareOffset(tester, Square.b4));
      await tester.pump();
      expect(_isSelected(tester, Square.f1), isFalse);
      expect(_moveDestCount(tester) + _premoveDestCount(tester), 0);
    });

    testWidgets('select and deselect with opponent piece', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f1));
      await tester.pump();
      expect(_isSelected(tester, Square.f1), isTrue);
      expect(_moveDestCount(tester) + _premoveDestCount(tester), 7);

      await tester.tapAt(squareOffset(tester, Square.f8));
      await tester.pump();
      expect(_isSelected(tester, Square.f1), isFalse);
      expect(_moveDestCount(tester) + _premoveDestCount(tester), 0);
    });

    testWidgets('select and deselect with same piece', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f1));
      await tester.pump();
      expect(_isSelected(tester, Square.f1), isTrue);
      expect(_moveDestCount(tester) + _premoveDestCount(tester), 7);

      await tester.tapAt(squareOffset(tester, Square.f1));
      await tester.pump();
      expect(_isSelected(tester, Square.f1), isFalse);
      expect(_moveDestCount(tester) + _premoveDestCount(tester), 0);
    });

    testWidgets('dragging an unselected piece to the same square should keep the piece selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestApp(
          initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      final f1 = squareOffset(tester, Square.f1);
      await tester.dragFrom(f1, const Offset(0, -(squareSize / 3)));
      await tester.pumpAndSettle();

      expect(_isSelected(tester, Square.f1), isTrue);
      expect(_moveDestCount(tester) + _premoveDestCount(tester), 7);
    });

    testWidgets('dragging off target unselects', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f1));
      await tester.pump();
      expect(_isSelected(tester, Square.f1), isTrue);
      expect(_moveDestCount(tester) + _premoveDestCount(tester), 7);

      await tester.dragFrom(
        squareOffset(tester, Square.f1),
        squareOffset(tester, Square.f1) + const Offset(0, -squareSize * 3),
      );
      await tester.pumpAndSettle();

      expect(_isSelected(tester, Square.f1), isFalse);
      expect(_moveDestCount(tester) + _premoveDestCount(tester), 0);
    });

    testWidgets('dragging off board unselects', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f1));
      await tester.pump();
      expect(_isSelected(tester, Square.f1), isTrue);
      expect(_moveDestCount(tester) + _premoveDestCount(tester), 7);

      await tester.dragFrom(
        squareOffset(tester, Square.f1),
        squareOffset(tester, Square.f1) + const Offset(0, -boardSize + squareSize),
      );
      await tester.pumpAndSettle();

      expect(_isSelected(tester, Square.f1), isFalse);
      expect(_moveDestCount(tester) + _premoveDestCount(tester), 0);
    });

    testWidgets('set/unset by tapping empty square or opponent piece', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      // set premove
      await makeMove(tester, Square.e4, Square.f5);
      expect(_isPremove(tester, Square.e4), isTrue);
      expect(_isPremove(tester, Square.f5), isTrue);

      // unset by tapping empty square
      await tester.tapAt(squareOffset(tester, Square.c5));
      await tester.pump();
      expect(_isPremove(tester, Square.e4), isFalse);
      expect(_isPremove(tester, Square.f5), isFalse);

      // unset by tapping opponent's piece
      await makeMove(tester, Square.d1, Square.f3);
      expect(_isPremove(tester, Square.d1), isTrue);
      expect(_isPremove(tester, Square.f3), isTrue);
      await tester.tapAt(squareOffset(tester, Square.g8));
      await tester.pump();
      expect(_isPremove(tester, Square.d1), isFalse);
      expect(_isPremove(tester, Square.f3), isFalse);
    });

    testWidgets('unset by dragging off board', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      // set premove
      await makeMove(tester, Square.e4, Square.f5);
      expect(_isPremove(tester, Square.e4), isTrue);
      expect(_isPremove(tester, Square.f5), isTrue);

      // unset by dragging off board
      await tester.dragFrom(
        squareOffset(tester, Square.e4),
        squareOffset(tester, Square.e4) + const Offset(0, -boardSize + squareSize),
      );
      await tester.pump();
      expect(_isPremove(tester, Square.e4), isFalse);
      expect(_isPremove(tester, Square.f5), isFalse);
    });

    testWidgets('unset by dragging to an empty square', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      // set premove
      await makeMove(tester, Square.e4, Square.f5);
      expect(_isPremove(tester, Square.e4), isTrue);
      expect(_isPremove(tester, Square.f5), isTrue);

      // unset by dragging to an empty square
      await tester.dragFrom(
        squareOffset(tester, Square.e4),
        squareOffset(tester, Square.e4) + const Offset(0, -squareSize),
      );
      await tester.pump();
      expect(_isPremove(tester, Square.e4), isFalse);
      expect(_isPremove(tester, Square.f5), isFalse);
    });

    testWidgets('unset by tapping same origin square again', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      // set premove
      await makeMove(tester, Square.e4, Square.f5);
      expect(_isPremove(tester, Square.e4), isTrue);
      expect(_isPremove(tester, Square.f5), isTrue);

      // unset by tapping same origin square again
      await tester.tapAt(squareOffset(tester, Square.e4));
      await tester.pump();
      expect(_isPremove(tester, Square.e4), isFalse);
      expect(_isPremove(tester, Square.f5), isFalse);
    });

    testWidgets('set and change by tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await makeMove(tester, Square.d1, Square.f3);
      expect(_isPremove(tester, Square.d1), isTrue);
      expect(_isPremove(tester, Square.f3), isTrue);
      await tester.tapAt(squareOffset(tester, Square.d2));
      await tester.pump();
      // premove is still set
      expect(_isPremove(tester, Square.d1), isTrue);
      expect(_isPremove(tester, Square.f3), isTrue);
      expect(_moveDestCount(tester) + _premoveDestCount(tester), 4);
      await tester.tapAt(squareOffset(tester, Square.d4));
      await tester.pump();
      // premove is changed
      expect(_isPremove(tester, Square.d1), isFalse);
      expect(_isPremove(tester, Square.f3), isFalse);
      expect(_isPremove(tester, Square.d2), isTrue);
      expect(_isPremove(tester, Square.d4), isTrue);
    });

    testWidgets('set and change by drag', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await makeMove(tester, Square.d1, Square.f3);
      expect(_isPremove(tester, Square.d1), isTrue);
      expect(_isPremove(tester, Square.f3), isTrue);
      await tester.dragFrom(squareOffset(tester, Square.d2), const Offset(0, -squareSize * 2));
      await tester.pump();
      // premove is changed
      expect(_isPremove(tester, Square.d1), isFalse);
      expect(_isPremove(tester, Square.f3), isFalse);
      expect(_isPremove(tester, Square.d2), isTrue);
      expect(_isPremove(tester, Square.d4), isTrue);
    });

    testWidgets('drag to set', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.dragFrom(squareOffset(tester, Square.e4), const Offset(0, -squareSize));
      await tester.pumpAndSettle();
      expect(_isPremove(tester, Square.e4), isTrue);
      expect(_isPremove(tester, Square.e5), isTrue);
      expect(_isSelected(tester, Square.e4), isFalse);
    });

    testWidgets('select another piece from same side does not unset', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialFen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await makeMove(tester, Square.d1, Square.c2);
      expect(_isPremove(tester, Square.d1), isTrue);
      expect(_isPremove(tester, Square.c2), isTrue);

      await tester.tapAt(squareOffset(tester, Square.e1));
      await tester.pump();
      expect(_isPremove(tester, Square.d1), isTrue);
      expect(_isPremove(tester, Square.c2), isTrue);
    });

    testWidgets('play premove', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          settings: ChessboardSettings(animationDuration: Duration.zero),
          initialPlayerSide: PlayerSide.white,
          shouldPlayOpponentMove: true,
        ),
      );

      await makeMove(tester, Square.e2, Square.e4);

      await makeMove(tester, Square.d1, Square.f3);
      expect(_isPremove(tester, Square.d1), isTrue);
      expect(_isPremove(tester, Square.f3), isTrue);

      // wait for opponent move to be played
      await tester.pump(const Duration(milliseconds: 200));

      // opponent move is played
      expect(find.byKey(const Key('a5-blackpawn')), findsOneWidget);

      // wait for the premove to be played
      await tester.pump();

      expect(_isPremove(tester, Square.d1), isFalse);
      expect(_isPremove(tester, Square.f3), isFalse);

      // premove has been played
      expect(find.byKey(const Key('d1-whitequeen')), findsNothing);
      expect(find.byKey(const Key('f3-whitequeen')), findsOneWidget);
    });

    testWidgets('play drop premove', (WidgetTester tester) async {
      final pos = Crazyhouse.initial.copyWith(
        pockets: Pockets.empty.increment(Side.white, Role.rook),
      );
      await tester.pumpWidget(
        _TestApp(
          rule: Rule.crazyhouse,
          initialFen: pos.fen,
          settings: const ChessboardSettings(animationDuration: Duration.zero),
          droppable: (validDropSquares: pos.legalDrops.squares.toISet()),
          initialPlayerSide: PlayerSide.white,
          shouldPlayOpponentMove: true,
          bottomWidget: Draggable(
            key: const Key('whiteRook'),
            data: Piece.whiteRook,
            feedback: const SizedBox.shrink(),
            child: PieceWidget(
              piece: Piece.whiteRook,
              size: squareSize,
              pieceAssets: PieceSet.merida.assets,
            ),
          ),
        ),
      );

      await makeMove(tester, Square.e2, Square.e4);

      final whiteRookDraggable = find.byKey(const Key('whiteRook'));
      await tester.drag(
        whiteRookDraggable,
        tester.getCenter(find.byKey(const Key('f3-drag-target'))) -
            tester.getCenter(whiteRookDraggable),
      );
      await tester.pump(); // Wait for piece to drop and board to redraw
      expect(_isPremove(tester, Square.f3), isTrue);

      // wait for opponent move to be played
      await tester.pump(const Duration(milliseconds: 200));

      // opponent move is played
      expect(find.byKey(const Key('a5-blackpawn')), findsOneWidget);

      // wait for the premove to be played
      await tester.pump();

      expect(_isPremove(tester, Square.f3), isFalse);

      // premove has been played
      expect(find.byKey(const Key('f3-whiterook')), findsOneWidget);
    });

    testWidgets('play a premove with promotion', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          settings: ChessboardSettings(animationDuration: Duration.zero),
          initialPlayerSide: PlayerSide.white,
          initialFen: '8/5P2/2RK2P1/8/4k3/8/8/8 w - - 0 1',
          shouldPlayOpponentMove: true,
        ),
      );

      await makeMove(tester, Square.g6, Square.g7);
      await makeMove(tester, Square.g7, Square.g8);
      expect(_isPremove(tester, Square.g7), isTrue);
      expect(_isPremove(tester, Square.g8), isTrue);

      // wait for opponent move to be played
      await tester.pump(const Duration(milliseconds: 200));

      // opponent move is played
      expect(find.byKey(const Key('d3-blackking')), findsOneWidget);

      // pawn was promoted to queen
      expect(_isPremove(tester, Square.g7), isFalse);
      expect(_isPremove(tester, Square.g8), isFalse);
      expect(find.byKey(const Key('g7-whitepawn')), findsNothing);
      expect(find.byKey(const Key('g8-whitequeen')), findsOneWidget);
    });

    testWidgets('play a premove with promotion, autoqueen disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          settings: ChessboardSettings(
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
      expect(_isPremove(tester, Square.g7), isTrue);
      expect(_isPremove(tester, Square.g8), isTrue);

      // wait for opponent move to be played
      await tester.pump(const Duration(milliseconds: 200));

      // promotion dialog is shown
      expect(find.byType(PromotionSelector), findsOneWidget);

      // premove highlight are not shown anymore
      expect(_isPremove(tester, Square.g7), isFalse);
      expect(_isPremove(tester, Square.g8), isFalse);

      // promotion pawn is not visible
      expect(find.byKey(const Key('g7-whitepawn')), findsNothing);

      // select knight
      await tester.tapAt(squareOffset(tester, Square.g7));
      await tester.pump();

      expect(find.byKey(const Key('g8-whiteknight')), findsOneWidget);
      expect(find.byKey(const Key('g7-whitepawn')), findsNothing);

      // wait for other opponent move to be played
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('cancel a premove promotion', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          settings: ChessboardSettings(
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
      expect(_isPremove(tester, Square.g7), isTrue);
      expect(_isPremove(tester, Square.g8), isTrue);

      // wait for opponent move to be played
      await tester.pump(const Duration(milliseconds: 200));

      // promotion dialog is shown
      expect(find.byType(PromotionSelector), findsOneWidget);

      // premove highlight are not shown anymore
      expect(_isPremove(tester, Square.g7), isFalse);
      expect(_isPremove(tester, Square.g8), isFalse);

      // cancel promotion dialog
      await tester.tapAt(squareOffset(tester, Square.c3));
      await tester.pump();

      // promotion dialog is closed
      expect(find.byType(PromotionSelector), findsNothing);

      expect(find.byKey(const Key('g7-whitepawn')), findsOneWidget);
    });
  });

  group('Drawing shapes', () {
    testWidgets('preconfigure board to draw a circle', (WidgetTester tester) async {
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialShapes: ISet({const Circle(orig: Square.e4, color: Color(0xFF0000FF))}),
        ),
      );

      expect(find.byType(BoardShapeWidget), paints..path(color: const Color(0xFF0000FF)));
    });

    testWidgets('preconfigure board to draw an arrow', (WidgetTester tester) async {
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialShapes: ISet({
            const Arrow(orig: Square.e2, dest: Square.e4, color: Color(0xFF0000FF)),
          }),
        ),
      );

      expect(
        find.byType(BoardShapeWidget),
        paints
          ..line(color: const Color(0xFF0000FF))
          ..path(color: const Color(0xFF0000FF)),
      );
    });

    testWidgets('preconfigure board to draw a piece shape', (WidgetTester tester) async {
      await tester.pumpWidget(
        _TestApp(
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

      expect(find.byType(BoardShapeWidget), findsOneWidget);

      final shapeSize = tester.getSize(find.byType(BoardShapeWidget));
      expect(shapeSize.width, squareSize);
      expect(shapeSize.height, squareSize);
    });

    testWidgets('cannot draw if not enabled', (WidgetTester tester) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));

      await TestAsyncUtils.guard<void>(() async {
        // keep pressing an empty square to enable drawing shapes
        final pressGesture = await tester.startGesture(squareOffset(tester, Square.a3));

        // drawing a circle with another tap
        final tapGesture = await tester.startGesture(squareOffset(tester, Square.e4));
        await tapGesture.up();

        await pressGesture.up();
      });

      expect(find.byType(BoardShapeWidget), findsNothing);
    });

    testWidgets('draw a circle by hand', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(initialPlayerSide: PlayerSide.both, enableDrawingShapes: true),
      );

      await TestAsyncUtils.guard<void>(() async {
        // keep pressing an empty square to enable drawing shapes
        final pressGesture = await tester.startGesture(squareOffset(tester, Square.a3));

        // drawing a circle with another tap
        final tapGesture = await tester.startGesture(squareOffset(tester, Square.e4));
        await tapGesture.up();

        await pressGesture.up();
      });

      // wait for the double tap delay to expire
      await tester.pump(const Duration(milliseconds: 210));

      expect(find.byType(BoardShapeWidget), paints..path(color: const Color(0xFF0000FF)));
    });

    testWidgets('draw an arrow by hand', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(initialPlayerSide: PlayerSide.both, enableDrawingShapes: true),
      );

      // keep pressing an empty square to enable drawing shapes
      final pressGesture = await tester.startGesture(squareOffset(tester, Square.a3));

      await tester.dragFrom(squareOffset(tester, Square.e2), const Offset(0, -(squareSize * 2)));

      await pressGesture.up();

      // wait for the double tap delay to expire
      await tester.pump(const Duration(milliseconds: 210));

      expect(
        find.byType(BoardShapeWidget),
        paints
          ..line(color: const Color(0xFF0000FF))
          ..path(color: const Color(0xFF0000FF)),
      );
    });

    testWidgets('can draw shapes on an non-interactive board', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(initialPlayerSide: PlayerSide.none, enableDrawingShapes: true),
      );

      // keep pressing an empty square to enable drawing shapes
      final pressGesture = await tester.startGesture(squareOffset(tester, Square.a3));

      await tester.dragFrom(squareOffset(tester, Square.e2), const Offset(0, -(squareSize * 2)));

      await pressGesture.up();

      // wait for the double tap delay to expire
      await tester.pump(const Duration(milliseconds: 210));

      expect(
        find.byType(BoardShapeWidget),
        paints
          ..line(color: const Color(0xFF0000FF))
          ..path(color: const Color(0xFF0000FF)),
      );
    });

    testWidgets('double tap to clear shapes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(initialPlayerSide: PlayerSide.both, enableDrawingShapes: true),
      );

      await TestAsyncUtils.guard<void>(() async {
        // keep pressing an empty square to enable drawing shapes
        final pressGesture = await tester.startGesture(squareOffset(tester, Square.a3));

        // drawing a circle with another tap
        final tapGesture = await tester.startGesture(squareOffset(tester, Square.e4));
        await tapGesture.up();

        await pressGesture.up();
      });

      // wait for the double tap delay to expire
      await tester.pump(const Duration(milliseconds: 210));

      // keep pressing an empty square to enable drawing shapes
      final pressGesture = await tester.startGesture(squareOffset(tester, Square.a3));

      await tester.dragFrom(squareOffset(tester, Square.e2), const Offset(0, -(squareSize * 2)));

      await pressGesture.up();

      // wait for the double tap delay to expire
      await tester.pump(const Duration(milliseconds: 210));

      expect(find.byType(BoardShapeWidget), findsNWidgets(2));

      await tester.tapAt(squareOffset(tester, Square.a3));
      await tester.tapAt(squareOffset(tester, Square.a3));
      await tester.pump();

      expect(find.byType(BoardShapeWidget), findsNothing);
    });

    testWidgets('selecting one piece should clear shapes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(initialPlayerSide: PlayerSide.both, enableDrawingShapes: true),
      );

      await TestAsyncUtils.guard<void>(() async {
        // keep pressing an empty square to enable drawing shapes
        final pressGesture = await tester.startGesture(squareOffset(tester, Square.a3));

        // drawing a circle with another tap
        final tapGesture = await tester.startGesture(squareOffset(tester, Square.e4));
        await tapGesture.up();

        await pressGesture.up();
      });

      // wait for the double tap delay to expire
      await tester.pump(const Duration(milliseconds: 210));

      expect(find.byType(BoardShapeWidget), findsOneWidget);

      await tester.tapAt(squareOffset(tester, Square.e2));
      await tester.pump();

      expect(find.byType(BoardShapeWidget), findsNothing);
    });
  });

  group('piece orientation behavior', () {
    void checkUpsideDownPieces(
      WidgetTester tester, {
      required bool expectWhiteUpsideDown,
      required bool expectBlackUpsideDown,
    }) {
      final pieceWidgets = tester.widgetList<PieceWidget>(find.byType(PieceWidget));
      expect(pieceWidgets, hasLength(32));
      for (final pieceWidget in pieceWidgets) {
        if (pieceWidget.piece.color == Side.white) {
          expect(pieceWidget.upsideDown, expectWhiteUpsideDown, reason: 'white is upside down');
        } else {
          expect(pieceWidget.upsideDown, expectBlackUpsideDown, reason: 'black is upside down');
        }
      }
    }

    testWidgets('facing user', (WidgetTester tester) async {
      for (final orientation in Side.values) {
        await tester.pumpWidget(
          _TestApp(
            key: ValueKey(orientation),
            settings: const ChessboardSettings(animationDuration: Duration.zero),
            initialPlayerSide: PlayerSide.both,
            orientation: orientation,
          ),
        );

        checkUpsideDownPieces(tester, expectWhiteUpsideDown: false, expectBlackUpsideDown: false);

        await makeMove(tester, Square.e2, Square.e4);

        checkUpsideDownPieces(tester, expectWhiteUpsideDown: false, expectBlackUpsideDown: false);
      }
    });

    testWidgets('opponent upside down', (WidgetTester tester) async {
      for (final orientation in Side.values) {
        await tester.pumpWidget(
          _TestApp(
            key: ValueKey(orientation),
            initialPlayerSide: PlayerSide.both,
            orientation: orientation,
            settings: const ChessboardSettings(
              animationDuration: Duration.zero,
              pieceOrientationBehavior: PieceOrientationBehavior.opponentUpsideDown,
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
          _TestApp(
            key: ValueKey(orientation),
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

  group('Atomic explosion animations', () {
    Chessboard fixedBoard({ISet<Square>? explosionSquares}) => Chessboard.fixed(
      size: boardSize,
      orientation: Side.white,
      fen: kInitialFEN,
      explosionSquares: explosionSquares,
    );

    testWidgets('no explosion on initial render even when explosionSquares is set', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(fixedBoard(explosionSquares: ISet(const {Square.e4})));

      expect(find.byType(ExplosionWidget), findsNothing);
    });

    testWidgets('explosion widget appears when explosionSquares changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(fixedBoard());
      await tester.pumpWidget(fixedBoard(explosionSquares: ISet(const {Square.e4})));

      expect(find.byType(ExplosionWidget), findsOneWidget);
    });

    testWidgets('one explosion widget per square in the set', (WidgetTester tester) async {
      await tester.pumpWidget(fixedBoard());
      await tester.pumpWidget(
        fixedBoard(explosionSquares: ISet(const {Square.e4, Square.d5, Square.f6})),
      );

      expect(find.byType(ExplosionWidget), findsNWidgets(3));
    });

    testWidgets('explosion widgets are removed after animation completes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(fixedBoard());
      await tester.pumpWidget(fixedBoard(explosionSquares: ISet(const {Square.e4})));

      expect(find.byType(ExplosionWidget), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(ExplosionWidget), findsNothing);
    });

    testWidgets('same ISet value does not re-trigger explosions', (WidgetTester tester) async {
      final squares = ISet(const {Square.e4});

      await tester.pumpWidget(fixedBoard());
      await tester.pumpWidget(fixedBoard(explosionSquares: squares));
      expect(find.byType(ExplosionWidget), findsOneWidget);

      // Advance past animation end so the widget removes itself.
      await tester.pumpAndSettle();
      expect(find.byType(ExplosionWidget), findsNothing);

      // Providing the same ISet instance again should not re-trigger.
      await tester.pumpWidget(fixedBoard(explosionSquares: squares));
      expect(find.byType(ExplosionWidget), findsNothing);
    });

    testWidgets('new explosion set adds to currently animating explosions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(fixedBoard());

      // Trigger first explosion on e4.
      await tester.pumpWidget(fixedBoard(explosionSquares: ISet(const {Square.e4})));
      expect(find.byType(ExplosionWidget), findsOneWidget);

      // Advance partway through the animation (less than 600 ms default duration).
      await tester.pump(const Duration(milliseconds: 200));

      // Trigger a second explosion on d5 while the first is still running.
      await tester.pumpWidget(fixedBoard(explosionSquares: ISet(const {Square.d5})));

      expect(find.byType(ExplosionWidget), findsNWidgets(2));

      // After settling, all explosions should be gone.
      await tester.pumpAndSettle();
      expect(find.byType(ExplosionWidget), findsNothing);
    });
  });

  group('board piece rendering', () {
    testWidgets('all pieces use PieceWidget when cache is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Chessboard.fixed(size: boardSize, orientation: Side.white, fen: kInitialFEN),
      );

      expect(find.byType(PieceWidget), findsNWidgets(32));
    });

    testWidgets('no fallback PieceWidget when all images are cached', (WidgetTester tester) async {
      final pieceAssets = const ChessboardSettings().pieceAssets;
      for (final asset in pieceAssets.values.toSet()) {
        ChessgroundImages.instance.add(asset, await _createFakeImage(45, 45));
      }
      addTearDown(() {
        for (final asset in pieceAssets.values.toSet()) {
          ChessgroundImages.instance.evict(asset);
        }
      });

      await tester.pumpWidget(
        const Chessboard.fixed(size: boardSize, orientation: Side.white, fen: kInitialFEN),
      );

      // All pieces drawn by PiecesPainter — no fallback widgets in the tree.
      expect(find.byType(PieceWidget), findsNothing);
    });

    testWidgets('only uncached pieces use PieceWidget', (WidgetTester tester) async {
      // Cache only the white pawn kind; covers all 8 white pawns.
      final asset = const ChessboardSettings().pieceAssets[Piece.whitePawn.kind]!;
      ChessgroundImages.instance.add(asset, await _createFakeImage(45, 45));
      addTearDown(() => ChessgroundImages.instance.evict(asset));

      await tester.pumpWidget(
        const Chessboard.fixed(size: boardSize, orientation: Side.white, fen: kInitialFEN),
      );

      // 32 total pieces − 8 white pawns drawn by PiecesPainter = 24 PieceWidgets.
      expect(find.byType(PieceWidget), findsNWidgets(24));
    });
  });

  group('drag avatar rendering', () {
    // The fallback PieceWidget used when an image is not cached is created with
    // feedbackSize = squareSize * dragFeedbackScale (default 2.0), which makes it
    // distinguishable from the board PieceWidgets that all use squareSize.
    const feedbackSize = squareSize * 2.0; // dragFeedbackScale default

    Iterable<PieceWidget> dragFeedbackPieceWidgets(WidgetTester tester) => tester
        .widgetList<PieceWidget>(find.byType(PieceWidget))
        .where((w) => w.size == feedbackSize);

    testWidgets(
      'uses CustomPaint fast path when dragged piece image is in ChessgroundImages cache',
      (WidgetTester tester) async {
        final asset = const ChessboardSettings().pieceAssets[Piece.whitePawn.kind]!;
        final fakeImage = await _createFakeImage(45, 45);
        ChessgroundImages.instance.add(asset, fakeImage);
        addTearDown(() => ChessgroundImages.instance.evict(asset));

        await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));

        // All 8 white pawns are now drawn by PiecesPainter, not PieceWidget.
        expect(tester.widgetList<PieceWidget>(find.byType(PieceWidget)).length, 24);

        await TestAsyncUtils.guard<void>(() async {
          final gesture = await tester.startGesture(squareOffset(tester, Square.e2));
          await tester.pump();
          // Exceed the _kDragDistanceThreshold of 3.0 px to start a drag.
          await gesture.moveBy(const Offset(0, -4));
          await tester.pump();

          // Fast path: piece drawn by _DragPiecePainter on canvas — no fallback PieceWidget.
          expect(dragFeedbackPieceWidgets(tester), isEmpty);

          await gesture.up();
        });
        await tester.pump();
      },
    );

    testWidgets(
      'uses PieceWidget fallback when dragged piece image is not in ChessgroundImages cache',
      (WidgetTester tester) async {
        // ChessgroundImages cache is empty by default in tests.
        await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));

        expect(find.byType(PieceWidget), findsNWidgets(32));

        await TestAsyncUtils.guard<void>(() async {
          final gesture = await tester.startGesture(squareOffset(tester, Square.e2));
          await tester.pump();
          await gesture.moveBy(const Offset(0, -4));
          await tester.pump();

          // Fallback path: one PieceWidget with feedbackSize in the overlay.
          expect(dragFeedbackPieceWidgets(tester), hasLength(1));

          await gesture.up();
        });
        await tester.pump();
      },
    );
  });
}

Future<void> makeMove(WidgetTester tester, Square from, Square to) async {
  final orientation = tester.widget<Chessboard>(find.byType(Chessboard)).orientation;
  await tester.tapAt(squareOffset(tester, from, orientation: orientation));
  await tester.pump();
  await tester.tapAt(squareOffset(tester, to, orientation: orientation));
  await tester.pump();
}

enum GameEvent {
  /// Simulates an event that would make the board non interactive
  nonInteractiveBoardEvent,

  /// Simulates an event that would make the board interactive again
  interactiveBoardEvent,

  /// Simulates an external move (e.g. opponent move from server)
  externalMove,
}

class _TestApp extends StatefulWidget {
  const _TestApp({
    required this.initialPlayerSide,
    this.initialFen = kInitialFEN,
    this.rule = Rule.chess,
    this.orientation = Side.white,
    this.settings,
    this.droppable,
    this.initialPromotionMove,
    this.initialShapes,
    this.enableDrawingShapes = false,
    this.shouldPlayOpponentMove = false,
    this.gameEventStream,
    this.onTouchedSquare,
    this.bottomWidget,
    this.canPromoteToKing = false,
    super.key,
  });

  final PlayerSide initialPlayerSide;
  final String initialFen;
  final Rule rule;
  final ChessboardSettings? settings;
  final Side orientation;
  final Droppable? droppable;

  final NormalMove? initialPromotionMove;
  final ISet<Shape>? initialShapes;
  final bool enableDrawingShapes;

  /// play the first available move for the opponent after a delay of 200ms
  final bool shouldPlayOpponentMove;

  /// A stream of game events
  final Stream<GameEvent>? gameEventStream;

  final void Function(Square)? onTouchedSquare;

  final Widget? bottomWidget;

  final bool canPromoteToKing;

  @override
  State<_TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<_TestApp> {
  late PlayerSide interactiveSide;
  late NormalMove? promotionMove;
  late ISet<Shape> shapes;
  late Position position;
  Move? lastMove;
  Move? premoveData;

  StreamSubscription<GameEvent>? _gameEventSub;

  ChessboardSettings get defaultSettings => ChessboardSettings(
    drawShape: DrawShapeOptions(
      enable: widget.enableDrawingShapes,
      onCompleteShape: (shape) {
        setState(() => shapes = shapes.add(shape));
      },
      onClearShapes: () {
        setState(() => shapes = ISet());
      },
      newShapeColor: const Color(0xFF0000FF),
    ),
  );

  @override
  void initState() {
    super.initState();
    interactiveSide = widget.initialPlayerSide;
    position = Position.setupPosition(widget.rule, Setup.parseFen(widget.initialFen));
    promotionMove = widget.initialPromotionMove;
    shapes = widget.initialShapes ?? ISet();

    _gameEventSub = widget.gameEventStream?.listen(_onGameEvent);
  }

  @override
  void dispose() {
    super.dispose();
    _gameEventSub?.cancel();
  }

  void _onGameEvent(GameEvent event) {
    switch (event) {
      case GameEvent.nonInteractiveBoardEvent:
        setState(() {
          interactiveSide = PlayerSide.none;
        });
      case GameEvent.interactiveBoardEvent:
        setState(() {
          interactiveSide = widget.initialPlayerSide;
        });
      case GameEvent.externalMove:
        setState(() {
          final allMoves = [
            for (final entry in position.legalMoves.entries)
              for (final dest in entry.value.squares) NormalMove(from: entry.key, to: dest),
          ];
          if (allMoves.isNotEmpty) {
            position = position.playUnchecked(allMoves.first);
            lastMove = allMoves.first;
          }
        });
    }
  }

  void _playMove(Move move) {
    position = position.playUnchecked(move);
    if (position.isGameOver) {
      interactiveSide = PlayerSide.none;
    }
    lastMove = move;
  }

  bool isPromotionPawnMove(Move move) {
    return move is NormalMove &&
        move.promotion == null &&
        position.board.roleAt(move.from) == Role.pawn &&
        ((move.to.rank == Rank.first && position.turn == Side.black) ||
            (move.to.rank == Rank.eighth && position.turn == Side.white));
  }

  void _onMove(Move move, {bool? viaDragAndDrop}) {
    setState(() {
      if (move is NormalMove && isPromotionPawnMove(move)) {
        promotionMove = move;
      } else {
        _playMove(move);
      }
    });

    if (widget.shouldPlayOpponentMove) {
      Timer(const Duration(milliseconds: 200), () {
        final allMoves = [
          for (final entry in position.legalMoves.entries)
            for (final dest in entry.value.squares) NormalMove(from: entry.key, to: dest),
        ];
        final opponentMove = allMoves.first;
        setState(() {
          position = position.playUnchecked(opponentMove);
          if (position.isGameOver) {
            interactiveSide = PlayerSide.none;
          }
          lastMove = opponentMove;
        });

        // play premove just after the opponent move
        if (premoveData != null) {
          if (position.isLegal(premoveData!)) {
            if (!isPromotionPawnMove(premoveData!)) {
              scheduleMicrotask(() {
                setState(() {
                  position = position.playUnchecked(premoveData!);
                  premoveData = null;
                });
              });
            } else {
              scheduleMicrotask(() {
                setState(() {
                  promotionMove = premoveData as NormalMove?;
                  premoveData = null;
                });
              });
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: Column(
          children: [
            Chessboard(
              size: boardSize,
              settings: widget.settings ?? defaultSettings,
              orientation: widget.orientation,
              fen: position.fen,
              lastMove: lastMove,
              game: GameData(
                playerSide: interactiveSide,
                isCheck: position.isCheck,
                sideToMove: position.turn == Side.white ? Side.white : Side.black,
                validMoves: makeLegalMoves(position),
                promotionMove: promotionMove,
                droppable: widget.droppable,
                onMove: _onMove,
                onPromotionSelection: (Role? role) {
                  setState(() {
                    if (role != null) {
                      _playMove(promotionMove!.withPromotion(role));
                    }
                    promotionMove = null;
                  });
                },
                premovable: (
                  premove: premoveData,
                  onSetPremove: (Move? move) {
                    setState(() {
                      premoveData = move;
                    });
                  },
                ),
                canPromoteToKing: widget.canPromoteToKing,
              ),
              onTouchedSquare: widget.onTouchedSquare,
              shapes: shapes,
            ),
            if (widget.bottomWidget != null) widget.bottomWidget!,
          ],
        ),
      ),
    );
  }
}

Offset squareOffset(WidgetTester tester, Square id, {Side orientation = Side.white}) {
  final rect = tester.getRect(find.byKey(const ValueKey('board-container')));
  final sq = rect.width / 8;
  final x = orientation == Side.black ? 7 - id.file : id.file;
  final y = orientation == Side.black ? id.rank : 7 - id.rank;
  final o = Offset(rect.left + x * sq, rect.top + y * sq);
  return Offset(o.dx + sq / 2, o.dy + sq / 2);
}

/// Creates a minimal in-memory [ui.Image] for tests that need a cached piece image.
Future<ui.Image> _createFakeImage(int width, int height) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawPaint(Paint()..color = const Color(0xFF0000FF));
  return recorder.endRecording().toImage(width, height);
}
