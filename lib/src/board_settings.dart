import 'package:flutter/widgets.dart';

import 'board_color_scheme.dart';
import 'models.dart';
import 'piece_set.dart';
import 'draw_shape_options.dart';

/// Describes how moves are made on an interactive board.
enum PieceShiftMethod {
  /// First tap the piece to be moved, then tap the target square.
  tapTwoSquares,

  /// Drag-and-drop the piece to the target square.
  drag,

  /// Both tap and drag are enabled.
  either;
}

/// Board settings that controls visual aspects and behavior of the board.
///
/// This is meant for fixed settings that don't change during a game. Sensible
/// defaults are provided.
@immutable
class ChessboardSettings {
  const ChessboardSettings({
    // theme
    this.colorScheme = ChessboardColorScheme.brown,
    this.pieceAssets = PieceSet.cburnettAssets,
    // visual settings
    this.borderRadius = BorderRadius.zero,
    this.boxShadow = const <BoxShadow>[],
    this.enableCoordinates = true,
    this.animationDuration = const Duration(milliseconds: 250),
    this.showLastMove = true,
    this.showValidMoves = true,
    this.blindfoldMode = false,
    this.dragFeedbackScale = 2.0,
    this.dragFeedbackOffset = const Offset(0.0, -1.0),

    // shape drawing
    this.drawShape = const DrawShapeOptions(),

    // behavior settings
    this.enablePremoveCastling = true,
    this.autoQueenPromotion = false,
    this.autoQueenPromotionOnPremove = true,
    this.pieceShiftMethod = PieceShiftMethod.either,
  });

  /// Theme of the board
  final ChessboardColorScheme colorScheme;

  /// Piece set
  final PieceAssets pieceAssets;

  /// Border radius of the board
  final BorderRadiusGeometry borderRadius;

  /// Box shadow of the board
  final List<BoxShadow> boxShadow;

  /// Whether to show board coordinates
  final bool enableCoordinates;

  /// Piece animation duration
  final Duration animationDuration;

  /// Whether to show last move highlight
  final bool showLastMove;

  /// Whether to show valid moves
  final bool showValidMoves;

  /// Pieces are hidden in blindfold mode
  final bool blindfoldMode;

  // Scale up factor for the piece currently under drag
  final double dragFeedbackScale;

  // Offset for the piece currently under drag
  final Offset dragFeedbackOffset;

  /// Whether castling is enabled with a premove.
  final bool enablePremoveCastling;

  /// If true the promotion selector won't appear and pawn will be promoted
  // automatically to queen
  final bool autoQueenPromotion;

  /// If true the promotion selector won't appear and pawn will be promoted
  /// automatically to queen only if the premove is confirmed
  final bool autoQueenPromotionOnPremove;

  /// Controls how moves are made.
  final PieceShiftMethod pieceShiftMethod;

  /// Shape drawing options object containing data about how new shapes can be drawn.
  final DrawShapeOptions drawShape;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ChessboardSettings &&
        other.colorScheme == colorScheme &&
        other.pieceAssets == pieceAssets &&
        other.borderRadius == borderRadius &&
        other.boxShadow == boxShadow &&
        other.enableCoordinates == enableCoordinates &&
        other.animationDuration == animationDuration &&
        other.showLastMove == showLastMove &&
        other.showValidMoves == showValidMoves &&
        other.blindfoldMode == blindfoldMode &&
        other.dragFeedbackScale == dragFeedbackScale &&
        other.dragFeedbackOffset == dragFeedbackOffset &&
        other.enablePremoveCastling == enablePremoveCastling &&
        other.autoQueenPromotion == autoQueenPromotion &&
        other.autoQueenPromotionOnPremove == autoQueenPromotionOnPremove &&
        other.pieceShiftMethod == pieceShiftMethod &&
        other.drawShape == drawShape;
  }

  @override
  int get hashCode => Object.hash(
        colorScheme,
        pieceAssets,
        borderRadius,
        boxShadow,
        enableCoordinates,
        animationDuration,
        showLastMove,
        showValidMoves,
        blindfoldMode,
        dragFeedbackScale,
        dragFeedbackOffset,
        enablePremoveCastling,
        autoQueenPromotion,
        autoQueenPromotionOnPremove,
        pieceShiftMethod,
        drawShape,
      );

  ChessboardSettings copyWith({
    ChessboardColorScheme? colorScheme,
    PieceAssets? pieceAssets,
    BorderRadiusGeometry? borderRadius,
    List<BoxShadow>? boxShadow,
    bool? enableCoordinates,
    Duration? animationDuration,
    bool? showLastMove,
    bool? showValidMoves,
    bool? blindfoldMode,
    double? dragFeedbackScale,
    Offset? dragFeedbackOffset,
    bool? enablePremoveCastling,
    bool? autoQueenPromotion,
    bool? autoQueenPromotionOnPremove,
    PieceShiftMethod? pieceShiftMethod,
    DrawShapeOptions? drawShape,
  }) {
    return ChessboardSettings(
      colorScheme: colorScheme ?? this.colorScheme,
      pieceAssets: pieceAssets ?? this.pieceAssets,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      enableCoordinates: enableCoordinates ?? this.enableCoordinates,
      animationDuration: animationDuration ?? this.animationDuration,
      showLastMove: showLastMove ?? this.showLastMove,
      showValidMoves: showValidMoves ?? this.showValidMoves,
      blindfoldMode: blindfoldMode ?? this.blindfoldMode,
      dragFeedbackScale: dragFeedbackScale ?? this.dragFeedbackScale,
      dragFeedbackOffset: dragFeedbackOffset ?? this.dragFeedbackOffset,
      enablePremoveCastling:
          enablePremoveCastling ?? this.enablePremoveCastling,
      autoQueenPromotionOnPremove:
          autoQueenPromotionOnPremove ?? this.autoQueenPromotionOnPremove,
      autoQueenPromotion: autoQueenPromotion ?? this.autoQueenPromotion,
      pieceShiftMethod: pieceShiftMethod ?? this.pieceShiftMethod,
      drawShape: drawShape ?? this.drawShape,
    );
  }
}
