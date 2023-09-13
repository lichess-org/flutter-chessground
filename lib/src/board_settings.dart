import 'package:flutter/widgets.dart';

import 'board_color_scheme.dart';
import 'models.dart';
import 'piece_set.dart';
import 'draw_shape_options.dart';

/// Board settings that control the theme, behavior and purpose of the board.
///
/// This is meant for fixed settings that don't change during a game. Sensible
/// defaults are provided.
@immutable
class BoardSettings {
  const BoardSettings({
    // theme
    this.colorScheme = BoardColorScheme.brown,
    this.pieceAssets = PieceSet.cburnettAssets,
    // visual settings
    this.enableCoordinates = true,
    this.animationDuration = const Duration(milliseconds: 250),
    this.showLastMove = true,
    this.showValidMoves = true,
    this.dragFeedbackSize = 2.0,
    this.dragFeedbackOffset = const Offset(0.0, -1.0),

    // shape drawing
    this.drawShape = const DrawShapeOptions(),

    // behavior settings
    this.enablePremoves = true,
    this.enablePremoveCastling = true,
    this.autoQueenPromotion = false,
    this.autoQueenPromotionOnPremove = false,
  });

  /// Theme of the board
  final BoardColorScheme colorScheme;

  /// Piece set
  final PieceAssets pieceAssets;

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

  /// Whether premoves are authorized or not.
  final bool enablePremoves;

  /// Whether castling is enabled with a premove.
  final bool enablePremoveCastling;

  /// If true the promotion selector won't appear and pawn will be promoted
  // automatically to queen
  final bool autoQueenPromotion;

  /// If true the promotion selector won't appear and pawn will be promoted
  /// automatically to queen only if the premove is confirmed
  final bool autoQueenPromotionOnPremove;

  /// Shape drawing options object containing data about how new shapes can be drawn.
  final DrawShapeOptions drawShape;

  BoardSettings copyWith({
    BoardColorScheme? colorScheme,
    PieceAssets? pieceAssets,
    bool? enableCoordinates,
    Duration? animationDuration,
    bool? showLastMove,
    bool? showValidMoves,
    double? dragFeedbackSize,
    Offset? dragFeedbackOffset,
    bool? enablePremoves,
    bool? enablePremoveCastling,
    bool? autoQueenPromotion,
    bool? autoQueenPromotionOnPremove,
    DrawShapeOptions? drawShape,
  }) {
    return BoardSettings(
      colorScheme: colorScheme ?? this.colorScheme,
      pieceAssets: pieceAssets ?? this.pieceAssets,
      enableCoordinates: enableCoordinates ?? this.enableCoordinates,
      animationDuration: animationDuration ?? this.animationDuration,
      showLastMove: showLastMove ?? this.showLastMove,
      showValidMoves: showValidMoves ?? this.showValidMoves,
      dragFeedbackSize: dragFeedbackSize ?? this.dragFeedbackSize,
      dragFeedbackOffset: dragFeedbackOffset ?? this.dragFeedbackOffset,
      enablePremoves: enablePremoves ?? this.enablePremoves,
      enablePremoveCastling:
          enablePremoveCastling ?? this.enablePremoveCastling,
      autoQueenPromotionOnPremove:
          autoQueenPromotionOnPremove ?? this.autoQueenPromotionOnPremove,
      autoQueenPromotion: autoQueenPromotion ?? this.autoQueenPromotion,
      drawShape: drawShape ?? this.drawShape,
    );
  }
}
