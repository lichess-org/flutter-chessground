import 'package:flutter/widgets.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

enum Side {
  white,
  black;

  Side get opposite => this == Side.white ? Side.black : Side.white;
}

enum InteractableSide { both, none, white, black }

enum Role { king, queen, knight, bishop, rook, pawn }

enum PieceKind {
  whitePawn,
  whiteKnight,
  whiteBishop,
  whiteRook,
  whiteQueen,
  whiteKing,
  blackPawn,
  blackKnight,
  blackBishop,
  blackRook,
  blackQueen,
  blackKing;

  static PieceKind fromPiece(Piece piece) {
    switch (piece.role) {
      case Role.pawn:
        return piece.color == Side.white
            ? PieceKind.whitePawn
            : PieceKind.blackPawn;
      case Role.knight:
        return piece.color == Side.white
            ? PieceKind.whiteKnight
            : PieceKind.blackKnight;
      case Role.bishop:
        return piece.color == Side.white
            ? PieceKind.whiteBishop
            : PieceKind.blackBishop;
      case Role.rook:
        return piece.color == Side.white
            ? PieceKind.whiteRook
            : PieceKind.blackRook;
      case Role.queen:
        return piece.color == Side.white
            ? PieceKind.whiteQueen
            : PieceKind.blackQueen;
      case Role.king:
        return piece.color == Side.white
            ? PieceKind.whiteKing
            : PieceKind.blackKing;
    }
  }
}

/// Describes a set of piece assets.
///
/// The Map keys must be the concatenation of role and color. Eg: 'blackpawn'.
/// The [PieceAssets] must be complete with all the pieces for both sides.
typedef PieceAssets = IMap<PieceKind, AssetImage>;

/// Square identifier using the algebraic coordinate notation such as e2, c3, etc.
typedef SquareId = String;

/// Representation of the pieces on a board
typedef Pieces = Map<SquareId, Piece>;

/// Sets of each valid destinations for an origin square
typedef ValidMoves = IMap<SquareId, ISet<SquareId>>;

const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
const ranks = ['1', '2', '3', '4', '5', '6', '7', '8'];
final List<SquareId> allSquares = List.unmodifiable([
  for (final f in files)
    for (final r in ranks) '$f$r'
]);
final List<Coord> allCoords = List.unmodifiable([
  for (final f in files)
    for (final r in ranks) Coord.fromSquareId('$f$r')
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

  SquareId get squareId => allSquares[8 * x + y];

  Offset offset(Side orientation, double squareSize) {
    final dx = (orientation == Side.black ? 7 - x : x) * squareSize;
    final dy = (orientation == Side.black ? y : 7 - y) * squareSize;
    return Offset(dx, dy);
  }

  @override
  String toString() {
    return '($x, $y)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Coord &&
            other.runtimeType == runtimeType &&
            other.x == x &&
            other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}

@immutable
class Piece {
  const Piece({
    required this.color,
    required this.role,
    this.promoted = false,
  });

  final Side color;
  final Role role;
  final bool promoted;

  PieceKind get kind => PieceKind.fromPiece(this);

  Piece copyWith({
    Side? color,
    Role? role,
    bool? promoted,
  }) {
    return Piece(
      color: color ?? this.color,
      role: role ?? this.role,
      promoted: promoted ?? this.promoted,
    );
  }

  @override
  String toString() {
    return 'Piece(${kind.name})';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Piece &&
            other.runtimeType == runtimeType &&
            other.color == color &&
            other.role == role &&
            other.promoted == promoted;
  }

  @override
  int get hashCode => Object.hash(color, role, promoted);

  static const whitePawn = Piece(color: Side.white, role: Role.pawn);
  static const whiteKnight = Piece(color: Side.white, role: Role.knight);
  static const whiteBishop = Piece(color: Side.white, role: Role.bishop);
  static const whiteRook = Piece(color: Side.white, role: Role.rook);
  static const whiteQueen = Piece(color: Side.white, role: Role.queen);
  static const whiteKing = Piece(color: Side.white, role: Role.king);

  static const blackPawn = Piece(color: Side.black, role: Role.pawn);
  static const blackKnight = Piece(color: Side.black, role: Role.knight);
  static const blackBishop = Piece(color: Side.black, role: Role.bishop);
  static const blackRook = Piece(color: Side.black, role: Role.rook);
  static const blackQueen = Piece(color: Side.black, role: Role.queen);
  static const blackKing = Piece(color: Side.black, role: Role.king);
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
    pieces.sort(
      (p1, p2) => _distanceSq(coord, p1.coord) - _distanceSq(coord, p2.coord),
    );
    return pieces.isNotEmpty ? pieces[0] : null;
  }

  int _distanceSq(Coord pos1, Coord pos2) {
    final dx = pos1.x - pos2.x;
    final dy = pos1.y - pos2.y;
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
  final Role? promotion;

  List<SquareId> get squares => List.unmodifiable([from, to]);

  String get uci => '$from$to${_toPieceLetter(promotion)}';

  Move withPromotion(Role promotion) {
    return Move(
      from: from,
      to: to,
      promotion: promotion,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Move &&
            other.runtimeType == runtimeType &&
            other.from == from &&
            other.to == to &&
            other.promotion == promotion;
  }

  @override
  int get hashCode => Object.hash(from, to, promotion);

  String _toPieceLetter(Role? role) {
    switch (role) {
      case Role.king:
        return 'k';
      case Role.queen:
        return 'q';
      case Role.rook:
        return 'r';
      case Role.bishop:
        return 'b';
      case Role.knight:
        return 'n';
      case Role.pawn:
        return 'p';
      default:
        return '';
    }
  }
}

@immutable
class Annotation {
  const Annotation({
    required this.symbol,
    required this.color,
    this.duration,
  });

  /// Annotation symbol. Two letters max.
  final String symbol;

  /// Annotation background color.
  final Color color;

  /// Specify a duration to create a transient annotation.
  final Duration? duration;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Annotation &&
            other.runtimeType == runtimeType &&
            other.symbol == symbol &&
            other.color == color &&
            other.duration == duration;
  }

  @override
  int get hashCode => Object.hash(symbol, color, duration);
}

Role _toRole(String uciLetter) {
  switch (uciLetter.trim().toLowerCase()) {
    case 'k':
      return Role.king;
    case 'q':
      return Role.queen;
    case 'r':
      return Role.rook;
    case 'b':
      return Role.bishop;
    case 'n':
      return Role.knight;
    default:
      return Role.pawn;
  }
}

@immutable
abstract class Shape {
  const Shape({
    required this.color,
    required this.orig,
  });

  final Color color;
  final SquareId orig;
}

@immutable
class Arrow extends Shape {
  const Arrow({
    required super.color,
    required super.orig,
    required this.dest,
  });

  final SquareId dest;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Arrow &&
            other.runtimeType == runtimeType &&
            other.color == color &&
            other.orig == orig &&
            other.dest == dest;
  }

  @override
  int get hashCode => Object.hash(color, orig, dest);
}
