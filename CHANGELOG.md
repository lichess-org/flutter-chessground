## 1.0.0

Initial release.

## 1.0.1

- Ensure premove square highlight takes precedence over last move.

## 1.0.2

- When premoving, tapping same piece will now deselect it (to be consistent with
normal moves).

## 1.0.3

- `showValidMoves` board setting now applies to premoves.

## 1.0.4

- tapping one's piece now cancels premove.

## 1.1.0

- Add Caliente, Kiwen-Suwi and MPChess piece sets
- Fix promotion menu still showing when going back in moves history

## 1.2.0

- Add `isDrop` meta info to `onMove` callback.

## 1.3.0

- Remove opacity on origin piece when dragging because of performance issue with
  impeller engine.
