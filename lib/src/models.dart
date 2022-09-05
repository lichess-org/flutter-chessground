import 'package:flutter/material.dart';

enum Color { white, black }

enum InteractableColor { both, none, white, black }

enum PieceRole { king, queen, knight, bishop, rook, pawn }

/// Describes a set of piece assets
///
/// The Map keys must be the concatenation of role and color. Eg: 'blackpawn'.
typedef PieceSet = Map<String, AssetImage>;

/// Square identifier such as e2, c3, etc.
typedef SquareId = String;

/// Representation of the pieces on a board
typedef Pieces = Map<SquareId, Piece>;

/// Sets of each valid destinations for an origin square
typedef ValidMoves = Map<SquareId, Set<SquareId>>;

const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
const ranks = ['1', '2', '3', '4', '5', '6', '7', '8'];
final List<SquareId> allSquares = List.unmodifiable([
  for (final f in files)
    for (final r in ranks) '$f$r'
]);

/// Zero-based numeric board coordinates
///
/// For instance a1 is (0, 0), a2 is (0, 1), etc.
@immutable
class Coord {
  const Coord({
    required this.x,
    required this.y,
  })  : assert(x >= 0 && x <= 7),
        assert(y >= 0 && y <= 7);

  Coord.fromSquareId(SquareId id)
      : x = id.codeUnitAt(0) - 97,
        y = id.codeUnitAt(1) - 49;

  final int x;
  final int y;

  @override
  toString() {
    return '($x, $y)';
  }

  SquareId squareId() {
    return allSquares[8 * x + y];
  }

  Offset offset(Color orientation, double squareSize) {
    final dx = (orientation == Color.black ? 7 - x : x) * squareSize;
    final dy = (orientation == Color.black ? y : 7 - y) * squareSize;
    return Offset(dx, dy);
  }

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && hashCode == other.hashCode;
  }

  @override
  int get hashCode => hashValues(x, y);
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

  String get kind => '${color.name}${role.name}';

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

  PositionedPiece? closest(List<PositionedPiece> pieces) {
    pieces.sort((p1, p2) => _distanceSq(coord, p1.coord) - _distanceSq(coord, p2.coord));
    return pieces.isNotEmpty ? pieces[0] : null;
  }

  int _distanceSq(Coord pos1, Coord pos2) {
    final dx = pos1.x - pos2.x, dy = pos1.y - pos2.y;
    return dx * dx + dy * dy;
  }
}

@immutable
class Move {
  const Move({
    required this.from,
    required this.to,
    this.promotion,
  });

  Move.fromUci(String uci)
      : from = uci.substring(0, 2),
        to = uci.substring(2, 4),
        promotion = uci.length > 4 ? _toRole(uci.substring(4)) : null;

  final SquareId from;
  final SquareId to;
  final PieceRole? promotion;

  List<SquareId> get squares => List.unmodifiable([from, to]);

  String get uci => '$from$to${_toPieceLetter(promotion)}';

  Move withPromotion(PieceRole promotion) {
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

  String _toPieceLetter(PieceRole? role) {
    switch (role) {
      case PieceRole.king:
        return 'k';
      case PieceRole.queen:
        return 'q';
      case PieceRole.rook:
        return 'r';
      case PieceRole.bishop:
        return 'b';
      case PieceRole.knight:
        return 'n';
      case PieceRole.pawn:
        return 'p';
      default:
        return '';
    }
  }
}

PieceRole _toRole(String uciLetter) {
  switch (uciLetter.trim().toLowerCase()) {
    case 'k':
      return PieceRole.king;
    case 'q':
      return PieceRole.queen;
    case 'r':
      return PieceRole.rook;
    case 'b':
      return PieceRole.bishop;
    case 'n':
      return PieceRole.knight;
    default:
      return PieceRole.pawn;
  }
}
