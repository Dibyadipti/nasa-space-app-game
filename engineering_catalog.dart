import '../models/mission_models.dart';

class EngineeringCatalog {
  static const List<MissionTarget> targets = [
    MissionTarget(
      id: 'leo',
      name: 'Low Earth Orbit (LEO)',
      subtitle: 'Earth Observation & Climate Monitoring',
      distanceAu: 0.00001,
      requiredDeltaV: 9.4,
      radiationRisk: 0.15,
      solarEfficiency: 1.0,
      nasaBodyQuery: 'earth',
    ),
    MissionTarget(
      id: 'moon',
      name: 'Lunar South Pole',
      subtitle: 'Water-Ice & Surface Prospecting',
      distanceAu: 0.00257,
      requiredDeltaV: 13.2,
      radiationRisk: 0.45,
      solarEfficiency: 0.95,
      nasaBodyQuery: 'moon',
    ),
    MissionTarget(
      id: 'mars',
      name: 'Mars Orbit & Surface',
      subtitle: 'Astrobiology & Atmospheric Analysis',
      distanceAu: 1.52,
      requiredDeltaV: 16.5,
      radiationRisk: 0.70,
      solarEfficiency: 0.43,
      nasaBodyQuery: 'mars',
    ),
    MissionTarget(
      id: 'europa',
      name: 'Jupiter / Europa',
      subtitle: 'Subsurface Ocean & Plume Detection',
      distanceAu: 5.20,
      requiredDeltaV: 21.0,
      radiationRisk: 0.95,
      solarEfficiency: 0.04,
      nasaBodyQuery: 'jupiter',
    ),
  ];

  static const List<LaunchVehicle> rockets = [
    LaunchVehicle(
      name: 'SmallSat Light Launcher',
      costMillion: 45,
      maxPayloadKg: 500,
      maxDeltaV: 10.5,
      reliability: 0.92,
    ),
    LaunchVehicle(
      name: 'Medium Reusable Falcon-Class',
      costMillion: 95,
      maxPayloadKg: 2200,
      maxDeltaV: 15.0,
      reliability: 0.97,
    ),
    LaunchVehicle(
      name: 'Heavy Deep-Space SLS-Class',
      costMillion: 210,
      maxPayloadKg: 6000,
      maxDeltaV: 22.5,
      reliability: 0.95,
    ),
  ];

  static const List<SpacecraftComponent> powerSystems = [
    SpacecraftComponent(
      name: 'Standard Solar Array',
      category: 'Power',
      costMillion: 20,
      massKg: 120,
      powerWatts: 800,
    ),
    SpacecraftComponent(
      name: 'High-Efficiency Triple-Junction Solar',
      category: 'Power',
      costMillion: 45,
      massKg: 180,
      powerWatts: 1800,
    ),
    SpacecraftComponent(
      name: 'MMRTG Nuclear Battery (Deep Space)',
      category: 'Power',
      costMillion: 110,
      massKg: 260,
      powerWatts: 650,
    ),
  ];

  static const List<SpacecraftComponent> commsSystems = [
    SpacecraftComponent(
      name: 'S-Band Omnidirectional Antenna',
      category: 'Comms',
      costMillion: 12,
      massKg: 40,
      powerWatts: -80,
      dataRateMbps: 2.0,
    ),
    SpacecraftComponent(
      name: 'X-Band High-Gain Dish',
      category: 'Comms',
      costMillion: 35,
      massKg: 110,
      powerWatts: -220,
      dataRateMbps: 25.0,
    ),
    SpacecraftComponent(
      name: 'Deep Space Optical Laser Comms',
      category: 'Comms',
      costMillion: 70,
      massKg: 150,
      powerWatts: -350,
      dataRateMbps: 150.0,
    ),
  ];

  static const List<SpacecraftComponent> payloads = [
    SpacecraftComponent(
      name: 'Multispectral Imaging Camera',
      category: 'Payload',
      costMillion: 30,
      massKg: 140,
      powerWatts: -180,
      sciencePoints: 35,
    ),
    SpacecraftComponent(
      name: 'Ground-Penetrating Radar',
      category: 'Payload',
      costMillion: 55,
      massKg: 240,
      powerWatts: -320,
      sciencePoints: 60,
    ),
    SpacecraftComponent(
      name: 'Mass Spectrometer & Sample Lab',
      category: 'Payload',
      costMillion: 80,
      massKg: 350,
      powerWatts: -410,
      sciencePoints: 90,
    ),
    SpacecraftComponent(
      name: 'Magnetometer & Radiation Sensor',
      category: 'Payload',
      costMillion: 25,
      massKg: 75,
      powerWatts: -90,
      sciencePoints: 30,
    ),
  ];
}
