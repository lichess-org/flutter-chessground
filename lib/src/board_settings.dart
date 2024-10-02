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

/// Describes how pieces on the board are oriented.
enum PieceOrientationBehavior {
  /// Pieces are always facing user (the default).
  facingUser,

  /// Opponent's pieces are upside down, for over the board play face to face.
  opponentUpsideDown,

  /// Piece orientation matches side to play, for over the board play where each user grabs the device in turn.
  sideToPlay,
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
    this.pieceShadow = true,
    this.pieceOrientationBehavior = PieceOrientationBehavior.facingUser,

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

  /// Whether the dark shadow under dragged pieces is enabled
  final bool pieceShadow;

  /// Controls if any pieces are displayed upside down.
  final PieceOrientationBehavior pieceOrientationBehavior;

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
        other.pieceShadow == pieceShadow &&
        other.pieceOrientationBehavior == pieceOrientationBehavior &&
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
    pieceShadow,
    pieceOrientationBehavior,
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
    bool? pieceShadow,
    PieceOrientationBehavior? pieceOrientationBehavior,
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
      pieceShadow: pieceShadow ?? this.pieceShadow,
      pieceOrientationBehavior:
      pieceOrientationBehavior ?? this.pieceOrientationBehavior,
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

/// Board editor settings that control the theme, behavior and purpose of the board editor.
///
/// This is meant for fixed settings that don't change while editing the board.
/// Sensible defaults are provided.
@immutable
class ChessboardEditorSettings {
  /// Creates a new [ChessboardEditorSettings] with the provided values.
  const ChessboardEditorSettings({
    // theme
    this.colorScheme = ChessboardColorScheme.brown,
    this.pieceAssets = PieceSet.cburnettAssets,
    // visual settings
    this.borderRadius = BorderRadius.zero,
    this.boxShadow = const <BoxShadow>[],
    this.enableCoordinates = true,
    this.dragFeedbackScale = 2.0,
    this.dragFeedbackOffset = const Offset(0.0, -1.0),
    this.pieceShadow = true,
  });

  /// Theme of the board.
  final ChessboardColorScheme colorScheme;

  /// Piece set.
  final PieceAssets pieceAssets;

  /// Border radius of the board.
  final BorderRadiusGeometry borderRadius;

  /// Box shadow of the board.
  final List<BoxShadow> boxShadow;

  /// Whether to show board coordinates.
  final bool enableCoordinates;

  // Scale up factor for the piece currently under drag.
  final double dragFeedbackScale;

  // Offset for the piece currently under drag.
  final Offset dragFeedbackOffset;

  // Whether the dark shadow under dragged pieces is enabled.
  final bool pieceShadow;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ChessboardEditorSettings &&
        other.colorScheme == colorScheme &&
        other.pieceAssets == pieceAssets &&
        other.borderRadius == borderRadius &&
        other.boxShadow == boxShadow &&
        other.enableCoordinates == enableCoordinates &&
        other.dragFeedbackScale == dragFeedbackScale &&
        other.dragFeedbackOffset == dragFeedbackOffset &&
        other.pieceShadow == pieceShadow;
  }

  @override
  int get hashCode => Object.hash(
    colorScheme,
    pieceAssets,
    borderRadius,
    boxShadow,
    enableCoordinates,
    dragFeedbackScale,
    dragFeedbackOffset,
    pieceShadow,
  );

  /// Creates a copy of this [ChessboardEditorSettings] but with the given fields replaced with the new values.
  ChessboardEditorSettings copyWith({
    ChessboardColorScheme? colorScheme,
    PieceAssets? pieceAssets,
    BorderRadiusGeometry? borderRadius,
    List<BoxShadow>? boxShadow,
    bool? enableCoordinates,
    double? dragFeedbackScale,
    Offset? dragFeedbackOffset,
    bool? pieceShadow,
  }) {
    return ChessboardEditorSettings(
      colorScheme: colorScheme ?? this.colorScheme,
      pieceAssets: pieceAssets ?? this.pieceAssets,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      enableCoordinates: enableCoordinates ?? this.enableCoordinates,
      dragFeedbackScale: dragFeedbackScale ?? this.dragFeedbackScale,
      dragFeedbackOffset: dragFeedbackOffset ?? this.dragFeedbackOffset,
      pieceShadow: pieceShadow ?? this.pieceShadow,
    );
  }
}
