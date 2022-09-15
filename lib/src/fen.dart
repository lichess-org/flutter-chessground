import 'package:flutter/material.dart';
import 'models.dart' as cg;

cg.Pieces readFen(String fen) {
  final cg.Pieces pieces = {};
  var row = 7, col = 0;
  for (final c in fen.characters) {
    switch (c) {
      case ' ':
      case '[':
        return pieces;
      case '/':
        --row;
        if (row < 0) return pieces;
        col = 0;
        break;
      case '~':
        final sid = cg.Coord(x: col - 1, y: row).squareId;
        final piece = pieces[sid];
        if (piece != null) {
          pieces[sid] = piece.copyWith(promoted: true);
        }
        break;
      default:
        final code = c.codeUnitAt(0);
        if (code < 57) {
          col += code - 48;
        } else {
          final roleLetter = c.toLowerCase();
          final sid = cg.Coord(x: col, y: row).squareId;
          pieces[sid] = cg.Piece(
            role: _roles[roleLetter]!,
            color: c == roleLetter ? cg.Color.black : cg.Color.white,
          );
          ++col;
        }
    }
  }
  return pieces;
}

const _roles = {
  'p': cg.PieceRole.pawn,
  'r': cg.PieceRole.rook,
  'n': cg.PieceRole.knight,
  'b': cg.PieceRole.bishop,
  'q': cg.PieceRole.queen,
  'k': cg.PieceRole.king,
};
