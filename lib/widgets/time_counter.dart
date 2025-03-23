import 'package:flutter/material.dart';
import 'dart:async';

class TimeCounter extends StatefulWidget {
  final DateTime startDate;

  const TimeCounter({
    Key? key,
    required this.startDate,
  }) : super(key: key);

  @override
  State<TimeCounter> createState() => _TimeCounterState();
}

class _TimeCounterState extends State<TimeCounter> {
  late Timer _timer;
  late Map<String, int> _timeDifference;

  @override
  void initState() {
    super.initState();
    _timeDifference = _calculateTimeDifference();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _timeDifference = _calculateTimeDifference();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Map<String, int> _calculateTimeDifference() {
    final now = DateTime.now();
    final diff = now.difference(widget.startDate);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;
    
    return {
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    };
  }

  @override
  Widget build(BuildContext context) {
    final timeUnits = [
      {'value': _timeDifference['days']!, 'label': 'дней', 'max': 100},
      {'value': _timeDifference['hours']!, 'label': 'часов', 'max': 24},
      {'value': _timeDifference['minutes']!, 'label': 'минут', 'max': 60},
      {'value': _timeDifference['seconds']!, 'label': 'секунд', 'max': 60},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: timeUnits.length,
      itemBuilder: (context, index) {
        final unit = timeUnits[index];
        return _buildTimeUnit(
          context,
          unit['value'] as int,
          unit['label'] as String, 
          unit['max'] as int, 
        );
      },
    );
  }

  Widget _buildTimeUnit(BuildContext context, int value, String label, int max) {
    final progress = value / max;
    
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: FractionallySizedBox(
                          alignment: Alignment.bottomCenter,
                          heightFactor: progress.clamp(0.0, 1.0),
                          child: Container(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          value.toString(),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}