import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb; // Web kontrolü için
import 'package:pedometer/pedometer.dart';
// import 'package:sensors_plus/sensors_plus.dart'; // GEÇİCİ OLARAK DEVRE DIŞI
import '../providers/motion_core_provider.dart';

class SensorService {
  StreamSubscription<StepCount>? _stepCountStream;
  // StreamSubscription<AccelerometerEvent>? _accelerometerStream; // GEÇİCİ OLARAK DEVRE DIŞI
  final MotionCoreProvider provider;

  SensorService(this.provider);

  Future<void> startListening() async {
    // Web platformunda sensörleri başlatma
    if (kIsWeb) {
      print('Sensors are not supported on Web');
      return;
    }

    try {
      // Pedometer stream
      _stepCountStream = Pedometer.stepCountStream.listen(
        (StepCount event) {
          provider.updateSteps(event.steps);
        },
        onError: (error) {
          print('Pedometer error: $error');
        },
      );
    } catch (e) {
      print('Sensor initialization error: $e');
    }
  }

  void stopListening() {
    _stepCountStream?.cancel();
    // _accelerometerStream?.cancel(); // GEÇİCİ OLARAK DEVRE DIŞI
  }

  Future<int> getInitialStepCount() async {
    // Web platformunda 0 döndür
    if (kIsWeb) {
      return 0;
    }

    try {
      // Stream'den ilk değeri al
      final completer = Completer<int>();
      late StreamSubscription<StepCount> tempSubscription;
      
      tempSubscription = Pedometer.stepCountStream.listen(
        (StepCount event) {
          if (!completer.isCompleted) {
            completer.complete(event.steps);
            tempSubscription.cancel();
          }
        },
        onError: (error) {
          if (!completer.isCompleted) {
            completer.complete(0);
            tempSubscription.cancel();
          }
        },
      );
      
      // Timeout ekle
      Future.delayed(const Duration(seconds: 2), () {
        if (!completer.isCompleted) {
          completer.complete(0);
          tempSubscription.cancel();
        }
      });
      
      return await completer.future;
    } catch (e) {
      print('Error getting initial step count: $e');
      return 0;
    }
  }
}
