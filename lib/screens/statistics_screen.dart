import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/starry_background.dart';
import '../widgets/neon_container.dart';
import '../providers/motion_core_provider.dart';
import '../utils/formatters.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<Map<String, int>> _dailyStepsFuture;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MotionCoreProvider>(context, listen: false);
    _dailyStepsFuture = provider.getDailySteps(7);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final provider = Provider.of<MotionCoreProvider>(context);
    final energy = provider.energyUnits;

    return Scaffold(
      backgroundColor: const Color(0xFF000510),
      body: StarryBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                child: Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.cyanAccent, size: isSmallScreen ? 24 : 28),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    Text(provider.getString('stats_title'), style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 20 : 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                  child: Column(
                    children: [
                      NeonContainer(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        glowColor: Colors.blueAccent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(provider.getString('daily_activity'), style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                            const SizedBox(height: 20),
                            FutureBuilder<Map<String, int>>(
                              future: _dailyStepsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Center(child: Text('No data available'));
                                }

                                final dailyData = snapshot.data!;
                                final last7Days = _getLast7Days(dailyData);

                                int maxValue = 0;
                                for (var steps in last7Days.values) {
                                  if (steps > maxValue) maxValue = steps;
                                }
                                if (maxValue == 0) maxValue = 1; // Avoid division by zero

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: last7Days.entries.map((entry) {
                                    final date = DateTime.parse(entry.key);
                                    final dayInitial = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1];
                                    final steps = entry.value;
                                    final isToday = date.day == DateTime.now().day && date.month == DateTime.now().month && date.year == DateTime.now().year;

                                    return _buildBar((steps / maxValue).toDouble(), dayInitial, isToday ? Colors.cyanAccent : Colors.blueAccent);
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      NeonContainer(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        glowColor: Colors.purpleAccent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(provider.getString('weekly_progress'), style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                            const SizedBox(height: 16),
                            _buildStatRow(provider.getString('total_steps'), Formatters.formatNumberWithCommas(energy.steps), Icons.directions_walk, Colors.purpleAccent, isSmallScreen),
                            const SizedBox(height: 12),
                            _buildStatRow(provider.getString('calories'), '${(energy.steps * 0.04).toInt()} ${provider.getString('kcal')}', Icons.local_fire_department, Colors.orangeAccent, isSmallScreen),
                            const SizedBox(height: 12),
                            _buildStatRow(provider.getString('distance'), '${(energy.steps * 0.0007).toStringAsFixed(2)} ${provider.getString('km')}', Icons.map, Colors.greenAccent, isSmallScreen),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Map<String, int> _getLast7Days(Map<String, int> data) {
    Map<String, int> result = {};
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      result[dateKey] = data[dateKey] ?? 0;
    }
    return result;
  }

  Widget _buildBar(double heightFactor, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 100 * heightFactor,
          width: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.exo2(color: Colors.white54, fontSize: 10)),
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
            Text(label, style: GoogleFonts.exo2(color: Colors.white70, fontSize: isSmallScreen ? 12 : 14)),
          ],
        ),
        Text(value, style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16)),
      ],
    );
  }
}
