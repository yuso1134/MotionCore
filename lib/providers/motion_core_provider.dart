import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Color için
import '../models/planet_state.dart';
import '../models/energy_units.dart';
import '../services/storage_service.dart';

class MotionCoreProvider with ChangeNotifier {
  PlanetState _planetState = PlanetState();
  EnergyUnits _energyUnits = EnergyUnits();
  Timer? _saveTimer;
  int _lastStepCount = 0;
  bool _isInitialized = false;
  bool _needsEnergySave = false;
  bool _needsPlanetSave = false;
  
  Set<String> _completedMissions = {};
  Map<String, dynamic> _purchasedItems = {};
  double _stepMultiplier = 1.0;
  double _harvestBonus = 1.0;

  // Market özellikleri
  bool _isNeonGlowActive = false;
  bool _isParticleEffectsActive = false;
  bool _isCustomColorsActive = false;
  
  // Seçilen özel renk (null ise varsayılan renkler kullanılır)
  Color? _customPlanetColor;
  
  String? _lastDate;
  Map<String, int> _dailySteps = {};

  PlanetState get planetState => _planetState;
  EnergyUnits get energyUnits => _energyUnits;
  Set<String> get completedMissions => _completedMissions;
  Map<String, dynamic> get purchasedItems => _purchasedItems;
  double get stepMultiplier => _stepMultiplier;
  double get harvestBonus => _harvestBonus;

  // Arayüzün erişmesi için getter'lar
  bool get isNeonGlowActive => _isNeonGlowActive;
  bool get isParticleEffectsActive => _isParticleEffectsActive;
  bool get isCustomColorsActive => _isCustomColorsActive;
  Color? get customPlanetColor => _customPlanetColor;

  // Ürün fiyatları (İade işlemi için gerekli)
  final Map<String, int> _itemPrices = {
    'step_multiplier_2x': 1,
    'energy_bonus_50': 1,
    'neon_glow': 1,
    'particle_effects': 1,
    'custom_colors': 1,
  };

  MotionCoreProvider() {
    initialize();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final energyData = await StorageService.loadEnergyData();
      final planetData = await StorageService.loadPlanetState();
      
      _energyUnits = EnergyUnits(
        steps: energyData['steps']!,
        availableEnergy: energyData['availableEnergy']!,
        totalHarvested: energyData['totalHarvested']!,
      );
      
      final savedHydro = planetData['hydrosphere']!;
      final savedAtmos = planetData['atmosphere']!;
      final savedBio = planetData['biosphere']!;
      
      if (savedHydro == 0.0 && savedAtmos == 0.0 && savedBio == 0.0) {
        _planetState = PlanetState(
          hydrosphere: 0.0, 
          atmosphere: 0.0,
          biosphere: 0.0,
        );
      } else {
        _planetState = PlanetState(
          hydrosphere: savedHydro,
          atmosphere: savedAtmos,
          biosphere: savedBio,
        );
      }
      
      _lastStepCount = _energyUnits.steps;
      
      _completedMissions = await StorageService.loadCompletedMissions();
      _purchasedItems = await StorageService.loadPurchasedItems();
      _updateActiveBoosts();
      
      _lastDate = await StorageService.loadLastDate();
      _dailySteps = await StorageService.loadDailySteps(30);
      _checkAndUpdateDailySteps();
      
      // Kaydedilen rengi yükle (Hex string olarak saklanmış olabilir)
      if (_purchasedItems.containsKey('selected_color')) {
        final colorValue = _purchasedItems['selected_color'] as int;
        _customPlanetColor = Color(colorValue);
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error loading saved data: $e');
      _isInitialized = true;
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

    notifyListeners();
  }
  
  // Özel renk seçme metodu
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
  
  // ... (Diğer metodlar aynı kalıyor) ...
  
  void _checkAndUpdateDailySteps() {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    if (_lastDate != todayKey) {
      if (_lastDate != null) {
        final yesterdayStartSteps = _dailySteps[_lastDate!] ?? 0;
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
    }
  }
  
  void _updateTodaySteps() {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    final todayStartSteps = _dailySteps[todayKey] ?? _energyUnits.steps;
    final todayTotalSteps = _energyUnits.steps - todayStartSteps;
    
    if (todayTotalSteps > 0) {
      StorageService.saveDailySteps(todayKey, todayTotalSteps);
      _dailySteps[todayKey] = todayTotalSteps;
    }
  }

  void updateSteps(int steps) {
    if (steps > _lastStepCount) {
      final newSteps = steps - _lastStepCount;
      _lastStepCount = steps;
      
      final energyGain = (newSteps * _stepMultiplier).toInt();
      
      _energyUnits = _energyUnits.copyWith(
        steps: steps,
        availableEnergy: _energyUnits.availableEnergy + energyGain,
      );
      
      _saveEnergyData();
      _updateTodaySteps();
      
      notifyListeners();
    }
  }
  
  void _saveEnergyData() {
    _needsEnergySave = true;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 1), () {
      if (_needsEnergySave) {
        StorageService.saveEnergyData(
          steps: _energyUnits.steps,
          availableEnergy: _energyUnits.availableEnergy,
          totalHarvested: _energyUnits.totalHarvested,
        );
        _needsEnergySave = false;
      }
    });
  }
  
  void _savePlanetData() {
    _needsPlanetSave = true;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 1), () {
      if (_needsPlanetSave) {
        StorageService.savePlanetState(
          hydrosphere: _planetState.hydrosphere,
          atmosphere: _planetState.atmosphere,
          biosphere: _planetState.biosphere,
        );
        _needsPlanetSave = false;
      }
    });
  }
  
  void _saveEnergyDataImmediate() {
    _saveTimer?.cancel();
    _needsEnergySave = false;
    StorageService.saveEnergyData(
      steps: _energyUnits.steps,
      availableEnergy: _energyUnits.availableEnergy,
      totalHarvested: _energyUnits.totalHarvested,
    );
  }
  
  void _savePlanetDataImmediate() {
    _saveTimer?.cancel();
    _needsPlanetSave = false;
    StorageService.savePlanetState(
      hydrosphere: _planetState.hydrosphere,
      atmosphere: _planetState.atmosphere,
      biosphere: _planetState.biosphere,
    );
  }

  void harvestEnergy() {
    if (_energyUnits.availableEnergy > 0) {
      final harvested = (_energyUnits.availableEnergy * _harvestBonus).toInt();
      
      _energyUnits = _energyUnits.copyWith(
        totalHarvested: _energyUnits.totalHarvested + harvested,
        availableEnergy: 0,
      );
      _saveEnergyDataImmediate();
      notifyListeners();
    }
  }
  
  Future<bool> claimMissionReward(String missionId, int reward) async {
    if (_completedMissions.contains(missionId)) {
      return false;
    }
    
    _energyUnits = _energyUnits.copyWith(
      totalHarvested: _energyUnits.totalHarvested + reward,
    );
    
    _completedMissions.add(missionId);
    await StorageService.saveCompletedMissions(_completedMissions);
    
    _saveEnergyDataImmediate();
    notifyListeners();
    return true;
  }
  
  Future<bool> purchaseMarketItem(String itemId, int price, {int? durationHours}) async {
    if (_energyUnits.totalHarvested < price) {
      return false;
    }
    
    _energyUnits = _energyUnits.copyWith(
      totalHarvested: _energyUnits.totalHarvested - price,
    );
    
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

  // Market verilerini sıfırlama ve İADE (Refund)
  Future<void> refundMarketData() async {
    int totalRefund = 0;
    
    // Satın alınan ürünlerin fiyatlarını hesapla
    _purchasedItems.forEach((key, value) {
      if (_itemPrices.containsKey(key)) {
        totalRefund += _itemPrices[key]!;
      }
    });

    // Parayı iade et
    _energyUnits = _energyUnits.copyWith(
      totalHarvested: _energyUnits.totalHarvested + totalRefund,
    );

    // Ürünleri sil
    _purchasedItems.clear();
    _customPlanetColor = null;
    await StorageService.savePurchasedItems(_purchasedItems);
    
    _updateActiveBoosts();
    _saveEnergyDataImmediate(); 
    notifyListeners();
  }

  // FACTORY RESET (Tam sıfırlama)
  Future<void> factoryReset() async {
    // 1. Enerji ve Adımları sıfırla
    _energyUnits = EnergyUnits(steps: 0, availableEnergy: 0, totalHarvested: 0);
    _lastStepCount = 0;
    
    // 2. Gezegeni sıfırla
    _planetState = PlanetState(hydrosphere: 0.0, atmosphere: 0.0, biosphere: 0.0);
    
    // 3. Market ve Görevleri sıfırla
    _purchasedItems.clear();
    _completedMissions.clear();
    _customPlanetColor = null;
    
    // 4. Günlük verileri sıfırla
    _dailySteps.clear();
    _lastDate = null;

    // Veritabanına kaydet
    _saveEnergyDataImmediate();
    _savePlanetDataImmediate();
    await StorageService.savePurchasedItems(_purchasedItems);
    await StorageService.saveCompletedMissions(_completedMissions);
    // StorageService'e clearAll gibi bir metod eklemek daha temiz olurdu ama şimdilik üzerine yazıyoruz.
    
    _updateActiveBoosts();
    notifyListeners();
  }
  
  Future<Map<String, int>> getDailySteps(int days) async {
    final now = DateTime.now();
    final Map<String, int> result = {};
    
    final storedData = await StorageService.loadDailySteps(days);
    
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      result[dateKey] = storedData[dateKey] ?? 0;
    }
    
    return result;
  }
  
  Future<Map<String, int>> getWeeklySteps(int weeks) async {
    final now = DateTime.now();
    final Map<String, int> result = {};
    
    final storedData = await StorageService.loadDailySteps(weeks * 7);
    
    for (int i = 0; i < weeks; i++) {
      final weekStart = now.subtract(Duration(days: i * 7));
      final weekKey = 'Week ${weeks - i}';
      
      int weekTotal = 0;
      for (int j = 0; j < 7; j++) {
        final date = weekStart.subtract(Duration(days: j));
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        weekTotal += storedData[dateKey] ?? 0;
      }
      
      result[weekKey] = weekTotal;
    }
    
    return result;
  }

  void updatePlanetState({
    double? hydrosphere,
    double? atmosphere,
    double? biosphere,
  }) {
    _planetState = _planetState.copyWith(
      hydrosphere: hydrosphere,
      atmosphere: atmosphere,
      biosphere: biosphere,
    );
    _savePlanetData();
    notifyListeners();
  }

  bool commitTerraforming({
    required double hydrosphere,
    required double atmosphere,
    required double biosphere,
  }) {
    final current = _planetState;
    
    final hydroDiff = (hydrosphere - current.hydrosphere).abs();
    final atmosDiff = (atmosphere - current.atmosphere).abs();
    final bioDiff = (biosphere - current.biosphere).abs();
    
    final cost = ((hydroDiff + atmosDiff + bioDiff) * 100).toInt();
    
    if (_energyUnits.totalHarvested < cost) {
      return false;
    }

    _energyUnits = _energyUnits.copyWith(
      totalHarvested: _energyUnits.totalHarvested - cost,
    );
    _saveEnergyDataImmediate();

    _planetState = _planetState.copyWith(
      hydrosphere: hydrosphere,
      atmosphere: atmosphere,
      biosphere: biosphere,
    );
    _savePlanetDataImmediate();
    notifyListeners();

    return true;
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    if (_needsEnergySave) {
      StorageService.saveEnergyData(
        steps: _energyUnits.steps,
        availableEnergy: _energyUnits.availableEnergy,
        totalHarvested: _energyUnits.totalHarvested,
      );
    }
    if (_needsPlanetSave) {
      StorageService.savePlanetState(
        hydrosphere: _planetState.hydrosphere,
        atmosphere: _planetState.atmosphere,
        biosphere: _planetState.biosphere,
      );
    }
    super.dispose();
  }
}
