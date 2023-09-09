import 'board_color_scheme.dart';

/// The chessboard theme.
enum BoardTheme {
  blue('Blue', BoardColorScheme.blue),
  blue2('Blue2', BoardColorScheme.blue2),
  blue3('Blue3', BoardColorScheme.blue3),
  blueMarble('Blue Marble', BoardColorScheme.blueMarble),
  canvas('Canvas', BoardColorScheme.canvas),
  wood('Wood', BoardColorScheme.wood),
  wood2('Wood2', BoardColorScheme.wood2),
  wood3('Wood3', BoardColorScheme.wood3),
  wood4('Wood4', BoardColorScheme.wood4),
  maple('Maple', BoardColorScheme.maple),
  maple2('Maple 2', BoardColorScheme.maple2),
  brown('Brown', BoardColorScheme.brown),
  leather('Leather', BoardColorScheme.leather),
  green('Green', BoardColorScheme.green),
  marble('Marble', BoardColorScheme.marble),
  greenPlastic('Green Plastic', BoardColorScheme.greenPlastic),
  grey('Grey', BoardColorScheme.grey),
  metal('Metal', BoardColorScheme.metal),
  olive('Olive', BoardColorScheme.olive),
  newspaper('Newspaper', BoardColorScheme.newspaper),
  purpleDiag('Purple-Diag', BoardColorScheme.purpleDiag),
  pinkPyramid('Pink', BoardColorScheme.pinkPyramid),
  horsey('Horsey', BoardColorScheme.horsey);

  final String label;

  final BoardColorScheme colors;

  const BoardTheme(this.label, this.colors);
}
