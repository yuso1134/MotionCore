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
              final dailyStatus = provider.dailyMissionsStatus;
              
              return Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.assignment,
                          color: Colors.cyanAccent,
                          size: isSmallScreen ? 24 : 28,
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.getString('missions_title'),
                              style: GoogleFonts.orbitron(
                                fontSize: isSmallScreen ? 18 : 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              provider.getString('missions_subtitle'),
                              style: GoogleFonts.exo2(
                                fontSize: isSmallScreen ? 10 : 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Missions List
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                      children: [
                        // --- GÜNLÜK GÖREVLER (DAILY MISSIONS) ---
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                provider.getString('daily_missions'), // DİL DESTEĞİ
                                style: GoogleFonts.orbitron(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orangeAccent,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                provider.getString('next_reset'), // DİL DESTEĞİ
                                style: GoogleFonts.exo2(
                                  fontSize: 10,
                                  color: Colors.white38,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        _buildDailyMissionItem(
                          context: context,
                          provider: provider,
                          missionId: 'daily_3k',
                          title: provider.getString('daily_3k_title'),
                          description: provider.getString('daily_3k_desc'),
                          reward: 500, // Ödül
                          status: dailyStatus['daily_3k'] ?? 0,
                          icon: Icons.directions_walk,
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        
                        _buildDailyMissionItem(
                          context: context,
                          provider: provider,
                          missionId: 'daily_7k',
                          title: provider.getString('daily_7k_title'),
                          description: provider.getString('daily_7k_desc'),
                          reward: 1000,
                          status: dailyStatus['daily_7k'] ?? 0,
                          icon: Icons.hiking,
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        
                        _buildDailyMissionItem(
                          context: context,
                          provider: provider,
                          missionId: 'daily_10k',
                          title: provider.getString('daily_10k_title'),
                          description: provider.getString('daily_10k_desc'),
                          reward: 2000,
                          status: dailyStatus['daily_10k'] ?? 0,
                          icon: Icons.emoji_events,
                          isSmallScreen: isSmallScreen,
                        ),

                        SizedBox(height: 24), // Bölüm Ayırıcı

                        // --- ANA GÖREVLER (MAIN MISSIONS) ---
                        Text(
                          'MAIN MISSIONS', // Dil desteği eklenebilir veya mevcut başlık kalsın
                          style: GoogleFonts.orbitron(
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 12),

                        _buildMissionItem(
                          context: context,
                          provider: provider,
                          missionId: 'mission_1',
                          title: provider.getString('mission_1_title'),
                          description: provider.getString('mission_1_desc'),
                          reward: 5000, // Ödüller arttırıldı
                          isCompleted: provider.energyUnits.steps >= 1000,
                          isClaimed: provider.completedMissions.contains('mission_1'),
                          icon: Icons.flag,
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        _buildMissionItem(
                          context: context,
                          provider: provider,
                          missionId: 'mission_2',
                          title: provider.getString('mission_2_title'),
                          description: provider.getString('mission_2_desc'),
                          reward: 10000,
                          isCompleted: provider.planetState.hydrosphere >= 0.1,
                          isClaimed: provider.completedMissions.contains('mission_2'),
                          icon: Icons.water_drop,
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        _buildMissionItem(
                          context: context,
                          provider: provider,
                          missionId: 'mission_3',
                          title: provider.getString('mission_3_title'),
                          description: provider.getString('mission_3_desc'),
                          reward: 15000,
                          isCompleted: provider.planetState.atmosphere >= 0.2,
                          isClaimed: provider.completedMissions.contains('mission_3'),
                          icon: Icons.cloud,
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        _buildMissionItem(
                          context: context,
                          provider: provider,
                          missionId: 'mission_4',
                          title: provider.getString('mission_4_title'),
                          description: provider.getString('mission_4_desc'),
                          reward: 20000,
                          isCompleted: provider.planetState.biosphere > 0,
                          isClaimed: provider.completedMissions.contains('mission_4'),
                          icon: Icons.eco,
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(height: 40),
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

  // GÜNLÜK GÖREV ÖĞESİ
  Widget _buildDailyMissionItem({
    required BuildContext context,
    required MotionCoreProvider provider,
    required String missionId,
    required String title,
    required String description,
    required int reward,
    required int status, // 0: Not Completed, 1: Completed, 2: Claimed
    required IconData icon,
    required bool isSmallScreen,
  }) {
    bool isCompleted = status >= 1;
    bool isClaimed = status == 2;
    
    Color statusColor = isClaimed 
        ? Colors.grey 
        : (isCompleted ? Colors.orangeAccent : Colors.white24);
        
    return NeonContainer(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      glowColor: isCompleted && !isClaimed ? Colors.orangeAccent : Colors.transparent,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.5)),
            ),
            child: Icon(
              icon,
              color: statusColor,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          SizedBox(width: isSmallScreen ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: isClaimed ? Colors.white54 : Colors.white,
                    decoration: isClaimed ? TextDecoration.lineThrough : null,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.exo2(
                    fontSize: isSmallScreen ? 10 : 11,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.bolt, size: 12, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      provider.getString('reward', params: {'amount': Formatters.formatNumberWithCommas(reward)}),
                      style: GoogleFonts.exo2(
                        fontSize: isSmallScreen ? 9 : 10,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          if (isCompleted && !isClaimed)
            SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await provider.claimDailyMissionReward(missionId, reward);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.getString('mission_claimed')),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  textStyle: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                child: Text(provider.getString('claim')),
              ),
            )
          else if (isClaimed)
            Icon(Icons.check_circle, color: Colors.grey, size: 24)
          else
            Icon(Icons.lock_clock, color: Colors.white12, size: 24),
        ],
      ),
    );
  }

  // ANA GÖREV ÖĞESİ (Eskisiyle aynı, sadece kopyaladım)
  Widget _buildMissionItem({
    required BuildContext context,
    required MotionCoreProvider provider,
    required String missionId,
    required String title,
    required String description,
    required int reward,
    required bool isCompleted,
    required bool isClaimed,
    required IconData icon,
    required bool isSmallScreen,
  }) {
    Color statusColor = isClaimed 
        ? Colors.grey 
        : (isCompleted ? Colors.greenAccent : Colors.white24);
        
    return NeonContainer(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      glowColor: isCompleted && !isClaimed ? Colors.greenAccent : Colors.transparent,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.5)),
            ),
            child: Icon(
              icon,
              color: statusColor,
              size: isSmallScreen ? 24 : 30,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: isClaimed ? Colors.white54 : Colors.white,
                    decoration: isClaimed ? TextDecoration.lineThrough : null,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.exo2(
                    fontSize: isSmallScreen ? 11 : 12,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.bolt, size: 14, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      provider.getString('reward', params: {'amount': Formatters.formatNumberWithCommas(reward)}),
                      style: GoogleFonts.exo2(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          if (isCompleted && !isClaimed)
            AnimatedButton(
              text: provider.getString('claim'),
              onPressed: () async {
                final success = await provider.claimMissionReward(missionId, reward);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.getString('mission_claimed')),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 8 : 10,
              ),
            )
          else if (isClaimed)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                provider.getString('claimed'),
                style: GoogleFonts.orbitron(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
