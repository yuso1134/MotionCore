import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/motion_core_provider.dart';
import '../widgets/starry_background.dart';
import '../widgets/neon_container.dart';
import '../widgets/animated_button.dart';
import '../models/planet_state.dart';

class TerraformingConsoleScreen extends StatefulWidget {
  const TerraformingConsoleScreen({super.key});

  @override
  State<TerraformingConsoleScreen> createState() => _TerraformingConsoleScreenState();
}

class _TerraformingConsoleScreenState extends State<TerraformingConsoleScreen> {
  PlanetPhase _selectedTargetPhase = PlanetPhase.blueHope;

  double _hydrosphereSlider = 0.0;
  double _atmosphereSlider = 0.0;
  double _biosphereSlider = 0.0;
  double _humanitySlider = 0.0;
  
  bool _humanityLocked = true;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MotionCoreProvider>(context, listen: false);
    final current = provider.planetState;
    
    _selectedTargetPhase = current.phase == PlanetPhase.deadRock ? PlanetPhase.blueHope : current.phase;
    
    _loadValuesForPhase(_selectedTargetPhase, current);
  }
  
  void _loadValuesForPhase(PlanetPhase phase, PlanetState current) {
    if (phase == PlanetPhase.blueHope) {
        _hydrosphereSlider = current.hydrosphere < 0.1 ? 0.5 : current.hydrosphere;
        _atmosphereSlider = current.atmosphere < 0.1 ? 0.5 : current.atmosphere;
        _biosphereSlider = current.biosphere;
        _humanitySlider = 0.0;
        _humanityLocked = true;
    } else if (phase == PlanetPhase.greenEden) {
        _hydrosphereSlider = current.hydrosphere < 0.1 ? 0.4 : current.hydrosphere;
        _atmosphereSlider = current.atmosphere < 0.1 ? 0.4 : current.atmosphere;
        _biosphereSlider = current.biosphere < 0.1 ? 0.5 : current.biosphere;
        _humanitySlider = current.humanity;
        _humanityLocked = false;
    }
    
    _balanceSliders('init');
  }

  void _balanceSliders(String changedSlider) {
    double total = _hydrosphereSlider + _atmosphereSlider + _biosphereSlider + _humanitySlider;
    
    if (total > 1.0) {
      double excess = total - 1.0;
      List<String> others = ['hydro', 'atmos', 'bio', 'human'];
      others.remove(changedSlider);
      
      double othersTotal = 0.0;
      if (others.contains('hydro')) othersTotal += _hydrosphereSlider;
      if (others.contains('atmos')) othersTotal += _atmosphereSlider;
      if (others.contains('bio')) othersTotal += _biosphereSlider;
      if (others.contains('human')) othersTotal += _humanitySlider;
      
      if (othersTotal > 0) {
        if (others.contains('hydro')) _hydrosphereSlider -= excess * (_hydrosphereSlider / othersTotal);
        if (others.contains('atmos')) _atmosphereSlider -= excess * (_atmosphereSlider / othersTotal);
        if (others.contains('bio')) _biosphereSlider -= excess * (_biosphereSlider / othersTotal);
        if (others.contains('human')) _humanitySlider -= excess * (_humanitySlider / othersTotal);
      }
      
      if (_hydrosphereSlider < 0) _hydrosphereSlider = 0;
      if (_atmosphereSlider < 0) _atmosphereSlider = 0;
      if (_biosphereSlider < 0) _biosphereSlider = 0;
      if (_humanitySlider < 0) _humanitySlider = 0;
    }
  }

  void _commitProcess() {
    final provider = Provider.of<MotionCoreProvider>(context, listen: false);
    
    provider.commitTerraforming(
      hydrosphere: _hydrosphereSlider,
      atmosphere: _atmosphereSlider,
      biosphere: _biosphereSlider,
      humanity: _humanitySlider,
    );

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Planet Updated Successfully!',
          style: GoogleFonts.orbitron(fontSize: 12),
        ),
        backgroundColor: Colors.green.withOpacity(0.9),
      ),
    );
  }

  void _showHelpDialog(BuildContext context, dynamic provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: Colors.cyanAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                provider.getString('console_help_title'),
                style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(
          provider.getString('console_help_desc'),
          style: GoogleFonts.exo2(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              provider.getString('got_it'),
              style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

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
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12.0 : 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.help_outline, color: Colors.white54, size: 24),
                          onPressed: () => _showHelpDialog(context, provider),
                          tooltip: 'Help',
                        ),
                        Expanded(
                          child: Text(
                            provider.getString('console_title'),
                            style: GoogleFonts.orbitron(
                              fontSize: isSmallScreen ? 14 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: NeonContainer(
                      padding: const EdgeInsets.all(12),
                      glowColor: Colors.purpleAccent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPlanetOption(
                            PlanetPhase.deadRock, 
                            provider.getString('dead_rock'), 
                            Icons.public_off, 
                            Colors.grey,
                            false
                          ),
                          _buildPlanetOption(
                            PlanetPhase.blueHope, 
                            provider.getString('blue_hope'), 
                            Icons.public, 
                            Colors.blueAccent,
                            true
                          ),
                          _buildPlanetOption(
                            PlanetPhase.greenEden, 
                            provider.getString('green_eden'), 
                            Icons.forest, 
                            Colors.greenAccent,
                            true
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                      child: Column(
                        children: [
                          _buildResourceSlider(
                            context: context,
                            provider: provider,
                            title: provider.getString('hydrosphere'),
                            icon: Icons.water_drop,
                            value: _hydrosphereSlider,
                            color: Colors.blue,
                            isSmallScreen: isSmallScreen,
                            onChanged: (value) {
                              setState(() {
                                _hydrosphereSlider = value;
                                _balanceSliders('hydro');
                              });
                            },
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          _buildResourceSlider(
                            context: context,
                            provider: provider,
                            title: provider.getString('atmosphere'),
                            icon: Icons.cloud,
                            value: _atmosphereSlider,
                            color: Colors.lightBlue,
                            isSmallScreen: isSmallScreen,
                            onChanged: (value) {
                              setState(() {
                                _atmosphereSlider = value;
                                _balanceSliders('atmos');
                              });
                            },
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          _buildResourceSlider(
                            context: context,
                            provider: provider,
                            title: provider.getString('biosphere'),
                            icon: Icons.eco,
                            value: _biosphereSlider,
                            color: Colors.green,
                            isSmallScreen: isSmallScreen,
                            onChanged: (value) {
                              setState(() {
                                _biosphereSlider = value;
                                _balanceSliders('bio');
                              });
                            },
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          _buildResourceSlider(
                            context: context,
                            provider: provider,
                            title: provider.getString('humanity'),
                            subtitle: _humanityLocked 
                                ? provider.getString('locked_humanity') 
                                : '(Civilization)',
                            icon: Icons.apartment,
                            value: _humanitySlider,
                            color: Colors.orangeAccent,
                            locked: _humanityLocked,
                            isSmallScreen: isSmallScreen,
                            onChanged: (value) {
                              if (!_humanityLocked) {
                                setState(() {
                                  _humanitySlider = value;
                                  _balanceSliders('human');
                                });
                              }
                            },
                          ),
                          SizedBox(height: isSmallScreen ? 24 : 30),
                          NeonContainer(
                            padding: EdgeInsets.zero,
                            glowColor: Colors.blueAccent,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _commitProcess,
                                borderRadius: BorderRadius.circular(8),
                                child: AnimatedButton(
                                  text: 'SAVE CHANGES',
                                  backgroundColor: Colors.blueAccent,
                                  onPressed: _commitProcess,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmallScreen ? 16 : 18,
                                  ),
                                ),
                              ),
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

  Widget _buildPlanetOption(PlanetPhase phase, String label, IconData icon, Color color, bool isSelectable) {
    final bool isSelected = _selectedTargetPhase == phase;
    
    return GestureDetector(
      onTap: isSelectable ? () {
        setState(() {
          _selectedTargetPhase = phase;
          final provider = Provider.of<MotionCoreProvider>(context, listen: false);
          _loadValuesForPhase(phase, provider.planetState);
        });
      } : null,
      child: Opacity(
        opacity: isSelectable ? 1.0 : 0.3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.white24,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)] : null,
              ),
              child: Icon(icon, color: isSelected ? color : Colors.white54, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.exo2(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.white38,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceSlider({
    required BuildContext context,
    required MotionCoreProvider provider,
    required String title,
    String? subtitle,
    required IconData icon,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
    required bool isSmallScreen,
    bool locked = false,
  }) {
    return NeonContainer(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      glowColor: locked ? Colors.redAccent : Colors.cyanAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: locked ? Colors.redAccent : color, size: isSmallScreen ? 18 : 20),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 10 : 12, fontWeight: FontWeight.w600, color: locked ? Colors.redAccent : Colors.cyanAccent, letterSpacing: 1.2)),
                    if (subtitle != null)
                      Text(subtitle, style: GoogleFonts.exo2(fontSize: isSmallScreen ? 8 : 9, color: Colors.white54)),
                  ],
                ),
              ),
              if (locked)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, color: Colors.redAccent, size: isSmallScreen ? 14 : 16),
                    const SizedBox(width: 4),
                    Text(provider.getString('locked').toUpperCase().replaceAll('(', '').replaceAll(')', ''), style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 8 : 10, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          if (!locked)
            Padding(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: color,
                  inactiveTrackColor: Colors.white.withOpacity(0.2),
                  thumbColor: color,
                  overlayColor: color.withOpacity(0.3),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
                  trackHeight: 10,
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 32),
                ),
                child: Slider(
                  value: value,
                  onChanged: (newValue) {
                    HapticFeedback.selectionClick();
                    onChanged(newValue);
                  },
                  onChangeStart: (_) => HapticFeedback.lightImpact(),
                  onChangeEnd: (_) => HapticFeedback.mediumImpact(),
                  min: 0.0,
                  max: 1.0,
                  divisions: 100, 
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
              child: Stack(
                children: [
                  Container(
                    height: isSmallScreen ? 8 : 10,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                  ),
                  FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: isSmallScreen ? 8 : 10,
                      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(5), boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)]),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: isSmallScreen ? 8 : 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(value * 100).toInt()}%', style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.bold, color: locked ? Colors.redAccent : color)),
            ],
          ),
        ],
      ),
    );
  }
}
