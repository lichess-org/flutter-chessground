import 'dart:ui' show hashValues;
import 'package:meta/meta.dart';

enum Color { white, black }

enum PieceRole { king, queen, knight, bishop, rook, pawn }

/// Square identifier such as e2, c3, etc.
typedef SquareId = String;

/// Representation of the pieces on a board
typedef Pieces = Map<SquareId, Piece>;

/// Sets of each valid destinations for an origin square
typedef ValidMoves = Map<SquareId, Set<SquareId>>;

/// Board coordinates starting at 0, independant from board orientation
@immutable
class Coord {
  final int x;
  final int y;

  const Coord({
    required this.x,
    required this.y,
  })  : assert(x >= 0 && x <= 7),
        assert(y >= 0 && y <= 7);

  @override
  toString() {
    return '($x, $y)';
  }
}

@immutable
class Piece {
  const Piece({
    required this.color,
    required this.role,
    this.promoted = false,
  });

  final Color color;
  final PieceRole role;
  final bool promoted;

  String get kind => '${color.name}_${role.name}';
  String get roleLetter {
    return role == PieceRole.king
        ? 'K'
        : role == PieceRole.queen
            ? 'Q'
            : role == PieceRole.rook
                ? 'R'
                : role == PieceRole.bishop
                    ? 'B'
                    : role == PieceRole.knight
                        ? 'K'
                        : 'P';
  }

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

  @override
  toString() {
    return kind;
  }

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && hashCode == other.hashCode;
  }

  @override
  int get hashCode => hashValues(color, role);
}

@immutable
class PositionedPiece {
  const PositionedPiece({
    required this.piece,
    required this.squareId,
    required this.coord,
  });

  final Piece piece;
  final SquareId squareId;
  final Coord coord;
}

@immutable
class Move {
  const Move({
    required this.from,
    required this.to,
    this.promotion,
  });

  final SquareId from;
  final SquareId to;
  final Piece? promotion;

  List<SquareId> get squares => List.unmodifiable([from, to]);

  String get uci => '$from$to${promotion?.roleLetter ?? ''}';

  Move withPromotion(Piece promotion) {
    return Move(
      from: from,
      to: to,
      promotion: promotion,
    );
  }

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && hashCode == other.hashCode;
  }

  @override
  int get hashCode => hashValues(from, to, promotion);
}
