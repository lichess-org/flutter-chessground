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
```

CI uses Flutter **beta** channel.

## Architecture

### Public API

All public exports go through `lib/chessground.dart`. Internal implementation lives in `lib/src/`.

### Three Board Widgets

- **`Chessboard`** (`src/widgets/board.dart`) — Main interactive board. Two constructors: `Chessboard()` for interactive play (requires `GameData`) and `Chessboard.fixed()` for non-interactive display with animations.
- **`StaticChessboard`** (`src/widgets/static_board.dart`) — Read-only board optimized for scrollable contexts (uses deferred loading).
- **`ChessboardEditor`** (`src/widgets/board_editor.dart`) — Position editor with drag and edit pointer modes.

### Core Data Flow

The board is driven by immutable data objects:
- **`GameData`** — Holds game state (side to move, valid moves, premove state) and callbacks (`onMove`, `onPremove`). Any game state change requires creating a new `GameData` instance.
- **`ChessboardSettings`** — All visual and behavioral configuration (theme, animations, piece shift method, draw shapes, coordinates, etc.).
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
