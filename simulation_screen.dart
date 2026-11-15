import 'dart:math';
import 'package:flutter/material.dart';
import '../models/mission_models.dart';

class SimulationScreen extends StatefulWidget {
  final MissionTarget target;
  final LaunchVehicle rocket;
  final SpacecraftComponent power;
  final SpacecraftComponent comms;
  final List<SpacecraftComponent> payloads;
  final double totalCost;
  final double maxBudget;
  final double totalMass;
  final double netPower;
  final int rawScience;
  final Map<String, dynamic> spaceWeather;

  const SimulationScreen({
    super.key,
    required this.target,
    required this.rocket,
    required this.power,
    required this.comms,
    required this.payloads,
    required this.totalCost,
    required this.maxBudget,
    required this.totalMass,
    required this.netPower,
    required this.rawScience,
    required this.spaceWeather,
  });

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<String> _telemetryLogs = [];
  bool _simulationComplete = false;
  bool _missionSuccess = false;
  int _finalScore = 0;
  String _postMissionSummary = '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });

    _runMissionSimulation();
  }

  Future<void> _runMissionSimulation() async {
    _animController.forward();

    void log(String msg) {
      if (!mounted) return;
      setState(() => _telemetryLogs.add(msg));
    }

    await Future.delayed(const Duration(milliseconds: 600));
    log('T+00:00:00 | Ignition sequence start on ${widget.rocket.name}...');

    await Future.delayed(const Duration(milliseconds: 900));
    if (widget.totalCost > widget.maxBudget) {
      log('CRITICAL FAILURE | Mission canceled due to budget overrun (\$${widget.totalCost.toInt()}M > \$${widget.maxBudget.toInt()}M).');
      _finalize(
        false,
        0,
        'Reduce rocket or payload costs to stay within the \$350M grant cap.',
      );
      return;
    }
    if (widget.totalMass > widget.rocket.maxPayloadKg) {
      log('CRITICAL FAILURE | Payload mass (${widget.totalMass.toInt()}kg) exceeds ${widget.rocket.name} lift capacity!');
      _finalize(
        false,
        0,
        'Select a heavier launch vehicle or remove heavy scientific instruments.',
      );
      return;
    }
    log('T+00:08:30 | Max-Q cleared. Spacecraft successfully inserted into parking orbit.');

    await Future.delayed(const Duration(milliseconds: 1000));
    double massPenalty = (widget.totalMass / widget.rocket.maxPayloadKg) * 1.5;
    double effectiveDeltaV = widget.rocket.maxDeltaV - massPenalty;
    if (effectiveDeltaV < widget.target.requiredDeltaV) {
      log('TRAJECTORY FAILURE | Insufficient Delta-V (${effectiveDeltaV.toStringAsFixed(1)} km/s vs ${widget.target.requiredDeltaV} km/s required).');
      _finalize(
        false,
        15,
        'Your rocket lacked the propulsion energy to reach ${widget.target.name}. Upgrade your launch vehicle.',
      );
      return;
    }
    log('T+14:22:10 | Trans-injection burn nominal! En route to ${widget.target.name}.');

    await Future.delayed(const Duration(milliseconds: 1000));
    double radMult =
        (widget.spaceWeather['radiationMultiplier'] ?? 1.0) as double;
    if (widget.target.radiationRisk * radMult > 0.8 &&
        !widget.power.name.contains('Nuclear')) {
      log('WARNING | High solar/planetary radiation degraded solar arrays!');
    }

    if (widget.netPower < 0) {
      log('POWER FAILURE | Spacecraft batteries depleted (${widget.netPower.toInt()}W deficit). Instruments offline.');
      _finalize(
        false,
        30,
        'Your instruments consumed more power than your panels generated at ${widget.target.name}.',
      );
      return;
    }
    log('ORBIT INSERTION | Arrived at ${widget.target.name}. Power bus stable (+${widget.netPower.toInt()}W).');

    await Future.delayed(const Duration(milliseconds: 900));
    double commsEfficiency =
        widget.target.distanceAu > 1.0 && widget.comms.dataRateMbps < 10
            ? 0.45
            : 1.0;
    int transmittedScience = (widget.rawScience * commsEfficiency).round();
    int budgetBonus = max(0, (widget.maxBudget - widget.totalCost).toInt());
    int totalScore = (transmittedScience * 10) + budgetBonus;

    if (commsEfficiency < 1.0) {
      log('COMMS BOTTLENECK | Low-gain antenna limited data return to 45% over deep space.');
    } else {
      log('SCIENCE DOWNLINK | Full high-rate telemetry received by Deep Space Network!');
    }

    _finalize(
      true,
      totalScore,
      commsEfficiency < 1.0
          ? 'Mission succeeded! Tip: Upgrade to X-Band or Optical Laser Comms for deep-space targets to transmit 100% of your science data.'
          : 'Outstanding engineering! Optimal balance of mass, Delta-V, power margin, and scientific return.',
    );
  }

  void _finalize(bool success, int score, String summary) {
    if (!mounted) return;
    setState(() {
      _simulationComplete = true;
      _missionSuccess = success;
      _finalScore = score;
      _postMissionSummary = summary;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Mission Simulation'),
        backgroundColor: const Color(0xFF151C2C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'EARTH',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.target.name.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00E5FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _animController.value,
                      minHeight: 10,
                      backgroundColor: Colors.white12,
                      color: _simulationComplete
                          ? (_missionSuccess
                              ? Colors.greenAccent
                              : Colors.redAccent)
                          : const Color(0xFF00E5FF),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: ListView.builder(
                  itemCount: _telemetryLogs.length,
                  itemBuilder: (context, idx) {
                    final line = _telemetryLogs[idx];
                    final isError = line.contains('FAILURE');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '> $line',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color:
                              isError ? Colors.redAccent : Colors.greenAccent,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (_simulationComplete) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _missionSuccess
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _missionSuccess
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _missionSuccess
                              ? 'MISSION ACCOMPLISHED'
                              : 'MISSION FAILED',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _missionSuccess
                                ? Colors.greenAccent
                                : Colors.redAccent,
                          ),
                        ),
                        Text(
                          'SCORE: $_finalScore',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _postMissionSummary,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('MODIFY SPACECRAFT DESIGN'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
