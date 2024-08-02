import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';
import 'models.dart';

/// Parses the board part of a FEN string.
Pieces readFen(String fen) {
  final Pieces pieces = {};
  int rank = 7;
  int file = 0;
  for (final c in fen.characters) {
    switch (c) {
      case ' ':
      case '[':
        return pieces;
      case '/':
        --rank;
        if (rank < 0) return pieces;
        file = 0;
      case '~':
        final square = Square.fromCoords(File(file - 1), Rank(rank));
        final piece = pieces[square];
        if (piece != null) {
          pieces[square] = piece.copyWith(promoted: true);
        }
      default:
        final code = c.codeUnitAt(0);
        if (code < 57) {
          file += code - 48;
        } else {
          final roleLetter = c.toLowerCase();
          final square = Square.fromCoords(File(file), Rank(rank));
          pieces[square] = Piece(
            role: _roles[roleLetter]!,
            color: c == roleLetter ? Side.black : Side.white,
          );
          ++file;
        }
    }
  }
  return pieces;
}

/// Converts the pieces to the board part of a FEN string.
String writeFen(Pieces pieces) {
  final buffer = StringBuffer();
  int empty = 0;
  for (int rank = 7; rank >= 0; rank--) {
    for (int file = 0; file < 8; file++) {
      final piece = pieces[Square.fromCoords(File(file), Rank(rank))];
      if (piece == null) {
        empty++;
      } else {
        if (empty > 0) {
          buffer.write(empty.toString());
          empty = 0;
        }
        buffer.write(
          piece.color == Side.white
              ? piece.role.uppercaseLetter
              : piece.role.letter,
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
