import 'package:flutter/material.dart';
import 'package:foodtrack/theme/app_colors.dart';

class PremiumBackground extends StatelessWidget {
  final Widget child;
  final bool showOrbs;
  final bool showGrid;

  const PremiumBackground({
    super.key,
    required this.child,
    this.showOrbs = true,
    this.showGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Base Ambient Color Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.bgGradient,
          ),
        ),
        // 2. Custom Painter for Orbs and Dotted Grid
        if (showOrbs || showGrid)
          Positioned.fill(
            child: CustomPaint(
              painter: _PremiumBackgroundPainter(
                showOrbs: showOrbs,
                showGrid: showGrid,
              ),
            ),
          ),
        // 3. Foreground Content
        Positioned.fill(child: child),
      ],
    );
  }
}

class _PremiumBackgroundPainter extends CustomPainter {
  final bool showOrbs;
  final bool showGrid;

  _PremiumBackgroundPainter({
    required this.showOrbs,
    required this.showGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showOrbs) {
      // 1. Top-Right Cyan/Blue Glow
      final paint1 = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.orbCyan,
            AppColors.orbCyan.withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.85, size.height * 0.15),
            radius: size.width * 0.65,
          ),
        );
      canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.15),
        size.width * 0.65,
        paint1,
      );

      // 2. Middle-Left Indigo/Purple Glow
      final paint2 = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.orbIndigo,
            AppColors.orbIndigo.withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.1, size.height * 0.55),
            radius: size.width * 0.75,
          ),
        );
      canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.55),
        size.width * 0.75,
        paint2,
      );

      // 3. Bottom-Right Amber/Orange Warm Glow
      final paint3 = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.orbAmber,
            AppColors.orbAmber.withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.8, size.height * 0.85),
            radius: size.width * 0.55,
          ),
        );
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.85),
        size.width * 0.55,
        paint3,
      );
    }

    if (showGrid) {
      final paintGrid = Paint()
        ..color = AppColors.gridColor
        ..style = PaintingStyle.fill;

      const spacing = 28.0;
      const dotRadius = 0.9;

      for (double x = spacing / 2; x < size.width; x += spacing) {
        for (double y = spacing / 2; y < size.height; y += spacing) {
          canvas.drawCircle(Offset(x, y), dotRadius, paintGrid);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumBackgroundPainter oldDelegate) {
    return oldDelegate.showOrbs != showOrbs || oldDelegate.showGrid != showGrid;
  }
}
