import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _keySteps = 'steps';
  static const String _keyEnergy = 'available_energy';
  static const String _keyTotalHarvested = 'total_harvested';
  static const String _keyLastSensorReading = 'last_sensor_reading'; // YENİ
  static const String _keyHydrosphere = 'hydrosphere';
  static const String _keyAtmosphere = 'atmosphere';
  static const String _keyBiosphere = 'biosphere';
  static const String _keyHumanity = 'humanity'; 
  static const String _keyCompletedMissions = 'completed_missions';
  static const String _keyPurchasedItems = 'purchased_items';
  static const String _keyLastDate = 'last_date';
  static const String _keyDailySteps = 'daily_steps';
  static const String _keyLanguage = 'app_language';

  // YENİ FONKSİYONLAR
  static Future<void> saveLastSensorReading(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastSensorReading, count);
  }

  static Future<int> loadLastSensorReading() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLastSensorReading) ?? 0;
  }

  static Future<String> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'en';
  }

  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, languageCode);
  }

  static Future<void> saveEnergyData({
    required int steps,
    required int availableEnergy,
    required int totalHarvested,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySteps, steps);
    await prefs.setInt(_keyEnergy, availableEnergy);
    await prefs.setInt(_keyTotalHarvested, totalHarvested);
  }

  static Future<Map<String, int>> loadEnergyData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'steps': prefs.getInt(_keySteps) ?? 0,
      'availableEnergy': prefs.getInt(_keyEnergy) ?? 0,
      'totalHarvested': prefs.getInt(_keyTotalHarvested) ?? 0,
    };
  }

  static Future<void> savePlanetState({
    required double hydrosphere,
    required double atmosphere,
    required double biosphere,
    double humanity = 0.0, 
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyHydrosphere, hydrosphere);
    await prefs.setDouble(_keyAtmosphere, atmosphere);
    await prefs.setDouble(_keyBiosphere, biosphere);
    await prefs.setDouble(_keyHumanity, humanity);
  }

  static Future<Map<String, double>> loadPlanetState() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hydrosphere': prefs.getDouble(_keyHydrosphere) ?? 0.0,
      'atmosphere': prefs.getDouble(_keyAtmosphere) ?? 0.0,
      'biosphere': prefs.getDouble(_keyBiosphere) ?? 0.0,
      'humanity': prefs.getDouble(_keyHumanity) ?? 0.0,
    };
  }
  
  static Future<void> saveCompletedMissions(Set<String> missionIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCompletedMissions, missionIds.toList());
  }
  
  static Future<Set<String>> loadCompletedMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCompletedMissions) ?? [];
    return list.toSet();
  }
  
  static Future<void> savePurchasedItems(Map<String, dynamic> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPurchasedItems, jsonEncode(items));
  }
  
  static Future<Map<String, dynamic>> loadPurchasedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyPurchasedItems);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return {};
  }
  
  static Future<void> saveLastDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastDate, date);
  }
  
  static Future<String?> loadLastDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastDate);
  }
  
  static Future<void> saveDailySteps(String date, int steps) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyDailySteps);
    Map<String, dynamic> dailyData = {};
    
    if (jsonString != null) {
      dailyData = jsonDecode(jsonString);
    }
    
    int currentSteps = (dailyData[date] as int?) ?? 0;
    dailyData[date] = currentSteps + steps;
    
    await prefs.setString(_keyDailySteps, jsonEncode(dailyData));
  }
  
  static Future<Map<String, int>> loadDailySteps(int daysBack) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyDailySteps);
    if (jsonString == null) return {};
    
    final Map<String, dynamic> rawData = jsonDecode(jsonString);
    final Map<String, int> result = {};
    
    rawData.forEach((key, value) {
      if (value is int) {
        result[key] = value;
      }
    });
    
    return result;
  }
}
