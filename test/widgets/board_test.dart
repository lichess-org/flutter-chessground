import 'dart:async';
import 'dart:ui' as ui;
import 'package:chessground/src/widgets/explosion.dart';
import 'package:chessground/src/widgets/promotion.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartchess/dartchess.dart';
import 'package:chessground/chessground.dart';
import 'package:mocktail/mocktail.dart';

const boardSize = 200.0;
const squareSize = boardSize / 8;

/// Builds a controller for a non-interactive board (PlayerSide.none).
ChessboardController nonInteractiveController(String fen) {
  return ChessboardController(
    game: GameData(
      fen: fen,
      playerSide: PlayerSide.none,
      sideToMove: Setup.parseFen(fen).turn,
      validMoves: const <Square, Set<Square>>{},
    ),
  );
}

PiecesPainter _piecesPainter(WidgetTester tester) {
  for (final element in find.byType(CustomPaint).evaluate()) {
    final widget = element.widget as CustomPaint;
    if (widget.painter is PiecesPainter) {
      return widget.painter! as PiecesPainter;
    }
  }
  throw StateError('PiecesPainter not found');
}

HighlightsPainter _highlightsPainter(WidgetTester tester) {
  for (final element in find.byType(CustomPaint).evaluate()) {
    final widget = element.widget as CustomPaint;
    if (widget.painter is HighlightsPainter) {
      return widget.painter! as HighlightsPainter;
    }
  }
  throw StateError('HighlightsPainter not found');
}

ExplosionsPainter _explosionsPainter(WidgetTester tester) {
  for (final element in find.byType(CustomPaint).evaluate()) {
    final widget = element.widget as CustomPaint;
    if (widget.painter is ExplosionsPainter) {
      return widget.painter! as ExplosionsPainter;
    }
  }
  throw StateError('ExplosionsPainter not found');
}

TranslatingPiecesPainter? _translatingPiecesPainter(WidgetTester tester) {
  for (final element in find.byType(CustomPaint).evaluate()) {
    final widget = element.widget as CustomPaint;
    if (widget.painter is TranslatingPiecesPainter) {
      return widget.painter! as TranslatingPiecesPainter;
    }
  }
  return null;
}

FadingPiecesPainter? _fadingPiecesPainter(WidgetTester tester) {
  for (final element in find.byType(CustomPaint).evaluate()) {
    final widget = element.widget as CustomPaint;
    if (widget.painter is FadingPiecesPainter) {
      return widget.painter! as FadingPiecesPainter;
    }
  }
  return null;
}

bool _isSelectedHighlight(WidgetTester tester, Square square) {
  return _highlightsPainter(tester).interactionNotifier.selected == square;
}

bool _isLastMoveHighlight(WidgetTester tester, Square square) {
  final p = _highlightsPainter(tester);
  return p.showLastMove &&
      p.interactionNotifier.lastMove != null &&
      p.interactionNotifier.lastMove!.hasSquare(square) &&
      (p.interactionNotifier.premove == null || !p.interactionNotifier.premove!.hasSquare(square));
}

bool _isPremoveHighlight(WidgetTester tester, Square square) {
  final p = _highlightsPainter(tester);
  return p.interactionNotifier.premove != null && p.interactionNotifier.premove!.hasSquare(square);
}

bool _isCheckSquareHighlight(WidgetTester tester, Square square) {
  return _highlightsPainter(tester).interactionNotifier.checkSquare == square;
}

int _moveDestHighlightCount(WidgetTester tester) {
  return _highlightsPainter(tester).interactionNotifier.moveDests.length;
}

int _premoveDestHighlightCount(WidgetTester tester) {
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

    final viewOnlyBoard = StaticChessboard(
      size: boardSize,
      orientation: Side.white,
      fen: kInitialFEN,
      onTouchedSquare: onTouchedSquare.call,
    );

    testWidgets('initial position display', (WidgetTester tester) async {
      await tester.pumpWidget(viewOnlyBoard);

      expect(find.byType(StaticChessboard), findsOneWidget);
      expect(_piecesPainter(tester).pieces.length, 32);
    });

    testWidgets('cannot select piece', (WidgetTester tester) async {
      await tester.pumpWidget(viewOnlyBoard);
      await tester.tapAt(squareOffset(tester, Square.e2));
      await tester.pump();

      expect(_isSelectedHighlight(tester, Square.e2), isFalse);

      verify(() => onTouchedSquare.call(Square.e2)).called(1);
      verifyNoMoreInteractions(onTouchedSquare);
    });

    testWidgets('moved piece is animated when the position change', (WidgetTester tester) async {
      const board = StaticChessboard(size: boardSize, orientation: Side.white, fen: kInitialFEN);

      await tester.pumpWidget(board);

      expect(_translatingPiecesPainter(tester)!.translatingPieces, isEmpty);
      expect(_piecesPainter(tester).pieces.length, 32);

      const board2 = StaticChessboard(
        size: boardSize,
        orientation: Side.white,
        fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
      );

      await tester.pumpWidget(board2);

      expect(_piecesPainter(tester).pieces.length, 32);
      final painter = _translatingPiecesPainter(tester);
      expect(painter, isNotNull);
      expect(painter!.translatingPieces.length, 1);
      expect(painter.translatingPieces[Square.e4]?.from, Square.e2);
      expect(painter.translatingPieces[Square.e4]?.piece, Piece.whitePawn);
      expect(painter.orientation, Side.white);

      await tester.pumpAndSettle();

      // After animation the pieces map is correct (pawn is at e4, not e2).
      expect(_piecesPainter(tester).pieces.containsKey(Square.e2), isFalse);
      expect(_piecesPainter(tester).pieces[Square.e4], Piece.whitePawn);
    });

    testWidgets('several pieces can be animated when the position change', (
      WidgetTester tester,
    ) async {
      const board = StaticChessboard(
        size: boardSize,
        orientation: Side.white,
        fen: 'rnbqk2r/pppp1ppp/5n2/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4',
      );

      await tester.pumpWidget(board);

      expect(_translatingPiecesPainter(tester)!.translatingPieces, isEmpty);
      expect(_piecesPainter(tester).pieces.length, 32);

      const board2 = StaticChessboard(
        size: boardSize,
        orientation: Side.white,
        fen: 'rnbqk2r/pppp1ppp/5n2/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQ1RK1 b kq - 5 4',
      );

      await tester.pumpWidget(board2);

      expect(_piecesPainter(tester).pieces.length, 32);
      expect(_translatingPiecesPainter(tester)!.translatingPieces.length, 2);

      await tester.pumpAndSettle();
    });

    testWidgets('a piece moved by drag and drop is not animated', (WidgetTester tester) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));

      await tester.dragFrom(squareOffset(tester, Square.e2), const Offset(0, -(squareSize * 2)));
      await tester.pump();

      // The dropped pawn is already at its destination, so it must not be
      // re-animated translating from e2 to e4.
      expect(_translatingPiecesPainter(tester)!.translatingPieces, isEmpty);

      await tester.pumpAndSettle();
      expect(_piecesPainter(tester).pieces[Square.e4], Piece.whitePawn);
      expect(_piecesPainter(tester).pieces.containsKey(Square.e2), isFalse);
    });

    testWidgets('a piece moved by tap is animated', (WidgetTester tester) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));

      await tester.tapAt(squareOffset(tester, Square.e2));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.e4));
      await tester.pump();

      // A tap move keeps the piece on its origin until the position changes, so
      // the pawn animates translating from e2 to e4.
      final painter = _translatingPiecesPainter(tester);
      expect(painter!.translatingPieces[Square.e4]?.from, Square.e2);
      expect(painter.translatingPieces[Square.e4]?.piece, Piece.whitePawn);

      await tester.pumpAndSettle();
    });

    testWidgets('background is constrained to the size of the board', (WidgetTester tester) async {
      await tester.pumpWidget(viewOnlyBoard);

      final size = tester.getSize(find.byType(SolidColorChessboardBackground));
      expect(size.width, boardSize);
      expect(size.height, boardSize);
    });

    testWidgets('displays a border', (WidgetTester tester) async {
      const board = StaticChessboard(
        size: boardSize,
        orientation: Side.white,
        fen: kInitialFEN,
        settings: StaticChessboardSettings(
          border: BoardBorder(width: 16.0, color: Color(0xFF000000)),
        ),
      );

      await tester.pumpWidget(board);

      final size = tester.getSize(find.byType(SolidColorChessboardBackground));
      expect(size.width, boardSize - 32.0);
      expect(size.height, boardSize - 32.0);
    });

    testWidgets('change in hue will use a color filter', (WidgetTester tester) async {
      const board = StaticChessboard(
        size: boardSize,
        orientation: Side.white,
        fen: kInitialFEN,
        settings: StaticChessboardSettings(hue: 100.0),
      );

      await tester.pumpWidget(board);

      expect(find.byType(ColorFiltered), findsOneWidget);
    });

    testWidgets('change in brightness will use a color filter', (WidgetTester tester) async {
      const board = StaticChessboard(
        size: boardSize,
        orientation: Side.white,
        fen: kInitialFEN,
        settings: StaticChessboardSettings(brightness: 0.9),
      );

      await tester.pumpWidget(board);

      expect(find.byType(ColorFiltered), findsOneWidget);
    });
  });

  group('Interactive board', () {
    testWidgets('initial lastMove and checkSquare are highlighted on first paint', (
      WidgetTester tester,
    ) async {
      // Scholar's mate: Qxf7# — queen moved from h5 to f7, black king on e8 is in check.
      const fen = 'r1bqkb1r/pppp1Qpp/2n2n2/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4';
      const lastMove = NormalMove(from: Square.h5, to: Square.f7);

      final controller = ChessboardController(
        game: const GameData(
          fen: fen,
          playerSide: PlayerSide.white,
          sideToMove: Side.black,
          validMoves: {},
          lastMove: lastMove,
          kingSquareInCheck: Square.e8,
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: Chessboard(controller: controller, size: boardSize, orientation: Side.white),
          ),
        ),
      );

      // No interaction required — highlights must be correct from the very first paint.
      expect(_isLastMoveHighlight(tester, Square.h5), isTrue);
      expect(_isLastMoveHighlight(tester, Square.f7), isTrue);
      expect(_isCheckSquareHighlight(tester, Square.e8), isTrue);
    });

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
        await tester.tapAt(squareOffset(tester, Square.a2));
        await tester.pump();

        expect(_isSelectedHighlight(tester, Square.a2), isTrue);
        expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 2);

        // selecting same deselects
        await tester.tapAt(squareOffset(tester, Square.a2));
        await tester.pump();
        expect(_isSelectedHighlight(tester, Square.a2), isFalse);
        expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 0);

        // selecting another square
        await tester.tapAt(squareOffset(tester, Square.a1));
        await tester.pump();
        expect(_isSelectedHighlight(tester, Square.a1), isTrue);
        expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 0);

        // selecting an opposite piece deselects
        await tester.tapAt(squareOffset(tester, Square.e7));
        await tester.pump();
        expect(_isSelectedHighlight(tester, Square.a1), isFalse);
        expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 0);

        // selecting an empty square deselects
        await tester.tapAt(squareOffset(tester, Square.a1));
        await tester.pump();
        expect(_isSelectedHighlight(tester, Square.a1), isTrue);
        await tester.tapAt(squareOffset(tester, Square.c4));
        await tester.pump();
        expect(_isSelectedHighlight(tester, Square.a1), isFalse);

        // cannot select a piece whose side is not the turn to move
        await tester.tapAt(squareOffset(tester, Square.e7));
        await tester.pump();
        expect(_isSelectedHighlight(tester, Square.e7), isFalse);

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
        await tester.tapAt(squareOffset(tester, Square.e2));
        await tester.pump();

        expect(_isSelectedHighlight(tester, Square.e2), isTrue);
        expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 2);

        await tester.tapAt(squareOffset(tester, Square.e4));
        await tester.pump();

        expect(_piecesPainter(tester).pieces[Square.e4], Piece.whitePawn);
        expect(_isSelectedHighlight(tester, Square.e2), isFalse);
        expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 0);

        // wait for the animations to finish
        await tester.pumpAndSettle();

        expect(_piecesPainter(tester).pieces[Square.e4], Piece.whitePawn);
        expect(_piecesPainter(tester).pieces.containsKey(Square.e2), isFalse);
        expect(_isLastMoveHighlight(tester, Square.e2), isTrue);
        expect(_isLastMoveHighlight(tester, Square.e4), isTrue);
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
        await tester.tapAt(squareOffset(tester, Square.e2));
        await tester.pump();

        // Tapping a square should have no effect...
        expect(_isSelectedHighlight(tester, Square.e2), isFalse);
        expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 0);

        // ... but move by drag should work
        await tester.dragFrom(squareOffset(tester, Square.e2), const Offset(0, -(squareSize * 2)));
        await tester.pumpAndSettle();
        expect(_piecesPainter(tester).pieces[Square.e4], Piece.whitePawn);
        expect(_piecesPainter(tester).pieces.containsKey(Square.e2), isFalse);
        expect(_isLastMoveHighlight(tester, Square.e2), isTrue);
        expect(_isLastMoveHighlight(tester, Square.e4), isTrue);

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
      await tester.tapAt(squareOffset(tester, Square.e2));
      await tester.pump();

      // simluate a drag that leaves the piece on the same square
      await tester.dragFrom(squareOffset(tester, Square.e2), const Offset(0, -(squareSize / 2)));
      await tester.pumpAndSettle();
      expect(_isSelectedHighlight(tester, Square.e2), isFalse);
    });

    testWidgets('castling by selecting king then rook is possible', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          fen: 'r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4',
          initialPlayerSide: PlayerSide.both,
        ),
      );
      await tester.tapAt(squareOffset(tester, Square.e1));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.h1));
      await tester.pump();

      // wait for the animations to finish
      await tester.pumpAndSettle();

      expect(_piecesPainter(tester).pieces.containsKey(Square.e1), isFalse);
      expect(_piecesPainter(tester).pieces.containsKey(Square.h1), isFalse);
      expect(_piecesPainter(tester).pieces[Square.g1], Piece.whiteKing);
      expect(_piecesPainter(tester).pieces[Square.f1], Piece.whiteRook);
      expect(_isLastMoveHighlight(tester, Square.e1), isTrue);
      expect(_isLastMoveHighlight(tester, Square.h1), isTrue);
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
        expect(_piecesPainter(tester).pieces[Square.e2], Piece.whitePawn);
        expect(_isSelectedHighlight(tester, Square.e2), isFalse);
        expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 0);
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
        expect(_piecesPainter(tester).pieces[Square.e2], Piece.whitePawn);
        expect(_isSelectedHighlight(tester, Square.e2), isFalse);
        expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 0);
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
        expect(_piecesPainter(tester).pieces[Square.e4], Piece.whitePawn);
        expect(_piecesPainter(tester).pieces.containsKey(Square.e2), isFalse);
        expect(_isLastMoveHighlight(tester, Square.e2), isTrue);
        expect(_isLastMoveHighlight(tester, Square.e4), isTrue);
      }
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
      expect(_piecesPainter(tester).pieces.containsKey(Square.e4), isFalse);
      expect(_piecesPainter(tester).pieces[Square.e2], Piece.whitePawn);
      expect(_isLastMoveHighlight(tester, Square.e2), isFalse);
      expect(_isLastMoveHighlight(tester, Square.e4), isFalse);

      // Original square is still selected after drag attempt
      expect(_isSelectedHighlight(tester, Square.e2), isTrue);
      expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 2);

      // ...so we can still tap to move
      await tester.tapAt(squareOffset(tester, Square.e4));
      await tester.pump();
      expect(_isSelectedHighlight(tester, Square.e2), isFalse);
      expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 0);
      expect(_piecesPainter(tester).pieces[Square.e4], Piece.whitePawn);
      expect(_piecesPainter(tester).pieces.containsKey(Square.e2), isFalse);
      expect(_isLastMoveHighlight(tester, Square.e2), isTrue);
      expect(_isLastMoveHighlight(tester, Square.e4), isTrue);
    });

    testWidgets('2 simultaneous pointer down events will cancel current drag/selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));
      await TestAsyncUtils.guard<void>(() async {
        await tester.startGesture(squareOffset(tester, Square.e2));

        await tester.pump();

        expect(_isSelectedHighlight(tester, Square.e2), isTrue);

        await tester.startGesture(squareOffset(tester, Square.e4));

        await tester.pump();

        // move is cancelled
        expect(_piecesPainter(tester).pieces.containsKey(Square.e4), isFalse);
        expect(_piecesPainter(tester).pieces[Square.e2], Piece.whitePawn);
        // selection is cancelled
        expect(_isSelectedHighlight(tester, Square.e2), isFalse);
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

        expect(_isSelectedHighlight(tester, Square.e2), isTrue);

        await tester.tapAt(squareOffset(tester, Square.d2));

        // finish the move as to release the piece
        await dragGesture.moveTo(squareOffset(tester, Square.e4));
        await dragGesture.up();
      });

      await tester.pump();

      // the piece should not have moved
      expect(_piecesPainter(tester).pieces.containsKey(Square.e4), isFalse);
      expect(_piecesPainter(tester).pieces[Square.e2], Piece.whitePawn);
      // the piece should not be selected
      expect(_isSelectedHighlight(tester, Square.e2), isFalse);

      // drag a piece and tap on an empty square while dragging
      await TestAsyncUtils.guard<void>(() async {
        final dragGesture = await tester.startGesture(squareOffset(tester, Square.d2));
        await tester.pump();

        // trigger a piece drag by moving the pointer by 4 pixels
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));
        await dragGesture.moveTo(const Offset(0, -1));

        expect(_isSelectedHighlight(tester, Square.d2), isTrue);

        // tap on an empty square
        await tester.tapAt(squareOffset(tester, Square.f5));

        // finish the move as to release the piece
        await dragGesture.moveTo(squareOffset(tester, Square.d4));
        await dragGesture.up();
      });

      await tester.pump();

      // the piece should not have moved
      expect(_piecesPainter(tester).pieces.containsKey(Square.d4), isFalse);
      expect(_piecesPainter(tester).pieces[Square.d2], Piece.whitePawn);
      // the piece should not be selected
      expect(_isSelectedHighlight(tester, Square.d2), isFalse);
    });

    testWidgets('dragging an unselected piece to the same square should keep the piece selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));
      final e2 = squareOffset(tester, Square.e2);
      await tester.dragFrom(e2, const Offset(0, -(squareSize / 3)));
      await tester.pumpAndSettle();

      expect(_piecesPainter(tester).pieces[Square.e2], Piece.whitePawn);
      expect(_isSelectedHighlight(tester, Square.e2), isTrue);
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

      expectSync(_piecesPainter(tester).pieces[Square.e2], Piece.whitePawn);
      expectSync(_isSelectedHighlight(tester, Square.e2), isTrue);

      await dragFuture;
      await tester.pumpAndSettle();

      expectSync(_isSelectedHighlight(tester, Square.e2), isFalse);
    });

    testWidgets('king check square black', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          fen: 'rnbqkbnr/ppp2ppp/3p4/4p3/3PP3/8/PPP2PPP/RNBQKBNR w KQkq - 0 3',
          initialPlayerSide: PlayerSide.white,
        ),
      );
      await makeMove(tester, Square.f1, Square.b5);
      expect(_isCheckSquareHighlight(tester, Square.e8), isTrue);
    });

    testWidgets('king check square white', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          fen: 'rnbqkbnr/pppp1ppp/8/4p3/3P4/4P3/PPP2PPP/RNBQKBNR b KQkq - 0 2',
          initialPlayerSide: PlayerSide.black,
        ),
      );
      await makeMove(tester, Square.f8, Square.b4);
      expect(_isCheckSquareHighlight(tester, Square.e1), isTrue);
    });

    testWidgets('piece is still selected when fen changes externally', (WidgetTester tester) async {
      final controller = StreamController<GameEvent>.broadcast();

      addTearDown(() {
        controller.close();
      });

      await tester.pumpWidget(
        _TestApp(
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
          gameEventStream: controller.stream,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.d2));
      await tester.pump();
      expect(_isSelectedHighlight(tester, Square.d2), isTrue);
      // 4 premoves destinations are highlighted
      expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 4);

      controller.add(GameEvent.externalMove);
      await tester.pump(const Duration(milliseconds: 1));

      // Selection should not be cleared
      expect(_isSelectedHighlight(tester, Square.d2), isTrue);
      // now 2 moves destinations are highlighted instead of 4
      expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 2);
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
          fen: kInitialBoardFEN,
          initialPlayerSide: PlayerSide.white,
          gameEventStream: controller.stream,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.e2));
      await tester.pump();
      expect(_isSelectedHighlight(tester, Square.e2), isTrue);

      controller.add(GameEvent.nonInteractiveBoardEvent);
      await tester.pump(const Duration(milliseconds: 1));

      expect(_isSelectedHighlight(tester, Square.e2), isFalse);
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
          fen: 'r1bqkbnr/ppp2ppp/2np4/4p3/2B1P3/5Q2/PPPP1PPP/RNB1K1NR w KQkq - 0 4',
          initialPlayerSide: PlayerSide.white,
          gameEventStream: controller.stream,
        ),
      );

      await TestAsyncUtils.guard<void>(() async {
        await tester.startGesture(squareOffset(tester, Square.f3));
        await tester.pump();
        expect(_isSelectedHighlight(tester, Square.f3), isTrue);
      });

      // make board non interactive in the middle of the gesture
      controller.add(GameEvent.nonInteractiveBoardEvent);
      await tester.pump(const Duration(milliseconds: 1));

      expect(_isSelectedHighlight(tester, Square.f3), isFalse);

      // board is not interactive
      await tester.tapAt(squareOffset(tester, Square.f3));
      await tester.pump();
      expect(_isSelectedHighlight(tester, Square.f3), isFalse);

      // make board interactive again
      controller.add(GameEvent.interactiveBoardEvent);
      await tester.pump(const Duration(milliseconds: 1));

      // the piece selection should work (which would not be the case if the
      // pointer event was not cancelled)
      await tester.tapAt(squareOffset(tester, Square.f3));
      await tester.pump();
      expect(_isSelectedHighlight(tester, Square.f3), isTrue);
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

  group('Drop squares enabled', () {
    testWidgets('dragging a piece onto the board triggers DropMove', (WidgetTester tester) async {
      final pos = Position.setupPosition(
        Rule.crazyhouse,
        Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR[Pn] w KQkq - 0 1'),
      );
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.both,
          rule: Rule.crazyhouse,
          fen: pos.fen,
          settings: const ChessboardSettings(enableDrops: true),
          validDropSquares: pos.legalDrops.squares.toSet(),
          bottomWidget: Column(
            children: [
              Draggable(
                key: const Key('whitePawn'),
                dragAnchorStrategy: pointerDragAnchorStrategy,
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
                dragAnchorStrategy: pointerDragAnchorStrategy,
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
        squareOffset(tester, Square.e4) - tester.getCenter(whitePawnDraggable),
      );

      await tester.pumpAndSettle();
      expect(_piecesPainter(tester).pieces[Square.e4], Piece.whitePawn);
      // Just to make sure we didn't play a normal move
      expect(_piecesPainter(tester).pieces[Square.e2], Piece.whitePawn);

      final blackKnightDraggable = find.byKey(const Key('blackKnight'));
      await tester.drag(
        blackKnightDraggable,
        squareOffset(tester, Square.e5) - tester.getCenter(blackKnightDraggable),
      );

      await tester.pumpAndSettle();
      expect(_piecesPainter(tester).pieces[Square.e4], Piece.whitePawn);
      expect(_piecesPainter(tester).pieces[Square.e5], Piece.blackKnight);
    });

    testWidgets('Cannot move pawns onto the back rank', (WidgetTester tester) async {
      final pos = Position.setupPosition(
        Rule.crazyhouse,
        Setup.parseFen('8/8/3K4/8/3k4/8/8/8[PNp] w - - 0 1'),
      );
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.both,
          fen: pos.fen,
          rule: Rule.crazyhouse,
          settings: const ChessboardSettings(enableDrops: true),
          validDropSquares: pos.legalDrops.squares.toSet(),
          bottomWidget: Column(
            children: [
              Draggable(
                key: const Key('whitePawn'),
                dragAnchorStrategy: pointerDragAnchorStrategy,
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
                dragAnchorStrategy: pointerDragAnchorStrategy,
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
        squareOffset(tester, Square.a1) - tester.getCenter(whitePawnDraggable),
      );
      await tester.drag(
        whitePawnDraggable,
        squareOffset(tester, Square.a8) - tester.getCenter(whitePawnDraggable),
      );

      await tester.pumpAndSettle();
      expect(_piecesPainter(tester).pieces.containsKey(Square.a8), isFalse);
      expect(_piecesPainter(tester).pieces.containsKey(Square.a1), isFalse);

      // Dragging other pieces onto the back rank should work though
      final whiteKnightDraggable = find.byKey(const Key('whiteKnight'));
      await tester.drag(
        whiteKnightDraggable,
        squareOffset(tester, Square.a8) - tester.getCenter(whiteKnightDraggable),
      );

      await tester.pumpAndSettle();
      expect(_piecesPainter(tester).pieces[Square.a8], Piece.whiteKnight);
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
          fen: pos.fen,
          rule: Rule.crazyhouse,
          settings: const ChessboardSettings(enableDrops: true),
          validDropSquares: pos.legalDrops.squares.toSet(),
          bottomWidget: Column(
            children: [
              Draggable(
                key: const Key('whitePawn'),
                dragAnchorStrategy: pointerDragAnchorStrategy,
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
        squareOffset(tester, Square.a4) - tester.getCenter(whitePawnDraggable),
      );

      await tester.pumpAndSettle();
      expect(_piecesPainter(tester).pieces.containsKey(Square.a4), isFalse);

      // Only square that blocks the check
      await tester.drag(
        whitePawnDraggable,
        squareOffset(tester, Square.d2) - tester.getCenter(whitePawnDraggable),
      );

      await tester.pumpAndSettle();
      expect(_piecesPainter(tester).pieces[Square.d2], Piece.whitePawn);
    });

    testWidgets('no drag targets if drop moves not explicitly enabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));

      expect(find.byType(DragTarget<Piece>), findsNothing);
    });

    testWidgets(
      'drop hover circle renders without crashing when dragging a pocket piece over a square',
      (WidgetTester tester) async {
        final pos = Position.setupPosition(
          Rule.crazyhouse,
          Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR[Pn] w KQkq - 0 1'),
        );
        await tester.pumpWidget(
          _TestApp(
            initialPlayerSide: PlayerSide.both,
            rule: Rule.crazyhouse,
            fen: pos.fen,
            settings: const ChessboardSettings(enableDrops: true),
            validDropSquares: pos.legalDrops.squares.toSet(),
            bottomWidget: Draggable(
              key: const Key('whitePawn'),
              dragAnchorStrategy: pointerDragAnchorStrategy,
              data: Piece.whitePawn,
              feedback: const SizedBox.shrink(),
              child: PieceWidget(
                piece: Piece.whitePawn,
                size: squareSize,
                pieceAssets: PieceSet.merida.assets,
              ),
            ),
          ),
        );

        final gesture = await tester.startGesture(
          tester.getCenter(find.byKey(const Key('whitePawn'))),
        );
        // Moving over e4 triggers DragTarget.onMove, which sets the hover notifier.
        await gesture.moveTo(squareOffset(tester, Square.e4));
        // Rebuilding here is the path that previously crashed: PositionedSquare
        // emits a Positioned widget which requires a Stack ancestor, but
        // DragTarget.builder wraps its output in MetaData, not Stack.
        await tester.pump();

        expect(
          find.descendant(of: find.byType(DragTarget<Piece>), matching: find.byType(Container)),
          findsOneWidget,
        );

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets('drop hover circle updates as pocket piece is dragged across squares', (
      WidgetTester tester,
    ) async {
      final pos = Position.setupPosition(
        Rule.crazyhouse,
        Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR[Pn] w KQkq - 0 1'),
      );
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.both,
          rule: Rule.crazyhouse,
          fen: pos.fen,
          settings: const ChessboardSettings(enableDrops: true),
          validDropSquares: pos.legalDrops.squares.toSet(),
          bottomWidget: Draggable(
            key: const Key('whitePawn'),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            data: Piece.whitePawn,
            feedback: const SizedBox.shrink(),
            child: PieceWidget(
              piece: Piece.whitePawn,
              size: squareSize,
              pieceAssets: PieceSet.merida.assets,
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('whitePawn'))),
      );
      await gesture.moveTo(squareOffset(tester, Square.e4));
      await tester.pump();
      expect(
        find.descendant(of: find.byType(DragTarget<Piece>), matching: find.byType(Container)),
        findsOneWidget,
      );

      await gesture.moveTo(squareOffset(tester, Square.d4));
      await tester.pump();
      expect(
        find.descendant(of: find.byType(DragTarget<Piece>), matching: find.byType(Container)),
        findsOneWidget,
      );

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('drop hover circle disappears after pocket piece is dropped', (
      WidgetTester tester,
    ) async {
      final pos = Position.setupPosition(
        Rule.crazyhouse,
        Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR[Pn] w KQkq - 0 1'),
      );
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.both,
          rule: Rule.crazyhouse,
          fen: pos.fen,
          settings: const ChessboardSettings(enableDrops: true),
          validDropSquares: pos.legalDrops.squares.toSet(),
          bottomWidget: Draggable(
            key: const Key('whitePawn'),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            data: Piece.whitePawn,
            feedback: const SizedBox.shrink(),
            child: PieceWidget(
              piece: Piece.whitePawn,
              size: squareSize,
              pieceAssets: PieceSet.merida.assets,
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('whitePawn'))),
      );
      await gesture.moveTo(squareOffset(tester, Square.e4));
      await tester.pump();
      expect(
        find.descendant(of: find.byType(DragTarget<Piece>), matching: find.byType(Container)),
        findsOneWidget,
      );

      await gesture.up();
      await tester.pumpAndSettle();
      // Circle is gone after the drop.
      expect(
        find.descendant(of: find.byType(DragTarget<Piece>), matching: find.byType(Container)),
        findsNothing,
      );
      expect(_piecesPainter(tester).pieces[Square.e4], Piece.whitePawn);
    });

    testWidgets('pocket piece draggable uses pointer drag anchor strategy', (tester) async {
      final pos = Position.setupPosition(
        Rule.crazyhouse,
        Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR[Pn] w KQkq - 0 1'),
      );
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.both,
          rule: Rule.crazyhouse,
          fen: pos.fen,
          settings: const ChessboardSettings(enableDrops: true),
          validDropSquares: pos.legalDrops.squares.toSet(),
          bottomWidget: Draggable<Piece>(
            key: const Key('pocketPiece'),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            data: Piece.whitePawn,
            feedback: PieceDragFeedback(
              squareSize: squareSize,
              piece: Piece.whitePawn,
              pieceAssets: PieceSet.merida.assets,
            ),
            child: PieceWidget(
              piece: Piece.whitePawn,
              size: squareSize,
              pieceAssets: PieceSet.merida.assets,
            ),
          ),
        ),
      );

      final draggable = tester.widget<Draggable<Piece>>(find.byKey(const Key('pocketPiece')));
      expect(draggable.dragAnchorStrategy, pointerDragAnchorStrategy);
    });

    testWidgets(
      'pocket piece drag feedback layout position matches pointer regardless of where piece is touched',
      (tester) async {
        final pos = Position.setupPosition(
          Rule.crazyhouse,
          Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR[Pn] w KQkq - 0 1'),
        );
        await tester.pumpWidget(
          _TestApp(
            initialPlayerSide: PlayerSide.both,
            rule: Rule.crazyhouse,
            fen: pos.fen,
            settings: const ChessboardSettings(enableDrops: true),
            validDropSquares: pos.legalDrops.squares.toSet(),
            bottomWidget: Draggable<Piece>(
              key: const Key('pocketPiece'),
              dragAnchorStrategy: pointerDragAnchorStrategy,
              data: Piece.whitePawn,
              feedback: PieceDragFeedback(
                squareSize: squareSize,
                piece: Piece.whitePawn,
                pieceAssets: PieceSet.merida.assets,
              ),
              child: PieceWidget(
                piece: Piece.whitePawn,
                size: squareSize,
                pieceAssets: PieceSet.merida.assets,
              ),
            ),
          ),
        );

        final pieceTopLeft = tester.getTopLeft(find.byKey(const Key('pocketPiece')));
        // Use mouse pointer: its hit slop is 1px, so any small move triggers the
        // drag (touch slop is 18px and would require a larger moveBy).
        const move = Offset(0.0, -10.0);

        // Drag from near the top-left corner of the pocket piece.
        final gesture1 = await tester.startGesture(
          pieceTopLeft + const Offset(2.0, 2.0),
          kind: PointerDeviceKind.mouse,
        );
        await gesture1.moveBy(move);
        await tester.pump();

        // With pointerDragAnchorStrategy the overlay Positioned is placed exactly
        // at the pointer, so getTopLeft == current pointer position.
        expect(
          tester.getTopLeft(find.byType(PieceDragFeedback)),
          pieceTopLeft + const Offset(2.0, -8.0),
        );

        await gesture1.cancel();
        await tester.pumpAndSettle();

        // Drag from near the bottom-right corner of the same piece.
        final gesture2 = await tester.startGesture(
          pieceTopLeft + const Offset(squareSize - 2.0, squareSize - 2.0),
          kind: PointerDeviceKind.mouse,
        );
        await gesture2.moveBy(move);
        await tester.pump();

        // Pointer is now at a different absolute position, but the invariant
        // holds: feedback top-left == current pointer position.
        expect(
          tester.getTopLeft(find.byType(PieceDragFeedback)),
          pieceTopLeft + const Offset(squareSize - 2.0, squareSize - 12.0),
        );

        await gesture2.cancel();
        await tester.pumpAndSettle();
      },
    );

    testWidgets("sets drop premove when dragging own pocket piece on opponent's turn", (
      WidgetTester tester,
    ) async {
      final pos = Position.setupPosition(
        Rule.crazyhouse,
        Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR[R] b KQkq - 0 1'),
      );
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.white,
          rule: Rule.crazyhouse,
          fen: pos.fen,
          settings: const ChessboardSettings(enableDrops: true),
          validDropSquares: pos.legalDrops.squares.toSet(),
          bottomWidget: Draggable(
            key: const Key('whiteRook'),
            dragAnchorStrategy: pointerDragAnchorStrategy,
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

      final whiteRookDraggable = find.byKey(const Key('whiteRook'));
      await tester.drag(
        whiteRookDraggable,
        squareOffset(tester, Square.f3) - tester.getCenter(whiteRookDraggable),
      );
      await tester.pumpAndSettle();

      expect(_isPremoveHighlight(tester, Square.f3), isTrue);
    });

    testWidgets('does not set drop premove when enablePremoves is false', (
      WidgetTester tester,
    ) async {
      final pos = Position.setupPosition(
        Rule.crazyhouse,
        Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR[R] b KQkq - 0 1'),
      );
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.white,
          rule: Rule.crazyhouse,
          fen: pos.fen,
          settings: const ChessboardSettings(enableDrops: true, enablePremoves: false),
          validDropSquares: pos.legalDrops.squares.toSet(),
          bottomWidget: Draggable(
            key: const Key('whiteRook'),
            dragAnchorStrategy: pointerDragAnchorStrategy,
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

      final whiteRookDraggable = find.byKey(const Key('whiteRook'));
      await tester.drag(
        whiteRookDraggable,
        squareOffset(tester, Square.f3) - tester.getCenter(whiteRookDraggable),
      );
      await tester.pumpAndSettle();

      expect(_isPremoveHighlight(tester, Square.f3), isFalse);
    });

    testWidgets('does not execute drop premove that was set on own turn', (
      WidgetTester tester,
    ) async {
      // Dragging a pocket piece to a square not in validDropSquares while it is
      // already the player's own turn should NOT register a premove. Without a
      // sideToMove guard, a stale DropMove would sit in the controller and fire
      // automatically after the opponent responds.
      final pos = Position.setupPosition(
        Rule.crazyhouse,
        Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR[R] w KQkq - 0 1'),
      );
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.white,
          rule: Rule.crazyhouse,
          fen: pos.fen,
          settings: const ChessboardSettings(enableDrops: true, animationDuration: Duration.zero),
          // f3 is deliberately absent from validDropSquares
          validDropSquares: const {Square.a1},
          shouldPlayOpponentMove: true,
          bottomWidget: Draggable(
            key: const Key('whiteRook'),
            dragAnchorStrategy: pointerDragAnchorStrategy,
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

      // Drag pocket rook to f3 while it is white's own turn (f3 not in validDropSquares)
      final whiteRookDraggable = find.byKey(const Key('whiteRook'));
      await tester.drag(
        whiteRookDraggable,
        squareOffset(tester, Square.f3) - tester.getCenter(whiteRookDraggable),
      );
      await tester.pumpAndSettle();

      // White then makes a regular pawn move
      await makeMove(tester, Square.e2, Square.e4);

      // Wait for the opponent's auto-move and any premove execution
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(); // drain microtask for premove

      // Rook must NOT be at f3: no premove should have been set
      expect(_piecesPainter(tester).pieces.containsKey(Square.f3), isFalse);
    });

    testWidgets('does not set drop premove for pawn dragged to back rank', (
      WidgetTester tester,
    ) async {
      final pos = Position.setupPosition(
        Rule.crazyhouse,
        Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR[P] b KQkq - 0 1'),
      );
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.white,
          rule: Rule.crazyhouse,
          fen: pos.fen,
          settings: const ChessboardSettings(enableDrops: true),
          validDropSquares: pos.legalDrops.squares.toSet(),
          bottomWidget: Draggable(
            key: const Key('whitePawn'),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            data: Piece.whitePawn,
            feedback: const SizedBox.shrink(),
            child: PieceWidget(
              piece: Piece.whitePawn,
              size: squareSize,
              pieceAssets: PieceSet.merida.assets,
            ),
          ),
        ),
      );

      final whitePawnDraggable = find.byKey(const Key('whitePawn'));
      await tester.drag(
        whitePawnDraggable,
        squareOffset(tester, Square.a8) - tester.getCenter(whitePawnDraggable),
      );
      await tester.pumpAndSettle();

      expect(_isPremoveHighlight(tester, Square.a8), isFalse);
    });
  });

  group('Promotion', () {
    testWidgets('selector is shown when pendingPromotion is set on the controller', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          fen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
          initialPromotionMove: NormalMove(from: Square.f7, to: Square.f8),
        ),
      );

      expect(find.byType(PromotionSelector), findsOneWidget);
      // pawn at f7 is hidden by painter while selector is open
      expect(_piecesPainter(tester).promotionMoveFrom, Square.f7);
    });

    testWidgets('promote a knight', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          fen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f7));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.f8));
      await tester.pump();
      await tester.pump();
      expect(find.byType(PromotionSelector), findsOneWidget);

      // promotion pawn is hidden by painter (still in pieces map but skipped due to promotionMoveFrom)
      expect(_piecesPainter(tester).promotionMoveFrom, Square.f7);

      // tap on the knight
      await tester.tapAt(squareOffset(tester, Square.f7));
      await tester.pump();
      expect(_piecesPainter(tester).pieces[Square.f8], Piece.whiteKnight);
      expect(_piecesPainter(tester).pieces.containsKey(Square.f7), isFalse);
      // painter no longer hides the pawn after promotion completes
      expect(_piecesPainter(tester).promotionMoveFrom, isNull);
    });

    testWidgets('Player on top promotes a bishop', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(initialPlayerSide: PlayerSide.both, fen: 'K7/8/k7/8/8/8/p7/1Q4n1 b - - 0 1'),
      );

      await tester.tapAt(squareOffset(tester, Square.a2));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.b1));
      await tester.pump();
      await tester.pump();
      expect(find.byType(PromotionSelector), findsOneWidget);

      // promotion pawn is hidden by painter (still in pieces map but skipped due to promotionMoveFrom)
      expect(_piecesPainter(tester).promotionMoveFrom, Square.a2);

      // tap on the bishop
      await tester.tapAt(squareOffset(tester, Square.b4));
      await tester.pump();
      expect(_piecesPainter(tester).pieces[Square.b1], Piece.blackBishop);
      expect(_piecesPainter(tester).pieces.containsKey(Square.a2), isFalse);
      expect(_piecesPainter(tester).promotionMoveFrom, isNull);
    });

    testWidgets('onMove is called exactly once with the complete move after piece selection', (
      WidgetTester tester,
    ) async {
      final recorded = <(Move, bool?)>[];
      final position = Position.setupPosition(
        Rule.chess,
        Setup.parseFen('8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1'),
      );
      final controller = ChessboardController(
        game: GameData(
          fen: position.fen,
          playerSide: PlayerSide.both,
          sideToMove: Side.white,
          validMoves: makeLegalMoves(position),
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: Chessboard(
              controller: controller,
              size: boardSize,
              orientation: Side.white,
              onMove: (move, {viaDragAndDrop}) => recorded.add((move, viaDragAndDrop)),
            ),
          ),
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f7));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.f8));
      await tester.pump();
      await tester.pump();

      expect(find.byType(PromotionSelector), findsOneWidget);
      // no callback fired before the user picks a piece
      expect(recorded, isEmpty);

      // tap knight (second choice, rendered at f7 square for white top-rank promotion)
      await tester.tapAt(squareOffset(tester, Square.f7));
      await tester.pump();

      expect(recorded, hasLength(1));
      expect(
        recorded.first.$1,
        const NormalMove(from: Square.f7, to: Square.f8, promotion: Role.knight),
      );
      expect(recorded.first.$2, isFalse); // tap move, not drag
      expect(find.byType(PromotionSelector), findsNothing);
    });

    testWidgets('onMove is not called when promotion is cancelled', (WidgetTester tester) async {
      final recorded = <Move>[];
      final position = Position.setupPosition(
        Rule.chess,
        Setup.parseFen('8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1'),
      );
      final controller = ChessboardController(
        game: GameData(
          fen: position.fen,
          playerSide: PlayerSide.both,
          sideToMove: Side.white,
          validMoves: makeLegalMoves(position),
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: Chessboard(
              controller: controller,
              size: boardSize,
              orientation: Side.white,
              onMove: (move, {viaDragAndDrop}) => recorded.add(move),
            ),
          ),
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f7));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.f8));
      await tester.pump();
      await tester.pump();
      expect(find.byType(PromotionSelector), findsOneWidget);

      // tap outside the selector to cancel
      await tester.tapAt(squareOffset(tester, Square.c4));
      await tester.pump();

      expect(find.byType(PromotionSelector), findsNothing);
      expect(recorded, isEmpty);
      expect(_piecesPainter(tester).promotionMoveFrom, isNull);
    });

    testWidgets('promotion via drag calls onMove with viaDragAndDrop: true', (
      WidgetTester tester,
    ) async {
      final recorded = <(Move, bool?)>[];
      final position = Position.setupPosition(
        Rule.chess,
        Setup.parseFen('8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1'),
      );
      final controller = ChessboardController(
        game: GameData(
          fen: position.fen,
          playerSide: PlayerSide.both,
          sideToMove: Side.white,
          validMoves: makeLegalMoves(position),
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: Chessboard(
              controller: controller,
              size: boardSize,
              orientation: Side.white,
              onMove: (move, {viaDragAndDrop}) => recorded.add((move, viaDragAndDrop)),
            ),
          ),
        ),
      );

      // drag pawn from f7 to f8 (one square up)
      await tester.dragFrom(squareOffset(tester, Square.f7), const Offset(0, -squareSize));
      await tester.pump();
      expect(find.byType(PromotionSelector), findsOneWidget);
      expect(recorded, isEmpty);

      // tap queen (first choice, at f8 for white top-rank promotion)
      await tester.tapAt(squareOffset(tester, Square.f8));
      await tester.pump();

      expect(recorded, hasLength(1));
      expect(
        recorded.first.$1,
        const NormalMove(from: Square.f7, to: Square.f8, promotion: Role.queen),
      );
      expect(recorded.first.$2, isTrue); // drag-and-drop flag preserved
      expect(find.byType(PromotionSelector), findsNothing);
    });

    testWidgets('default promotion shows 4 pieces without king', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          fen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f7));
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
          fen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
          canPromoteToKing: true,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f7));
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
          fen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
          canPromoteToKing: true,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f7));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.f8));
      await tester.pump();

      // wait for promotion selector to show
      await tester.pump();
      expect(find.byType(PromotionSelector), findsOneWidget);

      // tap on the king is the last option in the promotion selector
      await tester.tapAt(squareOffset(tester, Square.f4));
      await tester.pump();

      expect(_piecesPainter(tester).pieces[Square.f8], Piece.whiteKing);
      expect(_piecesPainter(tester).pieces.containsKey(Square.f7), isFalse);
    });

    testWidgets('Player on top can promote to King', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          fen: 'K7/8/k7/8/8/8/p7/1Q4n1 b - - 0 1',
          canPromoteToKing: true,
        ),
      );
      await tester.tapAt(squareOffset(tester, Square.a2));
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

      expect(_piecesPainter(tester).pieces[Square.b1], Piece.blackKing);
      expect(_piecesPainter(tester).pieces.containsKey(Square.a2), isFalse);
    });

    testWidgets('promote a piece on flipped board (orientation black)', (
      WidgetTester tester,
    ) async {
      const orientation = Side.black;
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          fen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
          orientation: orientation,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f7, orientation: orientation));
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

      // promotion pawn is hidden by painter (still in pieces map but skipped due to promotionMoveFrom)
      expect(_piecesPainter(tester).promotionMoveFrom, Square.f7);

      await tester.tapAt(squareOffset(tester, Square.f7, orientation: orientation));
      await tester.pump();
      expect(_piecesPainter(tester).pieces[Square.f8], Piece.whiteKnight);
      expect(_piecesPainter(tester).pieces.containsKey(Square.f7), isFalse);
    });

    testWidgets('player at bottom promotes a bishop on flipped board (orientation black)', (
      WidgetTester tester,
    ) async {
      const orientation = Side.black;
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          fen: 'K7/8/k7/8/8/8/p7/1Q4n1 b - - 0 1',
          orientation: orientation,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.a2, orientation: orientation));
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

      // promotion pawn is hidden by painter (still in pieces map but skipped due to promotionMoveFrom)
      expect(_piecesPainter(tester).promotionMoveFrom, Square.a2);

      // selector opens downward from b1 (rank 1 at top); queen, knight, rook, bishop
      await tester.tapAt(squareOffset(tester, Square.b4, orientation: orientation));
      await tester.pump();
      expect(_piecesPainter(tester).pieces[Square.b1], Piece.blackBishop);
      expect(_piecesPainter(tester).pieces.containsKey(Square.a2), isFalse);
    });

    testWidgets('can promote to king on flipped board (orientation black)', (
      WidgetTester tester,
    ) async {
      const orientation = Side.black;
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          fen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
          orientation: orientation,
          canPromoteToKing: true,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f7, orientation: orientation));
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

      expect(_piecesPainter(tester).pieces[Square.f8], Piece.whiteKing);
      expect(_piecesPainter(tester).pieces.containsKey(Square.f7), isFalse);
    });

    testWidgets('player at bottom can promote to King on flipped board (orientation black)', (
      WidgetTester tester,
    ) async {
      const orientation = Side.black;
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          fen: 'K7/8/k7/8/8/8/p7/1Q4n1 b - - 0 1',
          orientation: orientation,
          canPromoteToKing: true,
        ),
      );
      await tester.tapAt(squareOffset(tester, Square.a2, orientation: orientation));
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

      expect(_piecesPainter(tester).pieces[Square.b1], Piece.blackKing);
      expect(_piecesPainter(tester).pieces.containsKey(Square.a2), isFalse);
    });

    testWidgets('cancels promotion', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          initialPlayerSide: PlayerSide.both,
          fen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f7));
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
      expect(_piecesPainter(tester).pieces[Square.f7], Piece.whitePawn);
    });

    testWidgets('promotion, auto queen enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          settings: ChessboardSettings(autoQueenPromotion: true),
          initialPlayerSide: PlayerSide.both,
          fen: '8/5P2/2RK2P1/8/4k3/8/8/7r w - - 0 1',
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f7));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.f8));
      await tester.pump();
      expect(_piecesPainter(tester).pieces[Square.f8], Piece.whiteQueen);
      expect(_piecesPainter(tester).pieces.containsKey(Square.f7), isFalse);
    });
    testWidgets('promotion works when enableDrops is true', (WidgetTester tester) async {
      final pos = Position.setupPosition(
        Rule.crazyhouse,
        Setup.parseFen('8/5P2/2RK2P1/8/4k3/8/8/7r[P] w - - 0 1'),
      );

      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.both,
          rule: Rule.crazyhouse,
          fen: pos.fen,
          settings: const ChessboardSettings(enableDrops: true),
          validDropSquares: pos.legalDrops.squares.toSet(),
        ),
      );

      // Drag pawn to promotion square
      await tester.dragFrom(squareOffset(tester, Square.f7), const Offset(0, -squareSize));
      await tester.pump();

      // promotion dialog should show
      expect(find.byType(PromotionSelector), findsOneWidget);

      // promote
      await tester.tapAt(squareOffset(tester, Square.f8));
      await tester.pump();

      // Check that the dialog disappeared
      expect(find.byType(PromotionSelector), findsNothing);

      // Queen is here, pawn is gone
      expect(
        _piecesPainter(tester).pieces[Square.f8],
        const Piece(color: Side.white, role: Role.queen, promoted: true),
      );
      expect(_piecesPainter(tester).pieces.containsKey(Square.f7), isFalse);
    });
  });

  group('premoves', () {
    testWidgets('select and deselect with empty square', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f1));
      await tester.pump();
      expect(_isSelectedHighlight(tester, Square.f1), isTrue);
      expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 7);

      await tester.tapAt(squareOffset(tester, Square.b4));
      await tester.pump();
      expect(_isSelectedHighlight(tester, Square.f1), isFalse);
      expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 0);
    });

    testWidgets('select and deselect with opponent piece', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f1));
      await tester.pump();
      expect(_isSelectedHighlight(tester, Square.f1), isTrue);
      expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 7);

      await tester.tapAt(squareOffset(tester, Square.f8));
      await tester.pump();
      expect(_isSelectedHighlight(tester, Square.f1), isFalse);
      expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 0);
    });

    testWidgets('select and deselect with same piece', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f1));
      await tester.pump();
      expect(_isSelectedHighlight(tester, Square.f1), isTrue);
      expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 7);

      await tester.tapAt(squareOffset(tester, Square.f1));
      await tester.pump();
      expect(_isSelectedHighlight(tester, Square.f1), isFalse);
      expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 0);
    });

    testWidgets('dragging an unselected piece to the same square should keep the piece selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const _TestApp(
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      final f1 = squareOffset(tester, Square.f1);
      await tester.dragFrom(f1, const Offset(0, -(squareSize / 3)));
      await tester.pumpAndSettle();

      expect(_isSelectedHighlight(tester, Square.f1), isTrue);
      expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 7);
    });

    testWidgets('dragging off target unselects', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f1));
      await tester.pump();
      expect(_isSelectedHighlight(tester, Square.f1), isTrue);
      expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 7);

      await tester.dragFrom(
        squareOffset(tester, Square.f1),
        squareOffset(tester, Square.f1) + const Offset(0, -squareSize * 3),
      );
      await tester.pumpAndSettle();

      expect(_isSelectedHighlight(tester, Square.f1), isFalse);
      expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 0);
    });

    testWidgets('dragging off board unselects', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.tapAt(squareOffset(tester, Square.f1));
      await tester.pump();
      expect(_isSelectedHighlight(tester, Square.f1), isTrue);
      expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 7);

      await tester.dragFrom(
        squareOffset(tester, Square.f1),
        squareOffset(tester, Square.f1) + const Offset(0, -boardSize + squareSize),
      );
      await tester.pumpAndSettle();

      expect(_isSelectedHighlight(tester, Square.f1), isFalse);
      expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 0);
    });

    testWidgets('set/unset by tapping empty square or opponent piece', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      // set premove
      await makeMove(tester, Square.e4, Square.f5);
      expect(_isPremoveHighlight(tester, Square.e4), isTrue);
      expect(_isPremoveHighlight(tester, Square.f5), isTrue);

      // unset by tapping empty square
      await tester.tapAt(squareOffset(tester, Square.c5));
      await tester.pump();
      expect(_isPremoveHighlight(tester, Square.e4), isFalse);
      expect(_isPremoveHighlight(tester, Square.f5), isFalse);

      // unset by tapping opponent's piece
      await makeMove(tester, Square.d1, Square.f3);
      expect(_isPremoveHighlight(tester, Square.d1), isTrue);
      expect(_isPremoveHighlight(tester, Square.f3), isTrue);
      await tester.tapAt(squareOffset(tester, Square.g8));
      await tester.pump();
      expect(_isPremoveHighlight(tester, Square.d1), isFalse);
      expect(_isPremoveHighlight(tester, Square.f3), isFalse);
    });

    testWidgets('unset by dragging off board', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      // set premove
      await makeMove(tester, Square.e4, Square.f5);
      expect(_isPremoveHighlight(tester, Square.e4), isTrue);
      expect(_isPremoveHighlight(tester, Square.f5), isTrue);

      // unset by dragging off board
      await tester.dragFrom(
        squareOffset(tester, Square.e4),
        squareOffset(tester, Square.e4) + const Offset(0, -boardSize + squareSize),
      );
      await tester.pump();
      expect(_isPremoveHighlight(tester, Square.e4), isFalse);
      expect(_isPremoveHighlight(tester, Square.f5), isFalse);
    });

    testWidgets('unset by dragging to an empty square', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      // set premove
      await makeMove(tester, Square.e4, Square.f5);
      expect(_isPremoveHighlight(tester, Square.e4), isTrue);
      expect(_isPremoveHighlight(tester, Square.f5), isTrue);

      // unset by dragging to an empty square
      await tester.dragFrom(
        squareOffset(tester, Square.e4),
        squareOffset(tester, Square.e4) + const Offset(0, -squareSize),
      );
      await tester.pump();
      expect(_isPremoveHighlight(tester, Square.e4), isFalse);
      expect(_isPremoveHighlight(tester, Square.f5), isFalse);
    });

    testWidgets('unset by tapping same origin square again', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      // set premove
      await makeMove(tester, Square.e4, Square.f5);
      expect(_isPremoveHighlight(tester, Square.e4), isTrue);
      expect(_isPremoveHighlight(tester, Square.f5), isTrue);

      // unset by tapping same origin square again
      await tester.tapAt(squareOffset(tester, Square.e4));
      await tester.pump();
      expect(_isPremoveHighlight(tester, Square.e4), isFalse);
      expect(_isPremoveHighlight(tester, Square.f5), isFalse);
    });

    testWidgets('set and change by tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await makeMove(tester, Square.d1, Square.f3);
      expect(_isPremoveHighlight(tester, Square.d1), isTrue);
      expect(_isPremoveHighlight(tester, Square.f3), isTrue);
      await tester.tapAt(squareOffset(tester, Square.d2));
      await tester.pump();
      // premove is still set
      expect(_isPremoveHighlight(tester, Square.d1), isTrue);
      expect(_isPremoveHighlight(tester, Square.f3), isTrue);
      expect(_moveDestHighlightCount(tester) + _premoveDestHighlightCount(tester), 4);
      await tester.tapAt(squareOffset(tester, Square.d4));
      await tester.pump();
      // premove is changed
      expect(_isPremoveHighlight(tester, Square.d1), isFalse);
      expect(_isPremoveHighlight(tester, Square.f3), isFalse);
      expect(_isPremoveHighlight(tester, Square.d2), isTrue);
      expect(_isPremoveHighlight(tester, Square.d4), isTrue);
    });

    testWidgets('set and change by drag', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await makeMove(tester, Square.d1, Square.f3);
      expect(_isPremoveHighlight(tester, Square.d1), isTrue);
      expect(_isPremoveHighlight(tester, Square.f3), isTrue);
      await tester.dragFrom(squareOffset(tester, Square.d2), const Offset(0, -squareSize * 2));
      await tester.pump();
      // premove is changed
      expect(_isPremoveHighlight(tester, Square.d1), isFalse);
      expect(_isPremoveHighlight(tester, Square.f3), isFalse);
      expect(_isPremoveHighlight(tester, Square.d2), isTrue);
      expect(_isPremoveHighlight(tester, Square.d4), isTrue);
    });

    testWidgets('drag to set', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await tester.dragFrom(squareOffset(tester, Square.e4), const Offset(0, -squareSize));
      await tester.pumpAndSettle();
      expect(_isPremoveHighlight(tester, Square.e4), isTrue);
      expect(_isPremoveHighlight(tester, Square.e5), isTrue);
      expect(_isSelectedHighlight(tester, Square.e4), isFalse);
    });

    testWidgets('select another piece from same side does not unset', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          initialPlayerSide: PlayerSide.white,
        ),
      );

      await makeMove(tester, Square.d1, Square.c2);
      expect(_isPremoveHighlight(tester, Square.d1), isTrue);
      expect(_isPremoveHighlight(tester, Square.c2), isTrue);

      await tester.tapAt(squareOffset(tester, Square.e1));
      await tester.pump();
      expect(_isPremoveHighlight(tester, Square.d1), isTrue);
      expect(_isPremoveHighlight(tester, Square.c2), isTrue);
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
      expect(_isPremoveHighlight(tester, Square.d1), isTrue);
      expect(_isPremoveHighlight(tester, Square.f3), isTrue);

      // wait for opponent move to be played
      await tester.pump(const Duration(milliseconds: 200));

      // opponent move is played
      expect(_piecesPainter(tester).pieces[Square.a5], Piece.blackPawn);

      // wait for the premove to be played
      await tester.pump();

      expect(_isPremoveHighlight(tester, Square.d1), isFalse);
      expect(_isPremoveHighlight(tester, Square.f3), isFalse);

      // premove has been played
      expect(_piecesPainter(tester).pieces.containsKey(Square.d1), isFalse);
      expect(_piecesPainter(tester).pieces[Square.f3], Piece.whiteQueen);
    });

    testWidgets('play drop premove', (WidgetTester tester) async {
      final pos = Crazyhouse.initial.copyWith(
        pockets: Pockets.empty.increment(Side.white, Role.rook),
      );
      await tester.pumpWidget(
        _TestApp(
          rule: Rule.crazyhouse,
          fen: pos.fen,
          settings: const ChessboardSettings(animationDuration: Duration.zero, enableDrops: true),
          validDropSquares: pos.legalDrops.squares.toSet(),
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
        squareOffset(tester, Square.f3) - tester.getCenter(whiteRookDraggable),
      );
      await tester.pump(); // Wait for piece to drop and board to redraw
      expect(_isPremoveHighlight(tester, Square.f3), isTrue);

      // wait for opponent move to be played
      await tester.pump(const Duration(milliseconds: 200));

      // opponent move is played
      expect(_piecesPainter(tester).pieces[Square.a5], Piece.blackPawn);

      // wait for the premove to be played
      await tester.pump();

      expect(_isPremoveHighlight(tester, Square.f3), isFalse);

      // premove has been played
      expect(_piecesPainter(tester).pieces[Square.f3], Piece.whiteRook);
    });

    testWidgets('play a premove with promotion', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          settings: ChessboardSettings(animationDuration: Duration.zero),
          initialPlayerSide: PlayerSide.white,
          fen: '8/5P2/2RK2P1/8/4k3/8/8/8 w - - 0 1',
          shouldPlayOpponentMove: true,
        ),
      );

      await makeMove(tester, Square.g6, Square.g7);
      await makeMove(tester, Square.g7, Square.g8);
      expect(_isPremoveHighlight(tester, Square.g7), isTrue);
      expect(_isPremoveHighlight(tester, Square.g8), isTrue);

      // wait for opponent move to be played
      await tester.pump(const Duration(milliseconds: 200));

      // opponent move is played
      expect(_piecesPainter(tester).pieces[Square.d3], Piece.blackKing);

      // pawn was promoted to queen
      expect(_isPremoveHighlight(tester, Square.g7), isFalse);
      expect(_isPremoveHighlight(tester, Square.g8), isFalse);
      expect(_piecesPainter(tester).pieces.containsKey(Square.g7), isFalse);
      expect(_piecesPainter(tester).pieces[Square.g8], Piece.whiteQueen);
    });

    testWidgets('play a premove with promotion, autoqueen disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          settings: ChessboardSettings(
            autoQueenPromotionOnPremove: false,
            animationDuration: Duration.zero,
          ),
          initialPlayerSide: PlayerSide.white,
          fen: '8/5P2/2RK2P1/8/4k3/8/8/8 w - - 0 1',
          shouldPlayOpponentMove: true,
        ),
      );

      await makeMove(tester, Square.g6, Square.g7);
      await makeMove(tester, Square.g7, Square.g8);
      expect(_isPremoveHighlight(tester, Square.g7), isTrue);
      expect(_isPremoveHighlight(tester, Square.g8), isTrue);

      // wait for opponent move to be played
      await tester.pump(const Duration(milliseconds: 200));

      // promotion dialog is shown
      expect(find.byType(PromotionSelector), findsOneWidget);

      // premove highlight are not shown anymore
      expect(_isPremoveHighlight(tester, Square.g7), isFalse);
      expect(_isPremoveHighlight(tester, Square.g8), isFalse);

      // promotion pawn is hidden by painter (still in pieces map but skipped due to promotionMoveFrom)
      expect(_piecesPainter(tester).promotionMoveFrom, Square.g7);

      // select knight
      await tester.tapAt(squareOffset(tester, Square.g7));
      await tester.pump();

      expect(_piecesPainter(tester).pieces[Square.g8], Piece.whiteKnight);
      expect(_piecesPainter(tester).pieces.containsKey(Square.g7), isFalse);

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
          fen: '8/5P2/2RK2P1/8/4k3/8/8/8 w - - 0 1',
          shouldPlayOpponentMove: true,
        ),
      );

      await makeMove(tester, Square.g6, Square.g7);
      await makeMove(tester, Square.g7, Square.g8);
      expect(_isPremoveHighlight(tester, Square.g7), isTrue);
      expect(_isPremoveHighlight(tester, Square.g8), isTrue);

      // wait for opponent move to be played
      await tester.pump(const Duration(milliseconds: 200));

      // promotion dialog is shown
      expect(find.byType(PromotionSelector), findsOneWidget);

      // premove highlight are not shown anymore
      expect(_isPremoveHighlight(tester, Square.g7), isFalse);
      expect(_isPremoveHighlight(tester, Square.g8), isFalse);

      // cancel promotion dialog
      await tester.tapAt(squareOffset(tester, Square.c3));
      await tester.pump();

      // promotion dialog is closed
      expect(find.byType(PromotionSelector), findsNothing);

      expect(_piecesPainter(tester).pieces[Square.g7], Piece.whitePawn);
    });
  });

  group('Drawing shapes', () {
    testWidgets('preconfigure board to draw a circle', (WidgetTester tester) async {
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialShapes: {const Circle(orig: Square.e4, color: Color(0xFF0000FF))},
        ),
      );

      expect(find.byType(BoardShapeWidget), paints..path(color: const Color(0xFF0000FF)));
    });

    testWidgets('preconfigure board to draw an arrow', (WidgetTester tester) async {
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialShapes: {const Arrow(orig: Square.e2, dest: Square.e4, color: Color(0xFF0000FF))},
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
          initialShapes: {
            const PieceShape(
              orig: Square.e4,
              piece: Piece.whitePawn,
              pieceAssets: PieceSet.horseyAssets,
            ),
          },
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
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));

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
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));

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
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.none));

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
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));

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

    testWidgets('selecting one piece should clear user drawn shapes', (WidgetTester tester) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));

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

    testWidgets('drawing the same circle twice removes it', (WidgetTester tester) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));

      Future<void> drawCircleOnE4() async {
        await TestAsyncUtils.guard<void>(() async {
          final pressGesture = await tester.startGesture(squareOffset(tester, Square.a3));
          final tapGesture = await tester.startGesture(squareOffset(tester, Square.e4));
          await tapGesture.up();
          await pressGesture.up();
        });
        await tester.pump(const Duration(milliseconds: 210));
      }

      await drawCircleOnE4();
      expect(find.byType(BoardShapeWidget), findsOneWidget);

      await drawCircleOnE4();
      expect(find.byType(BoardShapeWidget), findsNothing);
    });

    testWidgets('drawing the same arrow twice removes it', (WidgetTester tester) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));

      Future<void> drawArrowE2E4() async {
        final pressGesture = await tester.startGesture(squareOffset(tester, Square.a3));
        await tester.dragFrom(squareOffset(tester, Square.e2), const Offset(0, -(squareSize * 2)));
        await pressGesture.up();
        await tester.pump(const Duration(milliseconds: 210));
      }

      await drawArrowE2E4();
      expect(find.byType(BoardShapeWidget), findsOneWidget);

      await drawArrowE2E4();
      expect(find.byType(BoardShapeWidget), findsNothing);
    });

    testWidgets('drawing a different shape on the same square adds to the set', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));

      // draw a circle on e4
      await TestAsyncUtils.guard<void>(() async {
        final pressGesture = await tester.startGesture(squareOffset(tester, Square.a3));
        final tapGesture = await tester.startGesture(squareOffset(tester, Square.e4));
        await tapGesture.up();
        await pressGesture.up();
      });
      await tester.pump(const Duration(milliseconds: 210));

      // draw an arrow from e4 to e6 — different shape, same origin square
      final pressGesture = await tester.startGesture(squareOffset(tester, Square.a3));
      await tester.dragFrom(squareOffset(tester, Square.e4), const Offset(0, -(squareSize * 2)));
      await pressGesture.up();
      await tester.pump(const Duration(milliseconds: 210));

      expect(find.byType(BoardShapeWidget), findsNWidgets(2));
    });

    testWidgets('external shapes are displayed alongside drawn shapes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialShapes: {const Arrow(orig: Square.d1, dest: Square.d4, color: Color(0xFFFF0000))},
        ),
      );

      // external shape is visible
      expect(find.byType(BoardShapeWidget), findsOneWidget);

      await TestAsyncUtils.guard<void>(() async {
        // draw a circle by hand
        final pressGesture = await tester.startGesture(squareOffset(tester, Square.a3));
        final tapGesture = await tester.startGesture(squareOffset(tester, Square.e4));
        await tapGesture.up();
        await pressGesture.up();
      });

      // wait for the double tap delay to expire
      await tester.pump(const Duration(milliseconds: 210));

      // both external and drawn shapes are visible
      expect(find.byType(BoardShapeWidget), findsNWidgets(2));
    });

    testWidgets('clearing drawn shapes does not affect external shapes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _TestApp(
          initialPlayerSide: PlayerSide.both,
          initialShapes: {const Circle(orig: Square.d4, color: Color(0xFFFF0000))},
        ),
      );

      await TestAsyncUtils.guard<void>(() async {
        // draw a circle by hand
        final pressGesture = await tester.startGesture(squareOffset(tester, Square.a3));
        final tapGesture = await tester.startGesture(squareOffset(tester, Square.e4));
        await tapGesture.up();
        await pressGesture.up();
      });

      await tester.pump(const Duration(milliseconds: 210));

      expect(find.byType(BoardShapeWidget), findsNWidgets(2));

      // double tap to clear drawn shapes
      await tester.tapAt(squareOffset(tester, Square.a3));
      await tester.tapAt(squareOffset(tester, Square.a3));
      await tester.pump();

      // only the external shape remains
      expect(find.byType(BoardShapeWidget), findsOneWidget);
    });
  });

  group('piece orientation behavior', () {
    void checkUpsideDownPieces(
      WidgetTester tester, {
      required bool expectWhiteUpsideDown,
      required bool expectBlackUpsideDown,
    }) {
      final painter = _piecesPainter(tester);
      for (final entry in painter.pieces.entries) {
        final isUpsideDown = switch (painter.pieceOrientationBehavior) {
          PieceOrientationBehavior.facingUser => false,
          PieceOrientationBehavior.opponentUpsideDown =>
            entry.value.color == painter.orientation.opposite,
          PieceOrientationBehavior.sideToPlay => painter.sideToMove == painter.orientation.opposite,
        };
        if (entry.value.color == Side.white) {
          expect(isUpsideDown, expectWhiteUpsideDown, reason: 'white is upside down');
        } else {
          expect(isUpsideDown, expectBlackUpsideDown, reason: 'black is upside down');
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
    late ChessboardController controller;

    setUp(() {
      controller = nonInteractiveController(kInitialFEN);
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildBoard() =>
        Chessboard(controller: controller, size: boardSize, orientation: Side.white);

    testWidgets(
      'no explosion on initial render even when triggerExplosion was called before pump',
      (WidgetTester tester) async {
        controller.triggerExplosion({Square.e4});
        await tester.pumpWidget(buildBoard());

        expect(_explosionsPainter(tester).notifier.activeExplosionCount, 0);
      },
    );

    testWidgets('explosion is active when triggerExplosion is called', (WidgetTester tester) async {
      await tester.pumpWidget(buildBoard());
      controller.triggerExplosion({Square.e4});
      await tester.pump();

      expect(_explosionsPainter(tester).notifier.activeExplosionCount, 1);
    });

    testWidgets('one active explosion per square in the set', (WidgetTester tester) async {
      await tester.pumpWidget(buildBoard());
      controller.triggerExplosion({Square.e4, Square.d5, Square.f6});
      await tester.pump();

      expect(_explosionsPainter(tester).notifier.activeExplosionCount, 3);
    });

    testWidgets('explosions are removed after animation completes', (WidgetTester tester) async {
      await tester.pumpWidget(buildBoard());
      controller.triggerExplosion({Square.e4});
      await tester.pump();

      expect(_explosionsPainter(tester).notifier.activeExplosionCount, 1);

      await tester.pumpAndSettle();

      expect(_explosionsPainter(tester).notifier.activeExplosionCount, 0);
    });

    testWidgets('same Set reference does not re-trigger explosions', (WidgetTester tester) async {
      final squares = {Square.e4};

      await tester.pumpWidget(buildBoard());
      controller.triggerExplosion(squares);
      await tester.pump();
      expect(_explosionsPainter(tester).notifier.activeExplosionCount, 1);

      // Advance past animation end so the explosion removes itself.
      await tester.pumpAndSettle();
      expect(_explosionsPainter(tester).notifier.activeExplosionCount, 0);

      // Calling triggerExplosion with the same Set reference should not re-trigger.
      controller.triggerExplosion(squares);
      await tester.pump();
      expect(_explosionsPainter(tester).notifier.activeExplosionCount, 0);
    });

    testWidgets('new explosion set adds to currently animating explosions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildBoard());

      // Trigger first explosion on e4.
      controller.triggerExplosion({Square.e4});
      await tester.pump();
      expect(_explosionsPainter(tester).notifier.activeExplosionCount, 1);

      // Advance partway through the animation (less than 600 ms default duration).
      await tester.pump(const Duration(milliseconds: 200));

      // Trigger a second explosion on d5 while the first is still running.
      controller.triggerExplosion({Square.d5});
      await tester.pump();

      expect(_explosionsPainter(tester).notifier.activeExplosionCount, 2);

      // After settling, all explosions should be gone.
      await tester.pumpAndSettle();
      expect(_explosionsPainter(tester).notifier.activeExplosionCount, 0);
    });
  });

  group('ChessboardController tree reattachment', () {
    late ChessboardController controller;

    setUp(() {
      controller = nonInteractiveController(kInitialFEN);
    });

    tearDown(() {
      controller.dispose();
    });

    // Regression: toggling a widget above the board in a Column shifts the
    // Chessboard from index 0 to index 1. Flutter deactivates the old
    // _BoardState and creates a new one before disposing the old one, which
    // previously triggered the "ChessboardController is already attached"
    // assertion in attachTo().
    testWidgets('does not crash when a sibling is inserted before the board in a Column', (
      WidgetTester tester,
    ) async {
      bool showExtra = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              // NoSplash avoids loading ink_sparkle.frag shader in tests;
              // Flutter 3.44 changed the shader format and it fails in the test environment.
              theme: ThemeData(splashFactory: NoSplash.splashFactory),
              home: Column(
                children: [
                  if (showExtra) const SizedBox(height: 10),
                  Chessboard(controller: controller, size: boardSize, orientation: Side.white),
                  ElevatedButton(
                    onPressed: () => setState(() => showExtra = !showExtra),
                    child: const Text('toggle'),
                  ),
                ],
              ),
            );
          },
        ),
      );

      expect(find.byType(Chessboard), findsOneWidget);
      expect(_piecesPainter(tester).pieces.length, 32);

      await tester.tap(find.text('toggle'));
      await tester.pump();

      expect(find.byType(Chessboard), findsOneWidget);
      expect(_piecesPainter(tester).pieces.length, 32);
    });

    testWidgets('controller remains functional after the board shifts position in a Column', (
      WidgetTester tester,
    ) async {
      bool showExtra = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              theme: ThemeData(splashFactory: NoSplash.splashFactory),
              home: Column(
                children: [
                  if (showExtra) const SizedBox(height: 10),
                  Chessboard(controller: controller, size: boardSize, orientation: Side.white),
                  ElevatedButton(
                    onPressed: () => setState(() => showExtra = !showExtra),
                    child: const Text('toggle'),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Shift the board to a new position in the tree.
      await tester.tap(find.text('toggle'));
      await tester.pump();

      // Controller should still drive the board correctly.
      controller.updatePosition(
        const GameData(
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          playerSide: PlayerSide.none,
          sideToMove: Side.black,
          validMoves: {},
        ),
        animate: false,
        resetPremove: true,
      );
      await tester.pump();

      expect(_piecesPainter(tester).pieces.containsKey(Square.e4), isTrue);
      expect(_piecesPainter(tester).pieces.containsKey(Square.e2), isFalse);
    });

    // Regression: after a tree shift, the old _BoardState.dispose() called
    // detach() on the controller, nulling the animations that the new state had
    // just set up in its initState(). Any subsequent rebuild (e.g. from setState
    // triggered by piece selection) then crashed with "not attached".
    testWidgets('board is still interactive after tree shift (setState-triggered rebuild)', (
      WidgetTester tester,
    ) async {
      bool showExtra = false;
      const position = Chess.initial;
      final interactiveController = ChessboardController(
        game: GameData(
          fen: kInitialFEN,
          playerSide: PlayerSide.both,
          sideToMove: Side.white,
          validMoves: makeLegalMoves(position),
        ),
      );
      addTearDown(interactiveController.dispose);

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              theme: ThemeData(splashFactory: NoSplash.splashFactory),
              home: Column(
                children: [
                  if (showExtra) const SizedBox(height: 10),
                  Chessboard(
                    controller: interactiveController,
                    size: boardSize,
                    orientation: Side.white,
                    onMove: (_, {viaDragAndDrop}) {},
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => showExtra = !showExtra),
                    child: const Text('toggle'),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Shift the board (inserts a sibling before it).
      await tester.tap(find.text('toggle'));
      await tester.pump();
      // At this point the old _BoardState has been disposed. Without the fix,
      // dispose() would have nulled the controller's animations.

      // Tapping a piece triggers setState inside _BoardState, which rebuilds
      // the board and accesses _controller.fadeAnimation — crashing without fix.
      await tester.tapAt(squareOffset(tester, Square.e2));
      await tester.pump();

      expect(_isSelectedHighlight(tester, Square.e2), isTrue);
    });

    // Regression: same bug but in the reverse direction — removing the sibling
    // shifts the board from index 1 back to index 0, going through the same
    // deactivate → new initState → old dispose sequence.
    testWidgets('board is still interactive after reverse tree shift (sibling removal)', (
      WidgetTester tester,
    ) async {
      bool showExtra = true;
      const position = Chess.initial;
      final interactiveController = ChessboardController(
        game: GameData(
          fen: kInitialFEN,
          playerSide: PlayerSide.both,
          sideToMove: Side.white,
          validMoves: makeLegalMoves(position),
        ),
      );
      addTearDown(interactiveController.dispose);

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              theme: ThemeData(splashFactory: NoSplash.splashFactory),
              home: Column(
                children: [
                  if (showExtra) const SizedBox(height: 10),
                  Chessboard(
                    controller: interactiveController,
                    size: boardSize,
                    orientation: Side.white,
                    onMove: (_, {viaDragAndDrop}) {},
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => showExtra = !showExtra),
                    child: const Text('toggle'),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Remove the sibling to shift board back to index 0.
      await tester.tap(find.text('toggle'));
      await tester.pump();

      await tester.tapAt(squareOffset(tester, Square.e2));
      await tester.pump();

      expect(_isSelectedHighlight(tester, Square.e2), isTrue);
    });

    testWidgets('board survives repeated back-and-forth tree shifts', (WidgetTester tester) async {
      bool showExtra = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              theme: ThemeData(splashFactory: NoSplash.splashFactory),
              home: Column(
                children: [
                  if (showExtra) const SizedBox(height: 10),
                  Chessboard(controller: controller, size: boardSize, orientation: Side.white),
                  ElevatedButton(
                    onPressed: () => setState(() => showExtra = !showExtra),
                    child: const Text('toggle'),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Toggle three times. Each toggle shifts the board in the Column and
      // goes through the full deactivate → new initState → old dispose cycle.
      // updatePosition(animate: false) forces a rebuild after each shift so
      // that any broken animation state is exercised immediately.
      const altFen = 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1';
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('toggle'));
        await tester.pump();
        final fen = i.isEven ? altFen : kInitialFEN;
        controller.updatePosition(
          GameData(
            fen: fen,
            playerSide: PlayerSide.none,
            sideToMove: Setup.parseFen(fen).turn,
            validMoves: const {},
          ),
          animate: false,
          resetPremove: true,
        );
        await tester.pump();
      }

      expect(find.byType(Chessboard), findsOneWidget);
      expect(_piecesPainter(tester).pieces.length, 32);
    });

    // Regression (lichess-org/mobile#3272): an animated move leaves the
    // fading/translating notifiers populated (they are only cleared by the next
    // updatePosition) and relies on the animation resting at value 1.0 to render
    // them invisibly. A tree shift detaches and re-attaches the controller,
    // creating a fresh AnimationController at value 0.0. Without clearing the
    // notifiers on detach, the board then repaints the captured piece at full
    // opacity and the moved piece at its origin — overlapping ghosts on the
    // board. On device this is hit by reparenting during an Android
    // predictive-back gesture after navigating a move.
    testWidgets('tree shift after an animated capture leaves no stale animation pieces', (
      WidgetTester tester,
    ) async {
      // White knight on f3, black pawn on e5 (plus kings).
      final captureController = nonInteractiveController('4k3/8/8/4p3/8/5N2/8/4K3 w - - 0 1');
      addTearDown(captureController.dispose);

      // The board carries a GlobalKey and lives in one of two branches. Flipping
      // `moved` relocates it to the other branch, which forces Flutter to
      // reparent the element (deactivate then activate) — the same lifecycle the
      // Android predictive-back gesture triggers, and which detaches then
      // re-attaches the controller.
      final boardKey = GlobalKey();
      bool moved = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            final board = Chessboard(
              key: boardKey,
              controller: captureController,
              size: boardSize,
              orientation: Side.white,
            );
            return MaterialApp(
              theme: ThemeData(splashFactory: NoSplash.splashFactory),
              home: Column(
                children: [
                  Expanded(child: moved ? const SizedBox.shrink() : board),
                  Expanded(child: moved ? board : const SizedBox.shrink()),
                  ElevatedButton(
                    onPressed: () => setState(() => moved = !moved),
                    child: const Text('toggle'),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Animate Nxe5: the knight translates f3 -> e5 and the captured pawn fades
      // out on e5.
      captureController.updatePosition(
        const GameData(
          fen: '4k3/8/8/4N3/8/8/8/4K3 b - - 0 1',
          playerSide: PlayerSide.none,
          sideToMove: Side.black,
          validMoves: {},
        ),
      );
      await tester.pumpAndSettle();

      // Precondition: the animation has finished (resting at value 1.0) but the
      // notifiers are still populated — rendered invisibly at this point.
      expect(_translatingPiecesPainter(tester)!.translatingPieces, isNotEmpty);
      expect(_fadingPiecesPainter(tester)!.fadingPieces, isNotEmpty);

      // Reparent the board: detaches and re-attaches the controller.
      await tester.tap(find.text('toggle'));
      await tester.pump();

      // The freshly attached controller is at value 0.0; the stale pieces must
      // have been dropped so nothing is repainted over the static position.
      expect(_translatingPiecesPainter(tester)!.translatingPieces, isEmpty);
      expect(_fadingPiecesPainter(tester)!.fadingPieces, isEmpty);

      // The static position is intact: knight on e5, pawn gone.
      expect(_piecesPainter(tester).pieces[Square.e5], Piece.whiteKnight);
      expect(_piecesPainter(tester).pieces.containsKey(Square.e5), isTrue);
      expect(_piecesPainter(tester).pieces.values.where((p) => p == Piece.blackPawn), isEmpty);
    });
  });

  group('board piece rendering', () {
    testWidgets('all pieces are rendered by PiecesPainter regardless of cache state', (
      WidgetTester tester,
    ) async {
      // Cache is empty — pieces should still be tracked in PiecesPainter.
      await tester.pumpWidget(
        const StaticChessboard(size: boardSize, orientation: Side.white, fen: kInitialFEN),
      );

      expect(_piecesPainter(tester).pieces.length, 32);
      // No fallback PieceWidget in the tree for static board pieces.
      expect(find.byType(PieceWidget), findsNothing);
    });

    testWidgets('PiecesPainter renders pieces when all images are pre-cached', (
      WidgetTester tester,
    ) async {
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
        const StaticChessboard(size: boardSize, orientation: Side.white, fen: kInitialFEN),
      );

      expect(_piecesPainter(tester).pieces.length, 32);
      expect(find.byType(PieceWidget), findsNothing);
    });
  });

  group('drag avatar rendering', () {
    testWidgets('drag piece is drawn by _DragPiecePainter on canvas (no PieceWidget overlay)', (
      WidgetTester tester,
    ) async {
      final asset = const ChessboardSettings().pieceAssets[Piece.whitePawn.kind]!;
      final fakeImage = await _createFakeImage(45, 45);
      ChessgroundImages.instance.add(asset, fakeImage);
      addTearDown(() => ChessgroundImages.instance.evict(asset));

      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.both));

      // No PieceWidget in tree — all static pieces rendered by PiecesPainter.
      expect(find.byType(PieceWidget), findsNothing);

      await TestAsyncUtils.guard<void>(() async {
        final gesture = await tester.startGesture(squareOffset(tester, Square.e2));
        await tester.pump();
        // Exceed the _kDragDistanceThreshold of 3.0 px to start a drag.
        await gesture.moveBy(const Offset(0, -4));
        await tester.pump();

        // Drag avatar uses _DragPiecePainter — still no PieceWidget in tree.
        expect(find.byType(PieceWidget), findsNothing);

        await gesture.up();
      });
      await tester.pump();
    });
  });

  group('no unnecessary rebuilds', () {
    testWidgets('selecting a piece does not rebuild the board widget', (WidgetTester tester) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.white));

      final highlightsBefore = _highlightsPainter(tester);
      final piecesBefore = _piecesPainter(tester);
      final explosionsBefore = _explosionsPainter(tester);

      await tester.tapAt(squareOffset(tester, Square.e2));
      await tester.pump();

      expect(_isSelectedHighlight(tester, Square.e2), isTrue);
      expect(
        identical(_highlightsPainter(tester), highlightsBefore),
        isTrue,
        reason: 'HighlightsPainter was recreated — build() was called',
      );
      expect(
        identical(_piecesPainter(tester), piecesBefore),
        isTrue,
        reason: 'PiecesPainter was recreated — build() was called',
      );
      expect(
        identical(_explosionsPainter(tester), explosionsBefore),
        isTrue,
        reason: 'ExplosionsPainter was recreated — build() was called',
      );
    });

    testWidgets('deselecting a piece does not rebuild the board widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.white));

      // Select e2 first.
      await tester.tapAt(squareOffset(tester, Square.e2));
      await tester.pump();
      expect(_isSelectedHighlight(tester, Square.e2), isTrue);

      final highlightsBefore = _highlightsPainter(tester);
      final piecesBefore = _piecesPainter(tester);
      final explosionsBefore = _explosionsPainter(tester);

      // Deselect by tapping the same square.
      await tester.tapAt(squareOffset(tester, Square.e2));
      await tester.pump();

      expect(_isSelectedHighlight(tester, Square.e2), isFalse);
      expect(
        identical(_highlightsPainter(tester), highlightsBefore),
        isTrue,
        reason: 'HighlightsPainter was recreated — build() was called',
      );
      expect(
        identical(_piecesPainter(tester), piecesBefore),
        isTrue,
        reason: 'PiecesPainter was recreated — build() was called',
      );
      expect(
        identical(_explosionsPainter(tester), explosionsBefore),
        isTrue,
        reason: 'ExplosionsPainter was recreated — build() was called',
      );
    });

    testWidgets('making a move does not rebuild the board widget', (WidgetTester tester) async {
      await tester.pumpWidget(const _TestApp(initialPlayerSide: PlayerSide.white));

      final highlightsBefore = _highlightsPainter(tester);
      final piecesBefore = _piecesPainter(tester);
      final explosionsBefore = _explosionsPainter(tester);

      await tester.tapAt(squareOffset(tester, Square.e2));
      await tester.pump();
      await tester.tapAt(squareOffset(tester, Square.e4));
      await tester.pump();

      expect(_isLastMoveHighlight(tester, Square.e4), isTrue);
      expect(
        identical(_highlightsPainter(tester), highlightsBefore),
        isTrue,
        reason: 'HighlightsPainter was recreated — build() was called',
      );
      expect(
        identical(_piecesPainter(tester), piecesBefore),
        isTrue,
        reason: 'PiecesPainter was recreated — build() was called',
      );
      expect(
        identical(_explosionsPainter(tester), explosionsBefore),
        isTrue,
        reason: 'ExplosionsPainter was recreated — build() was called',
      );
    });

    testWidgets('controller.updatePosition does not rebuild the board widget', (
      WidgetTester tester,
    ) async {
      final gameEventController = StreamController<GameEvent>();
      addTearDown(gameEventController.close);

      await tester.pumpWidget(
        _TestApp(initialPlayerSide: PlayerSide.white, gameEventStream: gameEventController.stream),
      );

      final highlightsBefore = _highlightsPainter(tester);
      final piecesBefore = _piecesPainter(tester);
      final explosionsBefore = _explosionsPainter(tester);

      // Trigger an external move via the controller (no setState on parent).
      gameEventController.add(GameEvent.externalMove);
      await tester.pump();

      expect(
        identical(_highlightsPainter(tester), highlightsBefore),
        isTrue,
        reason: 'HighlightsPainter was recreated — build() was called',
      );
      expect(
        identical(_piecesPainter(tester), piecesBefore),
        isTrue,
        reason: 'PiecesPainter was recreated — build() was called',
      );
      expect(
        identical(_explosionsPainter(tester), explosionsBefore),
        isTrue,
        reason: 'ExplosionsPainter was recreated — build() was called',
      );
    });
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
    this.fen = kInitialFEN,
    this.rule = Rule.chess,
    this.orientation = Side.white,
    this.settings,
    this.validDropSquares,
    this.initialPromotionMove,
    this.initialShapes = const {},
    this.shouldPlayOpponentMove = false,
    this.gameEventStream,
    this.onTouchedSquare,
    this.bottomWidget,
    this.canPromoteToKing = false,
    super.key,
  });

  final PlayerSide initialPlayerSide;
  final String fen;
  final Rule rule;
  final ChessboardSettings? settings;
  final Side orientation;
  final ValidDropSquares? validDropSquares;

  final NormalMove? initialPromotionMove;
  final Set<Shape> initialShapes;

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
  late ChessboardController _controller;
  late PlayerSide interactiveSide;
  late Position position;
  Move? lastMove;

  StreamSubscription<GameEvent>? _gameEventSub;

  ChessboardSettings get defaultSettings => ChessboardSettings(
    drawShape: const DrawShapeOptions(enable: true, newShapeColor: Color(0xFF0000FF)),
    canPromoteToKing: widget.canPromoteToKing,
  );

  @override
  void initState() {
    super.initState();
    interactiveSide = widget.initialPlayerSide;
    position = Position.setupPosition(widget.rule, Setup.parseFen(widget.fen));
    lastMove = widget.initialPromotionMove;
    _controller = ChessboardController(game: _buildGame());
    if (widget.initialPromotionMove != null) {
      _controller.pendingPromotion = widget.initialPromotionMove;
    }
    _gameEventSub = widget.gameEventStream?.listen(_onGameEvent);
  }

  @override
  void dispose() {
    _controller.dispose();
    _gameEventSub?.cancel();
    super.dispose();
  }

  GameData _buildGame() {
    return GameData(
      fen: position.fen,
      lastMove: lastMove,
      playerSide: interactiveSide,
      kingSquareInCheck: position.isCheck ? position.board.kingOf(position.turn) : null,
      sideToMove: position.turn == Side.white ? Side.white : Side.black,
      validMoves: makeLegalMoves(position),
      validDropSquares: widget.validDropSquares,
    );
  }

  void _onGameEvent(GameEvent event) {
    switch (event) {
      case GameEvent.nonInteractiveBoardEvent:
        interactiveSide = PlayerSide.none;
        _controller.updatePosition(_buildGame());
      case GameEvent.interactiveBoardEvent:
        interactiveSide = widget.initialPlayerSide;
        _controller.updatePosition(_buildGame());
      case GameEvent.externalMove:
        final allMoves = [
          for (final entry in position.legalMoves.entries)
            for (final dest in entry.value.squares) NormalMove(from: entry.key, to: dest),
        ];
        if (allMoves.isNotEmpty) {
          position = position.playUnchecked(allMoves.first);
          lastMove = allMoves.first;
          _controller.updatePosition(_buildGame());
        }
    }
  }

  void _playMove(Move move) {
    position = position.playUnchecked(move);
    if (position.isGameOver) {
      interactiveSide = PlayerSide.none;
    }
    lastMove = move;
  }

  void _onMove(Move move, {bool? viaDragAndDrop}) {
    _playMove(move);
    _controller.updatePosition(_buildGame());

    if (widget.shouldPlayOpponentMove) {
      Timer(const Duration(milliseconds: 200), () {
        final allMoves = [
          for (final entry in position.legalMoves.entries)
            for (final dest in entry.value.squares) NormalMove(from: entry.key, to: dest),
        ];
        final opponentMove = allMoves.first;
        position = position.playUnchecked(opponentMove);
        if (position.isGameOver) {
          interactiveSide = PlayerSide.none;
        }
        lastMove = opponentMove;
        _controller.updatePosition(_buildGame());

        // play premove just after the opponent move
        final premove = _controller.premove;
        if (premove != null) {
          if (position.isLegal(premove)) {
            if (premove is NormalMove &&
                premove.promotion == null &&
                position.board.roleAt(premove.from) == Role.pawn &&
                ((premove.to.rank == Rank.first && position.turn == Side.black) ||
                    (premove.to.rank == Rank.eighth && position.turn == Side.white))) {
              // Promotion premove with autoQueenPromotionOnPremove disabled
              final promoMove = premove;
              scheduleMicrotask(() {
                _controller.pendingPromotion = promoMove;
                _controller.premove = null;
                _controller.updatePosition(_buildGame());
              });
            } else {
              scheduleMicrotask(() {
                position = position.playUnchecked(premove);
                if (position.isGameOver) interactiveSide = PlayerSide.none;
                lastMove = premove;
                _controller.premove = null;
                _controller.updatePosition(_buildGame());
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
              controller: _controller,
              size: boardSize,
              settings: widget.settings ?? defaultSettings,
              orientation: widget.orientation,
              onMove: _onMove,
              onTouchedSquare: widget.onTouchedSquare,
              shapes: widget.initialShapes,
            ),
            if (widget.bottomWidget != null) widget.bottomWidget!,
          ],
        ),
      ),
    );
  }
}

Offset squareOffset(WidgetTester tester, Square id, {Side orientation = Side.white}) {
  // Use boardWidget.squareSize (based on widget.size) rather than the rendered
  // rect width — rect is unreliable when the board is pumped without a parent
  // that provides loose constraints (e.g. direct pumpWidget without MaterialApp
  // causes RenderView tight constraints to expand board-container to fill screen).
  final chessboardFinder = find.byType(Chessboard);
  final double sq =
      chessboardFinder.evaluate().isNotEmpty
          ? tester.widget<Chessboard>(chessboardFinder).squareSize
          : tester.widget<StaticChessboard>(find.byType(StaticChessboard)).squareSize;
  final topLeft = tester.getTopLeft(find.byKey(const ValueKey('board-container')));
  final x = orientation == Side.black ? 7 - id.file : id.file;
  final y = orientation == Side.black ? id.rank : 7 - id.rank;
  return topLeft + Offset(x * sq + sq / 2, y * sq + sq / 2);
}

/// Creates a minimal in-memory [ui.Image] for tests that need a cached piece image.
Future<ui.Image> _createFakeImage(int width, int height) {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawPaint(Paint()..color = const Color(0xFF0000FF));
  return recorder.endRecording().toImage(width, height);
}
