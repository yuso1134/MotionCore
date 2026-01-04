import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/motion_core_provider.dart';
import '../models/planet_state.dart';
import '../widgets/planet_widget.dart';
import '../widgets/starry_background.dart';
import '../widgets/neon_container.dart';
import '../widgets/animated_button.dart';
import '../widgets/smooth_page_transition.dart';
import '../utils/formatters.dart';
import 'terraforming_console_screen.dart';
import 'missions_screen.dart';
import 'statistics_screen.dart';
import 'market_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavIndex = 0;

  int _calculateProgressPercentage(int steps) {
    const int milestone = 10000;
    final progress = (steps % milestone) / milestone * 100;
    return progress.toInt().clamp(0, 100);
  }

  int _getNextMilestone(int steps) {
    const int milestone = 10000;
    return ((steps ~/ milestone) + 1) * milestone;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return Scaffold(
      backgroundColor: const Color(0xFF000510),
      body: StarryBackground(
        child: SafeArea(
          child: Consumer<MotionCoreProvider>(
            builder: (context, provider, child) {
              final energy = provider.energyUnits;
              final planet = provider.planetState;

              if (_selectedNavIndex != 0) {
                return _getNavigationScreen(_selectedNavIndex);
              }

              // ListView kullanarak taşma sorununu kesin çözelim
              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 20.0),
                children: [
                  // ÜST KISIM (Header)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12.0 : 16.0,
                      vertical: isSmallScreen ? 8.0 : 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              SmoothPageRoute(
                                builder: (context) => const TerraformingConsoleScreen(),
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'STAGE ${planet.stageNumber}: ${planet.stageName}',
                                style: GoogleFonts.orbitron(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                                textAlign: TextAlign.center, // Ortala
                              ),
                              const SizedBox(height: 4), // Yazılar arası boşluk
                              Text(
                                '(Progress: ${(planet.totalProgress * 100).toInt()}%)',
                                style: GoogleFonts.exo2(
                                  fontSize: isSmallScreen ? 10 : 11,
                                  color: Colors.white70,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: planet.phase == PlanetPhase.deadRock
                                ? Colors.grey.shade700
                                : planet.phase == PlanetPhase.blueHope
                                    ? Colors.blue.shade800
                                    : Colors.green.shade800,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Phase Başlığı
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12.0 : 20.0,
                      vertical: isSmallScreen ? 4.0 : 6.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        planet.phaseTitle,
                        style: GoogleFonts.orbitron(
                          fontSize: isSmallScreen ? 16 : 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // GEZEGEN - Sabit yükseklik ve AspectRatio kaldırıldı
                  // İçerik ne kadar yer kaplarsa o kadar uzayacak
                  Center(
                    child: SizedBox(
                      width: screenWidth * (isSmallScreen ? 0.7 : 0.8),
                      // Yükseklik kısıtlaması yok, PlanetWidget kendi boyutunu belirler
                      child: PlanetWidget(planetState: planet),
                    ),
                  ),

                  const SizedBox(height: 20), // Gezegen ile alt panel arası boşluk

                  // ALT PANEL (Neon Container)
                  Container(
                    margin: EdgeInsets.all(isSmallScreen ? 8 : 12),
                    child: NeonContainer(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      glowColor: Colors.cyanAccent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.bolt,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'KINETIC POTENTIAL:',
                                style: GoogleFonts.orbitron(
                                  fontSize: isSmallScreen ? 10 : 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end, // Hizalama
                            children: [
                              Flexible(
                                child: Text(
                                  Formatters.formatNumberWithCommas(energy.steps),
                                  style: GoogleFonts.orbitron(
                                    fontSize: isSmallScreen ? 20 : 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0), // Hizalama düzeltmesi
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.bolt,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    Text(
                                      'STEPS',
                                      style: GoogleFonts.orbitron(
                                        fontSize: isSmallScreen ? 12 : 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: GoogleFonts.exo2(
                                  fontSize: isSmallScreen ? 10 : 11,
                                  color: Colors.white54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${_calculateProgressPercentage(energy.steps)}%',
                                style: GoogleFonts.orbitron(
                                  fontSize: isSmallScreen ? 11 : 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyanAccent,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 8),
                          Stack(
                            children: [
                              Container(
                                height: isSmallScreen ? 8 : 10,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: _calculateProgressPercentage(energy.steps) / 100.0,
                                child: Container(
                                  height: isSmallScreen ? 8 : 10,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.cyanAccent, Colors.amber],
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 4 : 6),
                          Text(
                            'Next milestone: ${_getNextMilestone(energy.steps)} steps',
                            style: GoogleFonts.exo2(
                              fontSize: isSmallScreen ? 9 : 10,
                              color: Colors.white38,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          if (energy.steps == 0) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Keep walking, Captain!',
                              style: GoogleFonts.exo2(
                                fontSize: isSmallScreen ? 10 : 11,
                                color: Colors.white54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          AnimatedButton(
                            text: 'HARVEST ENERGY',
                            backgroundColor: Colors.orange,
                            disabledColor: Colors.grey.shade700,
                            onPressed: energy.availableEnergy > 0
                                ? () {
                                    provider.harvestEnergy();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                'Energy harvested! +${Formatters.formatNumberWithCommas(energy.availableEnergy)} units',
                                                style: GoogleFonts.orbitron(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.green.withOpacity(0.9),
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _getNavigationScreen(int index) {
    switch (index) {
      case 1:
        return const MissionsScreen();
      case 2:
        return const StatisticsScreen();
      case 3:
        return const MarketScreen();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF000510),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.public, 'WORLD', 0, Colors.blueAccent),
              _buildNavItem(Icons.assignment, 'MISSIONS', 1, Colors.white70),
              _buildNavItem(Icons.analytics, 'STATS', 2, Colors.white70),
              _buildNavItem(Icons.shopping_cart, 'MARKET', 3, Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Color color) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() {
            _selectedNavIndex = index;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: color.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? color : Colors.white54,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.white54,
                letterSpacing: 1,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
