import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherDialog extends StatefulWidget {
  @override
  _WeatherDialogState createState() => _WeatherDialogState();
}

class _WeatherDialogState extends State<WeatherDialog> {
  String _weatherForecast = '正在獲取天氣預報...';

  Future<void> _fetchWeatherForecast() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://data.weather.gov.hk/weatherAPI/opendata/weather.php?dataType=flw&lang=tc',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _weatherForecast = data['forecastDesc'].replaceAll('\n', ' ');
        });
      } else {
        setState(() {
          _weatherForecast = '無法獲取天氣預報';
        });
      }
    } catch (e) {
      setState(() {
        _weatherForecast = '無法獲取天氣預報';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeatherForecast();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Text(
        '天氣預測：$_weatherForecast',
        style: const TextStyle(fontSize: 24, color: Colors.black87),
      ),
    );
  }
}
