import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class Eva3DModelWidget extends StatefulWidget {
  const Eva3DModelWidget({Key? key}) : super(key: key);

  @override
  State<Eva3DModelWidget> createState() => _Eva3DModelWidgetState();
}

class _Eva3DModelWidgetState extends State<Eva3DModelWidget> {
  @override
  Widget build(BuildContext context) {
    // En Web, mostrar una versión simplificada
    // En móvil, mostrar el modelo 3D (si está disponible)
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.withOpacity(0.3),
            Colors.pink.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.pinkAccent.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          color: Colors.black87,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.pinkAccent,
                ),
                SizedBox(height: 20),
                Text(
                  'Eva Strong',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Tu asistente de fitness',
                  style: TextStyle(
                    color: Colors.pinkAccent,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
