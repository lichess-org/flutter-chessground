import 'dart:ui' as ui;

import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';

import '../images.dart';
import '../models.dart';

Rect _squareRect(Square square, double squareSize, Side orientation) {
  final x = orientation == Side.black ? 7 - square.file : square.file;
  final y = orientation == Side.black ? square.rank : 7 - square.rank;
  return Rect.fromLTWH(x * squareSize, y * squareSize, squareSize, squareSize);
}

class HighlightsPainter extends CustomPainter {
  HighlightsPainter({
    required this.squareSize,
    required this.orientation,
    required this.showLastMove,
    required this.lastMove,
    required this.premove,
    required this.premoveColor,
    required this.lastMoveColor,
    required this.selected,
    required this.selectedColor,
    required this.moveDests,
    required this.premoveDests,
    required this.validMoveColor,
    required this.occupiedSquares,
    required this.checkSquare,
    required this.squareHighlights,
  });

  final double squareSize;
  final Side orientation;
  final bool showLastMove;
  final Move? lastMove;
  final Move? premove;
  final Color premoveColor;
  final Color? lastMoveColor;
  final Square? selected;
  final Color? selectedColor;
  final ISet<Square> moveDests;
  final Set<Square> premoveDests;
  final Color validMoveColor;
  final Set<Square> occupiedSquares;
  final Square? checkSquare;
  final IMap<Square, Color> squareHighlights;

  @override
  void paint(Canvas canvas, Size size) {
    if (showLastMove && lastMove != null && lastMoveColor != null) {
      final paint = Paint()..color = lastMoveColor!;
      for (final square in lastMove!.squares) {
        if (premove == null || !premove!.hasSquare(square)) {
          canvas.drawRect(_squareRect(square, squareSize, orientation), paint);
        }
      }
    }

    if (premove != null) {
      final paint = Paint()..color = premoveColor;
      for (final square in premove!.squares) {
        canvas.drawRect(_squareRect(square, squareSize, orientation), paint);
      }
    }

    if (selected != null && selectedColor != null) {
      final paint = Paint()..color = selectedColor!;
      canvas.drawRect(_squareRect(selected!, squareSize, orientation), paint);
    }

    for (final MapEntry(key: square, value: color) in squareHighlights.entries) {
      canvas.drawRect(_squareRect(square, squareSize, orientation), Paint()..color = color);
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
    return squareSize != oldDelegate.squareSize ||
        orientation != oldDelegate.orientation ||
        showLastMove != oldDelegate.showLastMove ||
        lastMove != oldDelegate.lastMove ||
        premove != oldDelegate.premove ||
        premoveColor != oldDelegate.premoveColor ||
        lastMoveColor != oldDelegate.lastMoveColor ||
        selected != oldDelegate.selected ||
        selectedColor != oldDelegate.selectedColor ||
        moveDests != oldDelegate.moveDests ||
        !_setEquals(premoveDests, oldDelegate.premoveDests) ||
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
        canvas.rotate(3.141592653589793);
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
    return squareSize != oldDelegate.squareSize ||
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
