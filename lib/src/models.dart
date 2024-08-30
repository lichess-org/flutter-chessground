import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

/// The side that can interact with the board.
enum PlayerSide {
  /// No side can interact with the board.
  none,

  /// Both sides can interact with the board.
  ///
  /// This is used for games where both players can move the pieces as in over-the-board games.
  both,

  /// Only white side can interact with the board.
  white,

  /// Only black side can interact with the board.
  black;
}

/// Game data for an interactive chessboard.
///
/// This is used to control the state of the chessboard and to provide callbacks for user interactions.
@immutable
class GameData {
  /// Creates a new [GameData] with the provided values.
  const GameData({
    required this.playerSide,
    required this.sideToMove,
    required this.validMoves,
    required this.onMove,
    required this.onPromotionSelect,
    required this.onPromotionCancel,
    required this.promotionMove,
    this.isCheck,
    this.premovable,
  });

  /// Side that is allowed to move.
  final PlayerSide playerSide;

  /// Side which is to move.
  final Side sideToMove;

  /// A pawn move that should be promoted.
  ///
  /// Will show a promotion dialog if not null.
  final NormalMove? promotionMove;

  /// Highlight the king of current side to move
  final bool? isCheck;

  /// Set of moves allowed to be played by current side to move.
  final ValidMoves validMoves;

  /// Callback called after a move has been made.
  ///
  /// If the move has been made with drag and drop, `isDrop` will be true.
  ///
  /// If a piece has been captured, `captured` will be the captured piece.
  final void Function(NormalMove, {bool? isDrop, Piece? captured}) onMove;

  /// Callback called after a piece has been selected for promotion.
  ///
  /// The move is guaranteed to be a promotion move.
  final void Function(Role) onPromotionSelect;

  /// Callback called after a promotion has been canceled.
  final void Function() onPromotionCancel;

  /// Optional premovable state of the board.
  ///
  /// If `null`, the board will not allow premoves.
  final Premovable? premovable;
}

/// State of a premovable chessboard.
typedef Premovable = ({
  /// Registered premove.
  ///
  /// Will be shown on the board as a preview move.
  ///
  /// Chessground will not play the premove automatically, it is up to the library user to play it.
  NormalMove? premove,

  /// Callback called after a premove has been set.
  void Function(NormalMove) onSetPremove,

  /// Callback called after a premove has been unset.
  void Function() onUnsetPremove,
});

/// Describes a set of piece assets.
///
/// The [PieceAssets] must be complete with all the pieces for both sides.
typedef PieceAssets = IMap<PieceKind, AssetImage>;

/// Representation of the piece positions on a board.
typedef Pieces = Map<Square, Piece>;

/// Sets of each valid destinations for an origin square.
typedef ValidMoves = IMap<Square, ISet<Square>>;

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

  /// Optional duration to create a transient annotation.
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

/// Base class for shapes that can be drawn on the board.
sealed class Shape {
  /// Scale factor for the shape. Must be between 0.0 and 1.0.
  double get scale => 1.0;

  /// Decides what shape to draw based on the current shape and the new destination.
  Shape newDest(Square newDest);

  /// Returns a new shape with the same properties but a different scale.
  Shape withScale(double scale);
}

/// A circle shape that can be drawn on the board.
@immutable
class Circle implements Shape {
  /// Creates a new [Circle] with the provided values.
  ///
  /// The [scale] must be between 0.0 and 1.0.
  const Circle({
    required this.color,
    required this.orig,
    this.scale = 1.0,
  }) : assert(scale > 0.0 && scale <= 1.0);

  final Color color;
  final Square orig;

  /// Stroke width of the circle will be scaled by this factor.
  ///
  /// If 1.0, the width will be 1/16th of the square size.
  @override
  final double scale;

  @override
  Shape newDest(Square newDest) {
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

  /// Creates a copy of this [Circle] with the given fields replaced by the new values.
  Circle copyWith({
    Color? color,
    Square? orig,
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
  final Square orig;
  final Square dest;

  /// Width of the arrow and size of its tip will be scaled by this factor.
  ///
  /// If 1.0, the width will be 1/4th of the square size.
  @override
  final double scale;

  /// Creates a new [Arrow] with the provided values.
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
  Shape newDest(Square newDest) {
    return newDest == orig
        ? Circle(color: color, orig: orig, scale: scale)
        : Arrow(color: color, orig: orig, dest: newDest, scale: scale);
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

  /// Creates a copy of this [Arrow] with the given fields replaced by the new values.
  Arrow copyWith({
    Color? color,
    Square? orig,
    Square? dest,
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
  final Color? color;
  final Piece piece;
  final Square orig;
  final PieceAssets pieceAssets;
  final double opacity;
  @override
  final double scale;

  /// Creates a new [PieceShape] with the provided values.
  ///
  /// The [scale] must be between 0.0 and 1.0.
  /// The default [opacity] is 0.5 and the default [scale] is 0.9.
  const PieceShape({
    this.color,
    required this.piece,
    required this.orig,
    required this.pieceAssets,
    this.opacity = 0.5,
    this.scale = 0.9,
  }) : assert(scale > 0.0 && scale <= 1.0);

  @override
  Shape newDest(Square newDest) {
    return this;
  }

  @override
  Shape withScale(double newScale) {
    return PieceShape(
      color: color,
      piece: piece,
      orig: orig,
      pieceAssets: pieceAssets,
      opacity: opacity,
      scale: newScale,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PieceShape &&
            other.runtimeType == runtimeType &&
            other.color == color &&
            other.piece == piece &&
            other.orig == orig &&
            other.pieceAssets == pieceAssets &&
            other.opacity == opacity &&
            other.scale == scale;
  }

  @override
  int get hashCode =>
      Object.hash(color, opacity, piece, pieceAssets, orig, scale);

  /// Creates a copy of this [PieceShape] with the given fields replaced by the new values.
  PieceShape copyWith({
    Color? color,
    Piece? piece,
    Square? orig,
    PieceAssets? pieceAssets,
    double? opacity,
    double? scale,
  }) {
    return PieceShape(
      color: color ?? this.color,
      piece: piece ?? this.piece,
      orig: orig ?? this.orig,
      pieceAssets: pieceAssets ?? this.pieceAssets,
      opacity: opacity ?? this.opacity,
      scale: scale ?? this.scale,
    );
  }
}
