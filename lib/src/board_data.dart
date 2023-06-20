import 'package:flutter/widgets.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart'
    hide Tuple2;

import 'models.dart';

/// Board data.
///
/// Used to configure the board with state that will/may change during a game.
@immutable
class BoardData {
  const BoardData({
    required this.interactableSide,
    required this.orientation,
    required this.fen,
    this.sideToMove = Side.white,
    this.lastMove,
    this.validMoves,
    this.isCheck = false,
    this.shapes,
    this.onMove,
    this.annotations,
  });

  /// Which color is allowed to move? It can be both, none, white or black
  ///
  /// If `none` is chosen the board will be non interactable.
  final InteractableSide interactableSide;

  /// Side by which the board is oriented.
  final Side orientation;

  /// Side which is to move.
  final Side sideToMove;

  /// FEN string describing the position of the board.
  final String fen;

  /// Last move played, used to highlight corresponding squares.
  final Move? lastMove;

  /// Set of [Move] allowed to be played by current side to move.
  final ValidMoves? validMoves;

  /// Highlight the king of current side to move
  final bool isCheck;

  /// Optional set of [Shape] to be drawn on the board.
  final ISet<Shape>? shapes;

  /// Move annotations to be displayed on the board.
  final IMap<SquareId, Annotation>? annotations;

  /// Callback called after a move has been made.
  final void Function(Move, {bool? isPremove})? onMove;
}
