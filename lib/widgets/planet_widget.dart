import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/planet_state.dart';

class PlanetWidget extends StatelessWidget {
  final PlanetState planetState;

  const PlanetWidget({
    super.key,
    required this.planetState,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final planetSize = math.min(constraints.maxWidth, constraints.maxHeight);

      return Center(
        child: SizedBox(
          width: planetSize,
          height: planetSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Arkaplan glow
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getSubtleGlowColor(),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
              // Ana gezegen
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: _getRealisticGradient(),
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
                child: CustomPaint(
                  painter: RealisticPlanetPainter(
                    planetState: planetState,
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat()).rotate(
                    duration: const Duration(seconds: 40),
                    curve: Curves.linear,
                  ),
            ],
          ),
        ),
      );
    });
  }

  Color _getSubtleGlowColor() {
    switch (planetState.phase) {
      case PlanetPhase.deadRock:
        return Colors.grey.withOpacity(0.15);
      case PlanetPhase.blueHope:
        return Colors.blue.withOpacity(0.2);
      case PlanetPhase.greenEden:
        return Colors.green.withOpacity(0.2);
    }
  }

  List<Color> _getRealisticGradient() {
    switch (planetState.phase) {
      case PlanetPhase.deadRock:
        return [
          const Color(0xFF3A3A3A),
          const Color(0xFF2D2D2D),
          const Color(0xFF1F1F1F),
          const Color(0xFF2D2D2D),
        ];
      case PlanetPhase.blueHope:
        return [
          const Color(0xFF1E3A5F),
          const Color(0xFF0F4C75),
          const Color(0xFF0A2E4D),
          const Color(0xFF1E3A5F),
        ];
      case PlanetPhase.greenEden:
        return [
          const Color(0xFF2D5016),
          const Color(0xFF1F3A0F),
          const Color(0xFF152A08),
          const Color(0xFF2D5016),
        ];
    }
  }
}

class RealisticPlanetPainter extends CustomPainter {
  final PlanetState planetState;

  RealisticPlanetPainter({
    required this.planetState,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Stage 1: Dead Rock - Her zaman temel kraterleri çiz
    paint.color = const Color(0xFF1A1A1A);
    _drawCrater(canvas, center, radius * 0.3, radius * 0.12, paint);
    paint.color = const Color(0xFF252525);
    _drawCrater(canvas, Offset(center.dx + radius * 0.5, center.dy - radius * 0.2), radius * 0.15, radius * 0.1, paint);

    // Gelişime göre su ekle
    if (planetState.hydrosphere > 0) {
      final waterPaint = Paint()
        ..color = Colors.blue.shade900.withOpacity(0.5 * planetState.hydrosphere)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, waterPaint);
    }

    // Gelişime göre atmosfer/bulut ekle
    if (planetState.atmosphere > 0) {
      final atmosPaint = Paint()
        ..color = Colors.white.withOpacity(0.15 * planetState.atmosphere)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
      canvas.drawCircle(center, radius * 1.1, atmosPaint);
    }
    
    // Gelişime göre bitki örtüsü ekle
    if (planetState.biosphere > 0) {
        final bioPaint = Paint()
        ..color = Colors.green.shade800.withOpacity(0.6 * planetState.biosphere)
        ..style = PaintingStyle.fill;
      _drawVegetationArea(canvas, center, radius * 0.3, radius * 0.4, bioPaint);
    }
  }

  void _drawCrater(Canvas canvas, Offset center, double radius, double depth, Paint paint) {
    final baseColor = paint.color;
    paint.color = baseColor.withOpacity(0.8);
    canvas.drawCircle(center, radius, paint);
    paint.color = baseColor.withOpacity(0.6);
    canvas.drawCircle(center, radius * 0.7, paint);
    paint.color = baseColor.withOpacity(0.3);
    canvas.drawCircle(Offset(center.dx - radius * 0.3, center.dy - radius * 0.3), radius * 0.2, paint);
    paint.color = baseColor;
  }

  void _drawVegetationArea(Canvas canvas, Offset center, double offsetX, double size, Paint paint) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + offsetX, center.dy - offsetX * 0.5),
        width: size,
        height: size * 0.7,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
