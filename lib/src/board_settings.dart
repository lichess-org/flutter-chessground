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

/// Describes the kind of drag target highlighted on the board when dragging a piece.
enum DragTargetKind {
  /// A circle twice the size of a board square.
  circle,

  /// A square the size of a board square.
  square,

  /// No target is shown.
  none;
}

/// Describes the border of the board.
@immutable
class BoardBorder {
  /// Creates a new border with the provided values.
  const BoardBorder({
    required this.color,
    required this.width,
  });

  /// Color of the border
  final Color color;

  /// Width of the border
  final double width;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is BoardBorder && other.color == color && other.width == width;
  }

  @override
  int get hashCode => Object.hash(color, width);

  BoardBorder copyWith({
    Color? color,
    double? width,
  }) {
    return BoardBorder(
      color: color ?? this.color,
      width: width ?? this.width,
    );
  }
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
    this.border,
    this.borderRadius = BorderRadius.zero,
    this.boxShadow = const <BoxShadow>[],
    this.brightness = 0.0,
    this.hue = 0.0,
    this.enableCoordinates = true,
    this.animationDuration = const Duration(milliseconds: 250),
    this.showLastMove = true,
    this.showValidMoves = true,
    this.blindfoldMode = false,
    this.dragFeedbackScale = 2.0,
    this.dragFeedbackOffset = const Offset(0.0, -1.0),
    this.dragTargetKind = DragTargetKind.circle,
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

  /// Optional border of the board
  final BoardBorder? border;

  /// Border radius of the board
  final BorderRadiusGeometry borderRadius;

  /// Box shadow of the board
  final List<BoxShadow> boxShadow;

  /// Brightness adjustment of the board
  final double brightness;

  /// Hue adjustment of the board
  final double hue;

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

  /// The kind of drag target highlight when dragging a piece
  final DragTargetKind dragTargetKind;

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
        other.border == border &&
        other.borderRadius == borderRadius &&
        other.boxShadow == boxShadow &&
        other.enableCoordinates == enableCoordinates &&
        other.animationDuration == animationDuration &&
        other.showLastMove == showLastMove &&
        other.showValidMoves == showValidMoves &&
        other.blindfoldMode == blindfoldMode &&
        other.dragFeedbackScale == dragFeedbackScale &&
        other.dragFeedbackOffset == dragFeedbackOffset &&
        other.dragTargetKind == dragTargetKind &&
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
        border,
        borderRadius,
        boxShadow,
        enableCoordinates,
        animationDuration,
        showLastMove,
        showValidMoves,
        blindfoldMode,
        dragFeedbackScale,
        dragFeedbackOffset,
        dragTargetKind,
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
    DragTargetKind? dragTargetKind,
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
      border: border,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      enableCoordinates: enableCoordinates ?? this.enableCoordinates,
      animationDuration: animationDuration ?? this.animationDuration,
      showLastMove: showLastMove ?? this.showLastMove,
      showValidMoves: showValidMoves ?? this.showValidMoves,
      blindfoldMode: blindfoldMode ?? this.blindfoldMode,
      dragFeedbackScale: dragFeedbackScale ?? this.dragFeedbackScale,
      dragFeedbackOffset: dragFeedbackOffset ?? this.dragFeedbackOffset,
      dragTargetKind: dragTargetKind ?? this.dragTargetKind,
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
