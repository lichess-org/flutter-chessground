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
}
