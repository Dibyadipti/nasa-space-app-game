import 'package:flutter/material.dart';
import '../data/engineering_catalog.dart';
import '../models/mission_models.dart';
import '../services/nasa_api_gateway.dart';
import 'simulation_screen.dart';

class MissionBuilderScreen extends StatefulWidget {
  const MissionBuilderScreen({super.key});

  @override
  State<MissionBuilderScreen> createState() => _MissionBuilderScreenState();
}

class _MissionBuilderScreenState extends State<MissionBuilderScreen> {
  final double _maxBudgetMillion = 350.0;

  MissionTarget _selectedTarget = EngineeringCatalog.targets[1]; // Moon
  LaunchVehicle _selectedRocket = EngineeringCatalog.rockets[1]; // Medium
  SpacecraftComponent _selectedPower = EngineeringCatalog.powerSystems[0];
  SpacecraftComponent _selectedComms = EngineeringCatalog.commsSystems[0];
  final Set<SpacecraftComponent> _selectedPayloads = {
    EngineeringCatalog.payloads[0],
  };

  Map<String, dynamic>? _spaceWeather;
  Map<String, dynamic>? _planetData;
  bool _loadingApi = true;

  @override
  void initState() {
    super.initState();
    _loadTelemetryGateways();
  }

  Future<void> _loadTelemetryGateways() async {
    setState(() => _loadingApi = true);
    final weather = await NasaApiGateway.fetchSpaceWeatherStatus();
    final planet = await NasaApiGateway.fetchPlanetaryData(
      _selectedTarget.nasaBodyQuery,
    );
    if (!mounted) return;
    setState(() {
      _spaceWeather = weather;
      _planetData = planet;
      _loadingApi = false;
    });
  }

  double get _totalCost {
    double sum = _selectedRocket.costMillion +
        _selectedPower.costMillion +
        _selectedComms.costMillion;
    for (var p in _selectedPayloads) {
      sum += p.costMillion;
    }
    return sum;
  }

  double get _totalMass {
    double sum =
        _selectedPower.massKg + _selectedComms.massKg + 150; // 150kg bus frame
    for (var p in _selectedPayloads) {
      sum += p.massKg;
    }
    return sum;
  }

  double get _netPowerWatts {
    double generated = _selectedPower.name.contains('Nuclear')
        ? _selectedPower.powerWatts
        : _selectedPower.powerWatts * _selectedTarget.solarEfficiency;
    double consumed = _selectedComms.powerWatts.abs();
    for (var p in _selectedPayloads) {
      consumed += p.powerWatts.abs();
    }
    return generated - consumed;
  }

  int get _totalScience {
    int score = 0;
    for (var p in _selectedPayloads) {
      score += p.sciencePoints;
    }
    return score;
  }

  void _loadDemoPreset() {
    setState(() {
      _selectedTarget = EngineeringCatalog.targets[2]; // Mars
      _selectedRocket = EngineeringCatalog.rockets[2]; // Heavy SLS
      _selectedPower = EngineeringCatalog.powerSystems[2]; // Nuclear MMRTG
      _selectedComms = EngineeringCatalog.commsSystems[2]; // Optical Laser
      _selectedPayloads
        ..clear()
        ..add(EngineeringCatalog.payloads[0])
        ..add(EngineeringCatalog.payloads[3]);
    });
    _loadTelemetryGateways();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Loaded Optimal Mars Astrobiology Demo Preset!'),
        backgroundColor: Color(0xFF00E5FF),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool overBudget = _totalCost > _maxBudgetMillion;
    final bool overMass = _totalMass > _selectedRocket.maxPayloadKg;
    final bool lowPower = _netPowerWatts < 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mission Design Studio'),
        backgroundColor: const Color(0xFF151C2C),
        actions: [
          TextButton.icon(
            onPressed: _loadDemoPreset,
            icon: const Icon(Icons.auto_awesome, color: Color(0xFFFF6D00)),
            label: const Text(
              'Demo Preset',
              style: TextStyle(color: Color(0xFFFF6D00)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildResourceHud(overBudget, overMass, lowPower),
          _buildNasaGatewayBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('1. Mission Destination & Orbit'),
                ...EngineeringCatalog.targets.map((target) {
                  final selected = target.id == _selectedTarget.id;
                  return Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: selected
                            ? const Color(0xFF00E5FF)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(target.name),
                      subtitle: Text(
                        '${target.subtitle} • Δv: ${target.requiredDeltaV} km/s • Solar: ${(target.solarEfficiency * 100).toInt()}%',
                      ),
                      trailing: Radio<MissionTarget>(
                        value: target,
                        groupValue: _selectedTarget,
                        activeColor: const Color(0xFF00E5FF),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedTarget = val);
                            _loadTelemetryGateways();
                          }
                        },
                      ),
                      onTap: () {
                        setState(() => _selectedTarget = target);
                        _loadTelemetryGateways();
                      },
                    ),
                  );
                }),
                const SizedBox(height: 16),
                _buildSectionHeader('2. Launch Vehicle'),
                ...EngineeringCatalog.rockets.map((rocket) {
                  final selected = rocket.name == _selectedRocket.name;
                  return Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: selected
                            ? const Color(0xFF00E5FF)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(rocket.name),
                      subtitle: Text(
                        'Cost: \$${rocket.costMillion.toInt()}M • Max Mass: ${rocket.maxPayloadKg.toInt()} kg • Max Δv: ${rocket.maxDeltaV} km/s',
                      ),
                      trailing: Radio<LaunchVehicle>(
                        value: rocket,
                        groupValue: _selectedRocket,
                        activeColor: const Color(0xFF00E5FF),
                        onChanged: (val) =>
                            setState(() => _selectedRocket = val!),
                      ),
                      onTap: () => setState(() => _selectedRocket = rocket),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                _buildSectionHeader('3. Power Subsystem'),
                ...EngineeringCatalog.powerSystems.map((power) {
                  final effectiveWatts = power.name.contains('Nuclear')
                      ? power.powerWatts
                      : power.powerWatts * _selectedTarget.solarEfficiency;
                  return Card(
                    child: RadioListTile<SpacecraftComponent>(
                      value: power,
                      groupValue: _selectedPower,
                      activeColor: const Color(0xFF00E5FF),
                      title: Text(power.name),
                      subtitle: Text(
                        'Output at ${_selectedTarget.name}: +${effectiveWatts.toInt()}W • Mass: ${power.massKg.toInt()}kg • \$${power.costMillion.toInt()}M',
                      ),
                      onChanged: (val) =>
                          setState(() => _selectedPower = val!),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                _buildSectionHeader('4. Communications System'),
                ...EngineeringCatalog.commsSystems.map((comms) {
                  return Card(
                    child: RadioListTile<SpacecraftComponent>(
                      value: comms,
                      groupValue: _selectedComms,
                      activeColor: const Color(0xFF00E5FF),
                      title: Text(comms.name),
                      subtitle: Text(
                        'Data Rate: ${comms.dataRateMbps} Mbps • Power: ${comms.powerWatts.toInt()}W • \$${comms.costMillion.toInt()}M',
                      ),
                      onChanged: (val) =>
                          setState(() => _selectedComms = val!),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                _buildSectionHeader('5. Scientific Payloads (Select 1 or more)'),
                ...EngineeringCatalog.payloads.map((payload) {
                  final isChecked = _selectedPayloads.contains(payload);
                  return Card(
                    child: CheckboxListTile(
                      value: isChecked,
                      activeColor: const Color(0xFF00E5FF),
                      title: Text(payload.name),
                      subtitle: Text(
                        'Science: +${payload.sciencePoints} pts • Mass: ${payload.massKg.toInt()}kg • Power: ${payload.powerWatts.toInt()}W • \$${payload.costMillion.toInt()}M',
                      ),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedPayloads.add(payload);
                          } else if (_selectedPayloads.length > 1) {
                            _selectedPayloads.remove(payload);
                          }
                        });
                      },
                    ),
                  );
                }),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: (overBudget || overMass)
                  ? Colors.redAccent
                  : const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SimulationScreen(
                    target: _selectedTarget,
                    rocket: _selectedRocket,
                    power: _selectedPower,
                    comms: _selectedComms,
                    payloads: _selectedPayloads.toList(),
                    totalCost: _totalCost,
                    maxBudget: _maxBudgetMillion,
                    totalMass: _totalMass,
                    netPower: _netPowerWatts,
                    rawScience: _totalScience,
                    spaceWeather: _spaceWeather ?? {},
                  ),
                ),
              );
            },
            icon: const Icon(Icons.rocket_launch),
            label: Text(
              overBudget
                  ? 'WARNING: OVER BUDGET (\$${_totalCost.toInt()}M / \$${_maxBudgetMillion.toInt()}M)'
                  : overMass
                      ? 'WARNING: EXCEEDS ROCKET MASS LIMIT'
                      : 'LAUNCH & SIMULATE MISSION',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResourceHud(bool overBudget, bool overMass, bool lowPower) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: const Color(0xFF101624),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _hudMetric(
            'BUDGET',
            '\$${_totalCost.toInt()}/${_maxBudgetMillion.toInt()}M',
            overBudget ? Colors.redAccent : Colors.greenAccent,
          ),
          _hudMetric(
            'MASS',
            '${_totalMass.toInt()}/${_selectedRocket.maxPayloadKg.toInt()}kg',
            overMass ? Colors.redAccent : Colors.cyanAccent,
          ),
          _hudMetric(
            'NET POWER',
            '${_netPowerWatts >= 0 ? '+' : ''}${_netPowerWatts.toInt()}W',
            lowPower ? Colors.orangeAccent : Colors.greenAccent,
          ),
          _hudMetric(
            'SCIENCE',
            '$_totalScience pts',
            Colors.amberAccent,
          ),
        ],
      ),
    );
  }

  Widget _hudMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildNasaGatewayBanner() {
    if (_loadingApi) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        color: Colors.blueGrey.withOpacity(0.2),
        child: const Text(
          'Connecting to NASA DONKI Space Weather & Planetary Gateways...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.cyanAccent),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: const Color(0xFF00E5FF).withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.satellite_alt, size: 16, color: Color(0xFF00E5FF)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_spaceWeather?['status']}: Solar Flares (7d): ${_spaceWeather?['flareCount']} (${_spaceWeather?['latestClass']}) • Target Gravity: ${_planetData?['gravity']} m/s²',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00E5FF),
        ),
      ),
    );
  }
}
