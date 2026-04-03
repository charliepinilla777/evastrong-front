import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../l10n/app_strings.dart';
import '../services/api_service.dart';
import '../theme/eva_colors.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _msgCtrl    = TextEditingController();

  int    _rating   = 0;
  String _category = 'general';
  bool   _sending  = false;
  bool   _sent     = false;

  static const _categoryKeys = [
    'general', 'rutinas', 'dietas', 'app', 'soporte', 'otro',
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      _showSnack(AppStrings.of(context).selectRatingFirst);
      return;
    }

    setState(() => _sending = true);

    try {
      final token = ApiService.getToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final res = await http
          .post(
            Uri.parse('${AppConfig.backendUrl}/feedback'),
            headers: headers,
            body: jsonEncode({
              'name':     _nameCtrl.text.trim(),
              'email':    _emailCtrl.text.trim(),
              'rating':   _rating,
              'category': _category,
              'message':  _msgCtrl.text.trim(),
            }),
          )
          .timeout(AppConfig.apiTimeout);

      if (res.statusCode == 201) {
        setState(() { _sent = true; _sending = false; });
      } else {
        final body = jsonDecode(res.body);
        _showSnack(body['message'] ?? AppStrings.of(context).sendError);
        setState(() => _sending = false);
      }
    } catch (_) {
      _showSnack(AppStrings.of(context).connectionError);
      setState(() => _sending = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: EvaColors.cosmicRed),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          AppStrings.of(context).feedbackTitle,
          style: const TextStyle(
            fontFamily: 'Cormorant Garamond',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: EvaColors.primaryGradient),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: EvaColors.primaryGradient),
        child: _sent ? _buildSuccessView() : _buildForm(),
      ),
    );
  }

  // ──────────────────────────── FORMULARIO ────────────────────────────────

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 1.5),
                    ),
                    child: const Icon(Icons.chat_bubble_outline_rounded,
                        size: 42, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.of(context).feedbackSubtitle,
                    style: const TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.of(context).feedbackListening,
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Valoración con estrellas
            _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(AppStrings.of(context).yourRating),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final n = i + 1;
                      return GestureDetector(
                        onTap: () => setState(() => _rating = n),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            n <= _rating ? Icons.star : Icons.star_border,
                            color: n <= _rating ? const Color(0xFFFFD700) : Colors.white60,
                            size: 38,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Categoría
            _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(AppStrings.of(context).category),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categoryKeys.map((key) {
                      final selected = _category == key;
                      final label = AppStrings.of(context).feedbackCategory(key);
                      return GestureDetector(
                        onTap: () => setState(() => _category = key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white.withOpacity(0.35)
                                : Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? Colors.white70 : Colors.white24,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Datos personales (opcionales)
            _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(AppStrings.of(context).nameOptional),
                  const SizedBox(height: 8),
                  _textField(
                    controller: _nameCtrl,
                    hint: AppStrings.of(context).nameHint,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),
                  _label(AppStrings.of(context).emailOptional),
                  const SizedBox(height: 8),
                  _textField(
                    controller: _emailCtrl,
                    hint: AppStrings.of(context).emailHint,
                    icon: Icons.mail_outline,
                    keyboard: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Mensaje
            _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(AppStrings.of(context).yourComment),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _msgCtrl,
                    maxLines: 5,
                    maxLength: 1000,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Raleway', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: AppStrings.of(context).commentHint,
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white70),
                      ),
                      counterStyle: const TextStyle(color: Colors.white54),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? AppStrings.of(context).commentRequired : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Botón enviar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.25),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: Colors.white60, width: 1.5),
                  ),
                  elevation: 0,
                ),
                child: _sending
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        AppStrings.of(context).send,
                        style: const TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────── ÉXITO ────────────────────────────────────

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30, width: 1.5),
              ),
              child: const Icon(Icons.favorite_rounded, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 28),
            Text(
              AppStrings.of(context).thankYou,
              style: const TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.of(context).feedbackSuccess,
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 15,
                color: Colors.white.withOpacity(0.85),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: const BorderSide(color: Colors.white54),
                ),
              ),
              child: Text(
                AppStrings.of(context).backToHome,
                style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────── HELPERS ──────────────────────────────────

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: child,
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Raleway',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white, fontFamily: 'Raleway', fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white60, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white70),
        ),
      ),
    );
  }
}
