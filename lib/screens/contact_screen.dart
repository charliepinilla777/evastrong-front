import 'package:flutter/material.dart';
import '../theme/eva_colors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contacto',
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
              Icons.contact_phone,
              size: 80,
              color: EvaColors.vibrantPink,
            ),
            SizedBox(height: 20),
            Text(
              'Contacto',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: EvaColors.vibrantPink,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Contáctanos para cualquier duda',
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
