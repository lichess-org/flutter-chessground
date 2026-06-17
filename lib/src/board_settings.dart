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
  either,
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
  none,
}

/// Describes the border of the board.
@immutable
class BoardBorder {
  /// Creates a new border with the provided values.
  const BoardBorder({required this.color, required this.width});

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

  BoardBorder copyWith({Color? color, double? width}) {
    return BoardBorder(color: color ?? this.color, width: width ?? this.width);
  }
}

/// Board settings that controls visual aspects and behavior of the board.
///
/// This is meant for fixed settings that don't change during a game. Sensible defaults are
/// provided.
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
    this.brightness = 1.0,
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
    this.enableDrops = false,
    this.enablePremoves = true,
    this.enablePremoveCastling = true,
    this.autoQueenPromotion = false,
    this.autoQueenPromotionOnPremove = true,
    this.pieceShiftMethod = PieceShiftMethod.either,
    this.moveOnRelease = false,
    this.canPromoteToKing = false,
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
  ///
  /// A value under 1.0 darkens the board, while a value over 1.0 brightens it.
  /// A value of 0.0 will make it completely black. Default value is 1.0.
  final double brightness;

  /// Hue rotation of the board as an angle in degree from 0.0 to 360.0.
  ///
  /// A value of 0.0 leaves the hue unchanged. Default value is 0.0.
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

  /// Whether drop moves are enabled (for variants such as Crazyhouse).
  final bool enableDrops;

  /// Whether premoves are enabled.
  final bool enablePremoves;

  /// Whether castling is enabled with a premove.
  final bool enablePremoveCastling;

  /// If true the promotion selector won't appear and pawn will be promoted
  /// automatically to queen.
  final bool autoQueenPromotion;

  /// If true the promotion selector won't appear and pawn will be promoted
  /// automatically to queen only if the premove is confirmed
  final bool autoQueenPromotionOnPremove;

  /// Controls how moves are made.
  final PieceShiftMethod pieceShiftMethod;

  /// Whether a tap-to-move (selecting a piece, then a destination) is triggered
  /// when the pointer is released rather than when it is pressed.
  ///
  /// By default (`false`) the move is made as soon as the destination square is
  /// touched. When set to `true`, after a piece has been selected, touching a
  /// square only arms the move: the user can slide their finger to change the
  /// destination, and the move is committed on the square where the pointer is
  /// released. A square target follows the finger while choosing, like when
  /// dragging a piece but without the piece, and uses [dragTargetKind].
  ///
  /// This has no effect on drag-and-drop, which always commits on release.
  final bool moveOnRelease;

  /// Whether the pawn can be promoted to a king (for example in Antichess).
  final bool canPromoteToKing;

  /// Options that control the shape drawing gesture (enable/disable and color).
  ///
  /// Drawn shapes are stored in [ChessboardController] and can be cleared with
  /// [ChessboardController.clearDrawnShapes].
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
        other.brightness == brightness &&
        other.hue == hue &&
        other.enableCoordinates == enableCoordinates &&
        other.animationDuration == animationDuration &&
        other.showLastMove == showLastMove &&
        other.showValidMoves == showValidMoves &&
        other.blindfoldMode == blindfoldMode &&
        other.dragFeedbackScale == dragFeedbackScale &&
        other.dragFeedbackOffset == dragFeedbackOffset &&
        other.dragTargetKind == dragTargetKind &&
        other.pieceOrientationBehavior == pieceOrientationBehavior &&
        other.enableDrops == enableDrops &&
        other.enablePremoves == enablePremoves &&
        other.enablePremoveCastling == enablePremoveCastling &&
        other.autoQueenPromotion == autoQueenPromotion &&
        other.autoQueenPromotionOnPremove == autoQueenPromotionOnPremove &&
        other.pieceShiftMethod == pieceShiftMethod &&
        other.moveOnRelease == moveOnRelease &&
        other.canPromoteToKing == canPromoteToKing &&
        other.drawShape == drawShape;
  }

  @override
  int get hashCode => Object.hashAll([
    colorScheme,
    pieceAssets,
    border,
    borderRadius,
    boxShadow,
    brightness,
    hue,
    enableCoordinates,
    animationDuration,
    showLastMove,
    showValidMoves,
    blindfoldMode,
    dragFeedbackScale,
    dragFeedbackOffset,
    dragTargetKind,
    pieceOrientationBehavior,
    enableDrops,
    enablePremoves,
    enablePremoveCastling,
    autoQueenPromotion,
    autoQueenPromotionOnPremove,
    pieceShiftMethod,
    moveOnRelease,
    canPromoteToKing,
    drawShape,
  ]);

  ChessboardSettings copyWith({
    ChessboardColorScheme? colorScheme,
    double? brightness,
    double? hue,
    PieceAssets? pieceAssets,
    BoardBorder? border,
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
    bool? enableDrops,
    bool? enablePremoves,
    bool? enablePremoveCastling,
    bool? autoQueenPromotion,
    bool? autoQueenPromotionOnPremove,
    PieceShiftMethod? pieceShiftMethod,
    bool? moveOnRelease,
    bool? canPromoteToKing,
    DrawShapeOptions? drawShape,
  }) {
    return ChessboardSettings(
      colorScheme: colorScheme ?? this.colorScheme,
      brightness: brightness ?? this.brightness,
      hue: hue ?? this.hue,
      pieceAssets: pieceAssets ?? this.pieceAssets,
      border: border ?? this.border,
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
      pieceOrientationBehavior: pieceOrientationBehavior ?? this.pieceOrientationBehavior,
      enableDrops: enableDrops ?? this.enableDrops,
      enablePremoves: enablePremoves ?? this.enablePremoves,
      enablePremoveCastling: enablePremoveCastling ?? this.enablePremoveCastling,
      autoQueenPromotionOnPremove: autoQueenPromotionOnPremove ?? this.autoQueenPromotionOnPremove,
      autoQueenPromotion: autoQueenPromotion ?? this.autoQueenPromotion,
      pieceShiftMethod: pieceShiftMethod ?? this.pieceShiftMethod,
      moveOnRelease: moveOnRelease ?? this.moveOnRelease,
      canPromoteToKing: canPromoteToKing ?? this.canPromoteToKing,
      drawShape: drawShape ?? this.drawShape,
    );
  }
}

/// Visual settings for a [StaticChessboard].
///
/// This is the non-interactive counterpart of [ChessboardSettings]: it exposes
/// only the options that are meaningful for a board the user cannot play on
/// (no premoves, drag, promotion, shift method, etc.).
///
/// Use [StaticChessboardSettings.fromBoardSettings] to derive one from an
/// existing [ChessboardSettings].
@immutable
class StaticChessboardSettings {
  const StaticChessboardSettings({
    this.colorScheme = ChessboardColorScheme.brown,
    this.pieceAssets = PieceSet.cburnettAssets,
    this.border,
    this.borderRadius = BorderRadius.zero,
    this.boxShadow = const <BoxShadow>[],
    this.brightness = 1.0,
    this.hue = 0.0,
    this.enableCoordinates = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.showLastMove = true,
    this.blindfoldMode = false,
    this.pieceOrientationBehavior = PieceOrientationBehavior.facingUser,
  });

  /// Derives static settings from a full [ChessboardSettings], keeping only the
  /// options relevant to a non-interactive board.
  factory StaticChessboardSettings.fromBoardSettings(ChessboardSettings settings) {
    return StaticChessboardSettings(
      colorScheme: settings.colorScheme,
      pieceAssets: settings.pieceAssets,
      border: settings.border,
      borderRadius: settings.borderRadius,
      boxShadow: settings.boxShadow,
      brightness: settings.brightness,
      hue: settings.hue,
      enableCoordinates: settings.enableCoordinates,
      animationDuration: settings.animationDuration,
      showLastMove: settings.showLastMove,
      blindfoldMode: settings.blindfoldMode,
      pieceOrientationBehavior: settings.pieceOrientationBehavior,
    );
  }

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

  /// Hue rotation of the board as an angle in degree from 0.0 to 360.0.
  final double hue;

  /// Whether to show board coordinates
  final bool enableCoordinates;

  /// Piece animation duration (pieces animate when the position changes)
  final Duration animationDuration;

  /// Whether to show last move highlight
  final bool showLastMove;

  /// Pieces are hidden in blindfold mode
  final bool blindfoldMode;

  /// Controls if any pieces are displayed upside down.
  final PieceOrientationBehavior pieceOrientationBehavior;

  StaticChessboardSettings copyWith({
    ChessboardColorScheme? colorScheme,
    PieceAssets? pieceAssets,
    BoardBorder? border,
    BorderRadiusGeometry? borderRadius,
    List<BoxShadow>? boxShadow,
    double? brightness,
    double? hue,
    bool? enableCoordinates,
    Duration? animationDuration,
    bool? showLastMove,
    bool? blindfoldMode,
    PieceOrientationBehavior? pieceOrientationBehavior,
  }) {
    return StaticChessboardSettings(
      colorScheme: colorScheme ?? this.colorScheme,
      pieceAssets: pieceAssets ?? this.pieceAssets,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      brightness: brightness ?? this.brightness,
      hue: hue ?? this.hue,
      enableCoordinates: enableCoordinates ?? this.enableCoordinates,
      animationDuration: animationDuration ?? this.animationDuration,
      showLastMove: showLastMove ?? this.showLastMove,
      blindfoldMode: blindfoldMode ?? this.blindfoldMode,
      pieceOrientationBehavior: pieceOrientationBehavior ?? this.pieceOrientationBehavior,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is StaticChessboardSettings &&
        other.colorScheme == colorScheme &&
        other.pieceAssets == pieceAssets &&
        other.border == border &&
        other.borderRadius == borderRadius &&
        other.boxShadow == boxShadow &&
        other.brightness == brightness &&
        other.hue == hue &&
        other.enableCoordinates == enableCoordinates &&
        other.animationDuration == animationDuration &&
        other.showLastMove == showLastMove &&
        other.blindfoldMode == blindfoldMode &&
        other.pieceOrientationBehavior == pieceOrientationBehavior;
  }

  @override
  int get hashCode => Object.hashAll([
    colorScheme,
    pieceAssets,
    border,
    borderRadius,
    boxShadow,
    brightness,
    hue,
    enableCoordinates,
    animationDuration,
    showLastMove,
    blindfoldMode,
    pieceOrientationBehavior,
  ]);
}
