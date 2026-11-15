import 'package:flutter/material.dart';
import 'mission_builder_screen.dart';

class OnboardingTutorialScreen extends StatefulWidget {
  const OnboardingTutorialScreen({super.key});

  @override
  State<OnboardingTutorialScreen> createState() =>
      _OnboardingTutorialScreenState();
}

class _OnboardingTutorialScreenState extends State<OnboardingTutorialScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'icon': Icons.public,
      'title': 'Step 1: Choose Your Destination',
      'desc':
          'Every target in our Solar System requires a specific velocity change (Delta-V). Further targets like Mars or Europa have weak sunlight and high radiation.',
      'tip': 'Beginner Tip: Start with the Moon or LEO to learn resource balance!',
    },
    {
      'icon': Icons.rocket_launch,
      'title': 'Step 2: Balance Mass & Delta-V',
      'desc':
          'Every scientific instrument adds mass. If your spacecraft is too heavy or your rocket lacks Delta-V, your mission will never reach orbit.',
      'tip': 'Rule of Thumb: Keep total mass under 85% of your rocket\'s limit.',
    },
    {
      'icon': Icons.bolt,
      'title': 'Step 3: Power & Live NASA Telemetry',
      'desc':
          'Solar panels lose efficiency far from the Sun! Our live NASA DONKI Gateway checks real solar flares that can impact your electronics.',
      'tip': 'Deep Space Tip: Use an MMRTG Nuclear Battery for Jupiter/Europa.',
    },
  ];

  void _launchMissionBuilder() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MissionBuilderScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ORBITAL ARCHITECT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Color(0xFF00E5FF),
                    ),
                  ),
                  TextButton(
                    onPressed: _launchMissionBuilder,
                    child: const Text('Skip Tutorial →'),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00E5FF).withOpacity(0.12),
                            border: Border.all(
                              color: const Color(0xFF00E5FF),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            step['icon'],
                            size: 72,
                            color: const Color(0xFF00E5FF),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          step['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          step['desc'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6D00).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFF6D00)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lightbulb,
                                color: Color(0xFFFF6D00),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  step['tip'],
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? const Color(0xFF00E5FF)
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_currentPage < _steps.length - 1) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _launchMissionBuilder();
                    }
                  },
                  child: Text(
                    _currentPage == _steps.length - 1
                        ? 'ENTER MISSION CONTROL'
                        : 'NEXT BRIEFING',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
