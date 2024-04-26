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
