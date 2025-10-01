## 7.2.0

- Add RhosGFX piece set.
- Do not update the square all the time while panning in board editor.

## 7.1.6

Fix promotion selection order if player on top promotes

## 7.1.5

- Fix board image background not aligned with pieces on tablets.

## 7.1.4

- When piece shift method is set to `drag`, the piece will awlays be deselected
  when the pointer is released, even if the piece is dropped on the same square.

## 7.1.3

- Make board annotations always on top of shapes.

## 7.1.2

- Fix crash when calling `setState` in pointerUp, pointerMove or pointerCancel
  callbacks.
- flip pieces instead of rotating to keep the shadows in the same direction.

## 7.1.1

- Update dartchess to 0.11.0

## 7.1.0

- Expose 'BoardShapeWidget' class.

## 7.0.0

- Make the `hue` setting apply only to the board background to avoid changing
  board highlights colors.
- Update dependencies
- Update minimum Dart SDK version to 3.7.0 and minimum Flutter version to
  3.29.0

## 7.0.0-beta.1

- Update dependencies
- Update minimum Dart SDK version to 3.7.0 and minimum Flutter version to
  3.29.0

## 6.3.0

- Added an `onTouchedSquare` callback to `Chessboard`
- `Chessboard` now supports highlighting arbitrary squares.
- `StaticChessboard` now supports position change animations.

## 6.2.3

- Fix board editor color filter

## 6.2.2

- Fix default value of brightness

## 6.2.1

- Improved the color filter
- Values of hue and brightness are now precised in the documentation
- `BrightnessHueFilter` widget is now exposed.

## 6.2.0

- Add the possibility to change board colors

## 6.1.0

- Added a new `DragTargetKind` settings to control the appearance of the drag
  target.
- Detects if the drag is triggered with a mouse or a touch event, and adjust the
  drag settings accordingly to provide a better experience.
- Removed the `withValues` not yet available in specified dart sdk version.

## 6.0.0

### Breaking changes:
- Removed `ChessboardEditorSettings`. The `ChessboardEditor` widget now takes a
  `ChessboardSettings` object as a parameter.

### New features:
- Add a new `border` settings to show a border around the board.

### Bug fixes:
- Fixed a timer not properly canceled when the board is disposed.

## 5.3.0

- Added a new `StaticChessboard` widget that is optimized for scrollable
  contexts.
- `SolidColorChessboardBackground` is now implemented with `CustomPaint` to improve
  performance when building a lot of boards.
- Added a new board colorscheme: `ic`.

## 5.2.0

- Introduced a `ChessgroundImages` singleton to precache piece images. This is
  useful when using the same piece set in multiple places, and to avoid using the
  global flutter image cache, which can be unpredictable.
  It should prevent any "blinking" effect that could happen with the `Image`
  widget when the image is reloaded from the cache.

## 5.1.1

- Reset animation state when the board is updated. This fixes potential issues
  where the board would display ghost pieces on some conditions.

## 5.1.0

- Dragging a piece to the same square will now keep the piece selected.

## 5.0.0

- Added another `Chessboard.fixed` constructor that allows to set the board to a
  fixed position.
- Premove state is now lifted up to the parent widget, in order to allow
  instant play of premoves.
- Promotion state is now lifted up to the parent widget, in order to allow more
  control over the promotion dialog.
- Add symmetric piece set (`PieceAssets.symmetric`).
- `ChessboardEditor` now supports highlighting squares.
- Flip `BoardSettings.dragFeedbackOffset.dy` for flipped pieces.
  Support displaying all pieces upside down based on side to move.
- Fix: ensure the board background does not overflow the board.

### Breaking changes:
- `Chessboard` now require a `game` parameter of type `GameData` instead
  of `BoardData`.
- Added required parameters `piece` and `pieceAssets` to `PieceShape`, removed `role`. Added optional
  `opacity` parameter.
- Remove 'ChessboardState.opponentsPiecesUpsideDown' in favor of `ChessboardSettings.pieceOrientationBehavior`.

## 4.0.0

### New features:
- Add a `ChessboardEditor` widget, intended to be used as the basis for a board editor like lichess.org/editor.
- Add the `writeFen` helper function.

### Breaking changes:
- Requires an SDK version of at least 3.3.0.
- Chessground is now dependant on `dartchess`. It is only used for the models,
  and not for the game logic, so Chessground can still be used with any chess
  library.
- `Board` has been renamed to `Chessboard`, along with other classes.

### Bug fixes:
- Fix arrow bad shape when new destination is the same as the origin: it now
  returns a circle.
- Fix unsetting premoves:
    - When a premove is set, tapping on the same origin square will now unset
        it.
    - dragging a piece to an invalid square will now unset the premove.
    - dragging a piece off the board will now unset the premove.

## 3.2.0

- Add `pieceShiftMethod` to `BoardSetttings`, with possible values: `either` (default), `drag`, or `tapTwoSquares`.

## 3.1.2

- Any simultaneous touch on the board will now cancel the current piece
  selection or drag.

## 3.1.1

- Allow shapes to be drawn on a non-interactable board.
- Fix a bug where the board would be stuck after transitioning from a
  non-interactable board to an interactable one.
- Selecting a piece will now clear all shapes on the board.
- Add the `scale` property to all `Shape` classes. Use a 0.8 scale for the
  shapes being drawn on the board to distinguish them from the already drawn
  ones.

## 3.1.0

- Add an optional `scale` parameter to arrows (default is `scale: 1.0`, matching the previous behavior).
- Implement `BoardData.copyWith` method to allow updating the board data
- Implement `BoardData` equality and hashcode operators
- Implement `BoardSettings` equality and hashcode operators

## 3.0.0

Improve board interaction and add support for drawing shapes while playing.

### Playing:
- pieces are now moved with pointer down events, instead of a tap events
  (pointer down followed by a pointer up event): this allows to move a piece
  faster
- premoves are not anymore cleared when selecting another piece: this matches lichess website behaviour and allow to prepare another move along with the premove that is currently set

### Drawing shapes (experimental)
- drawing shapes is now possible while keeping the normal board play interaction (before it was either one or another mode)
- one can draw a shape by holding a finger to an empty square while using a second finger to draw a shape anywhere in the board
- a double tap on an empty square will clear all shapes at once
- to clear a single shape is still supported: draw the same shape again

## 2.6.4

- Fix coordinates and board display on devices with RightToLeft Directionality.

## 2.6.3

- Improve coordinates display on the board.

## 2.6.2

- Fix `borderRadius` settings not being applied to the board highlights.

## 2.6.1

- Fix BoardSettings `copyWith` method.

## 2.6.0

- Add 2 new settings: `borderRadius` and `boxShadow`.

## 2.5.0

- Add a new shape type: piece (useful to show promotion hints).

## 2.4.1

- Don't clip board: fix annotations display on edge.

## 2.4.0

- Deprecate `BoardTheme` and export `Background`.

## 2.3.0

- Remove handling of android gestures exclusion.

## 2.2.1

- Upgrade fast_immutable_collections to version 10.0.0.

## 2.2.0

- Improve quality of PNG files, fix wrong rendering of some piece set like
  "Cardinal". More info: https://github.com/lichess-org/flutter-chessground/pull/28.
- Piece cache size is now rounded to the nearest integer above the actual value.

## 2.1.0

- `BoardData.sideToMove` is now optional with no default value, as well as
`BoardData.isCheck` and constructor assertion will guarantee they are set when
needed.

## 2.0.0

- `BoardData.sideToMove` is now a required parameter.

## 1.6.1

- Fix missing blindfoldMode to BoardSettings.copyWith

## 1.6.0

- Add blindfold mode

## 1.5.3

- Don't run premove timer if premove is not set

## 1.5.2

- Don't try to execute a premove if it is not allowed.

## 1.5.1

- Use an immediate timer to execute premove, instead of a post frame callback.

## 1.5.0

- `premove` is not anymore a local state, so it can be controlled by the parent

## 1.4.1

- Change the `autoQueenPromotionOnPremove` default setting to true

## 1.4.0

- Add a drawing shapes option
- Add the `autoQueenPromotionOnPremove` setting

## 1.3.1

- Improve check highlight appearance and fix rendering with Impeller.

## 1.3.0

- Remove opacity on origin piece when dragging because of performance issue with
  impeller engine.

## 1.2.0

- Add `isDrop` meta info to `onMove` callback.

## 1.1.0

- Add Caliente, Kiwen-Suwi and MPChess piece sets
- Fix promotion menu still showing when going back in moves history

## 1.0.4

- tapping one's piece now cancels premove.

## 1.0.3

- `showValidMoves` board setting now applies to premoves.

## 1.0.2

- When premoving, tapping same piece will now deselect it (to be consistent with
normal moves).

## 1.0.1

- Ensure premove square highlight takes precedence over last move.

## 1.0.0

Initial release.
