import 'package:flutter/material.dart';

// Text demos
import 'text_demos/full_screen_text.dart';
import 'text_demos/sized_box_text.dart';
import 'text_demos/expanded_text.dart';
import 'text_demos/auto_morph.dart';
import 'text_demos/custom_colors.dart';
import 'text_demos/text_performance.dart';
import 'text_demos/splash_demo.dart';

// Image demos
import 'image_demos/full_screen_image.dart';
import 'image_demos/sized_box_image.dart';
import 'image_demos/expanded_image.dart';
import 'image_demos/image_performance.dart';

// Real-world
import 'real_world/portfolio_landing.dart';

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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A10),
        appBar: AppBar(
          title: const Text('Particle Examples'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white.withValues(alpha: 0.6),
            labelColor: Colors.white.withValues(alpha: 0.9),
            unselectedLabelColor: Colors.white.withValues(alpha: 0.35),
            tabs: const [
              Tab(icon: Icon(Icons.text_fields), text: 'Text'),
              Tab(icon: Icon(Icons.image), text: 'Image'),
              Tab(icon: Icon(Icons.web), text: 'Real World'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(_textDemos),
            _buildList(_imageDemos),
            _buildList(_realWorldDemos),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<_Demo> demos) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: demos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final demo = demos[index];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => demo.builder())),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(demo.icon, color: Colors.white.withValues(alpha: 0.4), size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        demo.title,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        demo.subtitle,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white.withValues(alpha: 0.2)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Demo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function() builder;

  const _Demo(this.title, this.subtitle, this.icon, this.builder);
}

final _textDemos = [
  _Demo('Full Screen', 'Preset switcher & dark/light mode', Icons.fullscreen, () => const FullScreenTextDemo()),
  _Demo('SizedBox', 'Multiple fixed-size widgets', Icons.crop_square, () => const SizedBoxTextDemo()),
  _Demo('Expanded', 'ParticleText in flex layout', Icons.expand, () => const ExpandedTextDemo()),
  _Demo('Auto Morphing', 'Text cycles automatically', Icons.autorenew, () => const AutoMorphDemo()),
  _Demo('Custom Colors', 'Live HSL sliders', Icons.palette, () => const CustomColorsDemo()),
  _Demo('Performance', 'Density + FPS counter', Icons.speed, () => const TextPerformanceDemo()),
  _Demo('Splash Screen', 'Animated app intro', Icons.launch, () => const SplashDemo()),
];

final _imageDemos = [
  _Demo('Full Screen', 'Dark/light/transparent background', Icons.fullscreen, () => const FullScreenImageDemo()),
  _Demo('SizedBox', 'Fixed-size image widgets', Icons.crop_square, () => const SizedBoxImageDemo()),
  _Demo('Expanded', 'ParticleImage in flex layout', Icons.expand, () => const ExpandedImageDemo()),
  _Demo('Performance', 'Density + FPS counter', Icons.speed, () => const ImagePerformanceDemo()),
];

final _realWorldDemos = [
  _Demo('Portfolio Landing', 'Developer portfolio with particle hero', Icons.web, () => const PortfolioLandingDemo()),
];
