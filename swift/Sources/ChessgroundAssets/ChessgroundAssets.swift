import Foundation

/// Provides access to the Chessground asset bundle.
///
/// Pass `ChessgroundAssets.bundle` when loading board textures or piece images:
/// ```swift
/// Image("board_wood2", bundle: ChessgroundAssets.bundle)
/// Image("piece_staunty_wK", bundle: ChessgroundAssets.bundle)
/// ```
///
/// Asset naming conventions:
/// - Board textures: `board_{name}` where `name` matches the `ChessboardColorScheme`
///   Dart constant (e.g. `board_blue2`, `board_blueMarble`, `board_wood3`).
/// - Piece images: `piece_{set}_{color}{kind}` where `set` is the camelCase piece-set
///   name, `color` is `w`/`b`, and `kind` is `K`/`Q`/`R`/`B`/`N`/`P`
///   (e.g. `piece_staunty_wK`, `piece_california_bQ`).
public enum ChessgroundAssets {
    /// The resource bundle containing all Chessground board textures and piece images.
    public static let bundle = Bundle.module
}
