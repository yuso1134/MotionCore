class PlanetState {
  final double hydrosphere; // 0.0 - 1.0
  final double atmosphere; // 0.0 - 1.0
  final double biosphere; // 0.0 - 1.0
  final double humanity; // 0.0 - 1.0 (Yeni alan)

  PlanetState({
    this.hydrosphere = 0.0,
    this.atmosphere = 0.0,
    this.biosphere = 0.0,
    this.humanity = 0.0,
  });

  PlanetState copyWith({
    double? hydrosphere,
    double? atmosphere,
    double? biosphere,
    double? humanity,
  }) {
    return PlanetState(
      hydrosphere: hydrosphere ?? this.hydrosphere,
      atmosphere: atmosphere ?? this.atmosphere,
      biosphere: biosphere ?? this.biosphere,
      humanity: humanity ?? this.humanity,
    );
  }

  // Gezegen fazını belirle
  PlanetPhase get phase {
    if (atmosphere < 0.3) {
      return PlanetPhase.deadRock;
    } else if (hydrosphere < 0.5) {
      return PlanetPhase.blueHope;
    } else if (biosphere > 0.3) {
      return PlanetPhase.greenEden;
    } else {
      return PlanetPhase.blueHope;
    }
  }

  // Toplam ilerleme yüzdesi (Humanity dahil)
  double get totalProgress {
    // Toplam 4 parametre var, ancak Phase 1-2'de Humanity yok.
    // Basitlik için 4'e bölüyoruz, maksimum %100 olması için arayüzde kontrol edeceğiz.
    return (hydrosphere + atmosphere + biosphere + humanity) / 4.0;
  }

  // Stage numarası (1, 2, 3)
  int get stageNumber {
    switch (phase) {
      case PlanetPhase.deadRock:
        return 1;
      case PlanetPhase.blueHope:
        return 2;
      case PlanetPhase.greenEden:
        return 3;
    }
  }

  // Stage adı
  String get stageName {
    switch (phase) {
      case PlanetPhase.deadRock:
        return 'DEAD ROCK';
      case PlanetPhase.blueHope:
        return 'BLUE HOPE';
      case PlanetPhase.greenEden:
        return 'GREEN EDEN';
    }
  }

  // Phase başlığı (Eski kodda kalmış olabilir ama artık kullanılmıyor, yine de modelde dursun)
  String get phaseTitle {
    switch (phase) {
      case PlanetPhase.deadRock:
        return 'Phase 1: Grey Rock';
      case PlanetPhase.blueHope:
        return 'Phase 2: Blue Hope';
      case PlanetPhase.greenEden:
        return 'Phase 3: Green Eden';
    }
  }
}

enum PlanetPhase {
  deadRock, // Phase 1: The Dead Rock (Grey)
  blueHope, // Phase 2: Blue Hope (Water)
  greenEden, // Phase 3: Green Eden (Life)
}
