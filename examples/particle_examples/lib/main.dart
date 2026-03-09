import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:particle_image/particle_image.dart';
import 'package:particle_text/particle_text.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Particle Examples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HOME
// ═══════════════════════════════════════════════════════════════════════════════

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final demos = <_DemoItem>[
      _DemoItem(
        'Full Screen',
        'Expands to fill entire screen with preset switcher',
        Icons.fullscreen,
        () => const FullScreenDemo(),
      ),
      _DemoItem(
        'SizedBox (Fixed Size)',
        'Multiple fixed-size particle widgets on one page',
        Icons.crop_square,
        () => const SizedBoxDemo(),
      ),
      _DemoItem(
        'Expanded (Flex Layout)',
        'ParticleText inside Column with AppBar & controls',
        Icons.expand,
        () => const ExpandedDemo(),
      ),
      _DemoItem(
        'Auto Morphing',
        'Text cycles through words automatically',
        Icons.autorenew,
        () => const AutoMorphDemo(),
      ),
      _DemoItem(
        'Custom Colors',
        'Live sliders for particle/background colors',
        Icons.palette,
        () => const CustomColorsDemo(),
      ),
      _DemoItem(
        'Performance Test',
        'Adjust particle density live with FPS counter',
        Icons.speed,
        () => const PerformanceDemo(),
      ),
      _DemoItem(
        'Splash Screen',
        'Realistic app intro animation',
        Icons.launch,
        () => const SplashDemo(),
      ),
      _DemoItem(
        'Image to Particles',
        'Convert any image into interactive particles',
        Icons.image,
        () => const ImageParticleDemo(),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A10),
      appBar: AppBar(
        title: const Text('Particle Examples'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: demos.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final demo = demos[index];
          return _DemoTile(
            title: demo.title,
            subtitle: demo.subtitle,
            icon: demo.icon,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => demo.builder()),
            ),
          );
        },
      ),
    );
  }
}

class _DemoItem {
  final String title, subtitle;
  final IconData icon;
  final Widget Function() builder;

  const _DemoItem(this.title, this.subtitle, this.icon, this.builder);
}

class _DemoTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _DemoTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.4), size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEMO 1: Full Screen
// ═══════════════════════════════════════════════════════════════════════════════

class FullScreenDemo extends StatefulWidget {
  const FullScreenDemo({super.key});

  @override
  State<FullScreenDemo> createState() => _FullScreenDemoState();
}

class _FullScreenDemoState extends State<FullScreenDemo> {
  String _text = 'Flutter';
  bool _isEditing = false;
  late TextEditingController _controller;
  int _presetIndex = 0;

  double _fontSize = 160.0;

  bool _isDark = true;

  final List<_Preset> _presets = [
    _Preset('Default', ParticleConfig(fontSize: 160.0)),
    _Preset('Cosmic', ParticleConfig.cosmic(fontSize: 160.0)),
    _Preset('Fire', ParticleConfig.fire(fontSize: 160.0)),
    _Preset('Matrix', ParticleConfig.matrix(fontSize: 160.0)),
    _Preset('Pastel', ParticleConfig.pastel(fontSize: 160.0)),
    _Preset('Minimal', ParticleConfig.minimal(fontSize: 160.0)),
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
      backgroundColor: _presetIndex == 0
          ? _isDark
                ? const Color(0xFF020308)
                : Colors.transparent
          : null,
      particleColor: _presetIndex == 0
          ? _isDark
                ? const Color(0xFF8CAADE)
                : Color(0xFF020308)
          : null,
      fontSize: _fontSize,
    );
    return Scaffold(
      backgroundColor: _isDark ? preset.config.backgroundColor : Colors.white.withValues(alpha: 0.3),
      body: Stack(
        children: [
          ParticleText(
            text: _text,
            config: config,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: themeColor.withValues(alpha: 0.3),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                SizedBox(width: 64),
                Expanded(
                  child: Text(
                    'TOUCH & DRAG TO INTERACT',
                    style: TextStyle(
                      color: themeColor.withValues(alpha: _isDark ? 0.15 : 0.5),
                      fontSize: 11,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isDark = !_isDark;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isDark ? const Color(0xFF8CAADE) : Color(0xFF020308),
                  ),
                  icon: Icon(
                    _isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: _isDark ? const Color(0xFF020308) : Color(0xFF8CAADE),
                  ),
                  label: Text(
                    _isDark ? "Dark" : "Light",
                    style: TextStyle(
                      color: _isDark ? const Color(0xFF020308) : Color(0xFF8CAADE),
                    ),
                  ),
                ),
                SizedBox(width: 16),
              ],
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                        onTap: () {
                          setState(() {
                            _presetIndex = index;
                            _isDark = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(
                              alpha: sel ? 0.12 : 0.04,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: themeColor.withValues(
                                alpha: sel ? 0.25 : 0.08,
                              ),
                            ),
                          ),
                          child: Text(
                            _presets[index].name,
                            style: TextStyle(
                              color: themeColor.withValues(
                                alpha: sel ? 0.8 : 0.35,
                              ),
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
                _slider(
                  'Font Size',
                  _fontSize,
                  60.0,
                  512.0,
                  (v) => setState(() => _fontSize = v),
                ),
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
        style: TextStyle(
          color: themeColor.withValues(alpha: 0.8),
          fontSize: 14,
        ),
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

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
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
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEMO 2: SizedBox (Fixed Size)
// ═══════════════════════════════════════════════════════════════════════════════

class SizedBoxDemo extends StatelessWidget {
  const SizedBoxDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A10),
      appBar: AppBar(
        title: const Text('SizedBox Examples'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sizedBoxCard(
              'Fixed 400×200',
              400,
              200,
              'Hello',
              ParticleConfig.cosmic(),
            ),
            const SizedBox(height: 32),
            _sizedBoxCard(
              'Fixed 300×150',
              300,
              150,
              'Fire',
              ParticleConfig.fire(),
            ),
            const SizedBox(height: 32),
            _sizedBoxCard(
              'Fixed 250×120',
              250,
              120,
              'Mini',
              ParticleConfig.matrix(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sizedBoxCard(
    String label,
    double w,
    double h,
    String text,
    ParticleConfig config,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: w,
              height: h,
              child: ParticleText(text: text, expand: false, config: config),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEMO 3: Expanded (Flex Layout)
// ═══════════════════════════════════════════════════════════════════════════════

class ExpandedDemo extends StatefulWidget {
  const ExpandedDemo({super.key});

  @override
  State<ExpandedDemo> createState() => _ExpandedDemoState();
}

class _ExpandedDemoState extends State<ExpandedDemo> {
  String _text = 'Expand';
  int _selectedIndex = 0;

  final _configs = [
    ParticleConfig.cosmic(),
    ParticleConfig.fire(),
    ParticleConfig.pastel(),
  ];
  final _labels = ['Cosmic', 'Fire', 'Pastel'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _configs[_selectedIndex].backgroundColor,
      appBar: AppBar(
        title: const Text('Expanded Example'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Text:',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: TextField(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _text,
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          setState(() => _text = val.trim());
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ParticleText(text: _text, config: _configs[_selectedIndex]),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        selectedItemColor: Colors.white.withValues(alpha: 0.9),
        unselectedItemColor: Colors.white.withValues(alpha: 0.3),
        onTap: (i) => setState(() => _selectedIndex = i),
        items: List.generate(
          _labels.length,
          (i) => BottomNavigationBarItem(
            icon: const Icon(Icons.auto_awesome),
            label: _labels[i],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEMO 4: Auto Morphing
// ═══════════════════════════════════════════════════════════════════════════════

class AutoMorphDemo extends StatefulWidget {
  const AutoMorphDemo({super.key});

  @override
  State<AutoMorphDemo> createState() => _AutoMorphDemoState();
}

class _AutoMorphDemoState extends State<AutoMorphDemo> {
  final _fontSize = 160.0;
  final _words = ['Flutter', 'Dart', 'Particle', 'Provider', 'BLoC', 'Riverpod', 'GetX', 'Kotlin', 'Swift'];
  int _index = 0;
  late Timer _timer;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_paused) {
        setState(() => _index = (_index + 1) % _words.length);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05060F),
      body: Stack(
        children: [
          ParticleText(
            text: _words[_index],
            config: ParticleConfig.cosmic(fontSize: _fontSize),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Current word indicator
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Word dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_words.length, (i) {
                    return Container(
                      width: i == _index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: i == _index ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.15),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // Pause/play button
                GestureDetector(
                  onTap: () => setState(() => _paused = !_paused),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _paused ? Icons.play_arrow : Icons.pause,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _paused ? 'Resume' : 'Auto-morphing',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEMO 5: Custom Colors
// ═══════════════════════════════════════════════════════════════════════════════

class CustomColorsDemo extends StatefulWidget {
  const CustomColorsDemo({super.key});

  @override
  State<CustomColorsDemo> createState() => _CustomColorsDemoState();
}

class _CustomColorsDemoState extends State<CustomColorsDemo> {
  final double _fontSize = 220.0;
  double _hue = 220;
  double _brightness = 0.02;
  double _repelForce = 8;
  double _returnSpeed = 0.04;

  ParticleConfig _buildConfig() {
    final base = HSLColor.fromAHSL(1, _hue, 0.5, 0.55).toColor();
    final displaced = HSLColor.fromAHSL(1, _hue, 0.4, 0.85).toColor();
    final glow = HSLColor.fromAHSL(1, _hue, 0.5, 0.75).toColor();
    final bg = Color.from(
      alpha: 1,
      red: _brightness,
      green: _brightness,
      blue: _brightness + 0.02,
    );

    return ParticleConfig(
      particleColor: base,
      displacedColor: displaced,
      pointerGlowColor: glow,
      backgroundColor: bg,
      repelForce: _repelForce,
      returnSpeed: _returnSpeed,
      fontSize: _fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _buildConfig();

    return Scaffold(
      backgroundColor: config.backgroundColor,
      appBar: AppBar(
        title: const Text('Custom Colors'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ParticleText(text: 'Color', config: config),
          ),
          // Controls panel
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            child: Column(
              children: [
                _slider('Hue', _hue, 0, 360, (v) => setState(() => _hue = v)),
                _slider(
                  'Background',
                  _brightness,
                  0,
                  0.15,
                  (v) => setState(() => _brightness = v),
                ),
                _slider(
                  'Repel Force',
                  _repelForce,
                  1,
                  20,
                  (v) => setState(() => _repelForce = v),
                ),
                _slider(
                  'Return Speed',
                  _returnSpeed,
                  0.01,
                  0.1,
                  (v) => setState(() => _returnSpeed = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
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
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                activeTrackColor: Colors.white.withValues(alpha: 0.3),
                inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
                thumbColor: Colors.white.withValues(alpha: 0.7),
                overlayColor: Colors.white.withValues(alpha: 0.05),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 45,
            child: Text(
              value.toStringAsFixed(value < 1 ? 2 : 0),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEMO 6: Performance Test
// ═══════════════════════════════════════════════════════════════════════════════

class PerformanceDemo extends StatefulWidget {
  const PerformanceDemo({super.key});

  @override
  State<PerformanceDemo> createState() => _PerformanceDemoState();
}

class _PerformanceDemoState extends State<PerformanceDemo> {
  double _density = 2000;
  int _frameCount = 0;
  double _fps = 0;
  late Timer _fpsTimer;
  DateTime _lastTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // FPS counter: measure every second
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastTime).inMilliseconds;
      if (elapsed > 0) {
        setState(() {
          _fps = (_frameCount * 1000.0 / elapsed);
          _frameCount = 0;
          _lastTime = now;
        });
      }
    });
    // Count frames via post-frame callback
    WidgetsBinding.instance.addPostFrameCallback(_countFrame);
  }

  void _countFrame(Duration _) {
    _frameCount++;
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback(_countFrame);
    }
  }

  @override
  void dispose() {
    _fpsTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final effectiveCount = ParticleConfig(
      particleDensity: _density,
    ).effectiveParticleCount(size);

    return Scaffold(
      backgroundColor: const Color(0xFF020308),
      appBar: AppBar(
        title: const Text('Performance Test'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ParticleText(
                  text: 'FPS',
                  config: ParticleConfig(particleDensity: _density),
                ),
                // FPS overlay
                Positioned(
                  top: 12,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_fps.toStringAsFixed(1)} FPS',
                      style: TextStyle(
                        color: _fps >= 55
                            ? const Color(0xFF44FF66)
                            : _fps >= 30
                            ? const Color(0xFFFFCC44)
                            : const Color(0xFFFF4444),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Controls
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Particle Density',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '~$effectiveCount particles',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    activeTrackColor: Colors.white.withValues(alpha: 0.3),
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
                    thumbColor: Colors.white.withValues(alpha: 0.8),
                    overlayColor: Colors.white.withValues(alpha: 0.05),
                  ),
                  child: Slider(
                    value: _density,
                    min: 500,
                    max: 8000,
                    onChanged: (v) => setState(() => _density = v),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '500',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.25),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '8000',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.25),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEMO 7: Splash Screen
// ═══════════════════════════════════════════════════════════════════════════════

class SplashDemo extends StatefulWidget {
  const SplashDemo({super.key});

  @override
  State<SplashDemo> createState() => _SplashDemoState();
}

class _SplashDemoState extends State<SplashDemo> with SingleTickerProviderStateMixin {
  bool _showSplash = true;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    // After 3 seconds, fade out and show the "app"
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _opacity = 0.0);
    });
  }

  void _onFadeComplete() {
    if (_opacity == 0.0 && mounted) {
      setState(() => _showSplash = false);
    }
  }

  void _restart() {
    setState(() {
      _showSplash = true;
      _opacity = 1.0;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _opacity = 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_showSplash) {
      // The "real app" after splash
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A10),
        appBar: AppBar(
          title: const Text('My App'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'App loaded!',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.replay),
                label: const Text('Replay Splash'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Back to demos',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Splash screen
    return Scaffold(
      backgroundColor: const Color(0xFF020308),
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 800),
        onEnd: _onFadeComplete,
        child: Stack(
          children: [
            ParticleText(
              text: 'MyApp',
              config: const ParticleConfig(
                particleDensity: 2500,
                particleColor: Color(0xFF6E8FCC),
                displacedColor: Color(0xFFB0C8FF),
                backgroundColor: Color(0xFF020308),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEMO 8: Image to Particles
// ═══════════════════════════════════════════════════════════════════════════════

class ImageParticleDemo extends StatefulWidget {
  const ImageParticleDemo({super.key});

  @override
  State<ImageParticleDemo> createState() => _ImageParticleDemoState();
}

class _ImageParticleDemoState extends State<ImageParticleDemo> {
  ui.Image? _image;
  int _selectedIcon = 0;
  bool _isAssetMode = false;

  // We generate images programmatically so no assets needed
  final _icons = [
    _IconDef('Flutter Logo', Icons.flutter_dash, const Color(0xFF54C5F8)),
    _IconDef('Heart', Icons.favorite, const Color(0xFFFF4466)),
    _IconDef('Star', Icons.star, const Color(0xFFFFCC00)),
    _IconDef('Music', Icons.music_note, const Color(0xFF88FF88)),
    _IconDef('Rocket', Icons.rocket_launch, const Color(0xFFFF8844)),
  ];

  @override
  void initState() {
    super.initState();
    _generateImage(_selectedIcon);
  }

  /// Renders a Material Icon into a [ui.Image] at high resolution.
  Future<void> _generateImage(int index) async {
    final def = _icons[index];
    const size = 256;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
    );

    // Draw the icon using TextPainter with the Material Icons font
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(def.icon.codePoint),
        style: TextStyle(
          fontSize: 200,
          fontFamily: def.icon.fontFamily,
          package: def.icon.fontPackage,
          color: def.color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset((size - iconPainter.width) / 2, (size - iconPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    picture.dispose();

    if (mounted) {
      setState(() {
        _image = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050508),
      appBar: AppBar(
        title: const Text('Image to Particles'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isAssetMode
                ? Column(
                    mainAxisSize: .min,
                    children: [
                      Flexible(
                        child: ParticleImage.asset(
                          'assets/flutter_logo.png',
                          key: const ValueKey('asset-flutter'),
                          config: const ParticleConfig(
                            particleDensity: 2500,
                            backgroundColor: Color(0xFF050508),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      Expanded(
                        child: ParticleImage.asset(
                          'assets/mw_logo.png',
                          key: const ValueKey('asset-mw'),
                          config: const ParticleConfig(
                            particleDensity: 2500,
                            backgroundColor: Color(0xFF050508),
                          ),
                        ),
                      ),
                    ],
                  )
                : _image != null
                ? ParticleImage(
                    key: ValueKey(_selectedIcon),
                    image: _image,
                    config: const ParticleConfig(
                      particleDensity: 2500,
                      backgroundColor: Color(0xFF050508),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
          ),
          // Selector
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Tap an icon to see it as particles',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Asset PNG button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isAssetMode = true;
                            _selectedIcon = -1;
                          });
                        },
                        child: Container(
                          width: 52,
                          height: 52,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _isAssetMode
                                ? const Color(
                                    0xFF54C5F8,
                                  ).withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isAssetMode
                                  ? const Color(
                                      0xFF54C5F8,
                                    ).withValues(alpha: 0.4)
                                  : Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                color: _isAssetMode ? const Color(0xFF54C5F8) : Colors.white.withValues(alpha: 0.35),
                                size: 20,
                              ),
                              Text(
                                'PNG',
                                style: TextStyle(
                                  color: _isAssetMode ? const Color(0xFF54C5F8) : Colors.white.withValues(alpha: 0.35),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Icon buttons
                      ...List.generate(_icons.length, (i) {
                        final sel = !_isAssetMode && i == _selectedIcon;
                        final def = _icons[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              if (_isAssetMode || i != _selectedIcon) {
                                _selectedIcon = i;
                                _isAssetMode = false;
                                _generateImage(i);
                              }
                            },
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: sel ? def.color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: sel ? def.color.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Icon(
                                def.icon,
                                color: sel ? def.color : Colors.white.withValues(alpha: 0.35),
                                size: 26,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconDef {
  final String name;
  final IconData icon;
  final Color color;

  const _IconDef(this.name, this.icon, this.color);
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _Preset {
  final String name;
  final ParticleConfig config;

  const _Preset(this.name, this.config);
}
