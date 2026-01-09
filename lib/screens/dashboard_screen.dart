import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math' as math;
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      WorldView(isSelected: _selectedNavIndex == 0),
      const MissionsScreen(),
      const StatisticsScreen(),
      const MarketScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF000510),
      body: StarryBackground(
        child: SafeArea(
          child: IndexedStack(
            index: _selectedNavIndex,
            children: pages,
          ),
        ),
      ),
      bottomNavigationBar: Consumer<MotionCoreProvider>(
        builder: (context, provider, child) {
          return _buildBottomNavBar(provider);
        },
      ),
    );
  }

  Widget _buildBottomNavBar(MotionCoreProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF000510),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.public, provider.getString('nav_world'), 0, Colors.blueAccent),
              _buildNavItem(Icons.assignment, provider.getString('nav_missions'), 1, Colors.white70),
              _buildNavItem(Icons.analytics, provider.getString('nav_stats'), 2, Colors.white70),
              _buildNavItem(Icons.shopping_cart, provider.getString('nav_market'), 3, Colors.white70),
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
          border: isSelected ? Border.all(color: color.withOpacity(0.3), width: 1) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(icon, color: isSelected ? color : Colors.white54, size: 24),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.orbitron(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? color : Colors.white54, letterSpacing: 1),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class WorldView extends StatefulWidget {
  final bool isSelected;
  const WorldView({super.key, required this.isSelected});

  @override
  State<WorldView> createState() => _WorldViewState();
}

class _WorldViewState extends State<WorldView> {
  PageController? _pageController;
  int _currentViewIndex = 0;

  static const int _milestoneStep = 10000;

  @override
  void initState() {
    super.initState();
    final initialPage = _getHighestUnlockedPageIndex();
    
    _pageController = PageController(initialPage: initialPage, viewportFraction: 0.9);
    _currentViewIndex = initialPage;
  }

  @override
  void didUpdateWidget(covariant WorldView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _jumpToLatestPage(animate: true);
    }
  }

  int _getHighestUnlockedPageIndex() {
    final provider = Provider.of<MotionCoreProvider>(context, listen: false);
    final totalSteps = provider.energyUnits.steps;
    if (!_isStageLocked(2, totalSteps)) return 2;
    if (!_isStageLocked(1, totalSteps)) return 1;
    return 0;
  }

  void _jumpToLatestPage({bool animate = false}) {
    if (mounted && _pageController != null && _pageController!.hasClients) {
      final latestPage = _getHighestUnlockedPageIndex();
      if (_pageController!.page?.round() != latestPage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pageController!.hasClients) {
            if (animate) {
              _pageController!.animateToPage(latestPage, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
            } else {
              _pageController!.jumpToPage(latestPage);
            }
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  int _calculateProgressPercentage(int steps) {
    final progress = (steps % _milestoneStep) / _milestoneStep * 100;
    return progress.toInt().clamp(0, 100);
  }

  int _getNextMilestone(int steps) {
    return ((steps ~/ _milestoneStep) + 1) * _milestoneStep;
  }

  bool _isStageLocked(int stageIndex, int totalSteps) {
    if (stageIndex == 0) return false;
    if (stageIndex == 1) return totalSteps < _milestoneStep;
    if (stageIndex == 2) return totalSteps < (_milestoneStep * 2);
    return true;
  }

  PlanetState _getPreviewState(int pageIndex) {
    switch (pageIndex) {
      case 0: return PlanetState();
      case 1: return PlanetState(hydrosphere: 1.0, atmosphere: 0.5);
      case 2: return PlanetState(hydrosphere: 1.0, atmosphere: 1.0, biosphere: 1.0);
      default: return PlanetState();
    }
  }

  String _getStageName(int index, MotionCoreProvider provider) {
    switch (index) {
      case 0: return provider.getString('dead_rock');
      case 1: return provider.getString('blue_hope');
      case 2: return provider.getString('green_eden');
      default: return 'UNKNOWN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return Consumer<MotionCoreProvider>(
      builder: (context, provider, child) {
        final energy = provider.energyUnits;
        final currentPlanetState = provider.planetState;
        final int totalSteps = energy.steps;
        final int actualStageIndex = (currentPlanetState.stageNumber - 1).clamp(0, 2);

        if (_pageController == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12.0 : 16.0, vertical: isSmallScreen ? 8.0 : 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.menu, color: Colors.white, size: 28), onPressed: () => Navigator.push(context, SmoothPageRoute(builder: (context) => const TerraformingConsoleScreen()))),
                  Expanded(
                    child: Column(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text('${provider.getString('stage')} ${_currentViewIndex + 1}: ${_getStageName(_currentViewIndex, provider)}', key: ValueKey<int>(_currentViewIndex), style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5), textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 4),
                        if (!_isStageLocked(_currentViewIndex, totalSteps))
                          Text(provider.getString('active_completed'), style: GoogleFonts.exo2(fontSize: isSmallScreen ? 10 : 11, color: Colors.greenAccent, letterSpacing: 0.5))
                        else
                          Text(provider.getString('locked'), style: GoogleFonts.exo2(fontSize: isSmallScreen ? 10 : 11, color: Colors.redAccent, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _isStageLocked(_currentViewIndex, totalSteps) ? Colors.grey.shade800 : Colors.blue.shade800, border: Border.all(color: Colors.white.withOpacity(0.3), width: 1)),
                    child: Center(child: Icon(_isStageLocked(_currentViewIndex, totalSteps) ? Icons.lock : Icons.check, size: 20, color: Colors.white70)),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: PageView.builder(
                controller: _pageController,
                itemCount: 3,
                onPageChanged: (index) => setState(() => _currentViewIndex = index),
                itemBuilder: (context, index) {
                  final bool isLocked = _isStageLocked(index, totalSteps);
                  final displayState = !isLocked && index == actualStageIndex ? currentPlanetState : _getPreviewState(index);
                  return AnimatedScale(
                    duration: const Duration(milliseconds: 300),
                    scale: _currentViewIndex == index ? 1.0 : 0.85,
                    child: LayoutBuilder(builder: (context, constraints) {
                      final availableSize = math.min(constraints.maxWidth, constraints.maxHeight);
                      return Center(
                        child: SizedBox(
                          width: availableSize * 0.9, height: availableSize * 0.9,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PlanetWidget(planetState: displayState),
                              if (isLocked)
                                ClipOval(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                    child: Container(
                                      color: Colors.black.withOpacity(0.5),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle, border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2)),
                                            child: const Icon(Icons.lock_outline, color: Colors.redAccent, size: 32),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(provider.getString('locked_zone'), style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text(provider.getString('reach_steps', params: {'steps': '${index * _milestoneStep}'}), style: GoogleFonts.exo2(fontSize: 12, color: Colors.redAccent, letterSpacing: 0.5)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            Container(
              constraints: BoxConstraints(maxHeight: screenHeight * 0.35),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                  child: !_isStageLocked(_currentViewIndex, totalSteps)
                      ? NeonContainer(
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          glowColor: Colors.cyanAccent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [const Icon(Icons.bolt, color: Colors.amber, size: 20), const SizedBox(width: 8), Text(provider.getString('kinetic_potential'), style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 10 : 12, fontWeight: FontWeight.w600, color: Colors.white70, letterSpacing: 1.5))]),
                              SizedBox(height: isSmallScreen ? 6 : 8),
                              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Flexible(child: Text(Formatters.formatNumberWithCommas(energy.steps), style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 20 : 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2), overflow: TextOverflow.ellipsis)), const SizedBox(width: 8), Padding(padding: const EdgeInsets.only(bottom: 4.0), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.bolt, color: Colors.amber, size: 18), Text(provider.getString('steps'), style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 12 : 16, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1.5))]))]),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(provider.getString('progress'), style: GoogleFonts.exo2(fontSize: isSmallScreen ? 10 : 11, color: Colors.white54, fontWeight: FontWeight.w500)), Text('${_calculateProgressPercentage(energy.steps)}%', style: GoogleFonts.orbitron(fontSize: isSmallScreen ? 11 : 12, fontWeight: FontWeight.bold, color: Colors.cyanAccent))]),
                              SizedBox(height: isSmallScreen ? 6 : 8),
                              Stack(children: [Container(height: isSmallScreen ? 8 : 10, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(5))), FractionallySizedBox(widthFactor: _calculateProgressPercentage(energy.steps) / 100.0, child: Container(height: isSmallScreen ? 8 : 10, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.cyanAccent, Colors.amber]), borderRadius: BorderRadius.circular(5), boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)])))]),
                              SizedBox(height: isSmallScreen ? 4 : 6),
                              Text(provider.getString('next_milestone', params: {'steps': '${_getNextMilestone(energy.steps)}'}), style: GoogleFonts.exo2(fontSize: isSmallScreen ? 9 : 10, color: Colors.white38, fontStyle: FontStyle.italic)),
                              if (energy.steps == 0) ...[const SizedBox(height: 6), Text(provider.getString('keep_walking'), style: GoogleFonts.exo2(fontSize: isSmallScreen ? 10 : 11, color: Colors.white54, fontStyle: FontStyle.italic))],
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              AnimatedButton(text: provider.getString('harvest_energy'), backgroundColor: Colors.orange, disabledColor: Colors.grey.shade700, onPressed: energy.availableEnergy > 0 ? () { provider.harvestEnergy(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.check_circle, color: Colors.white, size: 20), const SizedBox(width: 8), Flexible(child: Text(provider.getString('energy_harvested', params: {'amount': Formatters.formatNumberWithCommas(energy.availableEnergy)}), style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)))]), backgroundColor: Colors.green.withOpacity(0.9), duration: const Duration(seconds: 2), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))); } : null, padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14)),
                            ],
                          ),
                        )
                      : NeonContainer(padding: const EdgeInsets.all(20), glowColor: Colors.grey, child: Center(child: Text(provider.getString('locked_zone'), textAlign: TextAlign.center, style: GoogleFonts.orbitron(color: Colors.white60, fontSize: 14, letterSpacing: 1)))),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
