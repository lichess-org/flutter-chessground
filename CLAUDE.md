# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Chessground is a Flutter chessboard UI package developed for lichess.org. It contains no chess logic — all game logic is handled externally via the `dartchess` dependency. The package is published on pub.dev as `chessground`.

## Commands

```bash
flutter pub get          # Install dependencies
flutter test             # Run all tests
flutter test test/fen_test.dart  # Run a single test file
flutter analyze          # Run static analysis (strict mode: strict-casts, strict-inference, strict-raw-types)
dart format lib/ test/   # Format all source files
```

CI uses Flutter **beta** channel.

## Architecture

### Public API

All public exports go through `lib/chessground.dart`. Internal implementation lives in `lib/src/`.

### Three Board Widgets

- **`Chessboard`** (`src/widgets/board.dart`) — The interactive board. Always requires a `ChessboardController`. To disable interaction (e.g. at game end) drive it with game data whose `playerSide` is `PlayerSide.none` (`controller.interactive` becomes `false`).
- **`StaticChessboard`** (`src/widgets/static_board.dart`) — The non-interactive board, optimized for scrollable contexts (deferred loading). Animates on FEN change. Configured via `StaticChessboardSettings` and supports `shapes`, `squareHighlights`, `onTouchedSquare`, and a border.
- **`ChessboardEditor`** (`src/widgets/board_editor.dart`) — Position editor with drag and edit pointer modes.

### Core Data Flow

The board is driven by a controller and immutable data objects:
- **`ChessboardController`** (`src/widgets/board_controller.dart`) — Owns board position, game state, and piece animations. Create once in `initState`, dispose in `dispose`.
  - `ChessboardController(game: game)` — the only constructor; drives a `Chessboard`. Use `game.playerSide == PlayerSide.none` for a non-interactive (but externally animated) board.
  - `updatePosition(GameData game, {bool animate = true, bool resetPremove = false})` — update the board position. Pass `animate: false` to switch without animation (e.g. history navigation). Pass `resetPremove: true` to clear any pending premove when jumping to an arbitrary position. Drag-and-drop suppression is automatic: the board records drops internally (`recordDropMove`) so the dropped piece is not re-animated.
- **`GameData`** — Immutable snapshot of board and game state: `fen`, `playerSide`, `sideToMove`, `validMoves`, `lastMove`, `kingSquareInCheck`, `validDropSquares`. It is the single source of truth driving the controller.
- **`ChessboardSettings`** — All visual and behavioral configuration (theme, animations, piece shift method, draw shapes, coordinates, `enableDrops`, etc.).
- **`Pieces`** (`Map<Square, Piece>`) — Board position, typically derived from FEN via `readFen()`.

### Shape System

`Shape` is a sealed class hierarchy with three variants: `Arrow`, `Circle`, and `PieceShape`. Shapes are drawn on the board via custom painters in `src/widgets/shape.dart`.

### Key Types (from dartchess)

`Square`, `Piece`, `Side`, `Move` come from the `dartchess` package. Collection types `IMap`/`ISet` come from `fast_immutable_collections`.

### Image Caching

`ChessgroundImages` is a singleton that manages piece image caching to prevent blinking during rebuilds. It supports optional precaching at app startup.

## Code Conventions

- Immutable data classes with `@immutable`, `copyWith()`, manual `==`/`hashCode`
- Single quotes for strings (enforced by linter)
- Linting via `package:lint/package.yaml` with all strict modes enabled
- All files must be formatted with `dart format` before committing
