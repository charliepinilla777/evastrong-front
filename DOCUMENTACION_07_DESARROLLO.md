# 🛠️ EVA STRONG - GUÍA DE DESARROLLO

## 📝 CÓMO AGREGAR NUEVAS FEATURES

### Ejemplo: Agregar pantalla "Mi Perfil"

#### Paso 1: Crear componente en Frontend

**Archivo:** `lib/screens/profile_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _nameController = TextEditingController(
      text: authProvider.user?['name'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 24),

                // Nombre
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Email (read-only)
                TextField(
                  initialValue: authProvider.user?['email'] ?? '',
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón guardar
                ElevatedButton(
                  onPressed: () async {
                    bool success = await authProvider.updateProfile(
                      name: _nameController.text,
                    );
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perfil actualizado')),
                      );
                    }
                  },
                  child: const Text('Guardar cambios'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

#### Paso 2: Agregar ruta en main.dart

```dart
// En HomeScreen, agregar nueva pestaña
bottom: TabBar(
  controller: _tabController,
  tabs: const [
    Tab(icon: Icon(Icons.home), text: 'Inicio'),
    Tab(icon: Icon(Icons.fitness_center), text: 'Rutinas'),
    Tab(icon: Icon(Icons.person), text: 'Perfil'),  // ← Nuevo
    Tab(icon: Icon(Icons.phone), text: 'Contacto'),
  ],
),

// En TabBarView, agregar pantalla
TabBarView(
  controller: _tabController,
  children: [
    _buildHomeTab(scheme),
    _buildComingSoonTab('Rutinas'),
    const ProfileScreen(),  // ← Nuevo
    _buildContactoTab(scheme),
  ],
)
```

#### Paso 3: Actualizar TabController

```dart
_tabController = TabController(
  length: 4,  // Cambiar de 3 a 4
  vsync: this
);
```

---

## 🎨 PERSONALIZAR COLORES

### Cambiar paleta de colores

**Archivo:** `lib/main.dart`

```dart
// Encontrar:
static const _brandPurple = Color(0xFF6D28D9);
static const _brandLilac = Color(0xFFB46BFF);

// Cambiar por tus colores:
static const _brandPurple = Color(0xFF1E40AF);    // Azul
static const _brandLilac = Color(0xFF60A5FA);    // Azul claro
```

### Usar colores en widgets

```dart
// Obtener colores del tema
final scheme = Theme.of(context).colorScheme;

Container(
  color: scheme.primary,        // Color principal
  child: Text(
    'Hola',
    style: TextStyle(
      color: scheme.onPrimary,  // Contraste
    ),
  ),
);
```

---

## 🔌 AGREGAR NUEVO ENDPOINT EN BACKEND

### Ejemplo: Agregar endpoint para obtener estadísticas

#### Paso 1: Crear ruta

**Archivo:** `routes/stats.js`

```javascript
const express = require('express');
const authMiddleware = require('../middleware/auth');
const User = require('../models/User');

const router = express.Router();

// GET /stats/summary
// Obtener resumen de estadísticas del usuario
router.get('/summary', authMiddleware, async (req, res) => {
  try {
    const user = req.user;
    
    // Lógica para obtener stats
    const stats = {
      joinDate: user.createdAt,
      totalWorkouts: 42,        // Ejemplo
      totalMinutes: 3600,
      currentStreak: 7,
      personalBest: 100,  // kg levantados
    };

    res.json({
      success: true,
      stats,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

module.exports = router;
```

#### Paso 2: Registrar ruta en server.js

```javascript
const statsRoutes = require('./routes/stats');

// ... otros routes ...

app.use('/stats', statsRoutes);
```

#### Paso 3: Usar en Frontend

**Archivo:** `lib/services/api_service.dart`

```dart
static Future<Map<String, dynamic>> getStats() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/stats/summary'),
      headers: _getHeaders(requireAuth: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener estadísticas');
    }
  } catch (e) {
    rethrow;
  }
}
```

#### Paso 4: Usar en Provider

**Archivo:** `lib/providers/stats_provider.dart`

```dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StatsProvider extends ChangeNotifier {
  Map<String, dynamic>? _stats;
  bool _isLoading = false;

  Map<String, dynamic>? get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> getStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.getStats();
      _stats = result['stats'];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## 🗄️ MODIFICAR BASE DE DATOS

### Agregar campo a Usuario

#### Paso 1: Actualizar modelo en Backend

**Archivo:** `models/User.js`

```javascript
const userSchema = new mongoose.Schema({
  // ... campos existentes ...

  // Agregar nuevo campo:
  premiumFeatures: {
    type: [String],
    default: [],
    example: ['advanced_analytics', 'custom_workouts']
  },

  // ... más campos ...
});
```

#### Paso 2: Migrar datos existentes (si es necesario)

```javascript
// Script para ejecutar una sola vez
// Agregar a una nueva ruta temporal: routes/migrate.js

router.post('/migrate-add-premium-features', async (req, res) => {
  try {
    // Actualizar todos los usuarios sin el campo
    await User.updateMany(
      { premiumFeatures: { $exists: false } },
      { $set: { premiumFeatures: [] } }
    );
    
    res.json({ success: true, message: 'Migración completada' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});
```

#### Paso 3: Usar en Frontend

```dart
final premiumFeatures = user?['premiumFeatures'];
if (premiumFeatures?.contains('advanced_analytics') ?? false) {
  // Mostrar analytics avanzado
}
```

---

## 🧪 TESTING

### Testing en Frontend

**Archivo:** `test/widget_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:evastrong/main.dart';

void main() {
  group('Eva Strong App Tests', () {
    testWidgets('App inicia correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(const EvaStrongApp());

      // Verificar que la app se inicia
      expect(find.text('Eva Strong'), findsOneWidget);
      
      // Verificar que hay tabs
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('Tabs funcionan correctamente', 
      (WidgetTester tester) async {
      await tester.pumpWidget(const EvaStrongApp());

      // Verifica que hay 3 tabs
      expect(find.byType(Tab), findsWidgets);
    });
  });
}
```

**Ejecutar tests:**
```bash
flutter test
```

### Testing en Backend

**Archivo:** `tests/auth.test.js`

```javascript
const request = require('supertest');
const app = require('../server');
const User = require('../models/User');

describe('Auth Endpoints', () => {
  afterEach(async () => {
    await User.deleteMany({});
  });

  test('POST /auth/register debe crear usuario', async () => {
    const response = await request(app)
      .post('/auth/register')
      .send({
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User'
      });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.token).toBeDefined();
    expect(response.body.user.email).toBe('test@example.com');
  });

  test('POST /auth/login debe autenticar usuario', async () => {
    // Primero crear usuario
    await User.create({
      email: 'test@example.com',
      password: 'hasheada', // En real sería hasheada
      name: 'Test User'
    });

    const response = await request(app)
      .post('/auth/login')
      .send({
        email: 'test@example.com',
        password: 'password123'
      });

    expect(response.status).toBe(200);
    expect(response.body.token).toBeDefined();
  });
});
```

**Ejecutar tests:**
```bash
npm test
```

---

## 🐛 DEBUGGING

### Flutter Debugging

```dart
// Agregar logs
print('Usuario autenticado: ${authProvider.isLoggedIn}');
print('Token: ${authProvider.token}');

// Usar debugPrint (mejor que print)
import 'package:flutter/foundation.dart';
debugPrint('Error: $error');

// DevTools
flutter pub global activate devtools
devtools
flutter run --devtools-server-address=localhost:9100
```

### Node.js Debugging

```javascript
// Usar console.log
console.log('Usuario encontrado:', user);
console.error('Error:', error);

// Usar debugger (parar ejecución)
debugger;

// Iniciar con debugging
node --inspect server.js

// O usar Chrome DevTools
node --inspect-brk server.js
```

---

## 📦 DESPLEGAR A PRODUCCIÓN

### Frontend - Build APK para Google Play

```bash
cd C:\Users\Carlos\Desktop\EvaStrong

# Build APK
flutter build apk --release --split-per-abi

# Output en:
# build/app/outputs/flutter-apk/app-release.apk
```

### Backend - Deploy a Heroku

```bash
# 1. Crear app
heroku create evastrong-backend

# 2. Agregar variables
heroku config:set JWT_SECRET=tu_secreto
heroku config:set MONGODB_URI=...
heroku config:set GOOGLE_CLIENT_ID=...

# 3. Deploy
git push heroku main

# 4. Ver logs
heroku logs --tail
```

---

## 📋 CHECKLIST DE CALIDAD

Antes de publicar, verifica:

- [ ] Código sin errores: `flutter analyze`
- [ ] Tests pasando: `flutter test`
- [ ] No hay prints de debug
- [ ] Error handling implementado
- [ ] UI responsive en todos los tamaños
- [ ] Tema visual consistente
- [ ] Backend validando inputs
- [ ] Contraseñas hasheadas
- [ ] Tokens con expiración
- [ ] Rate limiting activo
- [ ] HTTPS en producción
- [ ] Variables de ambiente en .env
- [ ] Base de datos respalda

da
- [ ] Documentación actualizada

---

## 🚀 MEJORES PRÁCTICAS

### Frontend

```dart
// ✅ BIEN: Usar Providers para estado
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    // UI aquí
  },
);

// ❌ MAL: Guardar estado en StatefulWidget
class MyWidget extends StatefulWidget {
  bool isLoggedIn = false;  // ❌ Evitar
}

// ✅ BIEN: Validar antes de enviar
if (emailController.text.isEmpty) {
  showError('Email requerido');
  return;
}

// ❌ MAL: Confiar en backend para validar todo
postData(); // Sin validación local
```

### Backend

```javascript
// ✅ BIEN: Validar y sanitizar
const { email, password } = req.body;
if (!email || !password) {
  return res.status(400).json({ error: 'Campos requeridos' });
}

// ❌ MAL: Confiar en cliente
app.post('/login', (req, res) => {
  const user = findUser(req.body.email);  // Sin validar
});

// ✅ BIEN: Usar middleware de autenticación
router.get('/profile', authMiddleware, async (req, res) => {
  // req.user está garantizado
});

// ❌ MAL: Confiar en tokens sin verificar
app.get('/profile', (req, res) => {
  const token = req.headers.authorization;
  // No verificar si es válido
});
```

---

## 📞 RECURSOS ÚTILES

### Documentación oficial

- Flutter: https://flutter.dev/docs
- Dart: https://dart.dev/guides
- Express: https://expressjs.com
- MongoDB: https://docs.mongodb.com
- Mercado Pago: https://developers.mercadopago.com

### Herramientas

- Visual Studio Code: https://code.visualstudio.com
- Android Studio: https://developer.android.com/studio
- MongoDB Compass: https://www.mongodb.com/products/compass
- Postman: https://www.postman.com

---

**Fin de la documentación** 🎉

---

## 📚 ÍNDICE COMPLETO DE DOCUMENTACIÓN

1. ✅ DOCUMENTACION_01_INICIO.md - Visión general
2. ✅ DOCUMENTACION_02_ESTRUCTURA.md - Carpetas y archivos
3. ✅ DOCUMENTACION_03_FRONTEND.md - Flutter, widgets, servicios
4. ✅ DOCUMENTACION_04_BACKEND.md - Node.js, endpoints, modelos
5. ✅ DOCUMENTACION_05_INSTALACION.md - Paso a paso setup
6. ✅ DOCUMENTACION_06_FLUJOS.md - Flujos de usuario
7. ✅ DOCUMENTACION_07_DESARROLLO.md - Cómo agregar features (ACTUAL)

---

**Creado:** 2026-01-08  
**Versión:** 1.0.0  
**Estado:** ✅ Completo
