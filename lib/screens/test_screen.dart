import 'package:flutter/material.dart';
import '../theme/eva_colors.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Test',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: EvaColors.vibrantPink,
        elevation: 8,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings,
              size: 80,
              color: EvaColors.vibrantPink,
            ),
            SizedBox(height: 20),
            Text(
              'Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: EvaColors.vibrantPink,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Pantalla de pruebas y configuración',
              style: TextStyle(
                fontSize: 16,
                color: EvaColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
