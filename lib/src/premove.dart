import './models.dart';

Set<SquareId> premovesOf(
  SquareId square,
  Pieces pieces, {
  bool canCastle = false,
}) {
  final piece = pieces[square];
  if (piece == null) return {};
  final coord = Coord.fromSquareId(square);
  final r = piece.role;
  final mobility = r == Role.pawn
      ? _pawn(piece.color)
      : r == Role.knight
          ? _knight
          : r == Role.bishop
              ? _bishop
              : r == Role.rook
                  ? _rook
                  : r == Role.queen
                      ? _queen
                      : _king(
                          piece.color,
                          _rookFilesOf(pieces, piece.color),
                          canCastle,
                        );

  return Set.unmodifiable({
    for (final coord2 in allCoords)
      if ((coord.x != coord2.x || coord.y != coord2.y) &&
          mobility(coord.x, coord.y, coord2.x, coord2.y))
        coord2.squareId
  });
}

typedef _Mobility = bool Function(int x1, int y1, int x2, int y2);

int _diff(int a, int b) {
  return (a - b).abs();
}

_Mobility _pawn(Side color) {
  return (int x1, int y1, int x2, int y2) =>
      _diff(x1, x2) < 2 &&
      (color == Side.white
          ? y2 == y1 + 1 || (y1 <= 1 && y2 == y1 + 2 && x1 == x2)
          : y2 == y1 - 1 || (y1 >= 6 && y2 == y1 - 2 && x1 == x2));
}

bool _knight(int x1, int y1, int x2, int y2) {
  final xd = _diff(x1, x2);
  final yd = _diff(y1, y2);
  return (xd == 1 && yd == 2) || (xd == 2 && yd == 1);
}

bool _bishop(int x1, int y1, int x2, int y2) {
  return _diff(x1, x2) == _diff(y1, y2);
}

bool _rook(int x1, int y1, int x2, int y2) {
  return x1 == x2 || y1 == y2;
}

bool _queen(int x1, int y1, int x2, int y2) {
  return _bishop(x1, y1, x2, y2) || _rook(x1, y1, x2, y2);
}

_Mobility _king(Side color, List<int> rookFiles, bool canCastle) {
  return (int x1, int y1, int x2, int y2) =>
      (_diff(x1, x2) < 2 && _diff(y1, y2) < 2) ||
      (canCastle &&
          y1 == y2 &&
          y1 == (color == Side.white ? 0 : 7) &&
          ((x1 == 4 &&
                  ((x2 == 2 && rookFiles.contains(0)) ||
                      (x2 == 6 && rookFiles.contains(7)))) ||
              rookFiles.contains(x2)));
}

List<int> _rookFilesOf(Pieces pieces, Side color) {
  final backrank = color == Side.white ? '1' : '8';
  final List<int> files = [];
  for (final entry in pieces.entries) {
    if (entry.key[1] == backrank &&
        entry.value.color == color &&
        entry.value.role == Role.rook) {
      files.add(Coord.fromSquareId(entry.key).x);
    }
  }
  return files;
}
