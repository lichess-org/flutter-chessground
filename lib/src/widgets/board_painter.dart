import 'dart:math' show pi;
import 'dart:ui' as ui;

import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';

import '../board_settings.dart';
import '../images.dart';
import '../models.dart';
import 'animation.dart';

/// Holds the board's interactive highlight state and notifies [HighlightsPainter]
/// to repaint without triggering a widget rebuild.
class BoardHighlightNotifier extends ChangeNotifier {
  Square? selected;
  Set<Square> moveDests = const {};
  Set<Square> premoveDests = const {};
  Set<Square> occupiedSquares = const {};
  Move? lastMove;
  Move? premove;
  Square? checkSquare;

  void update({
    required Square? selected,
    required Set<Square> moveDests,
    required Set<Square> premoveDests,
    required Set<Square> occupiedSquares,
    required Move? lastMove,
    required Move? premove,
    required Square? checkSquare,
  }) {
    this.selected = selected;
    this.moveDests = moveDests;
    this.premoveDests = premoveDests;
    this.occupiedSquares = occupiedSquares;
    this.lastMove = lastMove;
    this.premove = premove;
    this.checkSquare = checkSquare;
    notifyListeners();
  }
}

Rect _squareRect(Square square, double squareSize, Side orientation) {
  final x = orientation == Side.black ? 7 - square.file : square.file;
  final y = orientation == Side.black ? square.rank : 7 - square.rank;
  return Rect.fromLTWH(x * squareSize, y * squareSize, squareSize, squareSize);
}

bool _isUpsideDown(
  Side pieceColor, {
  required PieceOrientationBehavior behavior,
  required Side orientation,
  Side? sideToMove,
}) => switch (behavior) {
  PieceOrientationBehavior.facingUser => false,
  PieceOrientationBehavior.opponentUpsideDown => pieceColor == orientation.opposite,
  PieceOrientationBehavior.sideToPlay => sideToMove == orientation.opposite,
};

class HighlightsPainter extends CustomPainter {
  HighlightsPainter({
    required this.interactionNotifier,
    required this.squareSize,
    required this.orientation,
    required this.showLastMove,
    required this.premoveColor,
    required this.lastMoveDetails,
    required this.selectedDetails,
    required this.validMoveColor,
    required this.squareHighlights,
    required this.highlightImagesLoaded,
  }) : super(repaint: interactionNotifier);

  final BoardHighlightNotifier interactionNotifier;
  final double squareSize;
  final Side orientation;
  final bool showLastMove;
  final Color premoveColor;
  final HighlightDetails? lastMoveDetails;
  final HighlightDetails? selectedDetails;
  final Color validMoveColor;
  final Map<Square, HighlightDetails> squareHighlights;
  final bool highlightImagesLoaded;

  @override
  void paint(Canvas canvas, Size size) {
    final selected = interactionNotifier.selected;
    final moveDests = interactionNotifier.moveDests;
    final premoveDests = interactionNotifier.premoveDests;
    final lastMove = interactionNotifier.lastMove;
    final premove = interactionNotifier.premove;
    final checkSquare = interactionNotifier.checkSquare;

    if (showLastMove && lastMove != null) {
      for (final square in lastMove.squares) {
        if (premove == null || !premove.hasSquare(square)) {
          _drawHighlight(canvas, _squareRect(square, squareSize, orientation), lastMoveDetails);
        }
      }
    }

    if (premove != null) {
      final paint = Paint()..color = premoveColor;
      for (final square in premove.squares) {
        canvas.drawRect(_squareRect(square, squareSize, orientation), paint);
      }
    }

    if (selected != null) {
      _drawHighlight(canvas, _squareRect(selected, squareSize, orientation), selectedDetails);
    }

    for (final MapEntry(key: square, value: details) in squareHighlights.entries) {
      _drawHighlight(canvas, _squareRect(square, squareSize, orientation), details);
    }

    if (moveDests.isNotEmpty) {
      _drawDests(canvas, moveDests, validMoveColor);
    }
    if (premoveDests.isNotEmpty) {
      _drawDests(canvas, premoveDests, premoveColor);
    }

    if (checkSquare != null) {
      _drawCheck(canvas, checkSquare);
    }
  }

  void _drawHighlight(Canvas canvas, Rect rect, HighlightDetails? details) {
    if (details == null) return;
    if (details.solidColor != null) {
      canvas.drawRect(rect, Paint()..color = details.solidColor!);
    }
    if (details.image != null) {
      final image = ChessgroundImages.instance.get(details.image!);
      if (image != null) {
        final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
        canvas.drawImageRect(image, src, rect, Paint()..filterQuality = FilterQuality.medium);
      }
    }
  }

  void _drawDests(Canvas canvas, Iterable<Square> dests, Color color) {
    final fillPaint = Paint()..color = color;
    final strokePaint =
        Paint()
          ..color = color
          ..strokeWidth = squareSize / 5
          ..style = PaintingStyle.stroke;
    for (final dest in dests) {
      final rect = _squareRect(dest, squareSize, orientation);
      final center = rect.center;
      if (interactionNotifier.occupiedSquares.contains(dest)) {
        canvas.save();
        canvas.clipRect(rect);
        canvas.drawCircle(center, squareSize - (squareSize / 3), strokePaint);
        canvas.restore();
      } else {
        canvas.drawCircle(center, squareSize / 6, fillPaint);
      }
    }
  }

  void _drawCheck(Canvas canvas, Square square) {
    final rect = _squareRect(square, squareSize, orientation);
    final layerPaint = Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0);
    canvas.saveLayer(rect, layerPaint);
    const gradient = RadialGradient(
      radius: 0.6,
      colors: [Color(0xFFFF0000), Color(0xFFE70000), Color(0x00A90000), Color(0x009E0000)],
      stops: [0.0, 0.25, 0.90, 1.0],
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(HighlightsPainter oldDelegate) {
    return highlightImagesLoaded != oldDelegate.highlightImagesLoaded ||
        squareSize != oldDelegate.squareSize ||
        orientation != oldDelegate.orientation ||
        showLastMove != oldDelegate.showLastMove ||
        premoveColor != oldDelegate.premoveColor ||
        lastMoveDetails != oldDelegate.lastMoveDetails ||
        selectedDetails != oldDelegate.selectedDetails ||
        validMoveColor != oldDelegate.validMoveColor ||
        squareHighlights != oldDelegate.squareHighlights;
  }
}

class PiecesPainter extends CustomPainter {
  PiecesPainter({
    required this.piecesNotifier,
    required this.translatingPiecesNotifier,
    required this.pieceAssets,
    required this.squareSize,
    required this.orientation,
    required ValueNotifier<Square?>? draggedPieceSquareNotifier,
    required this.gameNotifier,
    required this.blindfoldMode,
    required this.pieceOrientationBehavior,
    required this.imagesLoaded,
  }) : _draggedPieceSquareNotifier = draggedPieceSquareNotifier,
       super(repaint: Listenable.merge([piecesNotifier, draggedPieceSquareNotifier, gameNotifier]));

  final ValueNotifier<Pieces> piecesNotifier;
  final ValueNotifier<TranslatingPieces> translatingPiecesNotifier;

  Pieces get pieces => piecesNotifier.value;

  final PieceAssets pieceAssets;
  final double squareSize;
  final Side orientation;
  final ValueNotifier<Square?>? _draggedPieceSquareNotifier;
  final ValueNotifier<GameData?> gameNotifier;
  final bool blindfoldMode;
  final PieceOrientationBehavior pieceOrientationBehavior;

  Square? get promotionMoveFrom => gameNotifier.value?.promotionMove?.from;
  Side? get sideToMove => gameNotifier.value?.sideToMove;

  /// Whether all piece images are available in the cache.
  ///
  /// Included in [shouldRepaint] so the painter redraws when images finish loading.
  final bool imagesLoaded;

  @override
  void paint(Canvas canvas, Size size) {
    if (blindfoldMode) return;

    final game = gameNotifier.value;
    final pieces = piecesNotifier.value;
    final translatingPieceSquares = translatingPiecesNotifier.value.keys.toSet();
    final draggedPieceSquare = _draggedPieceSquareNotifier?.value;
    final promotionMoveFrom = game?.promotionMove?.from;
    final sideToMove = game?.sideToMove;
    final paint = Paint()..filterQuality = FilterQuality.medium;
    for (final entry in pieces.entries) {
      final square = entry.key;
      if (translatingPieceSquares.contains(square) ||
          square == draggedPieceSquare ||
          square == promotionMoveFrom) {
        continue;
      }
      final asset = pieceAssets[entry.value.kind];
      if (asset == null) continue;
      final image = ChessgroundImages.instance.get(asset);
      if (image == null) continue;

      final dst = _squareRect(square, squareSize, orientation);
      final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
      if (_isUpsideDown(
        entry.value.color,
        behavior: pieceOrientationBehavior,
        orientation: orientation,
        sideToMove: sideToMove,
      )) {
        canvas.save();
        canvas.translate(dst.center.dx, dst.center.dy);
        canvas.rotate(pi);
        canvas.translate(-dst.center.dx, -dst.center.dy);
        canvas.drawImageRect(image, src, dst, paint);
        canvas.restore();
      } else {
        canvas.drawImageRect(image, src, dst, paint);
      }
    }
  }

  @override
  bool shouldRepaint(PiecesPainter oldDelegate) {
    return imagesLoaded != oldDelegate.imagesLoaded ||
        squareSize != oldDelegate.squareSize ||
        orientation != oldDelegate.orientation ||
        blindfoldMode != oldDelegate.blindfoldMode ||
        pieceAssets != oldDelegate.pieceAssets ||
        pieceOrientationBehavior != oldDelegate.pieceOrientationBehavior;
  }
}

/// Paints all fading-out pieces for the current animation frame.
///
/// Driven by [animation] as the repaint listenable — only [paint] runs per
/// frame, no widget rebuild.
class FadingPiecesPainter extends CustomPainter {
  FadingPiecesPainter({
    required this.fadingPiecesNotifier,
    required this.squareSize,
    required this.orientation,
    required this.pieceAssets,
    required this.blindfoldMode,
    required this.pieceOrientationBehavior,
    required this.gameNotifier,
    required Animation<double> animation,
  }) : _animation = animation,
       super(repaint: animation);

  final ValueNotifier<FadingPieces> fadingPiecesNotifier;

  FadingPieces get fadingPieces => fadingPiecesNotifier.value;

  final double squareSize;
  final Side orientation;
  final PieceAssets pieceAssets;
  final bool blindfoldMode;
  final PieceOrientationBehavior pieceOrientationBehavior;
  final ValueNotifier<GameData?> gameNotifier;
  final Animation<double> _animation;

  @override
  void paint(Canvas canvas, Size size) {
    final fadingPieces = fadingPiecesNotifier.value;
    if (blindfoldMode || fadingPieces.isEmpty) return;

    final sideToMove = gameNotifier.value?.sideToMove;
    final alpha = (255 * (1.0 - _animation.value)).round().clamp(0, 255);
    final paint =
        Paint()
          ..filterQuality = FilterQuality.medium
          ..color = Color.fromARGB(alpha, 255, 255, 255);

    for (final entry in fadingPieces.entries) {
      final square = entry.key;
      final piece = entry.value;

      final asset = pieceAssets[piece.kind];
      if (asset == null) continue;
      final image = ChessgroundImages.instance.get(asset);
      if (image == null) continue;

      final dst = _squareRect(square, squareSize, orientation);
      final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());

      if (_isUpsideDown(
        piece.color,
        behavior: pieceOrientationBehavior,
        orientation: orientation,
        sideToMove: sideToMove,
      )) {
        canvas.save();
        canvas.translate(dst.center.dx, dst.center.dy);
        canvas.rotate(pi);
        canvas.translate(-dst.center.dx, -dst.center.dy);
        canvas.drawImageRect(image, src, dst, paint);
        canvas.restore();
      } else {
        canvas.drawImageRect(image, src, dst, paint);
      }
    }
  }

  @override
  bool shouldRepaint(FadingPiecesPainter oldDelegate) {
    return squareSize != oldDelegate.squareSize ||
        orientation != oldDelegate.orientation ||
        blindfoldMode != oldDelegate.blindfoldMode ||
        pieceAssets != oldDelegate.pieceAssets ||
        pieceOrientationBehavior != oldDelegate.pieceOrientationBehavior;
  }
}

/// Paints all translating pieces for the current animation frame.
///
/// Driven by [animation] as the repaint listenable — only [paint] runs per
/// frame, no widget rebuild.
class TranslatingPiecesPainter extends CustomPainter {
  TranslatingPiecesPainter({
    required this.translatingPiecesNotifier,
    required this.squareSize,
    required this.orientation,
    required this.pieceAssets,
    required this.blindfoldMode,
    required this.pieceOrientationBehavior,
    required this.gameNotifier,
    required Animation<double> animation,
  }) : _animation = animation,
       super(repaint: animation);

  final ValueNotifier<TranslatingPieces> translatingPiecesNotifier;

  TranslatingPieces get translatingPieces => translatingPiecesNotifier.value;

  final double squareSize;
  final Side orientation;
  final PieceAssets pieceAssets;
  final bool blindfoldMode;
  final PieceOrientationBehavior pieceOrientationBehavior;
  final ValueNotifier<GameData?> gameNotifier;
  final Animation<double> _animation;

  @override
  void paint(Canvas canvas, Size size) {
    final translatingPieces = translatingPiecesNotifier.value;
    if (blindfoldMode || translatingPieces.isEmpty) return;

    final sideToMove = gameNotifier.value?.sideToMove;
    final t = _animation.value;
    final paint = Paint()..filterQuality = FilterQuality.medium;

    for (final entry in translatingPieces.entries) {
      final toSquare = entry.key;
      final fromSquare = entry.value.from;
      final piece = entry.value.piece;

      final asset = pieceAssets[piece.kind];
      if (asset == null) continue;
      final image = ChessgroundImages.instance.get(asset);
      if (image == null) continue;

      final orientationFactor = orientation == Side.white ? 1 : -1;
      final dx = -(toSquare.file - fromSquare.file).toDouble() * orientationFactor;
      final dy = (toSquare.rank - fromSquare.rank).toDouble() * orientationFactor;

      final toRect = _squareRect(toSquare, squareSize, orientation);
      final dst = Rect.fromLTWH(
        toRect.left + dx * squareSize * (1.0 - t),
        toRect.top + dy * squareSize * (1.0 - t),
        squareSize,
        squareSize,
      );
      final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());

      if (_isUpsideDown(
        piece.color,
        behavior: pieceOrientationBehavior,
        orientation: orientation,
        sideToMove: sideToMove,
      )) {
        canvas.save();
        canvas.translate(dst.center.dx, dst.center.dy);
        canvas.rotate(pi);
        canvas.translate(-dst.center.dx, -dst.center.dy);
        canvas.drawImageRect(image, src, dst, paint);
        canvas.restore();
      } else {
        canvas.drawImageRect(image, src, dst, paint);
      }
    }
  }

  @override
  bool shouldRepaint(TranslatingPiecesPainter oldDelegate) {
    return squareSize != oldDelegate.squareSize ||
        orientation != oldDelegate.orientation ||
        blindfoldMode != oldDelegate.blindfoldMode ||
        pieceAssets != oldDelegate.pieceAssets ||
        pieceOrientationBehavior != oldDelegate.pieceOrientationBehavior;
  }
}

class DragPiecePainter extends CustomPainter {
  DragPiecePainter({
    required this.image,
    required this.feedbackSize,
    required this.feedbackOffset,
    required this.upsideDown,
    required this.positionNotifier,
  }) : super(repaint: positionNotifier);

  final ui.Image? image;
  final double feedbackSize;
  final Offset feedbackOffset;
  final bool upsideDown;
  final ValueNotifier<Offset> positionNotifier;

  @override
  void paint(Canvas canvas, Size size) {
    final img = image;
    if (img == null) return;
    final pos = positionNotifier.value;
    final dst = Rect.fromLTWH(
      pos.dx + feedbackOffset.dx,
      pos.dy + feedbackOffset.dy,
      feedbackSize,
      feedbackSize,
    );
    final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
    final paint = Paint()..filterQuality = FilterQuality.medium;
    if (upsideDown) {
      canvas.save();
      canvas.translate(dst.center.dx, dst.center.dy);
      canvas.rotate(pi);
      canvas.translate(-dst.center.dx, -dst.center.dy);
      canvas.drawImageRect(img, src, dst, paint);
      canvas.restore();
    } else {
      canvas.drawImageRect(img, src, dst, paint);
    }
  }

  @override
  bool shouldRepaint(DragPiecePainter oldDelegate) {
    return image != oldDelegate.image ||
        feedbackSize != oldDelegate.feedbackSize ||
        feedbackOffset != oldDelegate.feedbackOffset ||
        upsideDown != oldDelegate.upsideDown;
  }
}

class DragSquareTargetPainter extends CustomPainter {
  DragSquareTargetPainter({
    required this.squareSize,
    required this.targetKind,
    required this.positionNotifier,
  }) : super(repaint: positionNotifier);

  final double squareSize;
  final DragTargetKind targetKind;
  final ValueNotifier<Offset?> positionNotifier;

  @override
  void paint(Canvas canvas, Size size) {
    final pos = positionNotifier.value;
    if (pos == null || targetKind == DragTargetKind.none) return;
    final paint =
        Paint()
          ..color = const Color(0x33000000)
          ..style = PaintingStyle.fill;
    if (targetKind == DragTargetKind.circle) {
      // pos is already offset by -squareSize/2 so the circle is centered on the square
      canvas.drawCircle(Offset(pos.dx + squareSize, pos.dy + squareSize), squareSize, paint);
    } else {
      canvas.drawRect(Rect.fromLTWH(pos.dx, pos.dy, squareSize, squareSize), paint);
    }
  }

  @override
  bool shouldRepaint(DragSquareTargetPainter oldDelegate) {
    return squareSize != oldDelegate.squareSize || targetKind != oldDelegate.targetKind;
  }
}
