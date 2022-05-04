import 'package:meta/meta.dart';

enum Color { white, black }
enum PieceRole { king, queen, knight, bishop, rook, pawn }

typedef SquareId = String;
typedef Pieces = Map<String, Piece>;

/// Board coordinates, index starting at 0
@immutable
class Coord {
  final int x;
  final int y;

  const Coord({
    required this.x,
    required this.y,
  })  : assert(x >= 0 && x <= 7),
        assert(y >= 0 && y <= 7);
}

@immutable
class Piece {
  final Color color;
  final PieceRole role;
  final bool promoted;

  String get kind => '${color.name}_${role.name}';

  const Piece({
    required this.color,
    required this.role,
    this.promoted = false,
  });

  Piece copyWith({
    Color? color,
    PieceRole? role,
    bool? promoted,
  }) {
    return Piece(
      color: color ?? this.color,
      role: role ?? this.role,
      promoted: promoted ?? this.promoted,
    );
  }
}
