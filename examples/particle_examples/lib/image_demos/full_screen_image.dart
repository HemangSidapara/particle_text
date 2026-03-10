import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:particle_image/particle_image.dart';
import '../shared/models.dart';

class FullScreenImageDemo extends StatefulWidget {
  const FullScreenImageDemo({super.key});

  @override
  State<FullScreenImageDemo> createState() => _FullScreenImageDemoState();
}

class _FullScreenImageDemoState extends State<FullScreenImageDemo> {
  ui.Image? _image;
  int _selectedIcon = -1; // -1 means asset mode
  int _bgMode = 0; // 0=dark, 1=light, 2=transparent

  final _icons = [
    IconDef('Heart', Icons.favorite, const Color(0xFFFF4466)),
    IconDef('Star', Icons.star, const Color(0xFFFFCC00)),
    IconDef('Music', Icons.music_note, const Color(0xFF88FF88)),
    IconDef('Rocket', Icons.rocket_launch, const Color(0xFFFF8844)),
  ];

  final _assets = ['assets/flutter_logo.png', 'assets/mw_logo.png'];
  int _assetIndex = 0;

  final _bgLabels = ['Dark', 'Light', 'Transparent'];

  Color get _bgColor {
    switch (_bgMode) {
      case 1:
        return Colors.white;
      case 2:
        return Colors.transparent;
      default:
        return const Color(0xFF050508);
    }
  }

  Color get _scaffoldBg {
    switch (_bgMode) {
      case 1:
        return Colors.white;
      case 2:
        return const Color(0xFFF5F5F5);
      default:
        return const Color(0xFF050508);
    }
  }

  Color get themeColor => _bgMode == 0 ? Colors.white : Colors.black;

  ParticleConfig get _config => ParticleConfig(
    particleDensity: 3000,
    drawBackground: _bgMode != 2,
    backgroundColor: _bgColor,
    showPointerGlow: _bgMode == 0,
    pointerGlowColor: _bgMode == 0 ? const Color(0xFFC8D2F0) : Colors.grey,
  );

  Future<void> _generateIcon(int index) async {
    final def = _icons[index];
    const size = 256;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()));

    final painter = TextPainter(
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
    painter.layout();
    painter.paint(canvas, Offset((size - painter.width) / 2, (size - painter.height) / 2));

    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    picture.dispose();

    if (mounted) setState(() => _image = image);
  }

  @override
  Widget build(BuildContext context) {
    final isAssetMode = _selectedIcon < 0;

    return Scaffold(
      backgroundColor: _scaffoldBg,
      body: Stack(
        children: [
          if (isAssetMode)
            ParticleImage.asset(
              _assets[_assetIndex],
              key: ValueKey('asset-$_assetIndex-$_bgMode'),
              config: _config,
            )
          else if (_image != null)
            ParticleImage(
              key: ValueKey('icon-$_selectedIcon-$_bgMode'),
              image: _image,
              config: _config,
            )
          else
            Center(child: CircularProgressIndicator(color: themeColor.withValues(alpha: 0.3))),

          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: themeColor.withValues(alpha: 0.4)),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                Text(
                  'TOUCH & DRAG',
                  style: TextStyle(color: themeColor.withValues(alpha: 0.2), fontSize: 10, letterSpacing: 2),
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_bgMode == 0 ? Colors.black : Colors.white).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: themeColor.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Background mode
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Background: ', style: TextStyle(color: themeColor.withValues(alpha: 0.4), fontSize: 11)),
                      ...List.generate(3, (i) {
                        final sel = i == _bgMode;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => setState(() => _bgMode = i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: sel ? 0.15 : 0.04),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: themeColor.withValues(alpha: sel ? 0.3 : 0.08)),
                              ),
                              child: Text(
                                _bgLabels[i],
                                style: TextStyle(color: themeColor.withValues(alpha: sel ? 0.9 : 0.35), fontSize: 11),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Image selector
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...List.generate(_assets.length, (i) {
                          final sel = isAssetMode && i == _assetIndex;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _selectedIcon = -1;
                                _assetIndex = i;
                              }),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: sel
                                      ? const Color(0xFF54C5F8).withValues(alpha: 0.15)
                                      : themeColor.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: sel
                                        ? const Color(0xFF54C5F8).withValues(alpha: 0.4)
                                        : themeColor.withValues(alpha: 0.08),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      color: sel ? const Color(0xFF54C5F8) : themeColor.withValues(alpha: 0.35),
                                      size: 18,
                                    ),
                                    Text(
                                      i == 0 ? 'Logo1' : 'Logo2',
                                      style: TextStyle(
                                        color: sel ? const Color(0xFF54C5F8) : themeColor.withValues(alpha: 0.35),
                                        fontSize: 7,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        ...List.generate(_icons.length, (i) {
                          final sel = !isAssetMode && i == _selectedIcon;
                          final def = _icons[i];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                if (isAssetMode || i != _selectedIcon) {
                                  _selectedIcon = i;
                                  _generateIcon(i);
                                }
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: sel ? def.color.withValues(alpha: 0.15) : themeColor.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: sel ? def.color.withValues(alpha: 0.4) : themeColor.withValues(alpha: 0.08),
                                  ),
                                ),
                                child: Icon(
                                  def.icon,
                                  color: sel ? def.color : themeColor.withValues(alpha: 0.35),
                                  size: 24,
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
          ),
        ],
      ),
    );
  }
}
