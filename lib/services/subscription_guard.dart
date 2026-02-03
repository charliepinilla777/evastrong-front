import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'secure_auth_service.dart';

/// Guard para controlar acceso a features basado en suscripción
class SubscriptionGuard {
  /// Verificar acceso a feature específico
  static Future<bool> hasAccessTo(String feature) async {
    try {
      // Primero verificar localmente
      if (!await SecureAuthService.hasActiveSubscription()) {
        return false;
      }

      // Verificación adicional en backend
      final headers = await SecureAuthService.getAuthHeaders();

      final response = await http.get(
        Uri.parse('http://localhost:5000/api/subscription/check/$feature'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Subscription check error: $e');
      return false;
    }
  }

  /// Widget wrapper para features protegidos
  static Widget protectFeature({
    required Widget child,
    required String feature,
    required String requiredPlan,
    Widget? fallback,
    String? customMessage,
  }) {
    return FutureBuilder<bool>(
      future: hasAccessTo(feature),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasData && snapshot.data == true) {
          return child;
        }

        return fallback ??
            _buildUpgradePrompt(context, requiredPlan, customMessage);
      },
    );
  }

  /// Widget para proteger rutas completas
  static Widget protectRoute({
    required Widget child,
    required String route,
    String? customMessage,
  }) {
    return FutureBuilder<bool>(
      future: canAccessRoute(route),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasData && snapshot.data == true) {
          return child;
        }

        return _buildRouteBlocked(context, customMessage);
      },
    );
  }

  /// Verificar si se puede acceder a una ruta específica
  static Future<bool> canAccessRoute(String route) async {
    switch (route) {
      case '/premium-workouts':
        return await hasAccessTo('premium_workouts');
      case '/personal-training':
        return await hasAccessTo('personal_training');
      case '/custom-plans':
        return await hasAccessTo('custom_plans');
      case '/video-library':
        return await hasAccessTo('video_library');
      case '/advanced-analytics':
        return await hasAccessTo('advanced_analytics');
      case '/nutrition-plans':
        return await hasAccessTo('nutrition_plans');
      case '/community-premium':
        return await hasAccessTo('community_premium');
      default:
        return true; // Rutas públicas
    }
  }

  /// Widget de carga
  static Widget _buildLoadingWidget() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Verificando acceso...'),
          ],
        ),
      ),
    );
  }

  /// Widget de upgrade prompt
  static Widget _buildUpgradePrompt(
    BuildContext context,
    String requiredPlan,
    String? customMessage,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso Restringido'),
        backgroundColor: Colors.pink[100],
      ),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Colors.pink[300]),
            const SizedBox(height: 24),
            Text(
              '¡Esta función es exclusiva!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.pink[700],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              customMessage ??
                  'Esta función requiere el plan $requiredPlan para acceder.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildSubscriptionBenefits(context, requiredPlan),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _navigateToUpgrade(context, requiredPlan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Upgrade a $requiredPlan'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.pink[300]!),
                    ),
                    child: Text('Volver'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de ruta bloqueada
  static Widget _buildRouteBlocked(
    BuildContext context,
    String? customMessage,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso Denegado'),
        backgroundColor: Colors.red[100],
      ),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 80, color: Colors.red[300]),
            const SizedBox(height: 24),
            Text(
              'Acceso Denegado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              customMessage ?? 'No tienes permiso para acceder a esta sección.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Ir al Inicio'),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de beneficios de suscripción
  static Widget _buildSubscriptionBenefits(BuildContext context, String plan) {
    final benefits = _getPlanBenefits(plan);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Beneficios del plan $plan:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.pink[700],
            ),
          ),
          const SizedBox(height: 8),
          ...benefits
              .map(
                (benefit) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.pink[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          benefit,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              ,
        ],
      ),
    );
  }

  /// Obtener beneficios por plan
  static List<String> _getPlanBenefits(String plan) {
    switch (plan) {
      case 'basic':
        return [
          'Acceso a todos los workouts básicos',
          'Seguimiento de progreso',
          'Comunidad básica',
          'Soporte por email',
        ];
      case 'premium':
        return [
          'Acceso a todos los workouts premium',
          'Planes de entrenamiento personalizados',
          'Nutrición y dietas',
          'Video library completa',
          'Analytics avanzados',
          'Comunidad premium',
          'Soporte prioritario 24/7',
          'Eventos exclusivos',
        ];
      default:
        return ['Funcionalidades exclusivas'];
    }
  }

  /// Navegar a pantalla de upgrade
  static void _navigateToUpgrade(BuildContext context, String plan) {
    Navigator.of(context).pushNamed('/subscription-upgrade', arguments: plan);
  }

  /// Verificar múltiples features a la vez
  static Future<Map<String, bool>> checkMultipleFeatures(
    List<String> features,
  ) async {
    final results = <String, bool>{};

    for (final feature in features) {
      results[feature] = await hasAccessTo(feature);
    }

    return results;
  }

  /// Widget que muestra estado de suscripción
  static Widget buildSubscriptionStatus({bool showDetails = false}) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getSubscriptionStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData) {
          return const Text('Estado desconocido');
        }

        final status = snapshot.data!;
        final isActive = status['isActive'] ?? false;
        final plan = status['plan'] ?? 'free';
        final timeRemaining = status['timeRemaining'] ?? 'N/A';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive ? Colors.green[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? Colors.green[300]! : Colors.grey[300]!,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isActive ? Icons.check_circle : Icons.info,
                    color: isActive ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Plan $plan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.green[700] : Colors.grey[700],
                    ),
                  ),
                  if (isActive) ...[
                    const Spacer(),
                    Text(
                      timeRemaining,
                      style: TextStyle(fontSize: 12, color: Colors.green[600]),
                    ),
                  ],
                ],
              ),
              if (showDetails && status['features'] != null) ...[
                const SizedBox(height: 8),
                ...status['features']
                    .map<Widget>(
                      (feature) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Icon(
                              feature['enabled'] ? Icons.check : Icons.close,
                              size: 16,
                              color: feature['enabled']
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature['name'],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Obtener estado completo de suscripción
  static Future<Map<String, dynamic>> _getSubscriptionStatus() async {
    try {
      final headers = await SecureAuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/subscription/status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error getting subscription status: $e');
    }

    // Retornar información local si falla el backend
    return {
      'isActive': await SecureAuthService.hasActiveSubscription(),
      'plan': await SecureAuthService.getSubscriptionPlan(),
      'timeRemaining': SecureAuthService.subscriptionTimeRemainingFormatted,
      'features': SecureAuthService.subscriptionInfo?['features'] ?? [],
    };
  }
}
