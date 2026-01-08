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
                  Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                    child: Row(
                      children: [
                        Icon(Icons.shopping_cart, color: Colors.cyanAccent, size: isSmallScreen ? 24 : 28),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Text(provider.getString('market_title'), style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 20 : 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                        const Spacer(),
                        NeonContainer(
                          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 12, vertical: isSmallScreen ? 6 : 8),
                          glowColor: Colors.amber,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(Formatters.formatNumberWithCommas(energy.totalHarvested), style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 11 : 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(provider.getString('energy_boosts'), style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.bold, color: Colors.cyanAccent, letterSpacing: 1.5)),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          _buildMarketItem(context: context, provider: provider, title: provider.getString('item_step_x2'), description: provider.getString('desc_step_x2'), price: provider.getPrice('step_multiplier_2x'), icon: Icons.speed, color: Colors.blueAccent, isSmallScreen: isSmallScreen, availableEnergy: energy.totalHarvested, itemId: 'step_multiplier_2x', isPurchased: provider.purchasedItems.containsKey('step_multiplier_2x'), onPurchase: () async {
                            final price = provider.getPrice('step_multiplier_2x');
                            final success = await provider.purchaseMarketItem('step_multiplier_2x', price, durationHours: 24);
                            if (success && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.getString('purchased')), backgroundColor: Colors.green));
                          }),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          _buildMarketItem(context: context, provider: provider, title: provider.getString('item_bonus_50'), description: provider.getString('desc_bonus_50'), price: provider.getPrice('energy_bonus_50'), icon: Icons.trending_up, color: Colors.greenAccent, isSmallScreen: isSmallScreen, availableEnergy: energy.totalHarvested, itemId: 'energy_bonus_50', isPurchased: provider.purchasedItems.containsKey('energy_bonus_50'), onPurchase: () async {
                            final price = provider.getPrice('energy_bonus_50');
                            final success = await provider.purchaseMarketItem('energy_bonus_50', price);
                            if (success && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.getString('purchased')), backgroundColor: Colors.green));
                          }),
                          SizedBox(height: isSmallScreen ? 24 : 30),
                          Text(provider.getString('planet_customizations'), style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.bold, color: Colors.purpleAccent, letterSpacing: 1.5)),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          _buildMarketItem(context: context, provider: provider, title: provider.getString('item_neon'), description: provider.getString('desc_neon'), price: provider.getPrice('neon_glow'), icon: Icons.light_mode, color: Colors.purpleAccent, isSmallScreen: isSmallScreen, availableEnergy: energy.totalHarvested, itemId: 'neon_glow', isPurchased: provider.isNeonGlowActive, onPurchase: () async {
                            final price = provider.getPrice('neon_glow');
                            final success = await provider.purchaseMarketItem('neon_glow', price);
                            if (success && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.getString('purchased')), backgroundColor: Colors.green));
                          }),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          _buildMarketItem(context: context, provider: provider, title: provider.getString('item_particles'), description: provider.getString('desc_particles'), price: provider.getPrice('particle_effects'), icon: Icons.auto_awesome, color: Colors.orange, isSmallScreen: isSmallScreen, availableEnergy: energy.totalHarvested, itemId: 'particle_effects', isPurchased: provider.isParticleEffectsActive, onPurchase: () async {
                            final price = provider.getPrice('particle_effects');
                            final success = await provider.purchaseMarketItem('particle_effects', price);
                            if (success && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.getString('purchased')), backgroundColor: Colors.green));
                          }),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          _buildMarketItem(context: context, provider: provider, title: provider.getString('item_colors'), description: provider.getString('desc_colors'), price: provider.getPrice('custom_colors'), icon: Icons.palette, color: Colors.pinkAccent, isSmallScreen: isSmallScreen, availableEnergy: energy.totalHarvested, itemId: 'custom_colors', isPurchased: provider.isCustomColorsActive, onPurchase: () async {
                            final price = provider.getPrice('custom_colors');
                            final success = await provider.purchaseMarketItem('custom_colors', price);
                            if (success && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.getString('purchased')), backgroundColor: Colors.green));
                          }),
                          if (provider.isCustomColorsActive)
                            Container(
                              margin: const EdgeInsets.only(top: 12, left: 16, right: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.pinkAccent.withOpacity(0.3))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(provider.getString('select_color'), style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.pinkAccent, letterSpacing: 1)),
                                  const SizedBox(height: 12),
                                  Wrap(spacing: 12, runSpacing: 12, children: [
                                    _buildColorOption(context, provider, null, provider.getString('color_default')),
                                    _buildColorOption(context, provider, Colors.purpleAccent, provider.getString('color_purple')),
                                    _buildColorOption(context, provider, Colors.amber, provider.getString('color_gold')),
                                    _buildColorOption(context, provider, Colors.tealAccent, provider.getString('color_teal')),
                                    _buildColorOption(context, provider, Colors.redAccent, provider.getString('color_crimson')),
                                  ]),
                                ],
                              ),
                            ),
                          SizedBox(height: isSmallScreen ? 30 : 40),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  showDialog(context: context, builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF1A1A1A),
                                    title: Text(provider.getString('reset_refund_title'), style: GoogleFonts.orbitron(color: Colors.orangeAccent)),
                                    content: Text(provider.getString('reset_refund_desc'), style: GoogleFonts.exo2(color: Colors.white70)),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: Text(provider.getString('cancel'), style: const TextStyle(color: Colors.white))),
                                      TextButton(onPressed: () async { Navigator.pop(context); await provider.refundMarketData(); if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.getString('success_reset')), backgroundColor: Colors.orange)); }, child: Text(provider.getString('reset'), style: const TextStyle(color: Colors.orangeAccent))),
                                    ],
                                  ));
                                },
                                icon: Icon(Icons.refresh, color: Colors.orangeAccent.withOpacity(0.7)),
                                label: Text(provider.getString('reset_market'), style: GoogleFonts.orbitron(color: Colors.orangeAccent.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.orangeAccent.withOpacity(0.3)))),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  showDialog(context: context, builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF1A1A1A),
                                    title: Text(provider.getString('factory_reset_title'), style: GoogleFonts.orbitron(color: Colors.redAccent)),
                                    content: Text(provider.getString('factory_reset_desc'), style: GoogleFonts.exo2(color: Colors.white70, fontWeight: FontWeight.bold)),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: Text(provider.getString('cancel'), style: const TextStyle(color: Colors.white))),
                                      TextButton(onPressed: () async { Navigator.pop(context); await provider.factoryReset(); if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.getString('success_factory')), backgroundColor: Colors.redAccent)); }, child: Text(provider.getString('wipe_all'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
                                    ],
                                  ));
                                },
                                icon: Icon(Icons.delete_forever, color: Colors.redAccent.withOpacity(0.7)),
                                label: Text(provider.getString('factory_reset'), style: GoogleFonts.orbitron(color: Colors.redAccent.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.redAccent.withOpacity(0.3)))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('LANGUAGE: ', style: GoogleFonts.orbitron(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
                                const SizedBox(width: 8),
                                _buildLanguageButton('TR', 'tr', provider),
                                const SizedBox(width: 8),
                                Container(width: 1, height: 16, color: Colors.white24),
                                const SizedBox(width: 8),
                                _buildLanguageButton('EN', 'en', provider),
                              ],
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

  Widget _buildLanguageButton(String label, String code, MotionCoreProvider provider) {
    final bool isSelected = provider.currentLanguage == code;
    return InkWell(
      onTap: () => provider.setLanguage(code),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: isSelected ? Colors.cyanAccent.withOpacity(0.2) : Colors.transparent, borderRadius: BorderRadius.circular(4), border: isSelected ? Border.all(color: Colors.cyanAccent.withOpacity(0.5)) : null),
        child: Text(label, style: GoogleFonts.orbitron(color: isSelected ? Colors.cyanAccent : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildColorOption(BuildContext context, MotionCoreProvider provider, Color? color, String label) {
    final isSelected = provider.customPlanetColor?.value == color?.value;
    
    return GestureDetector(
      onTap: () => provider.setCustomPlanetColor(color),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color ?? Colors.grey.shade800, shape: BoxShape.circle, border: Border.all(color: isSelected ? Colors.white : Colors.white.withOpacity(0.2), width: isSelected ? 3 : 1), boxShadow: isSelected && color != null ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 10)] : null),
            child: color == null ? const Icon(Icons.block, color: Colors.white54, size: 20) : null,
          ),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.exo2(color: isSelected ? Colors.white : Colors.white54, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildMarketItem({
    required BuildContext context,
    required MotionCoreProvider provider,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isSmallScreen ? 50 : 60,
            height: isSmallScreen ? 50 : 60,
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.5), width: 1)),
            child: Icon(icon, color: color, size: isSmallScreen ? 24 : 28),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(description, style: GoogleFonts.exo2(fontSize: isSmallScreen ? 10 : 11, color: Colors.white54), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(Formatters.formatNumberWithCommas(price), style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 11 : 12, color: canAfford ? Colors.amber : Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canAfford && !isPurchased ? onPurchase : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20, vertical: isSmallScreen ? 12 : 14),
                decoration: BoxDecoration(color: isPurchased ? Colors.green.shade700 : (canAfford ? color : Colors.grey.shade700), borderRadius: BorderRadius.circular(8), boxShadow: canAfford && !isPurchased ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 2))] : null),
                child: Text(isPurchased ? provider.getString('owned') : provider.getString('buy'), style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 12 : 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
