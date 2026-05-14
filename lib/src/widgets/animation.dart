import 'package:dartchess/dartchess.dart';
import '../models.dart';

/// A Map of the pieces that are being translated on the board.
///
/// The keys are the squares the pieces are moving to, and the values are the pieces and the squares they are moving from.
typedef TranslatingPieces = Map<Square, ({Piece piece, Square from})>;

/// A Map of the pieces that are being faded out on the board.
///
/// Corresponds to the pieces that are no longer on the board after a position change.
typedef FadingPieces = Map<Square, Piece>;

/// Returns the pieces that need to be animated by comparing the old and new positions.
(TranslatingPieces, FadingPieces) preparePieceAnimations(
  Pieces oldPosition,
  Pieces newPosition, {
  Move? lastDrop,
}) {
  final Map<Square, ({Piece piece, Square from})> translatingPieces = {};
  final Map<Square, Piece> fadingPieces = {};
  final List<(Piece, Square)> newOnSquare = [];
  final List<(Piece, Square)> missingOnSquare = [];
  final Set<Square> animatedOrigins = {};
  for (final s in Square.values) {
    if ((lastDrop is NormalMove && s == lastDrop.from) || s == lastDrop?.to) {
      continue;
    }
    final oldP = oldPosition[s];
    final newP = newPosition[s];
    if (newP != null) {
      if (oldP != null) {
        if (newP != oldP) {
          missingOnSquare.add((oldP, s));
          newOnSquare.add((newP, s));
        }
      } else {
        newOnSquare.add((newP, s));
      }
    } else if (oldP != null) {
      missingOnSquare.add((oldP, s));
    }
  }
  for (final (newPiece, newPieceSquare) in newOnSquare) {
    // find the closest square that the piece was on before
    final fromSquare = _closestSquare(
      newPieceSquare,
      missingOnSquare.where((m) => m.$1 == newPiece).map((e) => e.$2),
    );
    if (fromSquare != null) {
      translatingPieces[newPieceSquare] = (piece: newPiece, from: fromSquare);
      animatedOrigins.add(fromSquare);
    }
  }
  for (final (missingPiece, missingPieceSquare) in missingOnSquare) {
    if (!animatedOrigins.contains(missingPieceSquare)) {
      fadingPieces[missingPieceSquare] = missingPiece;
    }
  }

  return (translatingPieces, fadingPieces);
}

/// Returns the closest square to the target square from a list of squares.
Square? _closestSquare(Square square, Iterable<Square> squares) {
  if (squares.isEmpty) return null;
  return squares.reduce((a, b) {
    final aDist = _distanceSq(square, a);
    final bDist = _distanceSq(square, b);
    return aDist < bDist ? a : b;
  });
}

int _distanceSq(Square pos1, Square pos2) {
  final dx = pos1.file - pos2.file;
  final dy = pos1.rank - pos2.rank;
  return dx * dx + dy * dy;
}

