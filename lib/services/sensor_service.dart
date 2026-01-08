import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import '../providers/motion_core_provider.dart';

class SensorService {
  final MotionCoreProvider _provider;
  StreamSubscription<StepCount>? _stepCountSubscription;

  SensorService(this._provider);

  Future<int> getInitialStepCount() async {
    try {
      return (await Pedometer.stepCountStream.first).steps;
    } catch (e) {
      return 0;
    }
  }

  Future<void> startListening() async {
    _stepCountSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        _provider.updateSteps(event.steps);
      },
      onError: (error) {
        debugPrint("Pedometer Error: $error");
      },
      cancelOnError: true,
    );
  }

  void stopListening() {
    _stepCountSubscription?.cancel();
  }
}
