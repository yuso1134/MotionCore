import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/starry_background.dart';
import '../widgets/neon_container.dart';
import '../widgets/animated_button.dart';
import '../providers/motion_core_provider.dart';
import '../utils/formatters.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

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
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                    child: Row(
                      children: [
                        const Icon(Icons.assignment, color: Colors.cyanAccent, size: 28),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(provider.getString('missions_title'), style: GoogleFonts.orbitron(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                            Text(provider.getString('missions_subtitle'), style: GoogleFonts.exo2(fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(provider.getString('daily_missions'), style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orangeAccent, letterSpacing: 1.5)),
                              Text(provider.getString('next_reset'), style: GoogleFonts.exo2(fontSize: 10, color: Colors.white38, fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                        _buildDailyMissionItem(provider: provider, missionId: 'daily_3k', reward: 500, icon: Icons.directions_walk),
                        const SizedBox(height: 12),
                        _buildDailyMissionItem(provider: provider, missionId: 'daily_7k', reward: 1000, icon: Icons.hiking),
                        const SizedBox(height: 12),
                        _buildDailyMissionItem(provider: provider, missionId: 'daily_10k', reward: 2000, icon: Icons.emoji_events),
                        const SizedBox(height: 24),
                        Text('MAIN MISSIONS', style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: 1.5)),
                        const SizedBox(height: 12),
                        _buildMissionItem(provider: provider, missionId: 'mission_1', reward: 5000, icon: Icons.flag),
                        const SizedBox(height: 16),
                        _buildMissionItem(provider: provider, missionId: 'mission_2', reward: 10000, icon: Icons.water_drop),
                        const SizedBox(height: 16),
                        _buildMissionItem(provider: provider, missionId: 'mission_3', reward: 15000, icon: Icons.cloud),
                        const SizedBox(height: 16),
                        _buildMissionItem(provider: provider, missionId: 'mission_4', reward: 20000, icon: Icons.eco),
                        const SizedBox(height: 40),
                      ],
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

  Widget _buildDailyMissionItem({
    required MotionCoreProvider provider,
    required String missionId,
    required int reward,
    required IconData icon,
  }) {
    final status = provider.dailyMissionsStatus[missionId] ?? 0;
    final title = provider.getString('${missionId}_title');
    final description = provider.getString('${missionId}_desc');
    bool isCompleted = status == 1;
    bool isClaimed = status == 2;
    Color statusColor = isClaimed ? Colors.grey : (isCompleted ? Colors.orangeAccent : Colors.white24);
        
    return NeonContainer(
      padding: const EdgeInsets.all(12),
      glowColor: isCompleted ? Colors.orangeAccent : Colors.transparent,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withOpacity(0.5))),
            child: Icon(icon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: isClaimed ? Colors.white54 : Colors.white)),
                const SizedBox(height: 2),
                Text(description, style: GoogleFonts.exo2(fontSize: 11, color: Colors.white70)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.bolt, size: 12, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(provider.getString('reward', params: {'amount': Formatters.formatNumberWithCommas(reward)}), style: GoogleFonts.exo2(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isCompleted)
            ElevatedButton(
              onPressed: () async => await provider.claimDailyMissionReward(missionId, reward),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12), textStyle: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold)),
              child: Text(provider.getString('claim')),
            )
          else if (isClaimed)
            const Icon(Icons.check_circle, color: Colors.grey, size: 24)
          else
            const Icon(Icons.lock_clock, color: Colors.white12, size: 24),
        ],
      ),
    );
  }

  Widget _buildMissionItem({
    required MotionCoreProvider provider,
    required String missionId,
    required int reward,
    required IconData icon,
  }) {
    final title = provider.getString('${missionId}_title');
    final description = provider.getString('${missionId}_desc');
    final isCompleted = provider.mainMissionsCompletionStatus[missionId] ?? false;
    final isClaimed = provider.completedMissions.contains(missionId);
    Color statusColor = isClaimed ? Colors.grey : (isCompleted ? Colors.greenAccent : Colors.white24);
        
    return NeonContainer(
      padding: const EdgeInsets.all(16),
      glowColor: isCompleted && !isClaimed ? Colors.greenAccent : Colors.transparent,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withOpacity(0.5))),
            child: Icon(icon, color: statusColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: isClaimed ? Colors.white54 : Colors.white)),
                const SizedBox(height: 4),
                Text(description, style: GoogleFonts.exo2(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.bolt, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(provider.getString('reward', params: {'amount': Formatters.formatNumberWithCommas(reward)}), style: GoogleFonts.exo2(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isCompleted && !isClaimed)
            AnimatedButton(
              text: provider.getString('claim'),
              onPressed: () async => await provider.claimMissionReward(missionId, reward),
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            )
          else if (isClaimed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Text(provider.getString('claimed'), style: GoogleFonts.orbitron(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.bold)),
            )
          else
            const Icon(Icons.hourglass_empty_rounded, color: Colors.white12, size: 24),
        ],
      ),
    );
  }
}
