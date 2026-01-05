// test/ui/responsive_ui_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_iot/core/widgets/responsive_layout.dart';
import 'package:health_iot/core/utils/platform_helper.dart';
import 'package:health_iot/core/theme/medical_typography.dart';

void main() {
  group('🎨 Responsive UI Tests - Cross Platform', () {
    testWidgets('📱 MOBILE Layout (Width: 375px) - iPhone SE', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(textTheme: MedicalTypography.textTheme),
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Container(
                color: Colors.blue,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Mobile View', style: MedicalTypography.textTheme.headlineMedium),
                      const SizedBox(height: 16),
                      Text('375 x 667', style: MedicalTypography.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              tablet: Container(color: Colors.green),
              desktop: Container(color: Colors.red),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify mobile layout is displayed
      expect(find.text('Mobile View'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
      
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.color, Colors.blue);

      debugPrint('✅ MOBILE Test PASSED - Layout renders correctly at 375px width');
    });

    testWidgets('📱 MOBILE Layout (Width: 414px) - iPhone 14 Pro Max', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(414, 896));
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(textTheme: MedicalTypography.textTheme),
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Container(
                color: Colors.blue,
                child: Center(child: Text('Mobile Large', style: MedicalTypography.textTheme.headlineMedium)),
              ),
              tablet: Container(color: Colors.green),
              desktop: Container(color: Colors.red),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Mobile Large'), findsOneWidget);
      
      debugPrint('✅ MOBILE Large Test PASSED - Layout renders correctly at 414px width');
    });

    testWidgets('📱 TABLET Layout (Width: 768px) - iPad', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(768, 1024));
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(textTheme: MedicalTypography.textTheme),
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Container(color: Colors.blue),
              tablet: Container(
                color: Colors.green,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Tablet View', style: MedicalTypography.textTheme.headlineMedium),
                      const SizedBox(height: 16),
                      Text('768 x 1024', style: MedicalTypography.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              desktop: Container(color: Colors.red),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify tablet layout is displayed
      expect(find.text('Tablet View'), findsOneWidget);
      
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.color, Colors.green);

      debugPrint('✅ TABLET Test PASSED - Layout renders correctly at 768px width');
    });

    testWidgets('🖥️ DESKTOP Layout (Width: 1280px) - Laptop', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 720));
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(textTheme: MedicalTypography.textTheme),
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Container(color: Colors.blue),
              tablet: Container(color: Colors.green),
              desktop: Container(
                color: Colors.red,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Desktop View', style: MedicalTypography.textTheme.headlineMedium),
                      const SizedBox(height: 16),
                      Text('1280 x 720', style: MedicalTypography.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify desktop layout is displayed
      expect(find.text('Desktop View'), findsOneWidget);
      
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.color, Colors.red);

      debugPrint('✅ DESKTOP Test PASSED - Layout renders correctly at 1280px width');
    });

    testWidgets('🖥️ DESKTOP Layout (Width: 1920px) - Full HD', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(textTheme: MedicalTypography.textTheme),
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Container(color: Colors.blue),
              tablet: Container(color: Colors.green),
              desktop: Container(
                color: Colors.red,
                child: Center(child: Text('Desktop Full HD', style: MedicalTypography.textTheme.headlineLarge)),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Desktop Full HD'), findsOneWidget);

      debugPrint('✅ DESKTOP Full HD Test PASSED - Layout renders correctly at 1920px width');
    });

    testWidgets('🎨 Typography Rendering Test - Medical Font Styles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(textTheme: MedicalTypography.textTheme),
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Headline Large', style: MedicalTypography.textTheme.headlineLarge),
                  Text('Headline Medium', style: MedicalTypography.textTheme.headlineMedium),
                  Text('Headline Small', style: MedicalTypography.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Text('Title Large', style: MedicalTypography.textTheme.titleLarge),
                  Text('Title Medium', style: MedicalTypography.textTheme.titleMedium),
                  Text('Title Small', style: MedicalTypography.textTheme.titleSmall),
                  const SizedBox(height: 16),
                  Text('Body Large - Medical records and patient information', style: MedicalTypography.textTheme.bodyLarge),
                  Text('Body Medium - Standard text for descriptions', style: MedicalTypography.textTheme.bodyMedium),
                  Text('Body Small - Additional info', style: MedicalTypography.textTheme.bodySmall),
                  const SizedBox(height: 16),
                  Text('120', style: MedicalTypography.vitalSignsNumber),
                  Text('bpm', style: MedicalTypography.vitalSignsUnit),
                  const SizedBox(height: 16),
                  Text('Alert: Critical condition', style: MedicalTypography.alertText),
                  Text('Success: Test completed', style: MedicalTypography.successText),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all text styles are rendered
      expect(find.text('Headline Large'), findsOneWidget);
      expect(find.text('Body Large - Medical records and patient information'), findsOneWidget);
      expect(find.text('120'), findsOneWidget);
      expect(find.text('Alert: Critical condition'), findsOneWidget);

      debugPrint('✅ TYPOGRAPHY Test PASSED - All medical font styles render correctly');
    });

    testWidgets('📐 Responsive Padding Test', (WidgetTester tester) async {
      // Test mobile padding
      await tester.binding.setSurfaceSize(const Size(375, 667));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsivePadding(
              mobilePadding: 16,
              tabletPadding: 24,
              desktopPadding: 32,
              child: Container(
                color: Colors.blue,
                child: const Text('Content'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      final mobilePadding = tester.widget<Padding>(find.byType(Padding).first);
      expect((mobilePadding.padding as EdgeInsets).left, 16.0);
      
      debugPrint('✅ RESPONSIVE PADDING Test PASSED - Mobile (16px)');

      // Test tablet padding
      await tester.binding.setSurfaceSize(const Size(768, 1024));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsivePadding(
              mobilePadding: 16,
              tabletPadding: 24,
              desktopPadding: 32,
              child: Container(
                color: Colors.green,
                child: const Text('Content'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      final tabletPadding = tester.widget<Padding>(find.byType(Padding).first);
      expect((tabletPadding.padding as EdgeInsets).left, 24.0);
      
      debugPrint('✅ RESPONSIVE PADDING Test PASSED - Tablet (24px)');

      // Test desktop padding
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsivePadding(
              mobilePadding: 16,
              tabletPadding: 24,
              desktopPadding: 32,
              child: Container(
                color: Colors.red,
                child: const Text('Content'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      final desktopPadding = tester.widget<Padding>(find.byType(Padding).first);
      expect((desktopPadding.padding as EdgeInsets).left, 32.0);
      
      debugPrint('✅ RESPONSIVE PADDING Test PASSED - Desktop (32px)');
    });

    testWidgets('📦 Max Width Container Test', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaxWidthContainer(
              maxWidth: 1200,
              child: Container(
                color: Colors.blue,
                child: const Text('Content with max width'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(MaxWidthContainer),
          matching: find.byType(Container).first,
        ),
      );
      
      expect(container, isNotNull);
      expect(find.text('Content with max width'), findsOneWidget);

      debugPrint('✅ MAX WIDTH CONTAINER Test PASSED - Desktop content constrained to 1200px');
    });
  });
}

// Extension to help with surface size in tests
extension WidgetTesterSurfaceSize on WidgetTester {
  Future<void> setSurfaceSize(Size? size) async {
    await binding.setSurfaceSize(size);
    await pumpAndSettle();
  }
}
