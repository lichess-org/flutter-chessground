import 'package:dartchess/dartchess.dart';

import './models.dart';

/// Returns the read-only set of squares that the piece on [square] can potentially premove to.
Set<Square> premovesOf(Square square, Pieces pieces, {bool canCastle = false}) {
  final piece = pieces[square];
  if (piece == null) return {};
  final r = piece.role;

  final mobility =
      (() {
        switch (r) {
          case Role.pawn:
            return _pawn(piece.color);
          case Role.knight:
            return _knight;
          case Role.bishop:
            return _bishop;
          case Role.rook:
            return _rook;
          case Role.queen:
            return _queen;
          case Role.king:
            return _king(
              piece.color,
              _rookFilesOf(pieces, piece.color),
              canCastle,
            );
        }
      })();

  return Set.unmodifiable({
    for (final s in Square.values)
      if ((square.file != s.file || square.rank != s.rank) &&
          mobility(square.file, square.rank, s.file, s.rank))
        s,
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

_Mobility _king(Side color, List<File> rookFiles, bool canCastle) {
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

List<File> _rookFilesOf(Pieces pieces, Side color) {
  final backrank = color == Side.white ? Rank.first : Rank.eighth;
  final List<File> files = [];
  for (final entry in pieces.entries) {
    if (entry.key.rank == backrank &&
        entry.value.color == color &&
        entry.value.role == Role.rook) {
      files.add(entry.key.file);
    }
  }
  return files;
}
