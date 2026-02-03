import 'package:flutter/material.dart';
import '../theme/eva_colors.dart';
import '../services/effects_3d_service.dart';
import '../services/user_profile_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserProfileService _profileService = UserProfileService.instance;
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _performanceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final user = _profileService.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _ageController.text = user.age.toString();
      _performanceController.text = user.performance.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _performanceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final String? imagePath = await _profileService.pickImage();
    if (imagePath != null) {
      setState(() {
        _isLoading = true;
      });

      await _profileService.updateProfile(profileImagePath: imagePath);

      setState(() {
        _isLoading = false;
      });

      _showSuccessMessage('Foto de perfil actualizada');
    }
  }

  Future<void> _takePhoto() async {
    final String? imagePath = await _profileService.takePhoto();
    if (imagePath != null) {
      setState(() {
        _isLoading = true;
      });

      await _profileService.updateProfile(profileImagePath: imagePath);

      setState(() {
        _isLoading = false;
      });

      _showSuccessMessage('Foto de perfil actualizada');
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorMessage('Por favor ingresa tu nombre');
      return;
    }

    final age = int.tryParse(_ageController.text);
    if (age == null || age < 13 || age > 120) {
      _showErrorMessage('Por favor ingresa una edad válida (13-120)');
      return;
    }

    final performance = double.tryParse(_performanceController.text);
    if (performance == null || performance < 0 || performance > 100) {
      _showErrorMessage('Por favor ingresa un desempeño válido (0-100)');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await _profileService.updateProfile(
      name: _nameController.text.trim(),
      age: age,
      performance: performance,
    );

    setState(() {
      _isLoading = false;
    });

    _showSuccessMessage('Perfil actualizado correctamente');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Effects3DService.text3D(
          text: message,
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: EvaColors.vibrantPink,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
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

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Effects3DService.card3D(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Effects3DService.text3D(
                text: 'Seleccionar Foto',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                shadows: Effects3DService.bigTextShadow3D,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Effects3DService.button3D(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage();
                    },
                    gradient: Effects3DService.buttonGradient3D,
                    child: Column(
                      children: [
                        Effects3DService.icon3D(
                          icon: Icons.photo_library,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Effects3DService.text3D(
                          text: 'Galería',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Effects3DService.button3D(
                    onPressed: () {
                      Navigator.pop(context);
                      _takePhoto();
                    },
                    gradient: Effects3DService.buttonGradient3D,
                    child: Column(
                      children: [
                        Effects3DService.icon3D(
                          icon: Icons.camera_alt,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Effects3DService.text3D(
                          text: 'Cámara',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _profileService.currentUser;

    return Scaffold(
      appBar: Effects3DService.appBar3D(
        title: 'Mi Perfil',
        gradient: Effects3DService.primaryGradient3D,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar y foto de perfil
            Effects3DService.card3D(
              gradient: Effects3DService.cardGradient3D,
              shadows: Effects3DService.elevatedShadow3D,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: Stack(
                        children: [
                          _profileService.buildProfileAvatar(radius: 60),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Effects3DService.card3D(
                              gradient: Effects3DService.buttonGradient3D,
                              shadows: Effects3DService.primaryShadow3D,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Effects3DService.icon3D(
                                  icon: Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Effects3DService.text3D(
                      text: 'Toca para cambiar tu foto',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      shadows: Effects3DService.textShadow3D,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Información del perfil
            Effects3DService.card3D(
              gradient: Effects3DService.cardGradient3D,
              shadows: Effects3DService.elevatedShadow3D,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Effects3DService.text3D(
                      text: 'Información Personal',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      shadows: Effects3DService.bigTextShadow3D,
                    ),
                    const SizedBox(height: 20),

                    // Campo de nombre
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nombre',
                      icon: Icons.person,
                      hintText: 'Tu nombre completo',
                    ),

                    const SizedBox(height: 16),

                    // Campo de edad
                    _buildTextField(
                      controller: _ageController,
                      label: 'Edad',
                      icon: Icons.cake,
                      hintText: 'Tu edad',
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 16),

                    // Campo de desempeño
                    _buildTextField(
                      controller: _performanceController,
                      label: 'Desempeño',
                      icon: Icons.trending_up,
                      hintText: 'Tu nivel de desempeño (0-100)',
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 24),

                    // Indicador de desempeño
                    if (user != null) ...[
                      Effects3DService.text3D(
                        text:
                            'Nivel de Desempeño: ${_profileService.getPerformanceLevel()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        shadows: Effects3DService.textShadow3D,
                      ),
                      const SizedBox(height: 8),
                      _profileService.buildPerformanceIndicator(height: 12),
                      const SizedBox(height: 8),
                      Effects3DService.text3D(
                        text: '${user.performance.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        shadows: Effects3DService.textShadow3D,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botón de guardar
            Effects3DService.button3D(
              onPressed: _isLoading ? () {} : _saveProfile,
              gradient: Effects3DService.primaryGradient3D,
              shadows: Effects3DService.elevatedShadow3D,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Effects3DService.text3D(
                      text: 'Guardar Cambios',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shadows: Effects3DService.bigTextShadow3D,
                    ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Effects3DService.text3D(
          text: label,
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
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Effects3DService.icon3D(
                icon: icon,
                color: EvaColors.vibrantPink,
              ),
              hintText: hintText,
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
