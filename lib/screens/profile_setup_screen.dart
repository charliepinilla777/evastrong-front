import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_strings.dart';
import '../services/routine_recommendation_service.dart';
import '../services/user_profile_service.dart';
import '../theme/eva_colors.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with TickerProviderStateMixin {
  final UserProfileService _userProfileService = UserProfileService.instance;
  final PageController _pageController = PageController();

  bool _isLoading = false;
  bool _isSaving = false;
  int _currentStep = 0;
  static const int _totalSteps = 5;

  // Form values
  String? _ageRange;
  String? _fitnessLevel;
  String? _constitution;
  bool _kneeSensitive = false;
  String? _pathologies;
  int _dailyTime = 15;

  // Animation controllers
  late AnimationController _heroAnimController;
  late Animation<double> _heroScaleAnim;
  late AnimationController _progressController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _heroAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heroScaleAnim = CurvedAnimation(
      parent: _heroAnimController,
      curve: Curves.elasticOut,
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _progressAnim = Tween<double>(begin: 0, end: 1 / _totalSteps).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _heroAnimController.forward();
    _progressController.forward();
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heroAnimController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _animateToStep(int step) {
    _heroAnimController.reset();
    _heroAnimController.forward();
    final target = (step + 1) / _totalSteps;
    _progressAnim = Tween<double>(
      begin: _progressAnim.value,
      end: target,
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));
    _progressController
      ..reset()
      ..forward();
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _loadCurrentProfile() async {
    setState(() => _isLoading = true);
    try {
      await _userProfileService.initializeProfile();
      final userProfile = _userProfileService.currentUser;
      if (userProfile != null) {
        setState(() {
          if (userProfile.age <= 35) _ageRange = '18-35';
          else if (userProfile.age <= 55) _ageRange = '36-55';
          else _ageRange = '55+';
          _fitnessLevel = _normalizeFitnessLevel(userProfile.fitnessLevel);
          _kneeSensitive = userProfile.kneeSensitive;
          _constitution = 'normopeso';
          _pathologies = 'ninguna';
        });
      }
      try {
        final response = await RoutineRecommendationService.getUserProfile();
        final data = response['data'];
        setState(() {
          _ageRange = data['ageRange'] ?? _ageRange;
          _constitution = data['constitution'] ?? _constitution;
          _fitnessLevel = _normalizeFitnessLevel(data['fitnessLevel']) ?? _fitnessLevel;
          _kneeSensitive = data['kneeSensitive'] ?? _kneeSensitive;
          _pathologies = data['pathologies'] ?? _pathologies;
          _dailyTime = data['dailyTime'] ?? _dailyTime;
        });
      } catch (_) {}
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.of(context).profileLoadError}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      int userAge = _ageRange == '18-35' ? 25 : _ageRange == '36-55' ? 45 : 60;
      await _userProfileService.updateProfile(
        name: _userProfileService.currentUser?.name ?? 'Usuario Eva',
        age: userAge,
        kneeSensitive: _kneeSensitive,
        fitnessLevel: _fitnessLevel ?? 'principiante',
      );
      try {
        await RoutineRecommendationService.updateUserProfile(
          ageRange: _ageRange!,
          constitution: _constitution!,
          fitnessLevel: _fitnessLevel!,
          kneeSensitive: _kneeSensitive,
          pathologies: _pathologies!,
          dailyTime: _dailyTime,
        );
      } catch (_) {}
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(context).profileUpdatedOk),
            backgroundColor: EvaColors.activeGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.of(context).profileSaveError}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0: return _ageRange != null;
      case 1: return _fitnessLevel != null;
      case 2: return _constitution != null;
      case 3: return _pathologies != null;
      case 4: return true;
      default: return false;
    }
  }

  void _next() {
    if (!_canProceed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.of(context).setupFieldRequired),
          backgroundColor: EvaColors.cosmicRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (_currentStep < _totalSteps - 1) {
      _animateToStep(_currentStep + 1);
    } else {
      _saveProfile();
    }
  }

  void _back() {
    if (_currentStep > 0) _animateToStep(_currentStep - 1);
    else Navigator.pop(context);
  }

  // ─────────────────────────────── BUILD ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: EvaColors.vibrantPink))
          : Stack(
              children: [
                // Background gradient
                _buildBackground(),
                // Content
                SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar(),
                      _buildProgressBar(),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildStepAge(),
                            _buildStepFitnessLevel(),
                            _buildStepConstitution(),
                            _buildStepHealth(),
                            _buildStepTime(),
                          ],
                        ),
                      ),
                      _buildBottomNav(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ── Background ──────────────────────────────────────────────────────────

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a0533),
            Color(0xFF2D0A4E),
            Color(0xFF3D0B61),
            Color(0xFF1a0533),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  // ── Top bar ─────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _back,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${_currentStep + 1} ${AppStrings.of(context).setupStepOf} $_totalSteps',
                style: GoogleFonts.raleway(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          // Logo / branding
          Text(
            'EVA',
            style: GoogleFonts.cormorantGaramond(
              color: EvaColors.vibrantPink,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress bar ────────────────────────────────────────────────────────

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (i) {
              final done = i < _currentStep;
              final active = i == _currentStep;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: done || active
                        ? const LinearGradient(colors: [
                            EvaColors.vibrantPink,
                            EvaColors.wellnessPurple,
                          ])
                        : null,
                    color: done || active ? null : Colors.white.withOpacity(0.15),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Bottom navigation ────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    final isLast = _currentStep == _totalSteps - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: GestureDetector(
        onTap: _canProceed ? _next : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 58,
          decoration: BoxDecoration(
            gradient: _canProceed
                ? const LinearGradient(
                    colors: [EvaColors.vibrantPink, EvaColors.wellnessPurple],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: _canProceed ? null : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            boxShadow: _canProceed
                ? [
                    BoxShadow(
                      color: EvaColors.vibrantPink.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast ? AppStrings.of(context).setupSaveProfile : AppStrings.of(context).setupContinue,
                        style: GoogleFonts.raleway(
                          color: _canProceed ? Colors.white : Colors.white30,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                        color: _canProceed ? Colors.white : Colors.white30,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ── Step scaffold ────────────────────────────────────────────────────────

  Widget _buildStep({
    required String emoji,
    required String title,
    required String subtitle,
    required Widget body,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero emoji with scale animation
          ScaleTransition(
            scale: _heroScaleAnim,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: EvaColors.vibrantPink.withOpacity(0.15),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                    color: EvaColors.vibrantPink.withOpacity(0.3), width: 1.5),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 36)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.cormorantGaramond(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.raleway(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          body,
        ],
      ),
    );
  }

  // ── Option card ──────────────────────────────────────────────────────────

  Widget _buildOptionCard({
    required String value,
    required String? selectedValue,
    required String label,
    required String emoji,
    String? description,
    required VoidCallback onTap,
    bool wide = false,
  }) {
    final selected = selectedValue == value;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: wide ? 20 : 14,
        ),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [
                    Color(0x33FF69B4),
                    Color(0x22800080),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? EvaColors.vibrantPink.withOpacity(0.8)
                : Colors.white.withOpacity(0.1),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: EvaColors.vibrantPink.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? EvaColors.vibrantPink.withOpacity(0.2)
                    : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.raleway(
                      color: selected ? Colors.white : Colors.white70,
                      fontSize: 15,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: GoogleFonts.raleway(
                        color: selected
                            ? Colors.white60
                            : Colors.white30,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected
                    ? const LinearGradient(
                        colors: [EvaColors.vibrantPink, EvaColors.wellnessPurple])
                    : null,
                border: selected
                    ? null
                    : Border.all(color: Colors.white24, width: 1.5),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────── STEP 1: EDAD ───────────────────────────────────────

  Widget _buildStepAge() {
    final s = AppStrings.of(context);
    final options = [
      {'value': '18-35', 'emoji': '🌸', 'label': s.setupAge1835,   'desc': s.setupAge1835Desc},
      {'value': '36-55', 'emoji': '🌺', 'label': s.setupAge3655,   'desc': s.setupAge3655Desc},
      {'value': '55+',   'emoji': '🌷', 'label': s.setupAge55plus, 'desc': s.setupAge55plusDesc},
    ];
    return _buildStep(
      emoji: '🌸',
      title: s.setupAgeTitle,
      subtitle: s.setupAgeSubtitle,
      body: Column(
        children: options.map((o) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOptionCard(
            value: o['value']!,
            selectedValue: _ageRange,
            label: o['label']!,
            emoji: o['emoji']!,
            description: o['desc']!,
            wide: true,
            onTap: () => setState(() => _ageRange = o['value']),
          ),
        )).toList(),
      ),
    );
  }

  // ─────────────────── STEP 2: FITNESS LEVEL ──────────────────────────────

  Widget _buildStepFitnessLevel() {
    final s = AppStrings.of(context);
    final options = [
      {'value': 'principiante', 'emoji': '🌱', 'label': s.setupLevelBeginner,     'desc': s.setupLevelBeginnerDesc},
      {'value': 'intermedio',   'emoji': '⚡', 'label': s.setupLevelIntermediate, 'desc': s.setupLevelIntermediateDesc},
      {'value': 'avanzado',     'emoji': '🔥', 'label': s.setupLevelAdvanced,     'desc': s.setupLevelAdvancedDesc},
    ];
    return _buildStep(
      emoji: '💪',
      title: s.setupLevelTitle,
      subtitle: s.setupLevelSubtitle,
      body: Column(
        children: options.map((o) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOptionCard(
            value: o['value']!,
            selectedValue: _fitnessLevel,
            label: o['label']!,
            emoji: o['emoji']!,
            description: o['desc']!,
            wide: true,
            onTap: () => setState(() => _fitnessLevel = o['value']),
          ),
        )).toList(),
      ),
    );
  }

  // ─────────────────── STEP 3: CONSTITUCIÓN ───────────────────────────────

  Widget _buildStepConstitution() {
    final s = AppStrings.of(context);
    final options = [
      {'value': 'bajo_peso', 'emoji': '🕊️', 'label': s.setupBodyUnderweight, 'desc': s.setupBodyUnderDesc},
      {'value': 'normopeso', 'emoji': '✨',  'label': s.setupBodyHealthy,     'desc': s.setupBodyHealthyDesc},
      {'value': 'sobrepeso', 'emoji': '🌿',  'label': s.setupBodyOverweight,  'desc': s.setupBodyOverDesc},
      {'value': 'obesidad',  'emoji': '🌻',  'label': s.setupBodyObese,       'desc': s.setupBodyObeseDesc},
    ];
    return _buildStep(
      emoji: '🌺',
      title: s.setupBodyTitle,
      subtitle: s.setupBodySubtitle,
      body: Column(
        children: options.map((o) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOptionCard(
            value: o['value']!,
            selectedValue: _constitution,
            label: o['label']!,
            emoji: o['emoji']!,
            description: o['desc']!,
            wide: true,
            onTap: () => setState(() => _constitution = o['value']),
          ),
        )).toList(),
      ),
    );
  }

  // ─────────────────── STEP 4: SALUD ──────────────────────────────────────

  Widget _buildStepHealth() {
    final s = AppStrings.of(context);
    final pathOptions = [
      {'value': 'ninguna',      'emoji': '💚', 'label': s.setupHealthNone},
      {'value': 'cardiaca',     'emoji': '❤️', 'label': s.setupHealthCardiac},
      {'value': 'respiratoria', 'emoji': '💨', 'label': s.setupHealthRespiratory},
      {'value': 'metabolica',   'emoji': '⚗️', 'label': s.setupHealthMetabolic},
      {'value': 'otra',         'emoji': '🩺', 'label': s.setupHealthOther},
    ];
    return _buildStep(
      emoji: '🏥',
      title: s.setupHealthTitle,
      subtitle: s.setupHealthSubtitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Knee sensitive toggle
          GestureDetector(
            onTap: () => setState(() => _kneeSensitive = !_kneeSensitive),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                gradient: _kneeSensitive
                    ? const LinearGradient(
                        colors: [Color(0x33FF69B4), Color(0x22800080)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: _kneeSensitive ? null : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _kneeSensitive
                      ? EvaColors.vibrantPink.withOpacity(0.8)
                      : Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _kneeSensitive
                          ? EvaColors.vibrantPink.withOpacity(0.2)
                          : Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Center(
                      child: Text('🦵', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.of(context).setupKneeSensitive,
                          style: GoogleFonts.raleway(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          AppStrings.of(context).setupKneeSensitiveDesc,
                          style: GoogleFonts.raleway(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _kneeSensitive,
                    onChanged: (v) => setState(() => _kneeSensitive = v),
                    activeColor: EvaColors.vibrantPink,
                    activeTrackColor: EvaColors.vibrantPink.withOpacity(0.3),
                    inactiveThumbColor: Colors.white38,
                    inactiveTrackColor: Colors.white12,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.of(context).setupHealthCondition,
            style: GoogleFonts.raleway(
              color: Colors.white60,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
            children: pathOptions.map((o) {
              final sel = _pathologies == o['value'];
              return GestureDetector(
                onTap: () => setState(() => _pathologies = o['value']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    gradient: sel
                        ? const LinearGradient(
                            colors: [Color(0x33FF69B4), Color(0x22800080)],
                          )
                        : null,
                    color: sel ? null : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sel
                          ? EvaColors.vibrantPink.withOpacity(0.8)
                          : Colors.white.withOpacity(0.1),
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(o['emoji']!, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          o['label']!,
                          style: GoogleFonts.raleway(
                            color: sel ? Colors.white : Colors.white60,
                            fontSize: 12,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────── STEP 5: TIEMPO ─────────────────────────────────────

  Widget _buildStepTime() {
    final s = AppStrings.of(context);
    final options = [
      {'value': 10, 'emoji': '⚡', 'label': s.setupTime10, 'desc': s.setupTime10Desc},
      {'value': 15, 'emoji': '🌟', 'label': s.setupTime15, 'desc': s.setupTime15Desc},
      {'value': 20, 'emoji': '🔥', 'label': s.setupTime20, 'desc': s.setupTime20Desc},
    ];
    return _buildStep(
      emoji: '⏱️',
      title: s.setupTimeTitle,
      subtitle: s.setupTimeSubtitle,
      body: Column(
        children: [
          ...options.map((o) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOptionCard(
              value: o['value'].toString(),
              selectedValue: _dailyTime.toString(),
              label: o['label']! as String,
              emoji: o['emoji']! as String,
              description: o['desc']! as String,
              wide: true,
              onTap: () => setState(() => _dailyTime = o['value'] as int),
            ),
          )),
          const SizedBox(height: 24),
          // Motivational close
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.of(context).setupAlmostDone,
                        style: GoogleFonts.cormorantGaramond(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.of(context).setupAlmostDoneDesc,
                        style: GoogleFonts.raleway(
                          color: Colors.white54,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── HELPERS ─────────────────────────────────────────────

  String? _normalizeFitnessLevel(dynamic value) {
    if (value == null) return null;
    switch (value.toString()) {
      case 'beginner': return 'principiante';
      case 'intermediate': return 'intermedio';
      case 'advanced': return 'avanzado';
      default: return value.toString();
    }
  }
}
