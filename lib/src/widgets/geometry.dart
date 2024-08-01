import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';

/// A mixin that provides geometry information about the chessboard.
mixin ChessboardGeometry {
  /// Visual size of the board.
  double get size;

  /// Side by which the board is oriented.
  Side get orientation;

  /// Size of a single square on the board.
  double get squareSize => size / 8;

  /// Converts a coordinate to a board offset.
  Offset coordOffset(Coord coord) {
    final x = orientation == Side.black ? 7 - coord.file : coord.file;
    final y = orientation == Side.black ? coord.rank : 7 - coord.rank;
    return Offset(x * squareSize, y * squareSize);
  }

  /// Converts a board offset to a coordinate.
  ///
  /// Returns `null` if the offset is outside the board.
  Coord? offsetCoord(Offset offset) {
    final x = (offset.dx / squareSize).floor();
    final y = (offset.dy / squareSize).floor();
    final orientX = orientation == Side.black ? 7 - x : x;
    final orientY = orientation == Side.black ? y : 7 - y;
    if (orientX >= 0 && orientX <= 7 && orientY >= 0 && orientY <= 7) {
      return Coord(orientX, orientY);
    } else {
      return null;
    }
  }

  /// Converts a board offset to a square id.
  ///
  /// Returns `null` if the offset is outside the board.
  Square? offsetSquare(Offset offset) {
    final x = (offset.dx / squareSize).floor();
    final y = (offset.dy / squareSize).floor();
    final orientX = orientation == Side.black ? 7 - x : x;
    final orientY = orientation == Side.black ? y : 7 - y;
    if (orientX >= 0 && orientX <= 7 && orientY >= 0 && orientY <= 7) {
      return Square.fromCoords(File(orientX), Rank(orientY));
    } else {
      return null;
    }
  }
}
