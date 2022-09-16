import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chessground/chessground.dart';

const initialFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('initial board display', (tester) async {
    await tester.pumpWidget(const Directionality(
        textDirection: TextDirection.ltr,
        child: Board(orientation: Color.white, size: 200, fen: initialFen)));

    final pieceFinder = find.byType(PieceWidget);
    final boardFinder = find.byType(Board);

    expect(boardFinder, findsOneWidget);
    expect(pieceFinder, findsNWidgets(32));
  });
}
