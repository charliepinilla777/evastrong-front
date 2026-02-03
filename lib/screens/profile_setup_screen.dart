import 'package:flutter/material.dart';
import '../services/routine_recommendation_service.dart';
import '../services/user_profile_service.dart';
import '../theme/eva_colors.dart';
import '../services/effects_3d_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;
  final UserProfileService _userProfileService = UserProfileService.instance;

  // Form controllers
  String? _ageRange;
  String? _constitution;
  String? _fitnessLevel;
  bool _kneeSensitive = false;
  String? _pathologies;
  int _dailyTime = 15;

  // Opciones para los selectores
  final List<String> _ageRanges = ['18-35', '36-55', '55+'];
  final List<String> _constitutions = [
    'bajo_peso',
    'normopeso',
    'sobrepeso',
    'obesidad',
  ];
  final List<String> _fitnessLevels = ['beginner', 'intermediate', 'advanced'];
  final List<String> _pathologiesOptions = [
    'ninguna',
    'cardiaca',
    'respiratoria',
    'metabolica',
    'otra',
  ];
  final List<int> _dailyTimeOptions = [10, 15, 20];

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    setState(() => _isLoading = true);
    try {
      // Cargar perfil del servicio local
      await _userProfileService.initializeProfile();
      final userProfile = _userProfileService.currentUser;

      if (userProfile != null) {
        setState(() {
          // Mapear edad a rango
          if (userProfile.age <= 35) {
            _ageRange = '18-35';
          } else if (userProfile.age <= 55) {
            _ageRange = '36-55';
          } else {
            _ageRange = '55+';
          }

          _fitnessLevel = userProfile.fitnessLevel;
          _kneeSensitive = userProfile.kneeSensitive;
          _constitution = 'normopeso'; // Valor por defecto
          _pathologies = 'ninguna'; // Valor por defecto
          _dailyTime = 15; // Valor por defecto
          _isLoading = false;
        });
      }

      // También intentar cargar del backend
      try {
        final response = await RoutineRecommendationService.getUserProfile();
        final profileData = response['data'];

        setState(() {
          _ageRange = profileData['ageRange'] ?? _ageRange;
          _constitution = profileData['constitution'] ?? _constitution;
          _fitnessLevel = profileData['fitnessLevel'] ?? _fitnessLevel;
          _kneeSensitive = profileData['kneeSensitive'] ?? _kneeSensitive;
          _pathologies = profileData['pathologies'] ?? _pathologies;
          _dailyTime = profileData['dailyTime'] ?? _dailyTime;
        });
      } catch (e) {
        print('Error cargando perfil del backend: $e');
        // Continuar con los datos locales
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar perfil: $e')));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      // Guardar en el servicio local primero
      int userAge = 25; // Valor por defecto
      if (_ageRange == '18-35')
        userAge = 25;
      else if (_ageRange == '36-55')
        userAge = 45;
      else if (_ageRange == '55+')
        userAge = 60;

      await _userProfileService.updateProfile(
        name: _userProfileService.currentUser?.name ?? 'Usuario Eva',
        age: userAge,
        kneeSensitive: _kneeSensitive,
        fitnessLevel: _fitnessLevel ?? 'principiante',
      );

      // También intentar guardar en el backend
      try {
        final response = await RoutineRecommendationService.updateUserProfile(
          ageRange: _ageRange!,
          constitution: _constitution!,
          fitnessLevel: _fitnessLevel!,
          kneeSensitive: _kneeSensitive,
          pathologies: _pathologies!,
          dailyTime: _dailyTime,
        );

        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Perfil actualizado exitosamente!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        // Si falla el backend, mostrar éxito localmente
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Perfil guardado localmente!'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar perfil: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Effects3DService.backgroundGradient3D.colors[0],
      appBar: Effects3DService.appBar3D(
        title: 'Configurar Perfil de Fitness',
        gradient: Effects3DService.primaryGradient3D,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  EvaColors.vibrantPink,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeaderCard3D(),
                    const SizedBox(height: 24),
                    _buildSectionTitle3D('Información Básica'),
                    const SizedBox(height: 16),

                    _buildDropdownField3D(
                      'Rango de Edad',
                      _ageRange,
                      _ageRanges,
                      (value) => setState(() => _ageRange = value),
                      'Selecciona tu rango de edad',
                    ),

                    const SizedBox(height: 16),

                    _buildDropdownField3D(
                      'Constitución Física',
                      _constitution,
                      _constitutions,
                      (value) => setState(() => _constitution = value),
                      'Selecciona tu tipo de constitución',
                    ),

                    const SizedBox(height: 16),

                    _buildDropdownField3D(
                      'Nivel de Fitness',
                      _fitnessLevel,
                      _fitnessLevels,
                      (value) => setState(() => _fitnessLevel = value),
                      'Selecciona tu nivel actual',
                    ),

                    const SizedBox(height: 24),

                    _buildSectionTitle3D('Preferencias y Limitaciones'),
                    const SizedBox(height: 16),

                    _buildSwitchField3D(
                      'Rodillas Sensibles',
                      _kneeSensitive,
                      (value) => setState(() => _kneeSensitive = value),
                      'Marcar si tienes problemas en las rodillas',
                    ),

                    const SizedBox(height: 16),

                    _buildDropdownField3D(
                      'Patologías',
                      _pathologies,
                      _pathologiesOptions,
                      (value) => setState(() => _pathologies = value),
                      'Selecciona si tienes alguna condición médica',
                    ),

                    const SizedBox(height: 16),

                    _buildDropdownField3D(
                      'Tiempo Diario Disponible',
                      _dailyTime.toString(),
                      _dailyTimeOptions.map((e) => e.toString()).toList(),
                      (value) => setState(() => _dailyTime = int.parse(value!)),
                      'Minutos que puedes dedicar al ejercicio',
                    ),

                    const SizedBox(height: 32),

                    _buildSaveButton3D(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard3D() {
    return Effects3DService.card3D(
      gradient: Effects3DService.primaryGradient3D,
      shadows: Effects3DService.elevatedShadow3D,
      child: Column(
        children: [
          Effects3DService.text3D(
            text: '💪 Crea Tu Perfil Perfecto',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            shadows: Effects3DService.bigTextShadow3D,
          ),
          const SizedBox(height: 16),
          Effects3DService.text3D(
            text:
                'Personaliza tu experiencia de fitness con rutinas adaptadas a tus necesidades y objetivos específicos.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            shadows: Effects3DService.textShadow3D,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle3D(String title) {
    return Effects3DService.card3D(
      gradient: Effects3DService.buttonGradient3D,
      shadows: Effects3DService.primaryShadow3D,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Effects3DService.text3D(
        text: title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        shadows: Effects3DService.bigTextShadow3D,
      ),
    );
  }

  Widget _buildDropdownField3D(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
    String hint,
  ) {
    return Effects3DService.card3D(
      shadows: Effects3DService.primaryShadow3D,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: EvaColors.vibrantPink,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          hintStyle: TextStyle(
            color: EvaColors.textPrimary.withOpacity(0.7),
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: EvaColors.vibrantPink.withOpacity(0.3),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: EvaColors.vibrantPink.withOpacity(0.3),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.cyan, width: 3),
          ),
          filled: true,
          fillColor: EvaColors.surfaceLight,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        dropdownColor: EvaColors.surfaceLight,
        icon: Effects3DService.icon3D(
          icon: Icons.arrow_drop_down,
          color: EvaColors.vibrantPink,
          size: 28,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Effects3DService.text3D(
              text: _formatDisplayText(item),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Campo requerido' : null,
      ),
    );
  }

  Widget _buildSwitchField3D(
    String label,
    bool value,
    Function(bool) onChanged,
    String description,
  ) {
    return Effects3DService.card3D(
      gradient: Effects3DService.glassDecoration3D().gradient != null
          ? null
          : LinearGradient(
              colors: [
                EvaColors.surfaceLight,
                EvaColors.vibrantPink.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      shadows: Effects3DService.primaryShadow3D,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Effects3DService.text3D(
                    text: label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: EvaColors.textPrimary.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: value
                        ? Colors.cyan.withOpacity(0.4)
                        : EvaColors.vibrantPink.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.cyan,
                activeTrackColor: EvaColors.vibrantPink.withOpacity(0.6),
                inactiveThumbColor: EvaColors.vibrantPink,
                inactiveTrackColor: EvaColors.vibrantPink.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton3D() {
    return Effects3DService.button3D(
      onPressed: _isSaving ? () {} : _saveProfile,
      gradient: Effects3DService.primaryGradient3D,
      shadows: Effects3DService.elevatedShadow3D,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
      child: _isSaving
          ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Effects3DService.text3D(
              text: 'Guardar Perfil',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              shadows: Effects3DService.bigTextShadow3D,
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [EvaColors.vibrantPink, EvaColors.vibrantPink, Colors.cyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: EvaColors.vibrantPink.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Colors.cyanAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              '💪 Crea Tu Perfil Perfecto',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 3.0,
                    color: Colors.black26,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, EvaColors.vibrantPink],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: const Text(
              'Personaliza tu experiencia de fitness con rutinas adaptadas a tus necesidades y objetivos específicos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.black26,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [EvaColors.vibrantPink, Colors.cyan],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: EvaColors.vibrantPink.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Colors.white, Colors.cyanAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black26,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientDropdownField(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
    String hint,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: EvaColors.vibrantPink.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: EvaColors.vibrantPink,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(color: EvaColors.textPrimary.withOpacity(0.6)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: EvaColors.vibrantPink.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: EvaColors.vibrantPink.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.cyan, width: 2),
          ),
          filled: true,
          fillColor: EvaColors.surfaceLight,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        dropdownColor: EvaColors.surfaceLight,
        icon: Icon(Icons.arrow_drop_down, color: EvaColors.vibrantPink),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [EvaColors.vibrantPink, Colors.cyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                _formatDisplayText(item),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Campo requerido' : null,
      ),
    );
  }

  Widget _buildGradientSwitchField(
    String label,
    bool value,
    Function(bool) onChanged,
    String description,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            EvaColors.surfaceLight,
            EvaColors.vibrantPink.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: EvaColors.vibrantPink.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [EvaColors.vibrantPink, Colors.cyan],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: EvaColors.textPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.cyan,
              activeTrackColor: EvaColors.vibrantPink.withOpacity(0.5),
              inactiveThumbColor: EvaColors.vibrantPink,
              inactiveTrackColor: EvaColors.vibrantPink.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientSaveButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [EvaColors.vibrantPink, Colors.cyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: EvaColors.vibrantPink.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: EvaColors.textOnVibrant,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Colors.cyanAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Text(
                  'Guardar Perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black26,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  String _formatDisplayText(String value) {
    switch (value) {
      case '18-35':
        return '18-35 años';
      case '36-55':
        return '36-55 años';
      case '55+':
        return '55+ años';
      case 'bajo_peso':
        return 'Bajo peso';
      case 'normopeso':
        return 'Normopeso';
      case 'sobrepeso':
        return 'Sobrepeso';
      case 'obesidad':
        return 'Obesidad';
      case 'beginner':
        return 'Principiante';
      case 'intermediate':
        return 'Intermedio';
      case 'advanced':
        return 'Avanzado';
      case 'ninguna':
        return 'Ninguna';
      case 'cardiaca':
        return 'Cardíaca';
      case 'respiratoria':
        return 'Respiratoria';
      case 'metabolica':
        return 'Metabólica';
      case 'otra':
        return 'Otra';
      default:
        return value;
    }
  }
}
