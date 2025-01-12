import 'package:chessground/src/widgets/animation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartchess/dartchess.dart';
import 'package:chessground/chessground.dart';

const boardSize = 200.0;

void main() {
  const board = StaticChessboard(
    size: boardSize,
    orientation: Side.white,
    fen: kInitialFEN,
  );

  testWidgets('initial position display', (WidgetTester tester) async {
    await tester.pumpWidget(board);

    expect(find.byType(StaticChessboard), findsOneWidget);
    expect(find.byType(PieceWidget), findsNWidgets(32));
  });

  testWidgets('background is constrained to the size of the board', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(board);

    final size = tester.getSize(find.byType(SolidColorChessboardBackground));
    expect(size.width, boardSize);
    expect(size.height, boardSize);
  });

  testWidgets('change in hue will use a color filter',
      (WidgetTester tester) async {
    const board = StaticChessboard(
      size: boardSize,
      orientation: Side.white,
      fen: kInitialFEN,
      hue: 100.0,
    );

    await tester.pumpWidget(board);

    expect(find.byType(ColorFiltered), findsOneWidget);
  });

  testWidgets('change in brightness will use a color filter',
      (WidgetTester tester) async {
    const board = StaticChessboard(
      size: boardSize,
      orientation: Side.white,
      fen: kInitialFEN,
      brightness: 0.9,
    );

    await tester.pumpWidget(board);

    expect(find.byType(ColorFiltered), findsOneWidget);
  });

  testWidgets('moved piece is animated when the position change',
      (WidgetTester tester) async {
    const board = StaticChessboard(
      size: boardSize,
      orientation: Side.white,
      fen: kInitialFEN,
    );

    await tester.pumpWidget(board);

    expect(find.byType(AnimatedPieceTranslation), findsNothing);
    expect(find.byType(PieceWidget), findsNWidgets(32));

    const board2 = StaticChessboard(
      size: boardSize,
      orientation: Side.white,
      fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
    );

    await tester.pumpWidget(board2);

    expect(find.byType(PieceWidget), findsNWidgets(32));
    expect(find.byType(AnimatedPieceTranslation), findsOneWidget);
    final translation =
        tester.firstWidget(find.byType(AnimatedPieceTranslation))
            as AnimatedPieceTranslation;
    expect(translation.fromSquare, Square.e2);
    expect(translation.toSquare, Square.e4);
    expect(translation.orientation, Side.white);
    expect(translation.duration, const Duration(milliseconds: 200));

    await tester.pumpAndSettle();

    expect(find.byType(AnimatedPieceTranslation), findsNothing);
  });

  testWidgets('several pieces can be animated when the position change',
      (WidgetTester tester) async {
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
}
