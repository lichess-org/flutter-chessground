import 'package:flutter/widgets.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

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
    this.sideToMove,
    this.premove,
    this.lastMove,
    this.validMoves,
    this.isCheck,
    this.shapes,
    this.annotations,
    this.opponentsPiecesUpsideDown = false,
  }) : assert(
          (isCheck == null && interactableSide == InteractableSide.none) ||
              sideToMove != null,
          'sideToMove must be set when isCheck is set, or when the board is interactable.',
        );

  /// Which color is allowed to move? It can be both, none, white or black
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
  final Move? premove;

  /// Last move played, used to highlight corresponding squares.
  final Move? lastMove;

  /// Set of [Move] allowed to be played by current side to move.
  final ValidMoves? validMoves;

  /// Highlight the king of current side to move
  final bool? isCheck;

  /// Optional set of [Shape] to be drawn on the board.
  final ISet<Shape>? shapes;

  /// Move annotations to be displayed on the board.
  final IMap<SquareId, Annotation>? annotations;
}
