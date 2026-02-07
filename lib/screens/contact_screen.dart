import 'package:flutter/material.dart';
import 'package:custom_signin_buttons/custom_signin_buttons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/eva_colors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir $url');
    }
  }

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.contact_phone,
              size: 80,
              color: EvaColors.vibrantPink,
            ),
            const SizedBox(height: 20),
            const Text(
              'Contáctanos',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: EvaColors.vibrantPink,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Síguenos en nuestras redes sociales',
              style: TextStyle(
                fontSize: 16,
                color: EvaColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Sección de Redes Sociales
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    EvaColors.vibrantPink.withOpacity(0.1),
                    EvaColors.wellnessPurple.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: EvaColors.vibrantPink.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    '💜 Síguenos en:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: EvaColors.vibrantPink,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Instagram
                  SignInButton(
                    button: Button.InstagramGradient,
                    text: 'Síguenos en Instagram',
                    onPressed: () {
                      _launchURL('https://instagram.com/evastrong');
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Facebook
                  SignInButton(
                    button: Button.FacebookNew,
                    text: 'Síguenos en Facebook',
                    onPressed: () {
                      _launchURL('https://facebook.com/evastrong');
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Pinterest
                  SignInButton(
                    button: Button.Pinterest,
                    text: 'Síguenos en Pinterest',
                    onPressed: () {
                      _launchURL('https://pinterest.com/evastrong');
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Google
                  SignInButton(
                    button: Button.Google,
                    text: 'Contáctanos por Gmail',
                    onPressed: () {
                      _launchURL('mailto:soporte@evastrong.app');
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Información adicional
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: EvaColors.vibrantPink.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.email, color: EvaColors.vibrantPink),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Email',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: EvaColors.vibrantPink,
                              ),
                            ),
                            Text(
                              'soporte@evastrong.app',
                              style: TextStyle(
                                color: EvaColors.textPrimary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: EvaColors.vibrantPink),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ubicación',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: EvaColors.vibrantPink,
                              ),
                            ),
                            Text(
                              'Bogotá, Colombia',
                              style: TextStyle(
                                color: EvaColors.textPrimary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
