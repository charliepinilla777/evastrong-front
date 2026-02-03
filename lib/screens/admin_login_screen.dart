import 'package:flutter/material.dart';
import '../theme/eva_colors.dart';
import '../services/effects_3d_service.dart';
import '../services/admin_service.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Usar el servicio de administración para el login
      final success = await AdminService.instance.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        // Navegar al dashboard
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const AdminDashboardScreen(),
            ),
          );
        }
      } else {
        _showError('Credenciales incorrectas');
      }
    } catch (e) {
      _showError('Error al iniciar sesión: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Effects3DService.text3D(
          text: message,
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Effects3DService.backgroundGradient3D,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Effects3DService.card3D(
                gradient: Effects3DService.cardGradient3D,
                shadows: Effects3DService.elevatedShadow3D,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo y título
                      Effects3DService.icon3D(
                        icon: Icons.admin_panel_settings,
                        color: EvaColors.vibrantPink,
                        size: 80,
                      ),
                      const SizedBox(height: 24),

                      Effects3DService.text3D(
                        text: 'Eva Strong Admin',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        shadows: Effects3DService.bigTextShadow3D,
                      ),

                      const SizedBox(height: 8),

                      Effects3DService.text3D(
                        text: 'Panel de Administración',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        shadows: Effects3DService.textShadow3D,
                      ),

                      const SizedBox(height: 48),

                      // Campo de email
                      _buildEmailField(),

                      const SizedBox(height: 20),

                      // Campo de contraseña
                      _buildPasswordField(),

                      const SizedBox(height: 32),

                      // Botón de login
                      Effects3DService.button3D(
                        onPressed: _isLoading ? () {} : _login,
                        gradient: Effects3DService.primaryGradient3D,
                        shadows: Effects3DService.elevatedShadow3D,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Effects3DService.text3D(
                                text: 'Iniciar Sesión',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                shadows: Effects3DService.bigTextShadow3D,
                              ),
                      ),

                      const SizedBox(height: 24),

                      // Información de ayuda
                      Effects3DService.card3D(
                        gradient: Effects3DService.cardGradient3D,
                        shadows: Effects3DService.primaryShadow3D,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Effects3DService.text3D(
                                text: 'Credenciales de Demo',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                shadows: Effects3DService.textShadow3D,
                              ),
                              const SizedBox(height: 8),
                              Effects3DService.text3D(
                                text: 'Email: admin@evastrong.com',
                                style: const TextStyle(fontSize: 12),
                                shadows: Effects3DService.textShadow3D,
                              ),
                              Effects3DService.text3D(
                                text: 'Contraseña: admin123456',
                                style: const TextStyle(fontSize: 12),
                                shadows: Effects3DService.textShadow3D,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Effects3DService.text3D(
          text: 'Email Administrativo',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shadows: Effects3DService.textShadow3D,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: Effects3DService.cardGradient3D,
            borderRadius: BorderRadius.circular(12),
            boxShadow: Effects3DService.primaryShadow3D,
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Effects3DService.icon3D(
                icon: Icons.email,
                color: EvaColors.vibrantPink,
              ),
              hintText: 'admin@evastrong.com',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Effects3DService.text3D(
          text: 'Contraseña',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shadows: Effects3DService.textShadow3D,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: Effects3DService.cardGradient3D,
            borderRadius: BorderRadius.circular(12),
            boxShadow: Effects3DService.primaryShadow3D,
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Effects3DService.icon3D(
                icon: Icons.lock,
                color: EvaColors.vibrantPink,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Effects3DService.icon3D(
                  icon: _obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: EvaColors.vibrantPink,
                ),
              ),
              hintText: '••••••••',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
