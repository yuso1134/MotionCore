import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/starry_background.dart';
import '../widgets/neon_container.dart';
import '../providers/motion_core_provider.dart';
import '../utils/formatters.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return Scaffold(
      backgroundColor: const Color(0xFF000510),
      body: StarryBackground(
        child: SafeArea(
          child: Consumer<MotionCoreProvider>(
            builder: (context, provider, child) {
              final energy = provider.energyUnits;

              return Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: Colors.cyanAccent,
                          size: isSmallScreen ? 24 : 28,
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Text(
                          provider.getString('stats_title'), // DİL DESTEĞİ
                          style: GoogleFonts.orbitron(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stats Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                      child: Column(
                        children: [
                          // Daily Activity Chart (Placeholder)
                          NeonContainer(
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                            glowColor: Colors.blueAccent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.getString('daily_activity'), // DİL DESTEĞİ
                                  style: GoogleFonts.orbitron(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Mock Chart
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildBar(0.4, 'M', Colors.blueAccent),
                                    _buildBar(0.6, 'T', Colors.blueAccent),
                                    _buildBar(0.3, 'W', Colors.blueAccent),
                                    _buildBar(0.8, 'T', Colors.cyanAccent), // Today
                                    _buildBar(0.5, 'F', Colors.blueAccent),
                                    _buildBar(0.7, 'S', Colors.blueAccent),
                                    _buildBar(0.4, 'S', Colors.blueAccent),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  provider.getString('daily_avg', params: {'steps': '4,500'}), // DİL DESTEĞİ
                                  style: GoogleFonts.exo2(
                                    fontSize: isSmallScreen ? 10 : 12,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 12 : 16),

                          // Weekly Progress
                          NeonContainer(
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                            glowColor: Colors.purpleAccent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.getString('weekly_progress'), // DİL DESTEĞİ
                                  style: GoogleFonts.orbitron(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildStatRow(
                                  provider.getString('total_steps'), // DİL DESTEĞİ
                                  Formatters.formatNumberWithCommas(energy.steps + 25000),
                                  Icons.directions_walk,
                                  Colors.purpleAccent,
                                  isSmallScreen,
                                ),
                                const SizedBox(height: 12),
                                _buildStatRow(
                                  provider.getString('calories'), // DİL DESTEĞİ
                                  '${(energy.steps * 0.04).toInt()} ${provider.getString('kcal')}',
                                  Icons.local_fire_department,
                                  Colors.orangeAccent,
                                  isSmallScreen,
                                ),
                                const SizedBox(height: 12),
                                _buildStatRow(
                                  provider.getString('distance'), // DİL DESTEĞİ
                                  '${(energy.steps * 0.0007).toStringAsFixed(2)} ${provider.getString('km')}',
                                  Icons.map,
                                  Colors.greenAccent,
                                  isSmallScreen,
                                ),
                              ],
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
    );
  }

  Widget _buildBar(double heightFactor, String label, Color color) {
    return Column(
      children: [
        Container(
          height: 100,
          width: 8,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            heightFactor: heightFactor,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.exo2(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: isSmallScreen ? 18 : 20),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Text(
              label,
              style: GoogleFonts.exo2(
                color: Colors.white70,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
      ],
    );
  }
}
