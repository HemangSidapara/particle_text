import 'package:flutter/material.dart';

Widget buildSlider(
  String label,
  double value,
  double min,
  double max,
  ValueChanged<double> onChanged,
  Color themeColor,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: themeColor.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
        Text(
          min.toStringAsFixed(min < 1 ? 2 : 0),
          style: TextStyle(color: themeColor.withValues(alpha: 0.25), fontSize: 9),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: themeColor.withValues(alpha: 0.3),
              inactiveTrackColor: themeColor.withValues(alpha: 0.08),
              thumbColor: themeColor.withValues(alpha: 0.7),
              overlayColor: themeColor.withValues(alpha: 0.05),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        Text(
          max.toStringAsFixed(max < 1 ? 2 : 0),
          style: TextStyle(color: themeColor.withValues(alpha: 0.25), fontSize: 9),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 45,
          child: Text(
            value.toStringAsFixed(value < 1 ? 2 : 0),
            textAlign: TextAlign.right,
            style: TextStyle(
              color: themeColor.withValues(alpha: 0.35),
              fontSize: 11,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildFpsOverlay(double fps) {
  return Positioned(
    top: 12,
    right: 16,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${fps.toStringAsFixed(1)} FPS',
        style: TextStyle(
          color: fps >= 55
              ? const Color(0xFF44FF66)
              : fps >= 30
              ? const Color(0xFFFFCC44)
              : const Color(0xFFFF4444),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    ),
  );
}

Widget buildPerfControls({
  required double density,
  double? fontSize,
  required int effectiveCount,
  required ValueChanged<double> onDensityChanged,
  ValueChanged<double>? onFontSizeChanged,
}) {
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.5),
      border: Border(
        top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
    ),
    child: Column(
      children: [
        _perfSlider(
          title: 'Particle Density',
          valueLabel: '~$effectiveCount particles',
          densityLabel: 'density: ${density.toStringAsFixed(0)}',
          value: density,
          min: 500,
          max: 15000,
          onChanged: onDensityChanged,
        ),
        if (fontSize != null && onFontSizeChanged != null) ...[
          const SizedBox(height: 8),
          _perfSlider(
            title: 'Font Size',
            valueLabel: '~${fontSize.toStringAsFixed(0)} px',
            value: fontSize,
            min: 40,
            max: 512,
            onChanged: onFontSizeChanged,
          ),
        ],
      ],
    ),
  );
}

Widget _perfSlider({
  required String title,
  required String valueLabel,
  String? densityLabel,
  required double value,
  required double min,
  required double max,
  required ValueChanged<double> onChanged,
}) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
          if (densityLabel != null)
            Text(densityLabel, style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
          Text(
            valueLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Row(
        children: [
          Text(
            min.toStringAsFixed(min < 1 ? 2 : 0),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 9),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                activeTrackColor: Colors.white.withValues(alpha: 0.3),
                inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
                thumbColor: Colors.white.withValues(alpha: 0.8),
                overlayColor: Colors.white.withValues(alpha: 0.05),
              ),
              child: Slider(value: value, min: min, max: max, onChanged: onChanged),
            ),
          ),
          Text(
            max.toStringAsFixed(max < 1 ? 2 : 0),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 9),
          ),
        ],
      ),
    ],
  );
}
