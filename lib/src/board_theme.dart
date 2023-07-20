import 'board_color_scheme.dart';

/// The chessboard theme.
enum BoardTheme {
  blue('Blue'),
  blue2('Blue2'),
  blue3('Blue3'),
  blueMarble('Blue Marble'),
  canvas('Canvas'),
  wood('Wood'),
  wood2('Wood2'),
  wood3('Wood3'),
  wood4('Wood4'),
  maple('Maple'),
  maple2('Maple 2'),
  brown('Brown'),
  leather('Leather'),
  green('Green'),
  marble('Marble'),
  greenPlastic('Green Plastic'),
  grey('Grey'),
  metal('Metal'),
  olive('Olive'),
  newspaper('Newspaper'),
  purpleDiag('Purple-Diag'),
  pinkPyramid('Pink'),
  horsey('Horsey');

  final String label;

  const BoardTheme(this.label);

  BoardColorScheme get colors {
    return switch (this) {
      BoardTheme.brown => BoardColorScheme.brown,
      BoardTheme.blue => BoardColorScheme.blue,
      BoardTheme.green => BoardColorScheme.green,
      BoardTheme.blue2 => BoardColorScheme.blue2,
      BoardTheme.blue3 => BoardColorScheme.blue3,
      BoardTheme.blueMarble => BoardColorScheme.blueMarble,
      BoardTheme.canvas => BoardColorScheme.canvas,
      BoardTheme.greenPlastic => BoardColorScheme.greenPlastic,
      BoardTheme.grey => BoardColorScheme.grey,
      BoardTheme.horsey => BoardColorScheme.horsey,
      BoardTheme.leather => BoardColorScheme.leather,
      BoardTheme.maple => BoardColorScheme.maple,
      BoardTheme.maple2 => BoardColorScheme.maple2,
      BoardTheme.marble => BoardColorScheme.marble,
      BoardTheme.metal => BoardColorScheme.metal,
      BoardTheme.newspaper => BoardColorScheme.newspaper,
      BoardTheme.olive => BoardColorScheme.olive,
      BoardTheme.pinkPyramid => BoardColorScheme.pinkPyramid,
      BoardTheme.purpleDiag => BoardColorScheme.purpleDiag,
      BoardTheme.wood => BoardColorScheme.wood,
      BoardTheme.wood2 => BoardColorScheme.wood2,
      BoardTheme.wood3 => BoardColorScheme.wood3,
      BoardTheme.wood4 => BoardColorScheme.wood4
    };
  }
}
