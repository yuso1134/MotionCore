import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000510),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFF1a1a3e),
              Color(0xFF0a0a2e),
              Color(0xFF000510),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Stars background
            ...List.generate(50, (index) {
              final random = math.Random(index);
              return Positioned(
                left: random.nextDouble() * MediaQuery.of(context).size.width,
                top: random.nextDouble() * MediaQuery.of(context).size.height,
                child: Container(
                  width: random.nextDouble() * 3 + 1,
                  height: random.nextDouble() * 3 + 1,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with animation
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow rings
                        ...List.generate(3, (index) {
                          return Container(
                            width: 200 + (index * 30),
                            height: 200 + (index * 30),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.cyanAccent.withOpacity(0.3 - index * 0.1),
                                width: 2,
                              ),
                            ),
                          )
                              .animate(onPlay: (controller) => controller.repeat())
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1.2, 1.2),
                                duration: Duration(seconds: 2 + index),
                                curve: Curves.easeInOut,
                              )
                              .then()
                              .scale(
                                begin: const Offset(1.2, 1.2),
                                end: const Offset(0.8, 0.8),
                                duration: Duration(seconds: 2 + index),
                                curve: Curves.easeInOut,
                              );
                        }),
                        
                        // Main planet/core
                        Container(
                          width: 200,
                          height: 200,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.cyanAccent,
                                Colors.blueAccent,
                                Color(0xFF0040aa),
                                Color(0xFF001a3e),
                              ],
                              stops: [0.0, 0.3, 0.6, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 255, 255, 0.6),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'MC',
                              style: GoogleFonts.orbitron(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 5,
                                shadows: [
                                  Shadow(
                                    color: Colors.cyanAccent.withOpacity(0.8),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .scale(
                              begin: const Offset(0.0, 0.0),
                              end: const Offset(1.0, 1.0),
                              duration: 800.ms,
                              curve: Curves.elasticOut,
                            )
                            .then()
                            .animate(onPlay: (controller) => controller.repeat())
                            .scale(
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.05, 1.05),
                              duration: 2000.ms,
                              curve: Curves.easeInOut,
                            )
                            .then()
                            .scale(
                              begin: const Offset(1.05, 1.05),
                              end: const Offset(1.0, 1.0),
                              duration: 2000.ms,
                              curve: Curves.easeInOut,
                            ),
                        
                        // Inner core glow
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white,
                                Color.fromRGBO(0, 255, 255, 0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        )
                            .animate(onPlay: (controller) => controller.repeat())
                            .scale(
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.3, 1.3),
                              duration: 1500.ms,
                              curve: Curves.easeInOut,
                            )
                            .then()
                            .scale(
                              begin: const Offset(1.3, 1.3),
                              end: const Offset(1.0, 1.0),
                              duration: 1500.ms,
                              curve: Curves.easeInOut,
                            ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // App name
                  Text(
                    'MOTIONCORE',
                    style: GoogleFonts.orbitron(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                      letterSpacing: 8,
                      shadows: [
                        Shadow(
                          color: Colors.cyanAccent.withOpacity(0.8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 800.ms)
                      .slideY(begin: 0.3, end: 0, delay: 500.ms, duration: 800.ms),
                  
                  const SizedBox(height: 10),
                  
                  Text(
                    'Terraform Your Planet',
                    style: GoogleFonts.exo2(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 2,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 800.ms)
                      .slideY(begin: 0.3, end: 0, delay: 1000.ms, duration: 800.ms),
                  
                  const SizedBox(height: 60),
                  
                  // Loading indicator
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1500.ms, duration: 500.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
