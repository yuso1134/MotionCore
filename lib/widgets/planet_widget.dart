import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/planet_state.dart';
import '../providers/motion_core_provider.dart';

class PlanetWidget extends StatefulWidget {
  final PlanetState planetState;

  const PlanetWidget({
    super.key,
    required this.planetState,
  });

  @override
  State<PlanetWidget> createState() => _PlanetWidgetState();
}

class _PlanetWidgetState extends State<PlanetWidget> {
  late int _randomSeed;

  @override
  void initState() {
    super.initState();
    _randomSeed = math.Random().nextInt(10000);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MotionCoreProvider>(context);
    
    final bool isDeadRock = widget.planetState.phase == PlanetPhase.deadRock;
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
              // 1. Arkaplan Glow
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

              // 2. Parçacık Efektleri
              if (isParticlesActive)
                ...List.generate(8 + (widget.planetState.humanity * 10).toInt(), (index) {
                  return Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 2 + math.Random(_randomSeed + index).nextDouble() * 3,
                        height: 2 + math.Random(_randomSeed + index).nextDouble() * 3,
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

              // 3. Ana Gezegen Çizimi
              ClipOval(
                child: Container(
                  width: planetSize,
                  height: planetSize,
                  color: Colors.transparent, 
                  child: CustomPaint(
                    painter: PlanetSurfacePainter(
                      planetState: widget.planetState,
                      customColor: customColor,
                      seed: _randomSeed,
                    ),
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat()).rotate(
                duration: Duration(seconds: 120 - (widget.planetState.humanity * 80).toInt().clamp(0, 100)), 
                curve: Curves.linear,
              ),
              
              // 4. Gölge Katmanı (Daha şeffaf)
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
                      Colors.black.withOpacity(0.1), 
                      Colors.black.withOpacity(0.4), 
                      Colors.black.withOpacity(0.8),
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
    switch (widget.planetState.phase) {
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
  final Color? customColor;
  final int seed;

  PlanetSurfacePainter({
    required this.planetState,
    this.customColor,
    required this.seed,
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

  void _drawDeadRock(Canvas canvas, Offset center, double radius) {
    final Paint basePaint = Paint()..style = PaintingStyle.fill;
    basePaint.color = const Color(0xFF888888); 
    canvas.drawCircle(center, radius, basePaint);

    final mariaPaint = Paint()..color = Colors.black.withOpacity(0.15);
    final random = math.Random(seed);

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

  void _drawBlueHope(Canvas canvas, Offset center, double radius) {
    final Paint oceanPaint = Paint()
      ..color = const Color(0xFF1565C0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, oceanPaint);

    final Paint landPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.fill;

    double bioScale = 0.5 + (planetState.biosphere * 0.5);
    _drawContinents(canvas, center, radius, landPaint, seed: seed + 1, scale: bioScale, count: 4 + (planetState.biosphere * 4).toInt());

    if (planetState.atmosphere > 0) {
      _drawClouds(canvas, center, radius, seed + 3, opacity: 0.2 + (planetState.atmosphere * 0.4), count: (planetState.atmosphere * 8).toInt());
    }
  }

  void _drawGreenEden(Canvas canvas, Offset center, double radius) {
    final Paint landPaint = Paint()
      ..color = Color.lerp(const Color(0xFF4E342E), const Color(0xFF1B5E20), planetState.biosphere)!
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, landPaint);

    final Paint waterPaint = Paint()
      ..color = const Color(0xFF0277BD)
      ..style = PaintingStyle.fill;

    _drawContinents(canvas, center, radius, waterPaint, seed: seed + 4, scale: 0.6, count: 3 + (planetState.hydrosphere * 5).toInt());

    // ŞEHİR IŞIKLARI - Green Eden'de daha belirgin olmalı
    // Humanity 0 ise çizme, > 0 ise çiz.
    if (planetState.humanity > 0) {
        _drawCityLights(canvas, center, radius, planetState.humanity, seed + 5);
    }

    if (planetState.atmosphere > 0) {
        _drawClouds(canvas, center, radius, seed + 6, opacity: 0.2 + (planetState.atmosphere * 0.5), count: (planetState.atmosphere * 10).toInt());
    }
  }

  // Basitleştirilmiş ve Garantili Işık Çizimi
  void _drawCityLights(Canvas canvas, Offset center, double radius, double intensity, int seed) {
      if (intensity <= 0) return;

      final random = math.Random(seed);
      final lightColor = customColor != null 
          ? customColor!.withOpacity(1.0) 
          : Colors.amberAccent.shade100.withOpacity(1.0); 
      
      final lightPaint = Paint()..color = lightColor..style = PaintingStyle.fill;
      
      // Işık sayısı: En az 20, en çok 300
      int lightCount = 20 + (intensity * 280).toInt(); 

      for (int i = 0; i < lightCount; i++) {
          // Gezegenin GÖRÜNEN yüzeyine (içine) rastgele dağılım
          // Radius'un %80'i içine dağıtıyoruz ki kenarlarda kaybolmasın
          final angle = random.nextDouble() * 2 * math.pi;
          final dist = random.nextDouble() * radius * 0.8;
          
          final dx = math.cos(angle) * dist;
          final dy = math.sin(angle) * dist;
          
          Offset point = center + Offset(dx, dy);
          
          // Işık boyutu: Belirgin (2.0 - 4.5 arası)
          double lightSize = 2.0 + (random.nextDouble() * 2.5); 
          
          // Glow efekti
          canvas.drawCircle(point, lightSize * 2.0, Paint()..color = lightColor.withOpacity(0.3));
          // Ana ışık noktası
          canvas.drawCircle(point, lightSize, lightPaint);
      }
  }

  void _drawContinents(Canvas canvas, Offset center, double radius, Paint paint, {required int seed, double scale = 1.0, int count = 5}) {
    final random = math.Random(seed);
    for (int i = 0; i < count; i++) {
      final dx = (random.nextDouble() - 0.5) * 1.6 * radius;
      final dy = (random.nextDouble() - 0.5) * 1.6 * radius;
      
      final path = Path();
      final blobCenter = center + Offset(dx, dy);
      final blobRadius = (20 + random.nextDouble() * 40) * scale;
      
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

  void _drawClouds(Canvas canvas, Offset center, double radius, int seed, {double opacity = 0.4, int count = 5}) {
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(opacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final random = math.Random(seed);
    List<Offset> cloudPositions = [];

    int attempts = 0;
    int drawn = 0;
    
    while (drawn < count && attempts < 100) {
        attempts++;
        final dx = (random.nextDouble() - 0.5) * radius * 1.6;
        final dy = (random.nextDouble() - 0.5) * radius * 1.2;
        final position = center + Offset(dx, dy);
        
        bool tooClose = false;
        for (var pos in cloudPositions) {
            if ((position - pos).distance < radius * 0.4) {
                tooClose = true;
                break;
            }
        }
        
        if (!tooClose) {
            cloudPositions.add(position);
            drawn++;
            canvas.drawOval(
                Rect.fromCenter(
                    center: position, 
                    width: radius * (0.4 + random.nextDouble() * 0.4), 
                    height: radius * 0.2
                ), 
                cloudPaint
            );
        }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
