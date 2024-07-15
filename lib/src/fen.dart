import 'package:flutter/widgets.dart';
import 'models.dart';

/// Parse the board part of a FEN string.
Pieces readFen(String fen) {
  final Pieces pieces = {};
  int row = 7;
  int col = 0;
  for (final c in fen.characters) {
    switch (c) {
      case ' ':
      case '[':
        return pieces;
      case '/':
        --row;
        if (row < 0) return pieces;
        col = 0;
      case '~':
        final sid = Coord(x: col - 1, y: row).squareId;
        final piece = pieces[sid];
        if (piece != null) {
          pieces[sid] = piece.copyWith(promoted: true);
        }
      default:
        final code = c.codeUnitAt(0);
        if (code < 57) {
          col += code - 48;
        } else {
          final roleLetter = c.toLowerCase();
          final sid = Coord(x: col, y: row).squareId;
          pieces[sid] = Piece(
            role: _roles[roleLetter]!,
            color: c == roleLetter ? Side.black : Side.white,
          );
          ++col;
        }
    }
  }
  return pieces;
}

/// Convert the pieces to the board part of a FEN string
String writeFen(Pieces pieces) {
  final buffer = StringBuffer();
  int empty = 0;
  for (int rank = 7; rank >= 0; rank--) {
    for (int file = 0; file < 8; file++) {
      final piece = pieces[Coord(x: file, y: rank).squareId];
      if (piece == null) {
        empty++;
      } else {
        if (empty > 0) {
          buffer.write(empty.toString());
          empty = 0;
        }
        buffer.write(
          piece.color == Side.white
              ? piece.role.letter.toUpperCase()
              : piece.role.letter.toLowerCase(),
        );
      }

      if (file == 7) {
        if (empty > 0) {
          buffer.write(empty.toString());
          empty = 0;
        }
        if (rank != 0) buffer.write('/');
      }
    }
  }
  return buffer.toString();
}

const _roles = {
  'p': Role.pawn,
  'r': Role.rook,
  'n': Role.knight,
  'b': Role.bishop,
  'q': Role.queen,
  'k': Role.king,
};
