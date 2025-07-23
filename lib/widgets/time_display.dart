import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeDisplay extends StatelessWidget {
  const TimeDisplay({super.key});

  String getTimePeriodLabel(DateTime now) {
    if (now.hour < 12) return '早上';
    if (now.hour < 18) return '下午';
    return '晚上';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeString = DateFormat('HH:mm').format(now);
    final dateString = DateFormat('y年M月d日').format(now);
    final timePeriod = getTimePeriodLabel(now);

    return Column(
      children: [
        Text(
          '$timePeriod $timeString',
          style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          dateString,
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
