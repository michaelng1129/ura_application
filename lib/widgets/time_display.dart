import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class TimeDisplay extends StatefulWidget {
  const TimeDisplay({super.key});

  @override
  State<TimeDisplay> createState() => _TimeDisplayState();
}

class _TimeDisplayState extends State<TimeDisplay> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String getTimePeriodLabel(DateTime now) {
    if (now.hour < 12) return '早上';
    if (now.hour < 18) return '下午';
    return '晚上';
  }

  @override
  Widget build(BuildContext context) {
    final timePeriod = getTimePeriodLabel(_now);
    final hourMinute = DateFormat('HH:mm').format(_now);
    final seconds = DateFormat('ss').format(_now);
    final dateString = DateFormat('y年M月d日').format(_now);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            text: '$timePeriod ',
            style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: hourMinute,
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: seconds,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
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
