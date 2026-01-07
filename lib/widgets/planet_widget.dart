import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/planet_state.dart';
import '../providers/motion_core_provider.dart';

class PlanetWidget extends StatelessWidget {
  final PlanetState planetState;

  const PlanetWidget({
    super.key,
    required this.planetState,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MotionCoreProvider>(context);
    
    // DEAD ROCK (Stage 1) kontrolü
    final bool isDeadRock = planetState.phase == PlanetPhase.deadRock;
    
    final bool isNeonActive = !isDeadRock && provider.isNeonGlowActive;
    final bool isParticlesActive = !isDeadRock && provider.isParticleEffectsActive;
    final Color? customColor = !isDeadRock ? provider.customPlanetColor : null;

    return LayoutBuilder(builder: (context, constraints) {
      final planetSize = math.min(constraints.maxWidth, constraints.maxHeight);

      return Center(
        child: SizedBox(
          width: planetSize,
          height: planetSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Arkaplan Glow (Sadece Glow rengi değişir)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isNeonActive 
                          ? (customColor ?? _getAtmosphereColor()).withOpacity(0.8) 
                          : (customColor?.withOpacity(0.4) ?? _getAtmosphereColor().withOpacity(0.1)),
                      blurRadius: isNeonActive ? 60 : 30,
                      spreadRadius: isNeonActive ? 10 : 1,
                    ),
                  ],
                ),
              ),

              // 2. Parçacık Efektleri (Custom Color kullanır)
              if (isParticlesActive)
                ...List.generate(8, (index) {
                  return Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 2 + math.Random().nextDouble() * 3,
                        height: 2 + math.Random().nextDouble() * 3,
                        decoration: BoxDecoration(
                          color: (customColor ?? _getAtmosphereColor()).withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .custom(
                    duration: Duration(seconds: 4 + index),
                    builder: (context, value, child) {
                      final angle = value * 2 * math.pi + index;
                      final radius = planetSize * 0.55 + (index * 5);
                      return Transform.translate(
                        offset: Offset(
                          math.cos(angle) * radius,
                          math.sin(angle) * radius * 0.4,
                        ),
                        child: child,
                      );
                    },
                  );
                }),

              // 3. Ana Gezegen Çizimi (Yüzey rengi değişmez, sadece orijinal renkler)
              ClipOval(
                child: Container(
                  width: planetSize,
                  height: planetSize,
                  color: Colors.transparent, 
                  child: CustomPaint(
                    painter: PlanetSurfacePainter(
                      planetState: planetState,
                      // customColor'ı buraya göndermiyoruz, böylece yüzey rengi değişmeyecek
                    ),
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat()).rotate(
                duration: const Duration(seconds: 120),
                curve: Curves.linear,
              ),
              
              // 4. Gölge Katmanı
              Container(
                width: planetSize,
                height: planetSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.5, -0.5),
                    radius: 1.3,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                      Colors.black,
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Color _getAtmosphereColor() {
    switch (planetState.phase) {
      case PlanetPhase.deadRock:
        return Colors.grey;
      case PlanetPhase.blueHope:
        return Colors.blueAccent;
      case PlanetPhase.greenEden:
        return Colors.greenAccent;
    }
  }
}

class PlanetSurfacePainter extends CustomPainter {
  final PlanetState planetState;
  // customColor parametresi kaldırıldı, sadece orijinal renkler kullanılacak

  PlanetSurfacePainter({
    required this.planetState,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    switch (planetState.phase) {
      case PlanetPhase.deadRock:
        _drawDeadRock(canvas, center, radius);
        break;
      case PlanetPhase.blueHope:
        _drawBlueHope(canvas, center, radius);
        break;
      case PlanetPhase.greenEden:
        _drawGreenEden(canvas, center, radius);
        break;
    }
  }

  // PHASE 1: DEAD ROCK
  void _drawDeadRock(Canvas canvas, Offset center, double radius) {
    final Paint basePaint = Paint()..style = PaintingStyle.fill;
    
    // Zemin Rengi - Sabit Gri
    basePaint.color = const Color(0xFF888888); 
    canvas.drawCircle(center, radius, basePaint);

    final mariaPaint = Paint()..color = Colors.black.withOpacity(0.15);
    final random = math.Random(999);

    for (int i = 0; i < 5; i++) {
        final dx = (random.nextDouble() - 0.5) * 1.2 * radius;
        final dy = (random.nextDouble() - 0.5) * 1.2 * radius;
        final r = radius * (0.2 + random.nextDouble() * 0.2);
        
        canvas.drawOval(
            Rect.fromCenter(center: center + Offset(dx, dy), width: r*1.2, height: r), 
            mariaPaint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        );
    }

    final craterPaint = Paint()..color = const Color(0xFF666666);
    
    _drawMoonCrater(canvas, center + Offset(radius * 0.2, -radius * 0.3), radius * 0.15, craterPaint);
    _drawMoonCrater(canvas, center + Offset(-radius * 0.4, radius * 0.1), radius * 0.12, craterPaint);
    _drawMoonCrater(canvas, center + Offset(radius * 0.1, radius * 0.5), radius * 0.08, craterPaint);
    
    for (int i = 0; i < 15; i++) {
        final dx = (random.nextDouble() - 0.5) * 1.6 * radius;
        final dy = (random.nextDouble() - 0.5) * 1.6 * radius;
        final r = radius * (0.02 + random.nextDouble() * 0.04);
        
        if (dx*dx + dy*dy < radius*radius * 0.8) {
            _drawMoonCrater(canvas, center + Offset(dx, dy), r, craterPaint);
        }
    }
  }
  
  void _drawMoonCrater(Canvas canvas, Offset pos, double r, Paint basePaint) {
      canvas.drawCircle(pos, r, basePaint);
      
      final shadowPaint = Paint()..color = Colors.black.withOpacity(0.5)..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: pos, radius: r), 0, math.pi, false, shadowPaint);
      
      canvas.drawCircle(pos + Offset(-r*0.1, -r*0.1), r*0.9, Paint()..color = Colors.black.withOpacity(0.2));
  }

  // PHASE 2: BLUE HOPE
  void _drawBlueHope(Canvas canvas, Offset center, double radius) {
    final Paint oceanPaint = Paint()
      ..color = const Color(0xFF1565C0) // Sabit Mavi
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, oceanPaint);

    final Paint landPaint = Paint()
      ..color = const Color(0xFF2E7D32) // Sabit Yeşil
      ..style = PaintingStyle.fill;

    _drawContinents(canvas, center, radius, landPaint, seed: 456);

    if (planetState.atmosphere > 0) {
      _drawClouds(canvas, center, radius, 789);
    }
  }

  // PHASE 3: GREEN EDEN
  void _drawGreenEden(Canvas canvas, Offset center, double radius) {
    final Paint landPaint = Paint()
      ..color = const Color(0xFF1B5E20) // Sabit Koyu Yeşil
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, landPaint);

    final Paint waterPaint = Paint()
      ..color = const Color(0xFF0277BD) // Sabit Mavi
      ..style = PaintingStyle.fill;

    _drawContinents(canvas, center, radius, waterPaint, seed: 999, scale: 0.6);

    final random = math.Random(101);
    final lightPaint = Paint()..color = Colors.amber.withOpacity(0.7);
    for (int i = 0; i < 30; i++) {
        final dx = (random.nextDouble() - 0.5) * 1.4 * radius;
        final dy = (random.nextDouble() - 0.5) * 1.4 * radius;
        if (dx*dx + dy*dy < radius*radius * 0.8) {
            canvas.drawCircle(center + Offset(dx, dy), 1.2, lightPaint);
        }
    }

    _drawClouds(canvas, center, radius, 202);
  }

  void _drawContinents(Canvas canvas, Offset center, double radius, Paint paint, {required int seed, double scale = 1.0}) {
    final random = math.Random(seed);
    for (int i = 0; i < 7; i++) {
      final dx = (random.nextDouble() - 0.5) * 1.6 * radius;
      final dy = (random.nextDouble() - 0.5) * 1.6 * radius;
      
      final path = Path();
      final blobCenter = center + Offset(dx, dy);
      final blobRadius = (25 + random.nextDouble() * 45) * scale;
      
      path.moveTo(blobCenter.dx + blobRadius, blobCenter.dy);
      for (double angle = 0; angle < math.pi * 2; angle += 0.4) {
        final r = blobRadius * (0.7 + random.nextDouble() * 0.5);
        path.lineTo(
          blobCenter.dx + math.cos(angle) * r,
          blobCenter.dy + math.sin(angle) * r
        );
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawClouds(Canvas canvas, Offset center, double radius, int seed) {
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final random = math.Random(seed);
    for (int i = 0; i < 5; i++) {
        final dx = (random.nextDouble() - 0.5) * radius * 1.2;
        final dy = (random.nextDouble() - 0.5) * radius * 0.8;
        
        canvas.drawOval(
            Rect.fromCenter(
                center: center + Offset(dx, dy), 
                width: radius * 0.7, 
                height: radius * 0.25
            ), 
            cloudPaint
        );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
