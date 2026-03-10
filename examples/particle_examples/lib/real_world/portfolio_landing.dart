import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:particle_text/particle_text.dart';
import 'package:particle_image/particle_image.dart';

/// Real-world example: a developer portfolio landing page using
/// particle_text for the hero section and particle_image for project logos.
class PortfolioLandingDemo extends StatefulWidget {
  const PortfolioLandingDemo({super.key});

  @override
  State<PortfolioLandingDemo> createState() => _PortfolioLandingDemoState();
}

class _PortfolioLandingDemoState extends State<PortfolioLandingDemo> {
  final _scrollController = ScrollController();
  int _selectedTab = 0;
  int _roleIndex = 0;
  Timer? _roleTimer;

  // Section keys for scroll navigation
  final _heroKey = GlobalKey();
  final _workKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _contactKey = GlobalKey();

  final _roles = ['Flutter Dev', 'UI Designer', 'Open Source'];

  // Generated project card images
  final Map<String, ui.Image> _projectImages = {};

  @override
  void initState() {
    super.initState();
    _roleTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) setState(() => _roleIndex = (_roleIndex + 1) % _roles.length);
    });
    _generateProjectImages();
  }

  Future<void> _generateProjectImages() async {
    final projects = {
      'Qoodo': (Icons.shopping_bag_rounded, const Color(0xFF54C5F8)),
      'Manufacturer OMS': (Icons.factory_rounded, const Color(0xFF44DD66)),
      'particle_core': (Icons.grain_rounded, const Color(0xFF9BB5E8)),
      'particle_text': (Icons.text_fields_rounded, const Color(0xFFB0C8FF)),
      'particle_image': (Icons.image_rounded, const Color(0xFFC8D2F0)),
      'Contributions': (Icons.code_rounded, const Color(0xFFFFAA44)),
    };

    for (final entry in projects.entries) {
      final image = await _renderIconToImage(
        entry.value.$1,
        entry.value.$2,
        entry.key,
      );
      if (mounted) {
        setState(() => _projectImages[entry.key] = image);
      }
    }
  }

  Future<ui.Image> _renderIconToImage(IconData icon, Color color, String label) async {
    const size = 200;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 200, 200));

    // Draw icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 100,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset((size - iconPainter.width) / 2, (size - iconPainter.height) / 2 - 20),
    );

    // Draw label
    final labelPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(
      canvas,
      Offset((size - labelPainter.width) / 2, size - 50),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    picture.dispose();
    return image;
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 600), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _roleTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080E),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          _buildHeroSection(),
          _buildCompanySection(),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
          _buildFeaturedSection(),
          _buildProjectCards(),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
          _buildAboutSection(),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
          _buildContactSection(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      key: _heroKey,
      backgroundColor: const Color(0xFF08080E),
      pinned: true,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6E8FCC), Color(0xFF9BB5E8)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'H',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Hemang Sidapara',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
          ),
        ],
      ),
      actions: [
        _navButton('Work', () => _scrollTo(_workKey)),
        _navButton('About', () => _scrollTo(_aboutKey)),
        _navButton('Contact', () => _scrollTo(_contactKey)),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _navButton(String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
    );
  }

  Widget _buildHeroSection() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 420,
        child: Stack(
          children: [
            ParticleText(
              text: _roles[_roleIndex],
              config: const ParticleConfig(
                fontSize: 80,
                particleDensity: 3000,
                particleColor: Color(0xFF6E8FCC),
                displacedColor: Color(0xFFB0C8FF),
                backgroundColor: Color(0xFF08080E),
                pointerGlowColor: Color(0xFF8EAADD),
                repelForce: 6,
                returnSpeed: 0.03,
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'Hemang Sidapara',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.25),
                      fontSize: 14,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_roles.length, (i) {
                      return Container(
                        width: i == _roleIndex ? 20 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.white.withValues(alpha: i == _roleIndex ? 0.5 : 0.12),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanySection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CURRENTLY AT',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 11,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: ParticleImage.asset(
                'assets/mw_logo.png',
                config: const ParticleConfig(
                  particleDensity: 2500,
                  backgroundColor: Color(0xFF0C0C14),
                  repelForce: 5,
                  returnSpeed: 0.03,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return SliverToBoxAdapter(
      key: _workKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FEATURED PROJECTS',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 11,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(3, (i) {
                final sel = i == _selectedTab;
                final labels = ['Apps', 'Packages', 'OSS'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: sel ? 0.1 : 0.03),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: sel ? 0.2 : 0.06),
                        ),
                      ),
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: sel ? 0.8 : 0.3),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCards() {
    if (_selectedTab == 0) return _buildAppsGrid();
    if (_selectedTab == 1) return _buildPackagesGrid();
    return _buildOSSGrid();
  }

  Widget _buildAppsGrid() {
    final apps = [
      _ProjectInfo(
        'Qoodo',
        'E-commerce marketplace app for local businesses',
        'Flutter + Firebase + Stripe',
        Icons.shopping_bag_rounded,
        const Color(0xFF54C5F8),
        url: 'https://play.google.com/store/apps/details?id=com.io.qoodo&hl=en_IN',
      ),
      _ProjectInfo(
        'Manufacturer OMS',
        'Order management system for manufacturers',
        'Flutter + REST API + Riverpod',
        Icons.factory_rounded,
        const Color(0xFF44DD66),
      ),
    ];

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildProjectCard(apps[index]),
          childCount: apps.length,
        ),
      ),
    );
  }

  Widget _buildPackagesGrid() {
    final packages = [
      _ProjectInfo(
        'particle_core',
        'High-performance particle physics engine with single drawRawAtlas GPU call',
        'Dart + Flutter Custom Painter',
        Icons.grain_rounded,
        const Color(0xFF9BB5E8),
      ),
      _ProjectInfo(
        'particle_text',
        'Interactive particle text effect — text rendered as thousands of particles',
        'Depends on particle_core',
        Icons.text_fields_rounded,
        const Color(0xFFB0C8FF),
      ),
      _ProjectInfo(
        'particle_image',
        'Images rendered as interactive particles with per-pixel color',
        'Depends on particle_core',
        Icons.image_rounded,
        const Color(0xFFC8D2F0),
      ),
    ];

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildProjectCard(packages[index]),
          childCount: packages.length,
        ),
      ),
    );
  }

  Widget _buildOSSGrid() {
    final oss = [
      _ProjectInfo(
        'Flutter Contributions',
        'Contributed to Flutter ecosystem — packages, bug fixes, and community support',
        'Open Source',
        Icons.code_rounded,
        const Color(0xFFFFAA44),
      ),
      _ProjectInfo(
        'Particle Packages',
        'This very package suite — particle_core, particle_text, particle_image',
        'Pub.dev + GitHub',
        Icons.auto_awesome,
        const Color(0xFFFF6688),
      ),
    ];

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildProjectCard(oss[index]),
          childCount: oss.length,
        ),
      ),
    );
  }

  Widget _buildProjectCard(_ProjectInfo project) {
    final hasParticle = _projectImages.containsKey(project.title);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: project.color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: project.color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Particle image header
          if (hasParticle)
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                color: const Color(0xFF0C0C14),
              ),
              clipBehavior: Clip.antiAlias,
              child: ParticleImage(
                key: ValueKey(project.title),
                image: _projectImages[project.title],
                expand: false,
                config: ParticleConfig(
                  particleDensity: 2000,
                  backgroundColor: const Color(0xFF0C0C14),
                  repelForce: 5,
                  returnSpeed: 0.03,
                  pointerGlowColor: project.color.withValues(alpha: 0.6),
                ),
              ),
            )
          else
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                color: project.color.withValues(alpha: 0.06),
              ),
              child: Center(
                child: Icon(project.icon, color: project.color.withValues(alpha: 0.3), size: 48),
              ),
            ),

          // Card content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(project.icon, color: project.color, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      project.title,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (project.url != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.open_in_new, color: project.color.withValues(alpha: 0.4), size: 14),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  project.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: project.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    project.tech,
                    style: TextStyle(
                      color: project.color.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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

  Widget _buildAboutSection() {
    return SliverToBoxAdapter(
      key: _aboutKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ABOUT',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 11,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flutter developer passionate about high-performance rendering, '
                    'creative UI effects, and known skills',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _skillChip('Flutter'),
                      _skillChip('Dart'),
                      _skillChip('Firebase'),
                      _skillChip('Custom Painters'),
                      _skillChip('BLoC'),
                      _skillChip('Riverpod'),
                      _skillChip('CI/CD'),
                      _skillChip('REST APIs'),
                      _skillChip('Kotlin'),
                      _skillChip('Swift'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6E8FCC).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6E8FCC).withValues(alpha: 0.15)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF9BB5E8).withValues(alpha: 0.8),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return SliverToBoxAdapter(
      key: _contactKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GET IN TOUCH',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 11,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6E8FCC).withValues(alpha: 0.08),
                    const Color(0xFF9BB5E8).withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF6E8FCC).withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Text(
                    'Interested in working together?',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Always open to exciting Flutter projects and collaborations.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _contactButton(Icons.email_rounded, 'Email'),
                      const SizedBox(width: 12),
                      _contactButton(Icons.code_rounded, 'GitHub'),
                      const SizedBox(width: 12),
                      _contactButton(Icons.work_rounded, 'LinkedIn'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Divider(
              color: Colors.white.withValues(alpha: 0.06),
              indent: 24,
              endIndent: 24,
            ),
            const SizedBox(height: 16),
            Text(
              'Built with particle_text & particle_image',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.2),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Back to demos',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectInfo {
  final String title;
  final String description;
  final String tech;
  final IconData icon;
  final Color color;
  final String? url;

  const _ProjectInfo(
    this.title,
    this.description,
    this.tech,
    this.icon,
    this.color, {
    this.url,
  });
}
