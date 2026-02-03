import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Pantalla para probar la conexión con el backend
class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  bool _isLoading = false;
  String _result = '';
  String _backendUrl = '';

  @override
  void initState() {
    super.initState();
    _backendUrl = AppConfig.backendUrl;
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'Probando conexión...';
    });

    try {
      // Probar conexión básica con el backend
      final response = await http
          .get(
            Uri.parse('$_backendUrl/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(AppConfig.apiTimeout);

      setState(() {
        if (response.statusCode == 200) {
          _result =
              '✅ Conexión exitosa con el backend!\n\n'
              'URL: $_backendUrl\n'
              'Status Code: ${response.statusCode}\n'
              'Response: ${response.body}';
        } else {
          _result =
              '⚠️ El backend respondió pero con un error:\n\n'
              'URL: $_backendUrl\n'
              'Status Code: ${response.statusCode}\n'
              'Response: ${response.body}';
        }
      });
    } catch (e) {
      setState(() {
        _result =
            '❌ Error de conexión:\n\n'
            'URL: $_backendUrl\n'
            'Error: $e\n\n'
            'Asegúrate de que tu backend esté corriendo en el puerto 5000';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Conexión Backend'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuración Actual:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Backend URL: $_backendUrl'),
                    Text(
                      'Ambiente: ${AppConfig.isDebugMode ? 'Desarrollo' : 'Producción'}',
                    ),
                    Text('API Timeout: ${AppConfig.apiTimeout.inSeconds}s'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Probar Conexión'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      _result.isEmpty
                          ? 'Presiona el botón para probar la conexión'
                          : _result,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
