import 'package:board_example/board_theme.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:material_ui/material_ui.dart';

/// A page to test the board brightness, contrast and hue adjustments.
///
/// Slider ranges are the same as the ones used on lichess.org.
class BoardColorFilterPage extends StatefulWidget {
  const BoardColorFilterPage({super.key});

  @override
  State<BoardColorFilterPage> createState() => _BoardColorFilterPageState();
}

class _BoardColorFilterPageState extends State<BoardColorFilterPage> {
  BoardTheme boardTheme = BoardTheme.brown;
  double brightness = 1.0;
  double contrast = 1.0;
  double hue = 0.0;

  bool get isDefault => brightness == 1.0 && contrast == 1.0 && hue == 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Board Color Filter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset',
            onPressed: isDefault
                ? null
                : () => setState(() {
                      brightness = 1.0;
                      contrast = 1.0;
                      hue = 0.0;
                    }),
          ),
        ],
      ),
      body: ListView(
        children: [
          LayoutBuilder(
            builder: (context, constraints) => StaticChessboard(
              size: constraints.maxWidth,
              orientation: Side.white,
              fen: kInitialFEN,
              lastMove: const NormalMove(from: Square.e2, to: Square.e4),
              settings: StaticChessboardSettings(
                colorScheme: boardTheme.colors,
                enableCoordinates: true,
                brightness: brightness,
                contrast: contrast,
                hue: hue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Board theme'),
            trailing: DropdownButton<BoardTheme>(
              value: boardTheme,
              onChanged: (value) {
                if (value != null) setState(() => boardTheme = value);
              },
              items: [
                for (final theme in BoardTheme.values)
                  DropdownMenuItem(value: theme, child: Text(theme.label)),
              ],
            ),
          ),
          _AdjustmentSlider(
            label: 'Brightness',
            value: brightness,
            min: 0.2,
            max: 1.4,
            divisions: 120,
            valueLabel: '${(brightness * 100).round()}%',
            onChanged: (value) => setState(() => brightness = value),
          ),
          _AdjustmentSlider(
            label: 'Contrast',
            value: contrast,
            min: 0.4,
            max: 2.0,
            divisions: 80,
            valueLabel: '${(contrast * 100).round()}%',
            onChanged: (value) => setState(() => contrast = value),
          ),
          _AdjustmentSlider(
            label: 'Hue',
            value: hue,
            min: 0.0,
            max: 360.0,
            divisions: 100,
            valueLabel: '+ ${hue.round()}°',
            onChanged: (value) => setState(() => hue = value),
          ),
        ],
      ),
    );
  }
}

class _AdjustmentSlider extends StatelessWidget {
  const _AdjustmentSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueLabel,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String valueLabel;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(valueLabel)],
      ),
      subtitle: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}
