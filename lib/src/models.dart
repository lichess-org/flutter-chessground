import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

/// The side that can interact with the board.
enum InteractableSide { both, none, white, black }

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
  final Color color;
  final Role role;
  final Square orig;
  @override
  final double scale;

  /// Creates a new [PieceShape] with the provided values.
  ///
  /// The [scale] must be between 0.0 and 1.0.
  const PieceShape({
    required this.color,
    required this.role,
    required this.orig,
    this.scale = 1.0,
  }) : assert(scale > 0.0 && scale <= 1.0);

  @override
  Shape newDest(Square newDest) {
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

  /// Creates a copy of this [PieceShape] with the given fields replaced by the new values.
  PieceShape copyWith({
    Color? color,
    Role? role,
    Square? orig,
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
