import 'package:flutter/material.dart';
import 'models.dart' as cg;

const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
const ranks = ['1', '2', '3', '4', '5', '6', '7', '8'];
final allSquares = List.unmodifiable([
  for (final f in files)
    for (final r in ranks) '$f$r'
]);

cg.SquareId coord2SquareId(cg.Coord coord) {
  return allSquares[8 * coord.x + coord.y];
}

cg.Coord squareId2Coord(cg.SquareId id) {
  return cg.Coord(
    x: id.codeUnitAt(0) - 97,
    y: id.codeUnitAt(1) - 49,
  );
}

Offset coord2Offset(cg.Coord coord, cg.Color orientation, double squareSize) {
  final dx =
      (orientation == cg.Color.black ? 7 - coord.x : coord.x) * squareSize;
  final dy =
      (orientation == cg.Color.black ? coord.y : 7 - coord.y) * squareSize;
  return Offset(dx, dy);
}

int distanceSq(cg.Coord pos1, cg.Coord pos2) {
  final dx = pos1.x - pos2.x, dy = pos1.y - pos2.y;
  return dx * dx + dy * dy;
}

cg.PositionedPiece? closestPiece(
    cg.PositionedPiece piece, List<cg.PositionedPiece> pieces) {
  pieces.sort((p1, p2) =>
      distanceSq(piece.coord, p1.coord) - distanceSq(piece.coord, p2.coord));
  return pieces.isNotEmpty ? pieces[0] : null;
}
