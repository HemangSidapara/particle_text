import 'package:flutter/material.dart';
import 'package:particle_text/particle_text.dart';
import '../shared/models.dart';
import '../shared/widgets.dart';

class FullScreenTextDemo extends StatefulWidget {
  const FullScreenTextDemo({super.key});

  @override
  State<FullScreenTextDemo> createState() => _FullScreenTextDemoState();
}

class _FullScreenTextDemoState extends State<FullScreenTextDemo> {
  String _text = 'Flutter';
  bool _isEditing = false;
  late TextEditingController _controller;
  int _presetIndex = 0;
  double _fontSize = 160.0;
  bool _isDark = true;

  final List<Preset> _presets = [
    Preset('Default', ParticleConfig(fontSize: 160.0)),
    Preset('Cosmic', ParticleConfig.cosmic(fontSize: 160.0)),
    Preset('Fire', ParticleConfig.fire(fontSize: 160.0)),
    Preset('Matrix', ParticleConfig.matrix(fontSize: 160.0)),
    Preset('Pastel', ParticleConfig.pastel(fontSize: 160.0)),
    Preset('Minimal', ParticleConfig.minimal(fontSize: 160.0)),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get themeColor => _isDark ? Colors.white : Colors.black;

  @override
  Widget build(BuildContext context) {
    final preset = _presets[_presetIndex];
    final config = preset.config.copyWith(
      drawBackground: _presetIndex == 0 ? _isDark : null,
      backgroundColor: _presetIndex == 0 ? (_isDark ? const Color(0xFF020308) : Colors.transparent) : null,
      particleColor: _presetIndex == 0 ? (_isDark ? const Color(0xFF8CAADE) : const Color(0xFF020308)) : null,
      fontSize: _fontSize,
    );

    return Scaffold(
      backgroundColor: _isDark ? preset.config.backgroundColor : Colors.white,
      body: Stack(
        children: [
          ParticleText(text: _text, config: config),

          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: themeColor.withValues(alpha: 0.3)),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'TOUCH & DRAG TO INTERACT',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: themeColor.withValues(alpha: _isDark ? 0.15 : 0.5),
                      fontSize: 11,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                if (_presetIndex == 0) ...[
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _isDark = !_isDark),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isDark ? const Color(0xFF8CAADE) : const Color(0xFF020308),
                    ),
                    icon: Icon(
                      _isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: _isDark ? const Color(0xFF020308) : const Color(0xFF8CAADE),
                    ),
                    label: Text(
                      _isDark ? 'Dark' : 'Light',
                      style: TextStyle(
                        color: _isDark ? const Color(0xFF020308) : const Color(0xFF8CAADE),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 16),
              ],
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Preset chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: _presets.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final sel = index == _presetIndex;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _presetIndex = index;
                          _isDark = true;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: sel ? 0.12 : 0.04),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: themeColor.withValues(alpha: sel ? 0.25 : 0.08),
                            ),
                          ),
                          child: Text(
                            _presets[index].name,
                            style: TextStyle(
                              color: themeColor.withValues(alpha: sel ? 0.8 : 0.35),
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                buildSlider('Font Size', _fontSize, 60.0, 512.0, (v) => setState(() => _fontSize = v), themeColor),
                const SizedBox(height: 8),
                _isEditing ? _buildEditor() : _buildChangeButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: themeColor.withValues(alpha: 0.15)),
      ),
      child: TextField(
        controller: _controller,
        autofocus: true,
        textAlign: TextAlign.center,
        style: TextStyle(color: themeColor.withValues(alpha: 0.8), fontSize: 14),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        onSubmitted: (val) {
          if (val.trim().isNotEmpty) {
            setState(() {
              _text = val.trim();
              _isEditing = false;
            });
          }
        },
      ),
    );
  }

  Widget _buildChangeButton() {
    return GestureDetector(
      onTap: () => setState(() {
        _isEditing = true;
        _controller.text = _text;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: themeColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: themeColor.withValues(alpha: 0.08)),
        ),
        child: Text(
          'change text',
          style: TextStyle(
            color: themeColor.withValues(alpha: 0.35),
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
