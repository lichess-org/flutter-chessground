import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/widgets.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'models.dart';

/// Board data.
///
/// Used to configure the board with state that will/may change during a game.
@immutable
abstract class BoardData {
  /// Creates a new [BoardData] with the provided values.
  const factory BoardData({
    required InteractableSide interactableSide,
    required Side orientation,
    required String fen,
    bool opponentsPiecesUpsideDown,
    Side? sideToMove,
    BoardMove? premove,
    BoardMove? lastMove,
    ValidMoves? validMoves,
    bool? isCheck,
    ISet<Shape>? shapes,
    IMap<SquareId, Annotation>? annotations,
  }) = _BoardData;

  const BoardData._({
    required this.interactableSide,
    required this.orientation,
    required this.fen,
    required this.opponentsPiecesUpsideDown,
    this.sideToMove,
    this.premove,
    this.lastMove,
    this.validMoves,
    this.isCheck,
    this.shapes,
    this.annotations,
  }) : assert(
          (isCheck == null && interactableSide == InteractableSide.none) ||
              sideToMove != null,
          'sideToMove must be set when isCheck is set, or when the board is interactable.',
        );

  /// Which color is allowed to move? It can be both, none, white or black.
  ///
  /// If `none` is chosen the board will be non interactable.
  final InteractableSide interactableSide;

  /// Side by which the board is oriented.
  final Side orientation;

  /// If `true` the opponent`s pieces are displayed rotated by 180 degrees.
  final bool opponentsPiecesUpsideDown;

  /// Side which is to move.
  final Side? sideToMove;

  /// FEN string describing the position of the board.
  final String fen;

  /// Registered premove. Will be played right after the next opponent move.
  final BoardMove? premove;

  /// Last move played, used to highlight corresponding squares.
  final BoardMove? lastMove;

  /// Set of [Move] allowed to be played by current side to move.
  final ValidMoves? validMoves;

  /// Highlight the king of current side to move
  final bool? isCheck;

  /// Optional set of [Shape] to be drawn on the board.
  final ISet<Shape>? shapes;

  /// Move annotations to be displayed on the board.
  final IMap<SquareId, Annotation>? annotations;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardData &&
          runtimeType == other.runtimeType &&
          interactableSide == other.interactableSide &&
          orientation == other.orientation &&
          opponentsPiecesUpsideDown == other.opponentsPiecesUpsideDown &&
          sideToMove == other.sideToMove &&
          fen == other.fen &&
          premove == other.premove &&
          lastMove == other.lastMove &&
          validMoves == other.validMoves &&
          isCheck == other.isCheck &&
          shapes == other.shapes &&
          annotations == other.annotations;

  @override
  int get hashCode => Object.hash(
        interactableSide,
        orientation,
        opponentsPiecesUpsideDown,
        sideToMove,
        fen,
        premove,
        lastMove,
        validMoves,
        isCheck,
        shapes,
        annotations,
      );

  /// Creates a copy of this [BoardData] but with the given fields replaced with the new values.
  BoardData copyWith({
    InteractableSide? interactableSide,
    Side? orientation,
    String? fen,
    bool? opponentsPiecesUpsideDown,
    Side? sideToMove,
    BoardMove? premove,
    BoardMove? lastMove,
    ValidMoves? validMoves,
    bool? isCheck,
    ISet<Shape>? shapes,
    IMap<SquareId, Annotation>? annotations,
  });
}

class _BoardData extends BoardData {
  const _BoardData({
    required super.interactableSide,
    required super.orientation,
    required super.fen,
    super.opponentsPiecesUpsideDown = false,
    super.sideToMove,
    super.premove,
    super.lastMove,
    super.validMoves,
    super.isCheck,
    super.shapes,
    super.annotations,
  }) : super._();

  @override
  BoardData copyWith({
    InteractableSide? interactableSide,
    Side? orientation,
    String? fen,
    bool? opponentsPiecesUpsideDown,
    Object? sideToMove = _Undefined,
    Object? premove = _Undefined,
    Object? lastMove = _Undefined,
    Object? validMoves = _Undefined,
    Object? isCheck = _Undefined,
    Object? shapes = _Undefined,
    Object? annotations = _Undefined,
  }) {
    return BoardData(
      interactableSide: interactableSide ?? this.interactableSide,
      orientation: orientation ?? this.orientation,
      opponentsPiecesUpsideDown:
          opponentsPiecesUpsideDown ?? this.opponentsPiecesUpsideDown,
      fen: fen ?? this.fen,
      sideToMove:
          sideToMove == _Undefined ? this.sideToMove : sideToMove as Side?,
      premove: premove == _Undefined ? this.premove : premove as BoardMove?,
      lastMove: lastMove == _Undefined ? this.lastMove : lastMove as BoardMove?,
      validMoves: validMoves == _Undefined
          ? this.validMoves
          : validMoves as ValidMoves?,
      isCheck: isCheck == _Undefined ? this.isCheck : isCheck as bool?,
      shapes: shapes == _Undefined ? this.shapes : shapes as ISet<Shape>?,
      annotations: annotations == _Undefined
          ? this.annotations
          : annotations as IMap<SquareId, Annotation>?,
    );
  }
}

class _Undefined {}
