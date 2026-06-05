import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartchess/dartchess.dart';
import 'package:chessground/chessground.dart';

const boardSize = 200.0;
const squareSize = boardSize / 8;

/// Renders a solid 45x45 image (the content is irrelevant: the `paints` matcher
/// inspects the Canvas calls, not pixels).
Future<ui.Image> _createSolidImage() {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawPaint(Paint()..color = const Color(0xFF0000FF));
  return recorder.endRecording().toImage(45, 45);
}

/// Installs a distinct fake image for each piece asset so the painters actually
/// issue `drawImageRect` calls, and registers a tear-down that evicts them.
Future<void> _installFakePieceImages() async {
  final pieceAssets = const ChessboardSettings().pieceAssets;
  for (final asset in pieceAssets.values) {
    ChessgroundImages.instance.add(asset, await _createSolidImage());
  }
  addTearDown(() {
    for (final asset in pieceAssets.values) {
      ChessgroundImages.instance.evict(asset);
    }
  });
}

/// Wraps a painter so the `paints` matcher can drive its [CustomPainter.paint].
void Function(Canvas) _paintOf(CustomPainter painter) =>
    (Canvas canvas) => painter.paint(canvas, const Size.square(boardSize));

// Distinct opaque highlight colors so `paints` color assertions are unambiguous.
const _lastMoveColor = Color(0xFFAA0000);
const _selectedColor = Color(0xFF00AA00);
const _validMoveColor = Color(0xFF0000AA);
const _premoveColor = Color(0xFFAAAA00);

/// The destination rect a piece/highlight on [square] occupies, white orientation.
Rect _squareRect(Square square) =>
    Rect.fromLTWH(square.file * squareSize, (7 - square.rank) * squareSize, squareSize, squareSize);

void main() {
  group('PiecesPainter paint() logic', () {
    PiecesPainter buildPainter({
      required Map<Square, Piece> pieces,
      Map<Square, ({Piece piece, Square from})> translatingPieces = const {},
      Square? draggedPieceSquare,
      NormalMove? pendingPromotion,
      bool blindfoldMode = false,
    }) {
      return PiecesPainter(
        piecesNotifier: ValueNotifier(pieces),
        translatingPiecesNotifier: ValueNotifier(translatingPieces),
        pieceAssets: const ChessboardSettings().pieceAssets,
        squareSize: squareSize,
        orientation: Side.white,
        draggedPieceSquareNotifier: ValueNotifier<Square?>(draggedPieceSquare),
        gameNotifier: ValueNotifier<GameData?>(null),
        pendingPromotionNotifier: ValueNotifier<NormalMove?>(pendingPromotion),
        blindfoldMode: blindfoldMode,
        pieceOrientationBehavior: PieceOrientationBehavior.facingUser,
        imagesLoaded: true,
      );
    }

    testWidgets('draws each piece into its own square rect', (tester) async {
      await _installFakePieceImages();
      final pieceAssets = const ChessboardSettings().pieceAssets;
      final blackKnightImage = ChessgroundImages.instance.get(pieceAssets[PieceKind.blackKnight]!);

      final painter = buildPainter(
        pieces: {Square.e4: Piece.whitePawn, Square.d5: Piece.blackKnight},
      );

      expect(
        (Canvas canvas) => painter.paint(canvas, const Size.square(boardSize)),
        paints
          ..drawImageRect(destination: _squareRect(Square.e4))
          ..drawImageRect(destination: _squareRect(Square.d5), image: blackKnightImage),
      );
    });

    testWidgets('skips dragged, translating and promoting squares', (tester) async {
      await _installFakePieceImages();

      final painter = buildPainter(
        pieces: {
          Square.e4: Piece.whitePawn, // drawn here
          Square.g1: Piece.whiteKnight, // dragged -> skipped
          Square.a8: Piece.blackRook, // translating -> skipped
          Square.e7: Piece.whitePawn, // pending promotion -> skipped
        },
        translatingPieces: {Square.a8: (from: Square.a6, piece: Piece.blackRook)},
        draggedPieceSquare: Square.g1,
        pendingPromotion: const NormalMove(from: Square.e7, to: Square.e8),
      );
      void paintCall(Canvas canvas) => painter.paint(canvas, const Size.square(boardSize));

      // Only e4 is left for the static painter to draw.
      expect(paintCall, paintsExactlyCountTimes(#drawImageRect, 1));
      expect(paintCall, paints..drawImageRect(destination: _squareRect(Square.e4)));
      expect(paintCall, isNot(paints..drawImageRect(destination: _squareRect(Square.g1))));
    });

    testWidgets('paints nothing in blindfold mode', (tester) async {
      await _installFakePieceImages();

      final painter = buildPainter(
        pieces: {Square.e4: Piece.whitePawn, Square.d5: Piece.blackKnight},
        blindfoldMode: true,
      );

      expect((Canvas canvas) => painter.paint(canvas, const Size.square(boardSize)), paintsNothing);
    });
  });

  group('TranslatingPiecesPainter paint() logic', () {
    TranslatingPiecesPainter buildPainter({
      required Map<Square, ({Piece piece, Square from})> translatingPieces,
      required double t,
      bool blindfoldMode = false,
    }) {
      return TranslatingPiecesPainter(
        translatingPiecesNotifier: ValueNotifier(translatingPieces),
        squareSize: squareSize,
        orientation: Side.white,
        pieceAssets: const ChessboardSettings().pieceAssets,
        blindfoldMode: blindfoldMode,
        pieceOrientationBehavior: PieceOrientationBehavior.facingUser,
        gameNotifier: ValueNotifier<GameData?>(null),
        animation: AlwaysStoppedAnimation<double>(t),
      );
    }

    // A knight in flight b1 -> c3 (changes both file and rank).
    const knightInFlight = {Square.c3: (from: Square.b1, piece: Piece.whiteKnight)};

    testWidgets('draws the piece on its origin square at t=0', (tester) async {
      await _installFakePieceImages();
      final painter = buildPainter(translatingPieces: knightInFlight, t: 0.0);

      expect(_paintOf(painter), paints..drawImageRect(destination: _squareRect(Square.b1)));
    });

    testWidgets('draws the piece on its destination square at t=1', (tester) async {
      await _installFakePieceImages();
      final painter = buildPainter(translatingPieces: knightInFlight, t: 1.0);

      expect(_paintOf(painter), paints..drawImageRect(destination: _squareRect(Square.c3)));
    });

    testWidgets('interpolates the destination rect at t=0.5', (tester) async {
      await _installFakePieceImages();
      final painter = buildPainter(translatingPieces: knightInFlight, t: 0.5);

      // Halfway between b1 (25, 175) and c3 (50, 125).
      expect(
        _paintOf(painter),
        paints..drawImageRect(destination: const Rect.fromLTWH(37.5, 150, squareSize, squareSize)),
      );
    });

    testWidgets('paints nothing when empty or in blindfold mode', (tester) async {
      await _installFakePieceImages();

      expect(_paintOf(buildPainter(translatingPieces: const {}, t: 0.5)), paintsNothing);
      expect(
        _paintOf(buildPainter(translatingPieces: knightInFlight, t: 0.5, blindfoldMode: true)),
        paintsNothing,
      );
    });
  });

  group('HighlightsPainter paint() logic', () {
    HighlightsPainter buildPainter({
      Square? selected,
      Set<Square> moveDests = const {},
      Set<Square> premoveDests = const {},
      Set<Square> occupiedSquares = const {},
      Move? lastMove,
      Move? premove,
      Square? checkSquare,
      bool showLastMove = true,
    }) {
      final notifier =
          BoardHighlightNotifier()
            ..selected = selected
            ..moveDests = moveDests
            ..premoveDests = premoveDests
            ..occupiedSquares = occupiedSquares
            ..lastMove = lastMove
            ..premove = premove
            ..checkSquare = checkSquare;
      return HighlightsPainter(
        interactionNotifier: notifier,
        squareSize: squareSize,
        orientation: Side.white,
        showLastMove: showLastMove,
        premoveColor: _premoveColor,
        lastMoveDetails: const HighlightDetails(solidColor: _lastMoveColor),
        selectedDetails: const HighlightDetails(solidColor: _selectedColor),
        validMoveColor: _validMoveColor,
        squareHighlights: const {},
        highlightImagesLoaded: true,
      );
    }

    testWidgets('draws the last move squares as solid rects', (tester) async {
      final painter = buildPainter(lastMove: const NormalMove(from: Square.e2, to: Square.e4));

      // `rect` matches the next drawRect in order, so assert both (from, then to).
      expect(
        _paintOf(painter),
        paints
          ..rect(rect: _squareRect(Square.e2), color: _lastMoveColor)
          ..rect(rect: _squareRect(Square.e4), color: _lastMoveColor),
      );
    });

    testWidgets('does not draw the last move highlight when showLastMove is false', (tester) async {
      final painter = buildPainter(
        lastMove: const NormalMove(from: Square.e2, to: Square.e4),
        showLastMove: false,
      );

      expect(_paintOf(painter), isNot(paints..rect(color: _lastMoveColor)));
    });

    testWidgets('draws premove squares and suppresses the last move under them', (tester) async {
      final painter = buildPainter(
        lastMove: const NormalMove(from: Square.e2, to: Square.e4),
        premove: const NormalMove(from: Square.e4, to: Square.e5),
      );

      // The full ordered sequence: e2 keeps its last-move color, but e4 (shared
      // with the premove) is drawn with the premove color, not the last-move
      // color — proving the suppression. e5 completes the premove.
      expect(
        _paintOf(painter),
        paints
          ..rect(rect: _squareRect(Square.e2), color: _lastMoveColor)
          ..rect(rect: _squareRect(Square.e4), color: _premoveColor)
          ..rect(rect: _squareRect(Square.e5), color: _premoveColor),
      );
    });

    testWidgets('draws the selected square', (tester) async {
      final painter = buildPainter(selected: Square.d4);

      expect(_paintOf(painter), paints..rect(rect: _squareRect(Square.d4), color: _selectedColor));
    });

    testWidgets('draws move destinations as dots on empty squares', (tester) async {
      final painter = buildPainter(moveDests: {Square.e4});
      final center = _squareRect(Square.e4).center;

      expect(
        _paintOf(painter),
        paints..circle(x: center.dx, y: center.dy, radius: squareSize / 6, color: _validMoveColor),
      );
    });

    testWidgets('draws move destinations as rings on occupied squares', (tester) async {
      final painter = buildPainter(moveDests: {Square.e5}, occupiedSquares: {Square.e5});
      final center = _squareRect(Square.e5).center;

      expect(
        _paintOf(painter),
        paints
          ..clipRect(rect: _squareRect(Square.e5))
          ..circle(
            x: center.dx,
            y: center.dy,
            radius: squareSize - squareSize / 3,
            color: _validMoveColor,
            style: PaintingStyle.stroke,
            strokeWidth: squareSize / 5,
          ),
      );
    });

    testWidgets('draws premove destinations with the premove color', (tester) async {
      final painter = buildPainter(premoveDests: {Square.e4});
      final center = _squareRect(Square.e4).center;

      expect(
        _paintOf(painter),
        paints..circle(x: center.dx, y: center.dy, radius: squareSize / 6, color: _premoveColor),
      );
    });

    testWidgets('draws the check square', (tester) async {
      final painter = buildPainter(checkSquare: Square.e1);

      // The check is a blurred radial gradient drawn as a rect over the square.
      expect(_paintOf(painter), paints..rect(rect: _squareRect(Square.e1)));
    });

    testWidgets('paints nothing when there are no highlights', (tester) async {
      expect(_paintOf(buildPainter()), paintsNothing);
    });
  });

  group('FadingPiecesPainter paint() logic', () {
    FadingPiecesPainter buildPainter({
      required Map<Square, Piece> fadingPieces,
      required double t,
      bool blindfoldMode = false,
    }) {
      return FadingPiecesPainter(
        fadingPiecesNotifier: ValueNotifier(fadingPieces),
        squareSize: squareSize,
        orientation: Side.white,
        pieceAssets: const ChessboardSettings().pieceAssets,
        blindfoldMode: blindfoldMode,
        pieceOrientationBehavior: PieceOrientationBehavior.facingUser,
        gameNotifier: ValueNotifier<GameData?>(null),
        animation: AlwaysStoppedAnimation<double>(t),
      );
    }

    // A captured pawn fading out on e5.
    const fadingPawn = {Square.e5: Piece.blackPawn};

    testWidgets('draws the piece fully opaque at t=0', (tester) async {
      await _installFakePieceImages();
      final painter = buildPainter(fadingPieces: fadingPawn, t: 0.0);

      // Modulating color carries the fade: full alpha at the start.
      expect(
        _paintOf(painter),
        paints..drawImageRect(
          destination: _squareRect(Square.e5),
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
      );
    });

    testWidgets('draws the piece fully transparent at t=1', (tester) async {
      await _installFakePieceImages();
      final painter = buildPainter(fadingPieces: fadingPawn, t: 1.0);

      expect(
        _paintOf(painter),
        paints..drawImageRect(
          destination: _squareRect(Square.e5),
          color: const Color.fromARGB(0, 255, 255, 255),
        ),
      );
    });

    testWidgets('modulates alpha with the animation value at t=0.5', (tester) async {
      await _installFakePieceImages();
      final painter = buildPainter(fadingPieces: fadingPawn, t: 0.5);

      // alpha = (255 * (1 - 0.5)).round() == 128
      expect(
        _paintOf(painter),
        paints..drawImageRect(
          destination: _squareRect(Square.e5),
          color: const Color.fromARGB(128, 255, 255, 255),
        ),
      );
    });

    testWidgets('paints nothing when empty or in blindfold mode', (tester) async {
      await _installFakePieceImages();

      expect(_paintOf(buildPainter(fadingPieces: const {}, t: 0.5)), paintsNothing);
      expect(
        _paintOf(buildPainter(fadingPieces: fadingPawn, t: 0.5, blindfoldMode: true)),
        paintsNothing,
      );
    });
  });

  group('DragPiecePainter paint() logic', () {
    DragPiecePainter buildPainter({
      required ui.Image? image,
      Offset position = const Offset(100, 100),
      Offset feedbackOffset = const Offset(-25, -25),
      double feedbackSize = 50,
      bool upsideDown = false,
    }) {
      return DragPiecePainter(
        image: image,
        feedbackSize: feedbackSize,
        feedbackOffset: feedbackOffset,
        upsideDown: upsideDown,
        positionNotifier: ValueNotifier(position),
      );
    }

    testWidgets('draws the image at the pointer position offset by feedbackOffset', (tester) async {
      final image = await _createSolidImage();
      addTearDown(image.dispose);
      final painter = buildPainter(image: image);

      // dst = position + feedbackOffset, sized feedbackSize: (75, 75, 50, 50).
      expect(
        _paintOf(painter),
        paints..drawImageRect(image: image, destination: const Rect.fromLTWH(75, 75, 50, 50)),
      );
    });

    testWidgets('still draws the image when upside down', (tester) async {
      final image = await _createSolidImage();
      addTearDown(image.dispose);
      final painter = buildPainter(image: image, upsideDown: true);
      final paintCall = _paintOf(painter);

      expect(paintCall, paintsExactlyCountTimes(#drawImageRect, 1));
      expect(paintCall, paints..drawImageRect(destination: const Rect.fromLTWH(75, 75, 50, 50)));
    });

    testWidgets('paints nothing when there is no image', (tester) async {
      expect(_paintOf(buildPainter(image: null)), paintsNothing);
    });
  });

  group('DragSquareTargetPainter paint() logic', () {
    // The translucent overlay the painter fills the target with.
    const targetColor = Color(0x33000000);

    DragSquareTargetPainter buildPainter({
      required DragTargetKind targetKind,
      Offset? position = const Offset(50, 50),
    }) {
      return DragSquareTargetPainter(
        squareSize: squareSize,
        targetKind: targetKind,
        positionNotifier: ValueNotifier<Offset?>(position),
      );
    }

    testWidgets('draws a square target as a filled rect at the position', (tester) async {
      final painter = buildPainter(targetKind: DragTargetKind.square);

      expect(
        _paintOf(painter),
        paints..rect(
          rect: const Rect.fromLTWH(50, 50, squareSize, squareSize),
          color: targetColor,
          style: PaintingStyle.fill,
        ),
      );
    });

    testWidgets('draws a circle target centered on the square', (tester) async {
      final painter = buildPainter(targetKind: DragTargetKind.circle);

      // The position is pre-offset by -squareSize/2, so the center is at
      // position + squareSize and the radius is a full square.
      expect(
        _paintOf(painter),
        paints..circle(
          x: 50 + squareSize,
          y: 50 + squareSize,
          radius: squareSize,
          color: targetColor,
          style: PaintingStyle.fill,
        ),
      );
    });

    testWidgets('paints nothing for DragTargetKind.none', (tester) async {
      expect(_paintOf(buildPainter(targetKind: DragTargetKind.none)), paintsNothing);
    });

    testWidgets('paints nothing when there is no position', (tester) async {
      expect(
        _paintOf(buildPainter(targetKind: DragTargetKind.square, position: null)),
        paintsNothing,
      );
    });
  });
}
