// swift-tools-version: 5.9
import PackageDescription

/// Swift Package exposing Chessground board textures and piece images as an
/// Xcode asset catalog, so iOS/macOS targets (e.g. WidgetKit extensions) can
/// consume the same assets that the Flutter side uses — without a copy script.
///
/// Usage in Package.swift:
///   .package(url: "https://github.com/lichess-org/flutter-chessground", from: "9.0.0")
///
/// Load assets in Swift:
///   Image("board_wood2", bundle: ChessgroundAssets.bundle)
///   Image("piece_staunty_wK", bundle: ChessgroundAssets.bundle)
let package = Package(
    name: "ChessgroundAssets",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "ChessgroundAssets", targets: ["ChessgroundAssets"]),
    ],
    targets: [
        .target(
            name: "ChessgroundAssets",
            path: "swift/Sources/ChessgroundAssets",
            resources: [
                .process("Assets.xcassets"),
            ]
        ),
    ]
)
