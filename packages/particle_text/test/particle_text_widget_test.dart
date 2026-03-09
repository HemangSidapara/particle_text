import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:particle_text/particle_text.dart';

void main() {
  group('ParticleText Widget', () {
    Widget buildApp({
      String text = 'Test',
      ParticleConfig config = const ParticleConfig(particleCount: 100),
      bool expand = true,
      VoidCallback? onTextChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ParticleText(
            text: text,
            config: config,
            expand: expand,
            onTextChanged: onTextChanged,
          ),
        ),
      );
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ParticleText), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ParticleText),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains RepaintBoundary for performance', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.descendant(
          of: find.byType(ParticleText),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('expands to fill parent by default', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 100));

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(ParticleText),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, double.infinity);
      expect(sizedBox.height, double.infinity);
    });

    testWidgets('contains GestureDetector for touch input', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.descendant(
          of: find.byType(ParticleText),
          matching: find.byType(GestureDetector),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains MouseRegion for hover input', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.descendant(
          of: find.byType(ParticleText),
          matching: find.byType(MouseRegion),
        ),
        findsOneWidget,
      );
    });

    testWidgets('handles text change via rebuild', (tester) async {
      await tester.pumpWidget(buildApp(text: 'Hello'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ParticleText), findsOneWidget);

      await tester.pumpWidget(buildApp(text: 'World'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ParticleText), findsOneWidget);
    });

    testWidgets('handles pan gestures without crashing', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 100));

      final gesture = find.descendant(
        of: find.byType(ParticleText),
        matching: find.byType(GestureDetector),
      );
      final center = tester.getCenter(gesture);
      final testGesture = await tester.startGesture(center);
      await tester.pump(const Duration(milliseconds: 50));
      await testGesture.moveBy(const Offset(50, 30));
      await tester.pump(const Duration(milliseconds: 50));
      await testGesture.up();
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('works with all presets', (tester) async {
      final presets = [
        const ParticleConfig(),
        ParticleConfig.cosmic(),
        ParticleConfig.fire(),
        ParticleConfig.matrix(),
        ParticleConfig.pastel(),
        ParticleConfig.minimal(),
      ];

      for (final preset in presets) {
        await tester.pumpWidget(buildApp(config: preset));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(ParticleText), findsOneWidget);
      }
    });

    testWidgets('works with non-expanding mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 200,
                child: ParticleText(
                  text: 'Small',
                  config: ParticleConfig(particleCount: 50),
                  expand: false,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ParticleText), findsOneWidget);
    });

    testWidgets('onTextChanged callback fires on text change', (tester) async {
      bool callbackFired = false;
      String text = 'Hello';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Expanded(
                      child: ParticleText(
                        text: text,
                        config: const ParticleConfig(particleCount: 50),
                        onTextChanged: () => callbackFired = true,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => text = 'World'),
                      child: const Text('Change'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(callbackFired, isFalse);

      await tester.tap(find.text('Change'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(callbackFired, isTrue);
    });
  });
}
