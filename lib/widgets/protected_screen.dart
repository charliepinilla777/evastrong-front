import 'package:flutter/material.dart';
import '../services/access_control_service.dart';

class ProtectedScreen extends StatelessWidget {
  final Widget child;
  final String screenName;
  final bool requireSubscription;
  final bool requireAdmin;

  const ProtectedScreen({
    Key? key,
    required this.child,
    required this.screenName,
    this.requireSubscription = true,
    this.requireAdmin = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAccess(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.data!) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Acceso Denegado',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getAccessDeniedMessage(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ),
          );
        }

        return child;
      },
    );
  }

  Future<bool> _checkAccess() async {
    if (requireAdmin) {
      return await AccessControlService.isAdmin();
    }

    if (requireSubscription) {
      return await AccessControlService.hasValidSubscription();
    }

    return true;
  }

  String _getAccessDeniedMessage() {
    if (requireAdmin) {
      return 'Solo administradores pueden acceder a esta sección.';
    }

    if (requireSubscription) {
      return 'Necesitas una suscripción activa para acceder a esta pantalla.\n\nUpgrade ahora para continuar.';
    }

    return 'No tienes acceso a esta pantalla.';
  }
}
