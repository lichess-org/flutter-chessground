import 'package:flutter/material.dart';
import 'models.dart' as cg;

/// Board settings that control the behavior and purpose of the board.
///
/// This is meant for fixed settings that don't change during a game.
@immutable
class Settings {
  const Settings({
    // visual settings
    this.enableCoordinates = true,
    this.animationDuration = const Duration(milliseconds: 250),
    this.showLastMove = true,
    this.showValidMoves = true,
    this.dragFeedbackSize = 2.0,
    this.dragFeedbackOffset = const Offset(0.0, -1.0),
    // behavior settings
    this.interactable = false,
    this.interactableColor = cg.InteractableColor.both,
    this.autoQueenPromotion = false,
  });

  /// Whether to show board coordinates
  final bool enableCoordinates;

  /// Piece animation duration
  final Duration animationDuration;

  /// Whether to show last move highlight
  final bool showLastMove;

  /// Whether to show valid moves
  final bool showValidMoves;

  // Scale up factor for the piece currently under drag
  final double dragFeedbackSize;

  // Offset for the piece currently under drag
  final Offset dragFeedbackOffset;

  /// Is it possible to move the pieces? If false the board will be view-only
  final bool interactable;

  /// Which color is allowed to move? It can be both, none, white or black
  final cg.InteractableColor interactableColor;

  /// If true the promotion selector won't appear and pawn will be promoted
  // automatically to queen
  final bool autoQueenPromotion;
}
