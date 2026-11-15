class MissionTarget {
  final String id;
  final String name;
  final String subtitle;
  final double distanceAu;
  final double requiredDeltaV;
  final double radiationRisk;
  final double solarEfficiency;
  final String nasaBodyQuery;

  const MissionTarget({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.distanceAu,
    required this.requiredDeltaV,
    required this.radiationRisk,
    required this.solarEfficiency,
    required this.nasaBodyQuery,
  });
}

class LaunchVehicle {
  final String name;
  final double costMillion;
  final double maxPayloadKg;
  final double maxDeltaV;
  final double reliability;

  const LaunchVehicle({
    required this.name,
    required this.costMillion,
    required this.maxPayloadKg,
    required this.maxDeltaV,
    required this.reliability,
  });
}

class SpacecraftComponent {
  final String name;
  final String category;
  final double costMillion;
  final double massKg;
  final double powerWatts;
  final int sciencePoints;
  final double dataRateMbps;

  const SpacecraftComponent({
    required this.name,
    required this.category,
    required this.costMillion,
    required this.massKg,
    required this.powerWatts,
    this.sciencePoints = 0,
    this.dataRateMbps = 0,
  });
}
