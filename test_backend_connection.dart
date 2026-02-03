/// Script de prueba para verificar conexión con backend
/// Ejecutar con: dart test_backend_connection.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> main() async {
  print('═══════════════════════════════════════════════════════════════');
  print('🔌 TEST DE CONEXIÓN BACKEND - EVASTRONG');
  print('═══════════════════════════════════════════════════════════════\n');

  const backendUrl = 'http://localhost:5000';

  try {
    // Test 1: Health Check
    print('📋 Test 1: Health Check');
    print('─────────────────────────────────────────────────────────────');
    await testHealthEndpoint(backendUrl);

    // Test 2: Registro
    print('\n📋 Test 2: Registro de Usuario');
    print('─────────────────────────────────────────────────────────────');
    final token = await testRegister(backendUrl);

    // Test 3: Login
    if (token != null) {
      print('\n📋 Test 3: Inicio de Sesión');
      print('─────────────────────────────────────────────────────────────');
      await testLogin(backendUrl);
    }

    // Test 4: Verificar Token
    if (token != null) {
      print('\n📋 Test 4: Verificar Token');
      print('─────────────────────────────────────────────────────────────');
      await testVerifyToken(backendUrl, token);
    }

    // Test 5: Refrescar Token
    if (token != null) {
      print('\n📋 Test 5: Refrescar Token');
      print('─────────────────────────────────────────────────────────────');
      await testRefreshToken(backendUrl, token);
    }

    print('\n═══════════════════════════════════════════════════════════════');
    print('✅ TODOS LOS TESTS COMPLETADOS');
    print('═══════════════════════════════════════════════════════════════\n');
  } catch (e) {
    print('\n❌ ERROR EN TESTS: $e');
    exit(1);
  }
}

Future<void> testHealthEndpoint(String baseUrl) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/health')).timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw Exception('Timeout en health check'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Health Check: OK');
      print('   Status: ${data['status']}');
      print('   Timestamp: ${data['timestamp']}');
    } else {
      print('❌ Health Check: FALLÓ (${response.statusCode})');
    }
  } catch (e) {
    print('❌ Error en Health Check: $e');
    rethrow;
  }
}

Future<String?> testRegister(String baseUrl) async {
  try {
    final email = 'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
    final password = 'TestPassword123!';
    final name = 'Test User';

    print('📝 Registrando usuario:');
    print('   Email: $email');
    print('   Password: $password');
    print('   Name: $name');

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Timeout en registro'),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('✅ Registro: EXITOSO');
      print('   User ID: ${data['user']['_id']}');
      print('   Email: ${data['user']['email']}');
      print('   Token: ${data['token'].substring(0, 20)}...');
      return data['token'];
    } else {
      print('❌ Registro: FALLÓ (${response.statusCode})');
      print('   Respuesta: ${response.body}');
    }
  } catch (e) {
    print('❌ Error en Registro: $e');
  }
  return null;
}

Future<String?> testLogin(String baseUrl) async {
  try {
    const email = 'test@example.com';
    const password = 'TestPassword123!';

    print('🔐 Iniciando sesión:');
    print('   Email: $email');
    print('   Password: $password');

    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Timeout en login'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Login: EXITOSO');
      print('   User ID: ${data['user']['_id']}');
      print('   Email: ${data['user']['email']}');
      print('   Token: ${data['token'].substring(0, 20)}...');
      return data['token'];
    } else if (response.statusCode == 401) {
      print('❌ Login: Credenciales inválidas');
    } else {
      print('❌ Login: FALLÓ (${response.statusCode})');
      print('   Respuesta: ${response.body}');
    }
  } catch (e) {
    print('❌ Error en Login: $e');
  }
  return null;
}

Future<void> testVerifyToken(String baseUrl, String token) async {
  try {
    print('🔐 Verificando token:');
    print('   Token: ${token.substring(0, 20)}...');

    final response = await http.get(
      Uri.parse('$baseUrl/auth/verify'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Timeout en verificación'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Verificación: VÁLIDO');
      print('   User ID: ${data['userId']}');
      print('   Message: ${data['message']}');
    } else {
      print('❌ Verificación: INVÁLIDO (${response.statusCode})');
      print('   Respuesta: ${response.body}');
    }
  } catch (e) {
    print('❌ Error en Verificación: $e');
  }
}

Future<void> testRefreshToken(String baseUrl, String token) async {
  try {
    print('🔄 Refrescando token:');
    print('   Token actual: ${token.substring(0, 20)}...');

    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Timeout en refresh'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Refresh: EXITOSO');
      print('   Nuevo token: ${data['token'].substring(0, 20)}...');
      print('   Message: ${data['message']}');
    } else {
      print('❌ Refresh: FALLÓ (${response.statusCode})');
      print('   Respuesta: ${response.body}');
    }
  } catch (e) {
    print('❌ Error en Refresh: $e');
  }
}

// Simple exit function
void exit(int code) {
  throw Exception('Exit code: $code');
}
