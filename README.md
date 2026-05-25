[![Tests](https://github.com/lichess-org/flutter-chessground/workflows/Test/badge.svg)](https://github.com/lichess-org/flutter-chessground/actions?query=workflow%3A%22Test%22)
[![pub package](https://img.shields.io/pub/v/chessground.svg)](https://pub.dev/packages/chessground)
[![package publisher](https://img.shields.io/pub/publisher/chessground.svg)](https://pub.dev/packages/chessground/publisher)
[![Discord](https://img.shields.io/discord/280713822073913354?label=Discord&logo=discord&style=flat)](https://discord.com/channels/280713822073913354/807722604478988348)

Chessground is a chessboard package developed for lichess.org. It doesn't handle
chess logic so you can use it with different chess variants.

## Features

- pieces animations: moving and fading away
- board highlights: last move, piece destinations
- move piece by tap or drag and drop
- premoves
- displays a shadow under dragged piece to indicate the drop square target
- board themes
- piece sets from lichess
- promotion selector
- draw shapes on board while playing using 2 fingers
- move annotations
- opponent's pieces can be displayed upside down
- create positions with a board editor

## Getting started

This package exports a `Chessboard` widget which can be interactable or not.

It is configurable with a `ChessboardSettings` object which defines the board
behavior and appearance.

### Interactive board

To interact with the board in order to play a game, create a `ChessboardController`
and pass it to `Chessboard(controller: ...)`. The controller holds the board
position and game state. Call `controller.animatePosition()` after each move to
advance the board with animation.

`GameData` is an immutable snapshot of the board and game state (the position FEN,
side to move, valid moves, last move, etc.). It is the single source of truth passed
to `controller.animatePosition()` and the constructor. All chess logic must be handled
outside this package.

Callbacks for user interactions (`onMove`, `onSetPremove`) are parameters on
the `Chessboard` widget rather than on `GameData`. Promotion is handled
internally — `onMove` fires once with a fully-resolved move after the user
picks a promotion piece.

The controller pattern means the board rebuilds itself in response to controller
updates, without requiring a parent `setState()`.

```dart
class _MyBoardState extends State<MyBoard> {
  late ChessboardController _controller;
  Position position = Chess.initial;
  Move? lastMove;

  @override
  void initState() {
    super.initState();
    _controller = ChessboardController(game: _buildGame());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  GameData _buildGame() => GameData(
    fen: position.fen,
    lastMove: lastMove,
    playerSide: PlayerSide.white,
    sideToMove: position.turn == Side.white ? Side.white : Side.black,
    kingSquareInCheck: position.isCheck ? position.board.kingOf(position.turn) : null,
    validMoves: makeLegalMoves(position),
  );

  void _onMove(Move move, {bool? viaDragAndDrop}) {
    position = position.playUnchecked(move);
    lastMove = move;
    _controller.animatePosition(_buildGame());
  }

  @override
  Widget build(BuildContext context) {
    return Chessboard(
      controller: _controller,
      size: MediaQuery.of(context).size.width,
      orientation: Side.white,
      onMove: _onMove,
    );
  }
}
```

### Non-interactive board

To display a read-only board, use `StaticChessboard`. The example below shows how
to render a non-interactable position without a controller or move callbacks.

### Piece image cache

Piece images are managed by `ChessgroundImages`, a singleton cache that holds decoded `ui.Image` objects. Board widgets automatically load images on first render if the cache is empty — pieces are invisible for the duration of that load (typically one async frame).

To guarantee pieces are visible on the very first frame, pre-populate the cache before the board is displayed:

```dart
// in main() or your app startup, before showing any board
await ChessgroundImages.instance.loadAll(
  PieceSet.stauntyAssets,
  devicePixelRatio: WidgetsBinding
      .instance.platformDispatcher.implicitView?.devicePixelRatio,
);
```

When switching piece sets at runtime, clear the old images first:

```dart
ChessgroundImages.instance.clear();
await ChessgroundImages.instance.loadAll(newPieceAssets);
```

If you only need to evict a single image, use `ChessgroundImages.instance.evict(asset)`.

This will display a non-interactable board from the starting position, using the
default theme:

```dart
import 'package:flutter/material.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR';

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chessground demo'),
      ),
      body: Center(
        child: StaticChessboard(
          size: screenWidth,
          orientation: Side.white,
          fen: fen,
        ),
      ),
    );
  }
}
```

## Usage

See the example app for:
- Random Bot: an interactable board for one player playing against a random bot,
- Free Play: an interactable board for two players sitting opposite to each other,
- Board editor: a board editor to create positions,
- Draw Shapes: activate the draw shapes feature and draw on the board using 2
- Board Thumbnails: a demo screen showing over hundred different boards in a grid,
  fingers.

## Swift Package (iOS/macOS)

This repository also ships a Swift package (`ChessgroundAssets`) that exposes the
same board textures, piece images, and theme colour data as an Xcode asset catalog.
It is intended for native iOS/macOS targets such as WidgetKit extensions that need
to render a chessboard matching the Flutter app's appearance.

### Adding the dependency

In Xcode: **File → Add Package Dependencies**, enter the repository URL, and add
the `ChessgroundAssets` library to your target.

Or in `Package.swift`:

```swift
.package(url: "https://github.com/lichess-org/flutter-chessground", from: "10.0.0")
```

### Loading assets

Pass `ChessgroundAssets.bundle` wherever you load a board or piece image:

```swift
import ChessgroundAssets

// Board texture (image-backed themes)
Image("board_wood2", bundle: ChessgroundAssets.bundle)

// Piece image
Image("piece_staunty_wK", bundle: ChessgroundAssets.bundle)
```

**Asset naming conventions**

| Asset | Name pattern | Example |
|-------|-------------|---------|
| Board texture | `board_{name}` | `board_blueMarble`, `board_wood3` |
| Piece image | `piece_{set}_{color}{kind}` | `piece_staunty_wK`, `piece_california_bQ` |

`name` matches the Dart `ChessboardColorScheme` constant. `set` is the camelCase
piece-set name matching the Dart `PieceSet` enum `.name` value. `color` is `w`/`b`
and `kind` is `K`/`Q`/`R`/`B`/`N`/`P`.

### Board theme colours

`ChessboardTheme` maps Dart theme names to light/dark square colours, last-move
highlight, and board image name:

```swift
let theme = ChessboardTheme.from(themeName: "wood2", pieceSet: "staunty")

theme.lightSquare       // Color
theme.darkSquare        // Color
theme.lastMoveHighlight // Color
theme.boardImageName    // "board_wood2" — nil for solid-colour themes
theme.pieceSet          // "staunty"
```

Theme names and colour values mirror the Dart `ChessboardColorScheme` constants.
Unrecognised names fall back to the default brown solid-colour theme.

### Maintaining the Swift assets

The asset catalog at `swift/Sources/ChessgroundAssets/Assets.xcassets/` is
generated from the canonical Flutter assets in `assets/`. After adding, removing,
or updating board textures or piece sets, regenerate and commit:

```sh
./scripts/gen-swift-xcassets.sh
```

The script reads directly from `assets/` — no pub cache or Flutter tooling needed.
SPM consumers then get the updated assets by bumping to the new release tag.
