import 'package:meta/meta.dart';

enum Color { white, black }
enum PieceRole { king, queen, knight, bishop, rook, pawn }

@immutable
class Piece {
  final Color color;
  final PieceRole role;

  String get kind => '${color.name}_${role.name}';

  const Piece({
    required this.color,
    required this.role,
  });
}
