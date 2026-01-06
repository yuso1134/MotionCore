import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/starry_background.dart';
import '../widgets/neon_container.dart';
import '../providers/motion_core_provider.dart';
import '../utils/formatters.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

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
                          Icons.shopping_cart,
                          color: Colors.cyanAccent,
                          size: isSmallScreen ? 24 : 28,
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Text(
                          'MARKET',
                          style: GoogleFonts.orbitron(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        Spacer(),
                        // Available Energy
                        NeonContainer(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 10 : 12,
                            vertical: isSmallScreen ? 6 : 8,
                          ),
                          glowColor: Colors.amber,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt, color: Colors.amber, size: 16),
                              SizedBox(width: 4),
                              Text(
                                Formatters.formatNumberWithCommas(energy.totalHarvested),
                                style: GoogleFonts.orbitron(
                                  fontSize: isSmallScreen ? 11 : 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Market Items
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Energy Boosts
                          Text(
                            'ENERGY BOOSTS',
                            style: GoogleFonts.orbitron(
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyanAccent,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),

                          _buildMarketItem(
                            context: context,
                            title: 'Step Multiplier x2',
                            description: 'Double energy from steps for 24h',
                            price: 1, // Fiyat 1 olarak güncellendi
                            icon: Icons.speed,
                            color: Colors.blueAccent,
                            isSmallScreen: isSmallScreen,
                            availableEnergy: energy.totalHarvested,
                            itemId: 'step_multiplier_2x',
                            isPurchased: provider.purchasedItems.containsKey('step_multiplier_2x'),
                            onPurchase: () async {
                              final success = await provider.purchaseMarketItem('step_multiplier_2x', 1, durationHours: 24);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Purchased! Step multiplier active for 24h'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Insufficient energy!'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),

                          SizedBox(height: isSmallScreen ? 12 : 16),

                          _buildMarketItem(
                            context: context,
                            title: 'Energy Bonus +50%',
                            description: 'Get 50% more energy from harvest',
                            price: 1, // Fiyat 1 olarak güncellendi
                            icon: Icons.trending_up,
                            color: Colors.greenAccent,
                            isSmallScreen: isSmallScreen,
                            availableEnergy: energy.totalHarvested,
                            itemId: 'energy_bonus_50',
                            isPurchased: provider.purchasedItems.containsKey('energy_bonus_50'),
                            onPurchase: () async {
                              final success = await provider.purchaseMarketItem('energy_bonus_50', 1);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Purchased! Energy bonus active'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Insufficient energy!'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),

                          SizedBox(height: isSmallScreen ? 24 : 30),

                          // Planet Customizations
                          Text(
                            'PLANET CUSTOMIZATIONS',
                            style: GoogleFonts.orbitron(
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.purpleAccent,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),

                          _buildMarketItem(
                            context: context,
                            title: 'Neon Glow Effect',
                            description: 'Enhanced planet glow animation',
                            price: 1, // Fiyat 1 olarak güncellendi
                            icon: Icons.light_mode,
                            color: Colors.purpleAccent,
                            isSmallScreen: isSmallScreen,
                            availableEnergy: energy.totalHarvested,
                            itemId: 'neon_glow',
                            isPurchased: provider.purchasedItems.containsKey('neon_glow'),
                            onPurchase: () async {
                              final success = await provider.purchaseMarketItem('neon_glow', 1);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Purchased! Neon glow effect unlocked'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Insufficient energy!'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),

                          SizedBox(height: isSmallScreen ? 12 : 16),

                          _buildMarketItem(
                            context: context,
                            title: 'Particle Effects',
                            description: 'Add particles around planet',
                            price: 1, // Fiyat 1 olarak güncellendi
                            icon: Icons.auto_awesome,
                            color: Colors.orange,
                            isSmallScreen: isSmallScreen,
                            availableEnergy: energy.totalHarvested,
                            itemId: 'particle_effects',
                            isPurchased: provider.purchasedItems.containsKey('particle_effects'),
                            onPurchase: () async {
                              final success = await provider.purchaseMarketItem('particle_effects', 1);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Purchased! Particle effects unlocked'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Insufficient energy!'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),

                          SizedBox(height: isSmallScreen ? 12 : 16),

                          _buildMarketItem(
                            context: context,
                            title: 'Custom Planet Colors',
                            description: 'Unlock custom color schemes',
                            price: 1, // Fiyat 1 olarak güncellendi
                            icon: Icons.palette,
                            color: Colors.pinkAccent,
                            isSmallScreen: isSmallScreen,
                            availableEnergy: energy.totalHarvested,
                            itemId: 'custom_colors',
                            isPurchased: provider.purchasedItems.containsKey('custom_colors'),
                            onPurchase: () async {
                              final success = await provider.purchaseMarketItem('custom_colors', 1);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Purchased! Custom colors unlocked'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Insufficient energy!'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),

                          SizedBox(height: isSmallScreen ? 30 : 40),

                          // SIFIRLA BUTONU (En Alta Eklendi)
                          Center(
                            child: TextButton.icon(
                              onPressed: () {
                                // Onay Dialogu
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF1A1A1A),
                                    title: Text(
                                      'Reset Market?',
                                      style: GoogleFonts.orbitron(color: Colors.redAccent),
                                    ),
                                    content: Text(
                                      'This will remove all purchased items and active boosts. Your energy units will remain.',
                                      style: GoogleFonts.exo2(color: Colors.white70),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel', style: TextStyle(color: Colors.white)),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context); // Dialogu kapat
                                          await provider.resetMarketData(); // Sıfırla
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Market data reset successfully.'),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        },
                                        child: Text('Reset', style: TextStyle(color: Colors.redAccent)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: Icon(Icons.refresh, color: Colors.redAccent.withOpacity(0.7)),
                              label: Text(
                                'RESET MARKET DATA',
                                style: GoogleFonts.orbitron(
                                  color: Colors.redAccent.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: isSmallScreen ? 20 : 30),
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

  Widget _buildMarketItem({
    required BuildContext context,
    required String title,
    required String description,
    required int price,
    required IconData icon,
    required Color color,
    required bool isSmallScreen,
    required int availableEnergy,
    required VoidCallback onPurchase,
    String? itemId,
    bool isPurchased = false,
  }) {
    final canAfford = availableEnergy >= price && !isPurchased;

    return NeonContainer(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      glowColor: canAfford ? color : Colors.grey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            width: isSmallScreen ? 50 : 60,
            height: isSmallScreen ? 50 : 60,
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: isSmallScreen ? 24 : 28),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          // Text Content - Horizontal layout
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title - Horizontal text
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 4),
                // Description - Horizontal text
                Text(
                  description,
                  style: GoogleFonts.exo2(
                    fontSize: isSmallScreen ? 10 : 11,
                    color: Colors.white54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 6),
                // Price - Horizontal
                Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    Icon(Icons.bolt, color: Colors.amber, size: 14),
                    SizedBox(width: 4),
                    Text(
                      Formatters.formatNumberWithCommas(price),
                      style: GoogleFonts.orbitron(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: canAfford ? Colors.amber : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          // Buy Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canAfford && !isPurchased ? onPurchase : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 20,
                  vertical: isSmallScreen ? 12 : 14,
                ),
                decoration: BoxDecoration(
                  color: isPurchased ? Colors.green.shade700 : (canAfford ? color : Colors.grey.shade700),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: canAfford && !isPurchased
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  isPurchased ? 'OWNED' : 'BUY',
                  style: GoogleFonts.orbitron(
                    fontSize: isSmallScreen ? 12 : 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
