import 'package:flutter/material.dart';
import '../services/routine_recommendation_service.dart';
import '../services/user_profile_service.dart';
import '../services/routine_service.dart';
import '../services/trial_service.dart';
import '../services/secure_storage_service.dart';
import 'profile_setup_screen.dart';
import 'payments_screen.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  _RoutinesScreenState createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  PersonalizedRoutine? _personalizedRoutine;
  List<RoutineTemplate> _templates = [];
  List<Routine> _backendRoutines = [];
  TrialStatus? _trialStatus;
  String _selectedAgeRange = '18-35';
  String _selectedLevel = 'principiante';
  bool? _selectedKneeSensitive;
  final String _selectedCategory = 'funcional';
  final UserProfileService _userProfileService = UserProfileService.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _userProfileService.initializeProfile();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Cargar estado de prueba
      try {
        final trialStatus = await TrialService.getTrialStatus();
        setState(() => _trialStatus = trialStatus);
      } catch (e) {
        print('Error al cargar estado de prueba: $e');
      }

      // Cargar rutinas del backend
      try {
        final routinesResponse = await RoutineService.getRoutines(
          page: 1,
          limit: 20,
        );
        if (routinesResponse['success']) {
          final List routinesJson = routinesResponse['data']['routines'] ?? [];
          setState(() {
            _backendRoutines = routinesJson.map((r) => Routine.fromJson(r)).toList();
          });
        }
      } catch (e) {
        print('Error al cargar rutinas del backend: $e');
      }

      // Obtener perfil del usuario
      final userProfile = _userProfileService.currentUser;

      // Actualizar filtros basados en el perfil del usuario
      if (userProfile != null) {
        _selectedLevel = userProfile.fitnessLevel;
        _selectedKneeSensitive = userProfile.kneeSensitive;

        // Determinar rango de edad basado en la edad del usuario
        if (userProfile.age <= 35) {
          _selectedAgeRange = '18-35';
        } else if (userProfile.age <= 55) {
          _selectedAgeRange = '36-55';
        } else {
          _selectedAgeRange = '55+';
        }
      }

      // Cargar rutina personalizada
      final personalizedResponse =
          await RoutineRecommendationService.getPersonalizedRoutine();
      if (personalizedResponse['success']) {
        setState(() {
          _personalizedRoutine = PersonalizedRoutine.fromJson(
            personalizedResponse['data']['routine'],
          );
        });
      }

      // Cargar plantillas
      await _loadTemplates();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTemplates() async {
    try {
      final response = await RoutineRecommendationService.getTemplates(
        ageRange: _selectedAgeRange,
        level: _selectedLevel,
        kneeSensitive: _selectedKneeSensitive,
        category: _selectedCategory,
      );

      if (response['success']) {
        setState(() {
          _templates = (response['data'] as List)
              .map((t) => RoutineTemplate.fromJson(t))
              .toList();
        });
      }
    } catch (e) {
      print('Error cargando plantillas: $e');
    }
  }

  Future<void> _refreshPersonalizedRoutine() async {
    try {
      final response =
          await RoutineRecommendationService.getPersonalizedRoutine();
      if (response['success']) {
        setState(() {
          _personalizedRoutine = PersonalizedRoutine.fromJson(
            response['data']['routine'],
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rutina actualizada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Rutinas'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Para Ti', icon: Icon(Icons.person)),
            Tab(text: 'Todas', icon: Icon(Icons.library_books)),
            Tab(text: 'Explorar', icon: Icon(Icons.explore)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileSetupScreen(),
                ),
              ).then((_) => _loadData());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_trialStatus != null && TrialService.shouldShowSubscriptionBanner(_trialStatus!))
                  _buildTrialBanner(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPersonalizedTab(),
                      _buildBackendRoutinesTab(),
                      _buildExploreTab(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshPersonalizedRoutine,
        backgroundColor: Colors.purple,
        tooltip: 'Actualizar Rutina',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildPersonalizedTab() {
    if (_personalizedRoutine == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No tienes una rutina personalizada',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configura tu perfil para obtener una recomendación',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileSetupScreen(),
                  ),
                ).then((_) => _loadData());
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('Configurar Perfil'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRoutineHeader(),
          const SizedBox(height: 20),
          _buildRoutineBlock(
            'Calentamiento',
            _personalizedRoutine!.calentamiento,
            Colors.orange,
          ),
          const SizedBox(height: 20),
          _buildRoutineBlock(
            'Principal',
            _personalizedRoutine!.principal,
            Colors.purple,
          ),
          const SizedBox(height: 20),
          _buildRoutineBlock(
            'Enfriamiento',
            _personalizedRoutine!.enfriamiento,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildExploreTab() {
    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: _templates.isEmpty
              ? const Center(
                  child: Text('No se encontraron plantillas con estos filtros'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    final template = _templates[index];
                    return _buildTemplateCard(template);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRoutineHeader() {
    final userProfile = _userProfileService.currentUser;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _personalizedRoutine!.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _personalizedRoutine!.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),

            // Información del usuario
            if (userProfile != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: Colors.purple,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tu Perfil: ${userProfile.name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoChip(
                            '${userProfile.age} años',
                            Icons.cake,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoChip(
                            userProfile.fitnessLevel,
                            Icons.fitness_center,
                          ),
                        ),
                      ],
                    ),
                    if (userProfile.kneeSensitive) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Rutina adaptada para sensibilidad en las rodillas',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Información de la rutina
            Row(
              children: [
                _buildInfoChip(
                  '${_personalizedRoutine!.duration} min',
                  Icons.timer,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  '${_personalizedRoutine!.mainCycles} ciclos',
                  Icons.repeat,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  _personalizedRoutine!.userProfile.fitnessLevel,
                  Icons.fitness_center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: Colors.purple[50],
      labelStyle: const TextStyle(color: Colors.purple),
    );
  }

  Widget _buildRoutineBlock(String title, RoutineBlock block, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fitness_center, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...block.exercises.map((exercise) => _buildExerciseItem(exercise)),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(Exercise exercise) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fitness_center, color: Colors.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  exercise.shortDescription,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (exercise.timeSeconds != null)
                Text(
                  '${exercise.timeSeconds}s',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              if (exercise.restSeconds > 0)
                Text(
                  'Desc: ${exercise.restSeconds}s',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        children: [
          const Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedAgeRange,
                  decoration: const InputDecoration(
                    labelText: 'Edad',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: ['18-35', '36-55', '55+'].map((age) {
                    return DropdownMenuItem(value: age, child: Text(age));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedAgeRange = value!);
                    _loadTemplates();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'Nivel',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: ['principiante', 'intermedio', 'avanzado'].map((
                    level,
                  ) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedLevel = value!);
                    _loadTemplates();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Filtro de sensibilidad de rodillas
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<bool>(
                  value: _selectedKneeSensitive,
                  decoration: const InputDecoration(
                    labelText: 'Sensibilidad Rodillas',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas')),
                    const DropdownMenuItem(
                      value: false,
                      child: Text('Sin restricción'),
                    ),
                    const DropdownMenuItem(
                      value: true,
                      child: Text('Con sensibilidad'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedKneeSensitive = value);
                    _loadTemplates();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(RoutineTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.purple[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.fitness_center, color: Colors.purple),
        ),
        title: Text(
          template.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(template.description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _showTemplateDetails(template),
      ),
    );
  }

  void _showTemplateDetails(RoutineTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(template.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(template.description),
              const SizedBox(height: 16),
              Text('Duración: ${template.baseDurationMinutes} min'),
              Text('Categoría: ${template.category}'),
              Text('Intensidad: ${template.intensity}'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: template.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateRoutineFromTemplate(template.templateId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Usar esta plantilla'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateRoutineFromTemplate(String templateId) async {
    try {
      final response =
          await RoutineRecommendationService.generateRoutineFromTemplate(
            templateId: templateId,
          );

      if (response['success']) {
        setState(() {
          _personalizedRoutine = PersonalizedRoutine.fromJson(
            response['data']['routine'],
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Rutina generada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );

        _tabController.animateTo(0);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al generar rutina: $e')));
    }
  }

  Widget _buildTrialBanner() {
    if (_trialStatus == null) return const SizedBox.shrink();

    final message = TrialService.getStatusMessage(_trialStatus!);
    final isExpired = _trialStatus!.trialExpired;
    final daysRemaining = _trialStatus!.daysRemaining;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExpired
              ? [Colors.red[400]!, Colors.red[600]!]
              : daysRemaining <= 2
                  ? [Colors.orange[400]!, Colors.orange[600]!]
                  : [Colors.purple[400]!, Colors.purple[600]!],
        ),
      ),
      child: Row(
        children: [
          Icon(
            isExpired ? Icons.lock : Icons.info_outline,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (!isExpired && daysRemaining <= 2)
                  const Text(
                    '¡Suscríbete ahora para seguir disfrutando!',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final token = await SecureStorageService.getToken();
              if (token != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PaymentsScreen(jwtToken: token)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: isExpired ? Colors.red : Colors.purple,
            ),
            child: Text(isExpired ? 'Suscribirse' : 'Ver Planes'),
          ),
        ],
      ),
    );
  }

  Widget _buildBackendRoutinesTab() {
    if (_backendRoutines.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay rutinas disponibles',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _backendRoutines.length,
      itemBuilder: (context, index) {
        final routine = _backendRoutines[index];
        return _buildBackendRoutineCard(routine);
      },
    );
  }

  Widget _buildBackendRoutineCard(Routine routine) {
    final canAccess = _trialStatus?.hasAccess ?? false;
    final isLocked = routine.accessLevel == 'premium' && !canAccess;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          if (isLocked) {
            _showSubscriptionDialog();
          } else {
            _showRoutineDetails(routine);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple[300]!, Colors.purple[600]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock : Icons.fitness_center,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                routine.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (routine.accessLevel == 'premium')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'PREMIUM',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          routine.description,
                          style: TextStyle(color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildRoutineInfoChip(
                    '${routine.duration} min',
                    Icons.timer,
                  ),
                  const SizedBox(width: 8),
                  _buildRoutineInfoChip(
                    routine.difficulty,
                    Icons.trending_up,
                  ),
                  const SizedBox(width: 8),
                  _buildRoutineInfoChip(
                    routine.category,
                    Icons.category,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        routine.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.purple),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.purple),
          ),
        ],
      ),
    );
  }

  void _showRoutineDetails(Routine routine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(routine.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(routine.description),
              const SizedBox(height: 16),
              Text('Instructor: ${routine.instructorName}'),
              Text('Duración: ${routine.duration} min'),
              Text('Dificultad: ${routine.difficulty}'),
              Text('Categoría: ${routine.category}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${routine.rating.toStringAsFixed(1)} (${routine.ratingCount} valoraciones)',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: routine.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar ejecución de rutina
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de ejecución próximamente'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Comenzar'),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contenido Premium'),
        content: const Text(
          'Esta rutina requiere una suscripción premium. ¿Deseas ver los planes disponibles?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final token = await SecureStorageService.getToken();
              if (token != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PaymentsScreen(jwtToken: token)),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Ver Planes'),
          ),
        ],
      ),
    );
  }
}
