import 'models.dart' as cg;

const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
const ranks = ['1', '2', '3', '4', '5', '6', '7', '8'];
final allSquares = List.unmodifiable([for (var f in files) for (var r in ranks) '$f$r']);

cg.SquareId coord2SquareId(cg.Coord coord) {
  return allSquares[8 * coord.x + coord.y];
}
