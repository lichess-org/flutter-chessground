import 'dart:math' show pi;
import 'dart:ui' as ui;

import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../images.dart';
import '../models.dart';
import 'animation.dart';

/// Holds the board's interactive highlight state and notifies [HighlightsPainter]
/// to repaint without triggering a widget rebuild.
class BoardHighlightNotifier extends ChangeNotifier {
  Square? selected;
  ISet<Square> moveDests = const ISetConst({});
  Set<Square> premoveDests = const {};

  void update({
    required Square? selected,
    required ISet<Square> moveDests,
    required Set<Square> premoveDests,
  }) {
    this.selected = selected;
    this.moveDests = moveDests;
    this.premoveDests = premoveDests;
    notifyListeners();
  }
}

Rect _squareRect(Square square, double squareSize, Side orientation) {
  final x = orientation == Side.black ? 7 - square.file : square.file;
  final y = orientation == Side.black ? square.rank : 7 - square.rank;
  return Rect.fromLTWH(x * squareSize, y * squareSize, squareSize, squareSize);
}

class HighlightsPainter extends CustomPainter {
  HighlightsPainter({
    required this.interactionNotifier,
    required this.squareSize,
    required this.orientation,
    required this.showLastMove,
    required this.lastMove,
    required this.premove,
    required this.premoveColor,
    required this.lastMoveDetails,
    required this.selectedDetails,
    required this.validMoveColor,
    required this.occupiedSquares,
    required this.checkSquare,
    required this.squareHighlights,
    required this.highlightImagesLoaded,
  }) : super(repaint: interactionNotifier);

  final BoardHighlightNotifier interactionNotifier;
  final double squareSize;
  final Side orientation;
  final bool showLastMove;
  final Move? lastMove;
  final Move? premove;
  final Color premoveColor;
  final HighlightDetails? lastMoveDetails;
  final HighlightDetails? selectedDetails;
  final Color validMoveColor;
  final Set<Square> occupiedSquares;
  final Square? checkSquare;
  final IMap<Square, HighlightDetails> squareHighlights;
  final bool highlightImagesLoaded;

  @override
  void paint(Canvas canvas, Size size) {
    final selected = interactionNotifier.selected;
    final moveDests = interactionNotifier.moveDests;
    final premoveDests = interactionNotifier.premoveDests;

    if (showLastMove && lastMove != null) {
      for (final square in lastMove!.squares) {
        if (premove == null || !premove!.hasSquare(square)) {
          _drawHighlight(canvas, _squareRect(square, squareSize, orientation), lastMoveDetails);
        }
      }
    }

    if (premove != null) {
      final paint = Paint()..color = premoveColor;
      for (final square in premove!.squares) {
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
      _drawCheck(canvas, checkSquare!);
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
      if (occupiedSquares.contains(dest)) {
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
        lastMove != oldDelegate.lastMove ||
        premove != oldDelegate.premove ||
        premoveColor != oldDelegate.premoveColor ||
        lastMoveDetails != oldDelegate.lastMoveDetails ||
        selectedDetails != oldDelegate.selectedDetails ||
        validMoveColor != oldDelegate.validMoveColor ||
        !_setEquals(occupiedSquares, oldDelegate.occupiedSquares) ||
        checkSquare != oldDelegate.checkSquare ||
        squareHighlights != oldDelegate.squareHighlights;
  }
}

class PiecesPainter extends CustomPainter {
  PiecesPainter({
    required this.pieces,
    required this.pieceAssets,
    required this.squareSize,
    required this.orientation,
    required this.draggedPieceSquare,
    required this.translatingPieceSquares,
    required this.promotionMoveFrom,
    required this.blindfoldMode,
    required this.upsideDownSquares,
    required this.imagesLoaded,
  });

  final Pieces pieces;
  final PieceAssets pieceAssets;
  final double squareSize;
  final Side orientation;
  final Square? draggedPieceSquare;
  final Set<Square> translatingPieceSquares;
  final Square? promotionMoveFrom;
  final bool blindfoldMode;
  final Set<Square> upsideDownSquares;

  /// Whether all piece images are available in the cache.
  ///
  /// Included in [shouldRepaint] so the painter redraws when images finish loading.
  final bool imagesLoaded;

  @override
  void paint(Canvas canvas, Size size) {
    if (blindfoldMode) return;

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
      if (upsideDownSquares.contains(square)) {
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
        draggedPieceSquare != oldDelegate.draggedPieceSquare ||
        promotionMoveFrom != oldDelegate.promotionMoveFrom ||
        blindfoldMode != oldDelegate.blindfoldMode ||
        pieceAssets != oldDelegate.pieceAssets ||
        !_mapEquals(pieces, oldDelegate.pieces) ||
        !_setEquals(translatingPieceSquares, oldDelegate.translatingPieceSquares) ||
        !_setEquals(upsideDownSquares, oldDelegate.upsideDownSquares);
  }
}

/// Paints all fading-out pieces for the current animation frame.
///
/// Driven by [animation] as the repaint listenable — only [paint] runs per
/// frame, no widget rebuild.
class FadingPiecesPainter extends CustomPainter {
  FadingPiecesPainter({
    required this.fadingPieces,
    required this.squareSize,
    required this.orientation,
    required this.pieceAssets,
    required this.blindfoldMode,
    required this.upsideDownSquares,
    required Animation<double> animation,
  }) : _animation = animation,
       super(repaint: animation);

  final FadingPieces fadingPieces;
  final double squareSize;
  final Side orientation;
  final PieceAssets pieceAssets;
  final bool blindfoldMode;
  final Set<Square> upsideDownSquares;
  final Animation<double> _animation;

  @override
  void paint(Canvas canvas, Size size) {
    if (blindfoldMode || fadingPieces.isEmpty) return;

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

      if (upsideDownSquares.contains(square)) {
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
        !_mapEquals(fadingPieces, oldDelegate.fadingPieces) ||
        !_setEquals(upsideDownSquares, oldDelegate.upsideDownSquares);
  }
}

/// Paints all translating pieces for the current animation frame.
///
/// Driven by [animation] as the repaint listenable — only [paint] runs per
/// frame, no widget rebuild.
class TranslatingPiecesPainter extends CustomPainter {
  TranslatingPiecesPainter({
    required this.translatingPieces,
    required this.squareSize,
    required this.orientation,
    required this.pieceAssets,
    required this.blindfoldMode,
    required this.upsideDownSquares,
    required Animation<double> animation,
  }) : _animation = animation,
       super(repaint: animation);

  final TranslatingPieces translatingPieces;
  final double squareSize;
  final Side orientation;
  final PieceAssets pieceAssets;
  final bool blindfoldMode;
  final Set<Square> upsideDownSquares;
  final Animation<double> _animation;

  @override
  void paint(Canvas canvas, Size size) {
    if (blindfoldMode || translatingPieces.isEmpty) return;

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

      if (upsideDownSquares.contains(toSquare)) {
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
        !_mapEquals(translatingPieces, oldDelegate.translatingPieces) ||
        !_setEquals(upsideDownSquares, oldDelegate.upsideDownSquares);
  }
}

bool _setEquals<T>(Set<T> a, Set<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final v in a) {
    if (!b.contains(v)) return false;
  }
  return true;
}

bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key) || b[entry.key] != entry.value) return false;
  }
  return true;
}
