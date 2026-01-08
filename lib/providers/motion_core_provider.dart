import 'dart:async';
import 'package:flutter/material.dart'; 
import '../models/planet_state.dart';
import '../models/energy_units.dart';
import '../services/storage_service.dart';
import '../utils/app_strings.dart'; 

class MotionCoreProvider with ChangeNotifier {
  PlanetState _planetState = PlanetState();
  EnergyUnits _energyUnits = EnergyUnits();
  int _lastSensorReading = 0;
  bool _isInitialized = false;
  
  Set<String> _completedMissions = {};
  Map<String, dynamic> _purchasedItems = {};
  double _stepMultiplier = 1.0;
  double _harvestBonus = 1.0;

  bool _isNeonGlowActive = false;
  bool _isParticleEffectsActive = false;
  bool _isCustomColorsActive = false;
  Color? _customPlanetColor;
  
  String? _lastDate;
  Map<String, int> _dailySteps = {};
  
  String _currentLanguage = 'en';

  Map<String, int> _dailyMissionsStatus = {'daily_3k': 0, 'daily_7k': 0, 'daily_10k': 0};
  Map<String, bool> mainMissionsCompletionStatus = {'mission_1': false, 'mission_2': false, 'mission_3': false, 'mission_4': false};

  PlanetState get planetState => _planetState;
  EnergyUnits get energyUnits => _energyUnits;
  Set<String> get completedMissions => _completedMissions;
  Map<String, dynamic> get purchasedItems => _purchasedItems;
  double get stepMultiplier => _stepMultiplier;
  double get harvestBonus => _harvestBonus;
  bool get isNeonGlowActive => _isNeonGlowActive;
  bool get isParticleEffectsActive => _isParticleEffectsActive;
  bool get isCustomColorsActive => _isCustomColorsActive;
  Color? get customPlanetColor => _customPlanetColor;
  String get currentLanguage => _currentLanguage;
  Map<String, int> get dailyMissionsStatus => _dailyMissionsStatus;

  final Map<String, int> _itemPrices = {
    'step_multiplier_2x': 5000,
    'energy_bonus_50': 3000,
    'neon_glow': 10000,
    'particle_effects': 15000,
    'custom_colors': 20000,
  };

  int getPrice(String itemId) => _itemPrices[itemId] ?? 999999;

  MotionCoreProvider() {
    initialize();
  }

  String getString(String key, {Map<String, String>? params}) {
    String text = AppStrings.translations[_currentLanguage]?[key] ?? key;
    if (params != null) {
      params.forEach((k, v) {
        text = text.replaceAll('@$k', v);
      });
    }
    return text;
  }

  Future<void> setLanguage(String langCode) async {
    _currentLanguage = langCode;
    await StorageService.saveLanguage(langCode);
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _currentLanguage = await StorageService.loadLanguage();
      final energyData = await StorageService.loadEnergyData();
      final planetData = await StorageService.loadPlanetState(); 
      
      _energyUnits = EnergyUnits(
        steps: energyData['steps']!,
        availableEnergy: energyData['availableEnergy']!,
        totalHarvested: energyData['totalHarvested']!,
      );
      
      _planetState = PlanetState(
        hydrosphere: planetData['hydrosphere']!,
        atmosphere: planetData['atmosphere']!,
        biosphere: planetData['biosphere']!,
        humanity: planetData['humanity'] ?? 0.0,
      );
      
      _lastSensorReading = await StorageService.loadLastSensorReading();
      _completedMissions = await StorageService.loadCompletedMissions();
      _purchasedItems = await StorageService.loadPurchasedItems();
      _updateActiveBoosts();
      _lastDate = await StorageService.loadLastDate();
      _dailySteps = await StorageService.loadDailySteps(30);
      _checkAndUpdateDailySteps();
      
      if (_purchasedItems.containsKey('selected_color')) {
        final colorValue = _purchasedItems['selected_color'] as int;
        _customPlanetColor = Color(colorValue);
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading saved data: $e');
    }
  }
  
  void _updateActiveBoosts() {
    _stepMultiplier = 1.0;
    _harvestBonus = 1.0;
    
    if (_purchasedItems.containsKey('step_multiplier_2x')) {
      final expiry = _purchasedItems['step_multiplier_2x'] as int?;
      if (expiry != null && expiry > DateTime.now().millisecondsSinceEpoch) {
        _stepMultiplier = 2.0;
      } else {
        _purchasedItems.remove('step_multiplier_2x');
        StorageService.savePurchasedItems(_purchasedItems);
      }
    }
    if (_purchasedItems.containsKey('energy_bonus_50')) {
      _harvestBonus = 1.5;
    }
    _isNeonGlowActive = _purchasedItems.containsKey('neon_glow');
    _isParticleEffectsActive = _purchasedItems.containsKey('particle_effects');
    _isCustomColorsActive = _purchasedItems.containsKey('custom_colors');
  }
  
  Future<void> setCustomPlanetColor(Color? color) async {
    _customPlanetColor = color;
    if (color != null) {
      _purchasedItems['selected_color'] = color.value;
    } else {
      _purchasedItems.remove('selected_color');
    }
    await StorageService.savePurchasedItems(_purchasedItems);
    notifyListeners();
  }
  
  void _checkAndUpdateDailySteps() {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (_lastDate != todayKey) {
      if (_lastDate != null) {
        final yesterdayStartSteps = _dailySteps[_lastDate!] ?? _energyUnits.steps;
        final yesterdayEndSteps = _energyUnits.steps;
        final yesterdayTotalSteps = yesterdayEndSteps - yesterdayStartSteps;
        if (yesterdayTotalSteps > 0) {
          StorageService.saveDailySteps(_lastDate!, yesterdayTotalSteps);
          _dailySteps[_lastDate!] = yesterdayTotalSteps;
        }
      }
      _dailySteps[todayKey] = _energyUnits.steps;
      StorageService.saveLastDate(todayKey);
      _lastDate = todayKey;
      _dailyMissionsStatus = {'daily_3k': 0, 'daily_7k': 0, 'daily_10k': 0};
    }
    _checkAllMissions();
  }
  
  void _updateTodaySteps({required int newSteps}) {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    int currentDailySteps = _dailySteps[todayKey] ?? 0;
    _dailySteps[todayKey] = currentDailySteps + newSteps;
    _checkAllMissions();
  }

  void _checkAllMissions() {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final todayTotalSteps = _dailySteps[todayKey] ?? 0;

    if (todayTotalSteps >= 3000 && _dailyMissionsStatus['daily_3k'] == 0) {
      _dailyMissionsStatus['daily_3k'] = 1;
    }
    if (todayTotalSteps >= 7000 && _dailyMissionsStatus['daily_7k'] == 0) {
      _dailyMissionsStatus['daily_7k'] = 1;
    }
    if (todayTotalSteps >= 10000 && _dailyMissionsStatus['daily_10k'] == 0) {
      _dailyMissionsStatus['daily_10k'] = 1;
    }

    mainMissionsCompletionStatus['mission_1'] = _energyUnits.steps >= 1000;
    mainMissionsCompletionStatus['mission_2'] = _planetState.hydrosphere >= 0.1;
    mainMissionsCompletionStatus['mission_3'] = _planetState.atmosphere >= 0.2;
    mainMissionsCompletionStatus['mission_4'] = _planetState.biosphere > 0;
  }
  
  Future<Map<String, int>> getDailySteps(int days) async {
    final now = DateTime.now();
    Map<String, int> result = {};
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      result[dateKey] = _dailySteps[dateKey] ?? 0;
    }
    return result;
  }

  Future<bool> claimDailyMissionReward(String missionId, int reward) async {
    if (_dailyMissionsStatus[missionId] == 1) {
      _energyUnits = _energyUnits.copyWith(totalHarvested: _energyUnits.totalHarvested + reward);
      _dailyMissionsStatus[missionId] = 2;
      _saveEnergyDataImmediate();
      notifyListeners();
      return true;
    }
    return false;
  }

  void updateSteps(int rawSensorSteps) async {
    if (!_isInitialized) return;

    if (_lastSensorReading == 0) {
      _lastSensorReading = rawSensorSteps;
      await StorageService.saveLastSensorReading(_lastSensorReading);
      return; 
    }

    int newSteps = 0;
    if (rawSensorSteps < _lastSensorReading) {
      newSteps = rawSensorSteps;
    } else {
      newSteps = rawSensorSteps - _lastSensorReading;
    }

    if (newSteps > 0) {
      _energyUnits = _energyUnits.copyWith(
        steps: _energyUnits.steps + newSteps,
        availableEnergy: _energyUnits.availableEnergy + (newSteps * _stepMultiplier).toInt(),
      );

      _updateTodaySteps(newSteps: newSteps);
      _saveEnergyData();
      notifyListeners();
    }

    _lastSensorReading = rawSensorSteps;
    await StorageService.saveLastSensorReading(_lastSensorReading);
  }
  
  void _saveEnergyData() {
    if(!_isInitialized) return;
    StorageService.saveEnergyData(steps: _energyUnits.steps, availableEnergy: _energyUnits.availableEnergy, totalHarvested: _energyUnits.totalHarvested);
  }
  
  void _savePlanetData() {
    if(!_isInitialized) return;
    StorageService.savePlanetState(hydrosphere: _planetState.hydrosphere, atmosphere: _planetState.atmosphere, biosphere: _planetState.biosphere, humanity: _planetState.humanity);
  }
  
  void _saveEnergyDataImmediate() => _saveEnergyData();
  void _savePlanetDataImmediate() => _savePlanetData();

  void harvestEnergy() {
    if (_energyUnits.availableEnergy > 0) {
      final harvested = (_energyUnits.availableEnergy * _harvestBonus).toInt();
      _energyUnits = _energyUnits.copyWith(totalHarvested: _energyUnits.totalHarvested + harvested, availableEnergy: 0);
      _saveEnergyDataImmediate();
      notifyListeners();
    }
  }
  
  Future<bool> claimMissionReward(String missionId, int reward) async {
    if (mainMissionsCompletionStatus[missionId] == true && !_completedMissions.contains(missionId)) {
        _energyUnits = _energyUnits.copyWith(totalHarvested: _energyUnits.totalHarvested + reward);
        _completedMissions.add(missionId);
        await StorageService.saveCompletedMissions(_completedMissions);
        _saveEnergyDataImmediate();
        notifyListeners();
        return true;
    }
    return false;
  }
  
  Future<bool> purchaseMarketItem(String itemId, int price, {int? durationHours}) async {
    if (_energyUnits.totalHarvested < price) {
      return false;
    }
    _energyUnits = _energyUnits.copyWith(totalHarvested: _energyUnits.totalHarvested - price);
    if (durationHours != null) {
      final expiry = DateTime.now().add(Duration(hours: durationHours)).millisecondsSinceEpoch;
      _purchasedItems[itemId] = expiry;
    } else {
      _purchasedItems[itemId] = true;
    }
    await StorageService.savePurchasedItems(_purchasedItems);
    _updateActiveBoosts();
    _saveEnergyDataImmediate();
    notifyListeners();
    return true;
  }

  Future<void> refundMarketData() async {
    int totalRefund = 0;
    _purchasedItems.forEach((key, value) {
      if (_itemPrices.containsKey(key)) {
        totalRefund += _itemPrices[key]!;
      }
    });
    _energyUnits = _energyUnits.copyWith(totalHarvested: _energyUnits.totalHarvested + totalRefund);
    _purchasedItems.clear();
    _customPlanetColor = null;
    await StorageService.savePurchasedItems(_purchasedItems);
    _updateActiveBoosts();
    _saveEnergyDataImmediate(); 
    notifyListeners();
  }

  Future<void> factoryReset() async {
    _energyUnits = EnergyUnits(steps: 0, availableEnergy: 0, totalHarvested: 0);
    _lastSensorReading = 0;
    await StorageService.saveLastSensorReading(0);
    _planetState = PlanetState();
    _purchasedItems.clear();
    _completedMissions.clear();
    _dailyMissionsStatus = {'daily_3k': 0, 'daily_7k': 0, 'daily_10k': 0};
    _customPlanetColor = null;
    _dailySteps.clear();
    _lastDate = null;
    _saveEnergyDataImmediate();
    _savePlanetDataImmediate();
    await StorageService.savePurchasedItems(_purchasedItems);
    await StorageService.saveCompletedMissions(_completedMissions);
    _updateActiveBoosts();
    notifyListeners();
  }
  
  bool commitTerraforming({
    required double hydrosphere,
    required double atmosphere,
    required double biosphere,
    double? humanity,
  }) {
    final current = _planetState;
    _planetState = _planetState.copyWith(hydrosphere: hydrosphere, atmosphere: atmosphere, biosphere: biosphere, humanity: humanity ?? current.humanity);
    _savePlanetDataImmediate();
    _checkAllMissions();
    notifyListeners();
    return true;
  }
}
