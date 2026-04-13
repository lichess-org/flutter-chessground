import SwiftUI

/// Colours, background image, and piece set for a chessboard theme.
///
/// Theme names and colour values mirror the Dart `ChessboardColorScheme` constants
/// in `board_color_scheme.dart`. Board image names map to assets in this package
/// (e.g. `"board_wood2"` → `Image("board_wood2", bundle: ChessgroundAssets.bundle)`).
public struct ChessboardTheme {
    public let lightSquare: Color
    public let darkSquare: Color
    public let lastMoveHighlight: Color
    /// Asset name for image-backed themes; `nil` means the theme uses solid colours.
    public let boardImageName: String?
    public let pieceSet: String

    public static let defaultPieceSet = "staunty"
    public static let defaultThemeName = "brown"

    /// Returns the theme for the given Dart theme name and piece-set name.
    ///
    /// Unrecognised theme names fall back to the default brown solid-colour theme.
    public static func from(themeName: String, pieceSet: String = defaultPieceSet) -> ChessboardTheme {
        switch themeName {

            // Solid-colour themes
        case "system":
            return .init(light: 0xF0D9B6, dark: 0xB58863, pieceSet: pieceSet)
        case "blue":
            return .init(light: 0xDEE3E6, dark: 0x8CA2AD, pieceSet: pieceSet)
        case "green":
            return .init(light: 0xFFFFDD, dark: 0x86A666, lastMove: tealLastMove, pieceSet: pieceSet)
        case "ic":
            return .init(light: 0xECECEC, dark: 0xC1C18E, pieceSet: pieceSet)

            // Image-backed themes
        case "blue2":
            return .init(light: 0x97B2C7, dark: 0x546F82,
                         boardImage: "board_blue2", pieceSet: pieceSet)
        case "blue3":
            return .init(light: 0xD9E0E6, dark: 0x315991,
                         boardImage: "board_blue3", pieceSet: pieceSet)
        case "blueMarble":
            return .init(light: 0xEAE6DD, dark: 0x7C7F87,
                         boardImage: "board_blueMarble", pieceSet: pieceSet)
        case "canvas":
            return .init(light: 0xD7DAEB, dark: 0x547388,
                         boardImage: "board_canvas", pieceSet: pieceSet)
        case "greenPlastic":
            return .init(light: 0xF2F9BB, dark: 0x59935D, lastMove: tealLastMove,
                         boardImage: "board_greenPlastic", pieceSet: pieceSet)
        case "grey":
            return .init(light: 0xB8B8B8, dark: 0x7D7D7D,
                         boardImage: "board_grey", pieceSet: pieceSet)
        case "horsey":
            return .init(light: 0xF0D9B5, dark: 0x946F51,
                         boardImage: "board_horsey", pieceSet: pieceSet)
        case "leather":
            return .init(light: 0xD1D1C9, dark: 0xC28E16,
                         boardImage: "board_leather", pieceSet: pieceSet)
        case "maple":
            return .init(light: 0xE8CEAB, dark: 0xBC7944,
                         boardImage: "board_maple", pieceSet: pieceSet)
        case "maple2":
            return .init(light: 0xE2C89F, dark: 0x996633,
                         boardImage: "board_maple2", pieceSet: pieceSet)
        case "marble":
            return .init(light: 0x93AB91, dark: 0x4F644E, lastMove: tealLastMove,
                         boardImage: "board_marble", pieceSet: pieceSet)
        case "metal":
            return .init(light: 0xC9C9C9, dark: 0x727272,
                         boardImage: "board_metal", pieceSet: pieceSet)
        case "newspaper":
            return .init(light: 0xFFFFFF, dark: 0x8D8D8D,
                         boardImage: "board_newspaper", pieceSet: pieceSet)
        case "olive":
            return .init(light: 0xB8B19F, dark: 0x6D6655,
                         boardImage: "board_olive", pieceSet: pieceSet)
        case "pinkPyramid":
            return .init(light: 0xE8E9B7, dark: 0xED7272,
                         boardImage: "board_pinkPyramid", pieceSet: pieceSet)
        case "purple":
            return .init(light: 0x9F90B0, dark: 0x7D4A8D,
                         boardImage: "board_purple", pieceSet: pieceSet)
        case "purpleDiag":
            return .init(light: 0xE5DAF0, dark: 0x957AB0,
                         boardImage: "board_purpleDiag", pieceSet: pieceSet)
        case "wood":
            return .init(light: 0xD8A45B, dark: 0x9B4D0F,
                         boardImage: "board_wood", pieceSet: pieceSet)
        case "wood2":
            return .init(light: 0xA38B5D, dark: 0x6C5017,
                         boardImage: "board_wood2", pieceSet: pieceSet)
        case "wood3":
            return .init(light: 0xD0CECA, dark: 0x755839,
                         boardImage: "board_wood3", pieceSet: pieceSet)
        case "wood4":
            return .init(light: 0xCAAF7D, dark: 0x7B5330,
                         boardImage: "board_wood4", pieceSet: pieceSet)

        default:  // "brown" and any unknown value
            return .init(light: 0xF0D9B6, dark: 0xB58863, pieceSet: pieceSet)
        }
    }

    // MARK: - Private

    private static let tealLastMove =
        Color(red: 0, green: 155 / 255, blue: 199 / 255).opacity(0.41)

    private static let defaultLastMove =
        Color(red: 156 / 255, green: 199 / 255, blue: 0).opacity(0.502)

    private init(light: UInt,
                 dark: UInt,
                 lastMove: Color? = nil,
                 boardImage: String? = nil,
                 pieceSet: String) {
        lightSquare = Color(rgb: light)
        darkSquare = Color(rgb: dark)
        lastMoveHighlight = lastMove ?? ChessboardTheme.defaultLastMove
        boardImageName = boardImage
        self.pieceSet = pieceSet
    }
}

// MARK: - Color helper

extension Color {
    /// Initialises a colour from a 24-bit `0xRRGGBB` integer.
    init(rgb: UInt) {
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}
