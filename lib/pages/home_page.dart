import 'package:flutter/material.dart';
import 'package:ura_application/widgets/time_display.dart';
import 'package:ura_application/widgets/stove_status.dart';
import 'package:ura_application/widgets/fu_zai_pet.dart';
import 'package:ura_application/widgets/weather_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2ED),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TimeDisplay(),
            SizedBox(height: 20),
            _StoveCard(),
            SizedBox(height: 20),
            WeatherDialog(),
            VirtualPet(),
          ],
        ),
      ),
    );
  }
}

class _StoveCard extends StatelessWidget {
  const _StoveCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: const StoveStatus(),
    );
  }
}
