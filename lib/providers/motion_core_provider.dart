import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Color için
import '../models/planet_state.dart';
import '../models/energy_units.dart';
import '../services/storage_service.dart';
import '../utils/app_strings.dart'; 

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

  bool _isNeonGlowActive = false;
  bool _isParticleEffectsActive = false;
  bool _isCustomColorsActive = false;
  Color? _customPlanetColor;
  
  String? _lastDate;
  Map<String, int> _dailySteps = {};
  
  String _currentLanguage = 'en';

  // GÜNLÜK GÖREVLER DURUMU
  // Map<MissionID, Status> -> Status: 0 (Not Completed), 1 (Completed), 2 (Claimed)
  Map<String, int> _dailyMissionsStatus = {
    'daily_3k': 0,
    'daily_7k': 0,
    'daily_10k': 0,
  };

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

  // İDEAL FİYATLAR (10.000 adım Milestone'a göre)
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
      
      final savedHydro = planetData['hydrosphere']!;
      final savedAtmos = planetData['atmosphere']!;
      final savedBio = planetData['biosphere']!;
      final savedHuman = planetData['humanity'] ?? 0.0; 
      
      if (savedHydro == 0.0 && savedAtmos == 0.0 && savedBio == 0.0 && savedHuman == 0.0) {
        _planetState = PlanetState();
      } else {
        _planetState = PlanetState(
          hydrosphere: savedHydro,
          atmosphere: savedAtmos,
          biosphere: savedBio,
          humanity: savedHuman,
        );
      }
      
      _lastStepCount = _energyUnits.steps;
      _completedMissions = await StorageService.loadCompletedMissions();
      _purchasedItems = await StorageService.loadPurchasedItems();
      
      // Günlük görev durumlarını yükleyebiliriz ama basitlik için günlük resetleniyor varsayıyoruz
      // İstenirse StorageService'e eklenebilir. Şimdilik hafızada.
      
      _updateActiveBoosts();
      _lastDate = await StorageService.loadLastDate();
      _dailySteps = await StorageService.loadDailySteps(30);
      _checkAndUpdateDailySteps(); // Günlük kontrol ve sıfırlama burada
      
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
      // GÜN DEĞİŞTİ!
      if (_lastDate != null) {
        final yesterdayStartSteps = _dailySteps[_lastDate!] ?? 0;
        final yesterdayEndSteps = _energyUnits.steps;
        final yesterdayTotalSteps = yesterdayEndSteps - yesterdayStartSteps;
        if (yesterdayTotalSteps > 0) {
          StorageService.saveDailySteps(_lastDate!, yesterdayTotalSteps);
          _dailySteps[_lastDate!] = yesterdayTotalSteps;
        }
      }
      
      // Yeni gün için başlangıç değerini ayarla
      _dailySteps[todayKey] = _energyUnits.steps;
      StorageService.saveLastDate(todayKey);
      _lastDate = todayKey;
      
      // GÜNLÜK GÖREVLERİ SIFIRLA
      _dailyMissionsStatus = {
        'daily_3k': 0,
        'daily_7k': 0,
        'daily_10k': 0,
      };
      // (Burada completedMissions içinden günlük görevleri silmek gerekmez, çünkü ayrı map kullanıyoruz)
    }
    
    // Günlük görevleri kontrol et (Başlangıçta)
    _checkDailyMissions();
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
    
    // Günlük görevleri kontrol et (Her adım güncellemesinde)
    _checkDailyMissions(todayTotalSteps);
  }

  void _checkDailyMissions([int? todaySteps]) {
    if (todaySteps == null) {
      // Bugünün adımlarını hesapla
      final now = DateTime.now();
      final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final start = _dailySteps[todayKey] ?? _energyUnits.steps;
      todaySteps = _energyUnits.steps - start;
    }

    if (todaySteps >= 3000 && _dailyMissionsStatus['daily_3k'] == 0) {
      _dailyMissionsStatus['daily_3k'] = 1; // Completed
    }
    if (todaySteps >= 7000 && _dailyMissionsStatus['daily_7k'] == 0) {
      _dailyMissionsStatus['daily_7k'] = 1;
    }
    if (todaySteps >= 10000 && _dailyMissionsStatus['daily_10k'] == 0) {
      _dailyMissionsStatus['daily_10k'] = 1;
    }
    // notifyListeners() genellikle updateSteps içinde çağrıldığı için burada gerekmez ama 
    // manuel çağrılar için ekleyebiliriz. Ancak loop olmasın.
  }

  // Günlük görev ödülünü al
  Future<bool> claimDailyMissionReward(String missionId, int reward) async {
    if (_dailyMissionsStatus[missionId] == 1) { // Eğer tamamlandıysa (1)
      _energyUnits = _energyUnits.copyWith(
        totalHarvested: _energyUnits.totalHarvested + reward,
      );
      _dailyMissionsStatus[missionId] = 2; // Alındı (2) olarak işaretle
      
      _saveEnergyDataImmediate();
      notifyListeners();
      return true;
    }
    return false;
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
      _updateTodaySteps(); // Günlük görev kontrolü burada yapılıyor
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
          humanity: _planetState.humanity, // Humanity eklendi
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
      humanity: _planetState.humanity, // Humanity eklendi
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

  Future<void> refundMarketData() async {
    int totalRefund = 0;
    _purchasedItems.forEach((key, value) {
      if (_itemPrices.containsKey(key)) {
        totalRefund += _itemPrices[key]!;
      }
    });
    _energyUnits = _energyUnits.copyWith(
      totalHarvested: _energyUnits.totalHarvested + totalRefund,
    );
    _purchasedItems.clear();
    _customPlanetColor = null;
    await StorageService.savePurchasedItems(_purchasedItems);
    _updateActiveBoosts();
    _saveEnergyDataImmediate(); 
    notifyListeners();
  }

  Future<void> factoryReset() async {
    _energyUnits = EnergyUnits(steps: 0, availableEnergy: 0, totalHarvested: 0);
    _lastStepCount = 0;
    _planetState = PlanetState(hydrosphere: 0.0, atmosphere: 0.0, biosphere: 0.0, humanity: 0.0);
    _purchasedItems.clear();
    _completedMissions.clear();
    _dailyMissionsStatus = {'daily_3k': 0, 'daily_7k': 0, 'daily_10k': 0}; // Günlük görevleri sıfırla
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
    double? humanity, // Yeni parametre
  }) {
    _planetState = _planetState.copyWith(
      hydrosphere: hydrosphere,
      atmosphere: atmosphere,
      biosphere: biosphere,
      humanity: humanity,
    );
    _savePlanetData();
    notifyListeners();
  }

  bool commitTerraforming({
    required double hydrosphere,
    required double atmosphere,
    required double biosphere,
    double? humanity, // Yeni parametre (opsiyonel olabilir, ama konsolda vereceğiz)
  }) {
    final current = _planetState;
    final hydroDiff = (hydrosphere - current.hydrosphere).abs();
    final atmosDiff = (atmosphere - current.atmosphere).abs();
    final bioDiff = (biosphere - current.biosphere).abs();
    final humanDiff = (humanity != null) ? (humanity - current.humanity).abs() : 0.0;
    
    final cost = ((hydroDiff + atmosDiff + bioDiff + humanDiff) * 100).toInt();
    
    // Ücretsiz olduğu için enerji kontrolü kaldırıldı (istek üzerine)
    // if (_energyUnits.totalHarvested < cost) return false;

    // Harcama da yapmıyoruz
    /*
    _energyUnits = _energyUnits.copyWith(
      totalHarvested: _energyUnits.totalHarvested - cost,
    );
    _saveEnergyDataImmediate();
    */

    _planetState = _planetState.copyWith(
      hydrosphere: hydrosphere,
      atmosphere: atmosphere,
      biosphere: biosphere,
      humanity: humanity ?? current.humanity,
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
        humanity: _planetState.humanity,
      );
    }
    super.dispose();
  }
}
