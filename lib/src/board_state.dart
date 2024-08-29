import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'models.dart';

/// The chessboard state.
///
/// This state should be updated after every move during a game.
///
/// To make a fixed board, set [interactableSide] to [InteractableSide.none].
@immutable
abstract class ChessboardState {
  /// Creates a new [ChessboardState] with the provided values.
  const factory ChessboardState({
    required InteractableSide interactableSide,
    required Side orientation,
    required String fen,
    bool opponentsPiecesUpsideDown,
    Side? sideToMove,
    NormalMove? promotionMove,
    NormalMove? premove,
    NormalMove? lastMove,
    ValidMoves? validMoves,
    bool? isCheck,
    ISet<Shape>? shapes,
    IMap<Square, Annotation>? annotations,
  }) = _ChessboardState;

  const ChessboardState._({
    required this.interactableSide,
    required this.orientation,
    required this.fen,
    required this.opponentsPiecesUpsideDown,
    this.sideToMove,
    this.promotionMove,
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

  /// A pawn move that should be promoted.
  ///
  /// Setting this will show a promotion dialog.
  final NormalMove? promotionMove;

  /// Registered premove.
  ///
  /// Will be shown on the board as a preview move.
  ///
  /// Chessground will not play the premove automatically, it is up to the library user to play it.
  final NormalMove? premove;

  /// Last move played, used to highlight corresponding squares.
  final NormalMove? lastMove;

  /// Set of moves allowed to be played by current side to move.
  final ValidMoves? validMoves;

  /// Highlight the king of current side to move
  final bool? isCheck;

  /// Optional set of [Shape] to be drawn on the board.
  final ISet<Shape>? shapes;

  /// Move annotations to be displayed on the board.
  final IMap<Square, Annotation>? annotations;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChessboardState &&
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

  /// Creates a copy of this [ChessboardState] but with the given fields replaced with the new values.
  ChessboardState copyWith({
    InteractableSide? interactableSide,
    Side? orientation,
    String? fen,
    bool? opponentsPiecesUpsideDown,
    Side? sideToMove,
    NormalMove? promotionMove,
    NormalMove? premove,
    NormalMove? lastMove,
    ValidMoves? validMoves,
    bool? isCheck,
    ISet<Shape>? shapes,
    IMap<Square, Annotation>? annotations,
  });
}

class _ChessboardState extends ChessboardState {
  const _ChessboardState({
    required super.interactableSide,
    required super.orientation,
    required super.fen,
    super.opponentsPiecesUpsideDown = false,
    super.sideToMove,
    super.premove,
    super.promotionMove,
    super.lastMove,
    super.validMoves,
    super.isCheck,
    super.shapes,
    super.annotations,
  }) : super._();

  @override
  ChessboardState copyWith({
    InteractableSide? interactableSide,
    Side? orientation,
    String? fen,
    bool? opponentsPiecesUpsideDown,
    Object? sideToMove = _Undefined,
    Object? promotionMove = _Undefined,
    Object? premove = _Undefined,
    Object? lastMove = _Undefined,
    Object? validMoves = _Undefined,
    Object? isCheck = _Undefined,
    Object? shapes = _Undefined,
    Object? annotations = _Undefined,
  }) {
    return ChessboardState(
      interactableSide: interactableSide ?? this.interactableSide,
      orientation: orientation ?? this.orientation,
      opponentsPiecesUpsideDown:
          opponentsPiecesUpsideDown ?? this.opponentsPiecesUpsideDown,
      fen: fen ?? this.fen,
      sideToMove:
          sideToMove == _Undefined ? this.sideToMove : sideToMove as Side?,
      promotionMove: promotionMove == _Undefined
          ? this.promotionMove
          : promotionMove as NormalMove?,
      premove: premove == _Undefined ? this.premove : premove as NormalMove?,
      lastMove:
          lastMove == _Undefined ? this.lastMove : lastMove as NormalMove?,
      validMoves: validMoves == _Undefined
          ? this.validMoves
          : validMoves as ValidMoves?,
      isCheck: isCheck == _Undefined ? this.isCheck : isCheck as bool?,
      shapes: shapes == _Undefined ? this.shapes : shapes as ISet<Shape>?,
      annotations: annotations == _Undefined
          ? this.annotations
          : annotations as IMap<Square, Annotation>?,
    );
  }
}

class _Undefined {}
