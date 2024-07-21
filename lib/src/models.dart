import 'package:flutter/widgets.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

/// The chessboard side, white or black.
enum Side {
  white,
  black;

  Side get opposite => this == Side.white ? Side.black : Side.white;
}

/// The side that can interact with the board.
enum InteractableSide { both, none, white, black }

/// Piece role, such as pawn, knight, etc.
enum Role {
  king,
  queen,
  knight,
  bishop,
  rook,
  pawn;

  String get letter => switch (this) {
        Role.king => 'K',
        Role.queen => 'Q',
        Role.knight => 'N',
        Role.bishop => 'B',
        Role.rook => 'R',
        Role.pawn => 'P',
      };
}

/// Piece kind, such as white pawn, black knight, etc.
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
/// The [PieceAssets] must be complete with all the pieces for both sides.
typedef PieceAssets = IMap<PieceKind, AssetImage>;

/// Square identifier using the algebraic coordinate notation such as e2, c3, etc.
extension type const SquareId._(String value) {
  const SquareId(this.value)
      : assert(
          value == 'a1' ||
              value == 'a2' ||
              value == 'a3' ||
              value == 'a4' ||
              value == 'a5' ||
              value == 'a6' ||
              value == 'a7' ||
              value == 'a8' ||
              value == 'b1' ||
              value == 'b2' ||
              value == 'b3' ||
              value == 'b4' ||
              value == 'b5' ||
              value == 'b6' ||
              value == 'b7' ||
              value == 'b8' ||
              value == 'c1' ||
              value == 'c2' ||
              value == 'c3' ||
              value == 'c4' ||
              value == 'c5' ||
              value == 'c6' ||
              value == 'c7' ||
              value == 'c8' ||
              value == 'd1' ||
              value == 'd2' ||
              value == 'd3' ||
              value == 'd4' ||
              value == 'd5' ||
              value == 'd6' ||
              value == 'd7' ||
              value == 'd8' ||
              value == 'e1' ||
              value == 'e2' ||
              value == 'e3' ||
              value == 'e4' ||
              value == 'e5' ||
              value == 'e6' ||
              value == 'e7' ||
              value == 'e8' ||
              value == 'f1' ||
              value == 'f2' ||
              value == 'f3' ||
              value == 'f4' ||
              value == 'f5' ||
              value == 'f6' ||
              value == 'f7' ||
              value == 'f8' ||
              value == 'g1' ||
              value == 'g2' ||
              value == 'g3' ||
              value == 'g4' ||
              value == 'g5' ||
              value == 'g6' ||
              value == 'g7' ||
              value == 'g8' ||
              value == 'h1' ||
              value == 'h2' ||
              value == 'h3' ||
              value == 'h4' ||
              value == 'h5' ||
              value == 'h6' ||
              value == 'h7' ||
              value == 'h8',
        );

  /// The file of the square, such as 'a', 'b', 'c', etc.
  String get file => value[0];

  /// The rank of the square, such as '1', '2', '3', etc.
  String get rank => value[1];

  /// The x-coordinate of the square on the board.
  int get x => value.codeUnitAt(0) - 97;

  /// The y-coordinate of the square on the board.
  int get y => value.codeUnitAt(1) - 49;

  /// The coordinate of the square on the board.
  Coord get coord => Coord(x: x, y: y);
}

/// Representation of the piece positions on a board.
typedef Pieces = Map<SquareId, Piece>;

/// Sets of each valid destinations for an origin square.
typedef ValidMoves = IMap<SquareId, ISet<SquareId>>;

/// Files of the chessboard.
///
/// This is an immutable list of strings from 'a' to 'h'.
const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

/// Ranks of the chessboard.
///
/// This is an immutable list of strings from '1' to '8'.
const ranks = ['1', '2', '3', '4', '5', '6', '7', '8'];

/// All the squares of the chessboard.
///
/// This is an immutable list of [SquareId] from 'a1' to 'h8'.
final List<SquareId> allSquares = List.unmodifiable([
  for (final f in files)
    for (final r in ranks) SquareId('$f$r'),
]);

/// All the coordinates of the chessboard.
///
/// This is an immutable list of [Coord] from (0, 0) to (7, 7).
final List<Coord> allCoords = List.unmodifiable([
  for (final f in files)
    for (final r in ranks) SquareId('$f$r').coord,
]);

/// Square highlight color or image on the chessboard.
@immutable
class HighlightDetails {
  const HighlightDetails({
    this.solidColor,
    this.image,
  }) : assert(
          solidColor != null || image != null,
          'You must provide either `solidColor` or `image`.',
        );

  final Color? solidColor;
  final AssetImage? image;
}

/// Zero-based numeric board coordinate.
///
/// For instance a1 is (0, 0), a2 is (0, 1), etc.
@immutable
class Coord {
  /// Create a new [Coord] with the provided values.
  const Coord({
    required this.x,
    required this.y,
  })  : assert(x >= 0 && x <= 7),
        assert(y >= 0 && y <= 7);

  /// The x-coordinate of the coordinate.
  final int x;

  /// The y-coordinate of the coordinate.
  final int y;

  /// Gets the square identifier of the coordinate.
  SquareId get squareId => allSquares[8 * x + y];

  /// Returns the offset of the coordinate on the board based on the orientation.
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

/// Describes a chess piece by its role and color.
///
/// Can be promoted.
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

/// A piece and its position on the board.
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

/// A chess move.
@immutable
class Move {
  const Move({
    required this.from,
    required this.to,
    this.promotion,
  });

  Move.fromUci(String uci)
      : from = SquareId(uci.substring(0, 2)),
        to = SquareId(uci.substring(2, 4)),
        promotion = uci.length > 4 ? _toRole(uci.substring(4)) : null;

  final SquareId from;
  final SquareId to;
  final Role? promotion;

  List<SquareId> get squares => List.unmodifiable([from, to]);

  String get uci => '$from$to${_toPieceLetter(promotion)}';

  bool hasSquare(SquareId squareId) {
    return from == squareId || to == squareId;
  }

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
    return switch (role) {
      Role.king => 'k',
      Role.queen => 'q',
      Role.rook => 'r',
      Role.bishop => 'b',
      Role.knight => 'n',
      Role.pawn => 'p',
      _ => ''
    };
  }
}

/// A chess move annotation represented by a symbol and a color.
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

/// Base class for shapes that can be drawn on the board.
sealed class Shape {
  /// Scale factor for the shape. Must be between 0.0 and 1.0.
  double get scale => 1.0;

  /// Decide what shape to draw based on the current shape and the new destination.
  Shape newDest(SquareId newDest);

  /// Returns a new shape with the same properties but a different scale.
  Shape withScale(double scale);
}

/// An circle shape that can be drawn on the board.
@immutable
class Circle implements Shape {
  /// Create a new [Circle] with the provided values.
  ///
  /// The [scale] must be between 0.0 and 1.0.
  const Circle({
    required this.color,
    required this.orig,
    this.scale = 1.0,
  }) : assert(scale > 0.0 && scale <= 1.0);

  final Color color;
  final SquareId orig;

  /// Stroke width of the circle will be scaled by this factor.
  ///
  /// If 1.0, the width will be 1/16th of the square size.
  @override
  final double scale;

  @override
  Shape newDest(SquareId newDest) {
    return newDest == orig
        ? this
        : Arrow(color: color, orig: orig, dest: newDest, scale: scale);
  }

  @override
  Shape withScale(double newScale) {
    return Circle(color: color, orig: orig, scale: newScale);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Circle &&
            other.runtimeType == runtimeType &&
            other.orig == orig &&
            other.color == color &&
            other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(color, orig, scale);

  /// Create a new [Circle] with the provided values.
  Circle copyWith({
    Color? color,
    SquareId? orig,
    double? scale,
  }) {
    return Circle(
      color: color ?? this.color,
      orig: orig ?? this.orig,
      scale: scale ?? this.scale,
    );
  }
}

/// An arrow shape that can be drawn on the board.
@immutable
class Arrow implements Shape {
  final Color color;
  final SquareId orig;
  final SquareId dest;

  /// Width of the arrow and size of its tip will be scaled by this factor.
  ///
  /// If 1.0, the width will be 1/4th of the square size.
  @override
  final double scale;

  /// Create a new [Arrow] with the provided values.
  ///
  /// The [orig] and [dest] must be different squares.
  /// The [scale] must be between 0.0 and 1.0.
  const Arrow({
    required this.color,
    required this.orig,
    required this.dest,
    this.scale = 1.0,
  }) : assert(orig != dest && scale > 0.0 && scale <= 1.0);

  @override
  Shape newDest(SquareId newDest) {
    return Arrow(color: color, orig: orig, dest: newDest, scale: scale);
  }

  @override
  Shape withScale(double newScale) {
    return Arrow(color: color, orig: orig, dest: dest, scale: newScale);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Arrow &&
            other.runtimeType == runtimeType &&
            other.orig == orig &&
            other.dest == dest &&
            other.color == color &&
            other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(color, orig, dest, scale);

  /// Create a new [Arrow] with the provided values.
  Arrow copyWith({
    Color? color,
    SquareId? orig,
    SquareId? dest,
    double? scale,
  }) {
    return Arrow(
      color: color ?? this.color,
      orig: orig ?? this.orig,
      dest: dest ?? this.dest,
      scale: scale ?? this.scale,
    );
  }
}

/// A piece shape that can be drawn on the board.
@immutable
class PieceShape implements Shape {
  final Color color;
  final Role role;
  final SquareId orig;
  @override
  final double scale;

  /// Create a new [PieceShape] with the provided values.
  ///
  /// The [scale] must be between 0.0 and 1.0.
  const PieceShape({
    required this.color,
    required this.role,
    required this.orig,
    this.scale = 1.0,
  }) : assert(scale > 0.0 && scale <= 1.0);

  @override
  Shape newDest(SquareId newDest) {
    return this;
  }

  @override
  Shape withScale(double newScale) {
    return PieceShape(color: color, role: role, orig: orig, scale: newScale);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PieceShape &&
            other.runtimeType == runtimeType &&
            other.color == color &&
            other.role == role &&
            other.orig == orig &&
            other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(color, role, orig, scale);

  /// Create a new [PieceShape] with the provided values.
  PieceShape copyWith({
    Color? color,
    Role? role,
    SquareId? orig,
    double? scale,
  }) {
    return PieceShape(
      color: color ?? this.color,
      role: role ?? this.role,
      orig: orig ?? this.orig,
      scale: scale ?? this.scale,
    );
  }
}
