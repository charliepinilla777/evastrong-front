# 📱 EVA STRONG - DOCUMENTACIÓN FRONTEND

## 🎯 ¿QUÉ ES EL FRONTEND?

El frontend es la **interfaz visual** que ves en tu pantalla. Es lo que construimos con Flutter.

```
Lo que ves (UI)
     ↓
Lo que interactúas (Widgets)
     ↓
Lo que procesa (Providers)
     ↓
Lo que comunica (Services)
     ↓
Backend (Server)
```

---

## 🏗️ ESTRUCTURA DE CAPAS

```
┌────────────────────────────────────────┐
│          UI LAYER (Pantallas)          │
│  ┌──────────────────────────────────┐  │
│  │  HomeScreen                      │  │
│  │  ├─ Tab 1: Inicio                │  │
│  │  ├─ Tab 2: Rutinas               │  │
│  │  └─ Tab 3: Contacto              │  │
│  └──────────────────────────────────┘  │
└────────────────────────────────────────┘
                   ↓
┌────────────────────────────────────────┐
│     PROVIDER LAYER (Estado)            │
│  ┌──────────────────────────────────┐  │
│  │  AuthProvider                    │  │
│  │  ├─ Autenticación                │  │
│  │  └─ Datos del usuario            │  │
│  ├──────────────────────────────────┤  │
│  │  SubscriptionProvider            │  │
│  │  ├─ Suscripción actual           │  │
│  │  └─ Historial de pagos           │  │
│  └──────────────────────────────────┘  │
└────────────────────────────────────────┘
                   ↓
┌────────────────────────────────────────┐
│      SERVICE LAYER (API)               │
│  ┌──────────────────────────────────┐  │
│  │  ApiService                      │  │
│  │  └─ Llamadas HTTP al backend     │  │
│  └──────────────────────────────────┘  │
└────────────────────────────────────────┘
                   ↓
┌────────────────────────────────────────┐
│       BACKEND (Servidor)               │
│  Node.js + Express + MongoDB           │
└────────────────────────────────────────┘
```

---

## 📄 main.dart - EL PUNTO DE ENTRADA

### ¿Qué hace?

`main.dart` es el **primer archivo que ejecuta Flutter**. Define:
- La app principal
- El tema visual
- Las pantallas

### Código explicado

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/subscription_provider.dart';

// 1. Función main() - se ejecuta primero
void main() {
  runApp(const EvaStrongApp());
}

// 2. EvaStrongApp - widget principal
class EvaStrongApp extends StatelessWidget {
  const EvaStrongApp({super.key});

  // 3. Definir colores personalizados
  static const _brandPurple = Color(0xFF6D28D9);   // Púrpura
  static const _brandLilac = Color(0xFFB46BFF);   // Lila
  static const _brandDeep = Color(0xFF2E1065);    // Fondo oscuro

  // 4. Crear tema personalizado
  ThemeData _buildTheme(Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,                         // Usar Material 3
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _brandPurple,                  // Color base
        brightness: brightness,
      ).copyWith(
        primary: _brandPurple,                    // Color principal
        secondary: _brandLilac,                   // Color secundario
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: brightness == Brightness.dark 
        ? _brandDeep 
        : base.scaffoldBackgroundColor,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eva Strong',
      
      // 5. Aplicar tema claro
      theme: _buildTheme(Brightness.light),
      
      // 6. Aplicar tema oscuro
      darkTheme: _buildTheme(Brightness.dark),
      
      // 7. Detectar tema del sistema
      themeMode: ThemeMode.system,
      
      // 8. Proveedores globales (state management)
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ],
        child: const HomeScreen(title: 'Eva Strong'),
      ),
    );
  }
}

// 9. HomeScreen - pantalla principal con tabs
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        
        // 10. Crear las 3 pestañas (tabs)
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Inicio'),
            Tab(icon: Icon(Icons.fitness_center), text: 'Rutinas'),
            Tab(icon: Icon(Icons.phone), text: 'Contacto'),
          ],
        ),
      ),
      
      // 11. Contenido de cada pestaña
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(context),      // Tab 1: Inicio
          _buildComingSoonTab('Rutinas'),  // Tab 2: Rutinas
          _buildContactoTab(context),  // Tab 3: Contacto
        ],
      ),
    );
  }

  // 12. Pestaña 1: Inicio (bienvenida)
  Widget _buildHomeTab(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.secondary.withValues(alpha: 0.90),  // Lila semi-transparente
            scheme.primary.withValues(alpha: 0.85),    // Púrpura semi-transparente
          ],
        ),
      ),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bienvenido a Eva Strong',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Transforma tu cuerpo, fortalece tu mente',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text('Ver rutinas'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 13. Pestaña 2 y 3: Coming Soon
  Widget _buildComingSoonTab(String title) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.secondary.withValues(alpha: 0.90),
            scheme.primary.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.construction, size: 64, color: scheme.primary),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Coming soon — Eva Strong',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 🔌 ApiService - CLIENTE HTTP

### ¿Qué es?

ApiService es una **clase que centraliza todas las llamadas al backend**. Es como un intermediario.

```
Widget → ApiService → HTTP → Backend → BD
         (aquí)
```

### Por qué es importante

- **Un único lugar** para cambiar URLs
- **Reutilizable** en toda la app
- **Consistente** en headers y autenticación
- **Fácil de testear**

### Métodos principales

#### 1. setToken() / getToken()
```dart
// Guardar token después de login
ApiService.setToken('jwt_token_aqui');

// Leer token después
String? token = ApiService.getToken();
```

#### 2. _getHeaders()
```dart
// Crear headers automáticamente
// Con autenticación si es necesario

// Headers sin autenticación
{
  'Content-Type': 'application/json'
}

// Headers con autenticación
{
  'Content-Type': 'application/json',
  'Authorization': 'Bearer jwt_token_aqui'
}
```

#### 3. register()
```dart
// Registrar nuevo usuario
final result = await ApiService.register(
  email: 'nuevo@example.com',
  password: 'pass123456',
  name: 'Juan Pérez',
);

// Retorna:
{
  'success': true,
  'token': 'jwt_token',
  'user': {
    'email': '...',
    'name': '...',
    'id': '...'
  }
}
```

**Flujo:**
```
1. ApiService.register() recibe datos
2. Crea JSON con email, password, name
3. Envía POST request a /auth/register
4. Backend valida y crea usuario
5. Backend retorna token
6. ApiService guarda token automáticamente
7. Retorna resultado al Provider
```

#### 4. login()
```dart
final result = await ApiService.login(
  email: 'usuario@example.com',
  password: 'contraseña',
);

// Retorna: { token, user, ... }
```

#### 5. getProfile()
```dart
// Obtener datos del usuario autenticado
final result = await ApiService.getProfile();

// Retorna:
{
  'success': true,
  'user': {
    'name': 'Juan',
    'email': 'juan@example.com',
    'age': 30,
    'fitnessLevel': 'beginner',
    '...'
  }
}
```

**Nota:** Requiere token válido en headers

#### 6. createPaymentPreference()
```dart
// Crear pago en Mercado Pago
final result = await ApiService.createPaymentPreference(
  plan: 'premium',
  period: 'monthly',
);

// Retorna:
{
  'preferenceId': 'mp_preference_id',
  'initPoint': 'https://www.mercadopago.com/...',  ← Abrir en navegador
  'sandboxUrl': 'https://sandbox.mercadopago.com/...',
  'paymentId': 'payment_db_id'
}
```

---

## 🎛️ AuthProvider - GESTIÓN DE AUTENTICACIÓN

### ¿Qué es?

AuthProvider es una **clase que gestiona el estado de autenticación**. Mantiene:
- Si el usuario está autenticado
- El token JWT
- Datos del usuario
- Errores

### Por qué es importante

- **Estado centralizado** (no repetir lógica)
- **Notifica widgets** cuando cambia
- **Reutilizable** en toda la app
- **Fácil de testear**

### Variables privadas

```dart
bool _isLoggedIn = false;           // ¿Usuario autenticado?
String? _token;                     // JWT token
Map<String, dynamic>? _user;        // Datos: { name, email, age, ... }
bool _isLoading = false;            // ¿Está cargando?
String? _error;                     // Último error
```

### Métodos principales

#### 1. register()
```dart
// En un widget:
bool success = await authProvider.register(
  email: 'nuevo@example.com',
  password: 'pass123456',
  name: 'María González',
);

if (success) {
  // Usuario registrado y autenticado
  print('Token: ${authProvider.token}');
  print('Usuario: ${authProvider.user}');
} else {
  // Error
  print('Error: ${authProvider.error}');
}
```

**Flujo interno:**
```
1. register() → ApiService.register()
2. Espera respuesta
3. Si success:
   - Guarda token
   - Guarda usuario
   - Establece _isLoggedIn = true
   - Notifica a widgets
4. Si error:
   - Guarda mensaje de error
   - Notifica a widgets
```

#### 2. login()
```dart
bool success = await authProvider.login(
  email: 'usuario@example.com',
  password: 'contraseña',
);

if (success) {
  print('¡Login exitoso!');
}
```

#### 3. logout()
```dart
await authProvider.logout();
// Limpia token, usuario, estado
// Notifica a widgets
```

#### 4. getProfile()
```dart
await authProvider.getProfile();
// Obtiene datos actualizados del usuario
// Actualiza authProvider.user
```

#### 5. updateProfile()
```dart
bool success = await authProvider.updateProfile(
  name: 'Nuevo nombre',
  age: 25,
  gender: 'female',
  fitnessLevel: 'intermediate',
);
```

#### 6. verifyToken()
```dart
// Verificar si token aún es válido
bool isValid = await authProvider.verifyToken();

if (isValid) {
  print('Token válido');
} else {
  print('Token expirado o inválido');
}
```

### Uso en widgets con Consumer

```dart
// Consumer actualiza automáticamente cuando AuthProvider cambia
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    
    // Si está cargando
    if (authProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    // Si no está autenticado
    if (!authProvider.isLoggedIn) {
      return Center(child: Text('Por favor inicia sesión'));
    }
    
    // Si está autenticado
    return Center(
      child: Column(
        children: [
          Text('Bienvenido: ${authProvider.user?['name']}'),
          Text('Email: ${authProvider.user?['email']}'),
        ],
      ),
    );
  },
);
```

---

## 💳 SubscriptionProvider - GESTIÓN DE SUSCRIPCIONES

### ¿Qué es?

SubscriptionProvider gestiona:
- Suscripción actual del usuario
- Historial de pagos
- Cambios de plan
- Cancelaciones

### Variables privadas

```dart
Map<String, dynamic>? _subscription;     // Plan actual
List<Map<String, dynamic>> _paymentHistory = [];  // Historial
bool _isLoading = false;
String? _error;
```

### Getters útiles

```dart
// En tu widget:
print(subscriptionProvider.isPremium);   // ¿Es premium?
print(subscriptionProvider.isActive);    // ¿Suscripción activa?
print(subscriptionProvider.subscription?['plan']);  // Qué plan tiene
```

### Métodos principales

#### 1. getCurrentSubscription()
```dart
await subscriptionProvider.getCurrentSubscription();

// Ahora puedes acceder a:
var sub = subscriptionProvider.subscription;
print(sub?['plan']);        // 'basic', 'premium'
print(sub?['status']);      // 'active', 'expired'
print(sub?['endDate']);     // Fecha de vencimiento
```

#### 2. createPaymentPreference()
```dart
Map<String, dynamic>? preference = 
    await subscriptionProvider.createPaymentPreference(
  plan: 'premium',
  period: 'monthly',
);

if (preference != null) {
  // Abrir Mercado Pago
  String initPoint = preference['initPoint'];
  // Usar: launchUrl(Uri.parse(initPoint))
}
```

#### 3. changePlan()
```dart
bool success = await subscriptionProvider.changePlan('premium');

if (success) {
  print('Plan cambiado exitosamente');
}
```

#### 4. cancelSubscription()
```dart
bool success = await subscriptionProvider.cancelSubscription(
  reason: 'No tengo tiempo', // Opcional
);
```

#### 5. getPaymentHistory()
```dart
await subscriptionProvider.getPaymentHistory();

List<Map> payments = subscriptionProvider.paymentHistory;
for (var payment in payments) {
  print('${payment['amount']} ARS - ${payment['status']}');
}
```

---

## 🎨 TEMAS Y COLORES

### Definición de colores

```dart
static const _brandPurple = Color(0xFF6D28D9);   // #6D28D9
static const _brandLilac = Color(0xFFB46BFF);   // #B46BFF
static const _brandDeep = Color(0xFF2E1065);    // #2E1065
```

### ColorScheme automático

```dart
ColorScheme.fromSeed(
  seedColor: _brandPurple,  // Color base
  brightness: brightness,   // Light o Dark
)
```

Flutter genera automáticamente paleta completa:
- Primary (púrpura)
- Secondary (lila)
- Surface (fondo)
- Error (rojo para errores)
- etc.

### Usar colores en widgets

```dart
final scheme = Theme.of(context).colorScheme;

Container(
  color: scheme.primary,           // Púrpura
  child: Text(
    'Hola',
    style: TextStyle(
      color: scheme.onPrimary,     // Color contraste
    ),
  ),
);
```

---

## 🚀 FLUJOS COMUNES

### Flujo 1: Login Manual

```
Usuario ve pantalla de login
          ↓
Ingresa email y contraseña
          ↓
Presiona botón "Login"
          ↓
authProvider.login()
          ↓
ApiService.login() → POST /auth/login
          ↓
Backend verifica credenciales
          ↓
Backend retorna JWT token
          ↓
ApiService guarda token
          ↓
AuthProvider notifica widgets
          ↓
UI redirige a HomeScreen
          ↓
Usuario ve "Bienvenido: [nombre]"
```

### Flujo 2: Comprar Premium

```
Usuario en Tab "Planes"
          ↓
Presiona "Comprar Premium"
          ↓
subscriptionProvider.createPaymentPreference()
          ↓
Backend crea preferencia en Mercado Pago
          ↓
Retorna URL de pago
          ↓
Frontend abre navegador → Mercado Pago
          ↓
Usuario completa pago con tarjeta
          ↓
Mercado Pago redirige → "Pago exitoso"
          ↓
Backend recibe webhook
          ↓
Backend crea suscripción en BD
          ↓
Usuario obtiene acceso premium
          ↓
Frontend muestra "Suscripción activa"
```

### Flujo 3: Cambiar Plan

```
Usuario con plan "Basic"
          ↓
Ve opción "Actualizar a Premium"
          ↓
Presiona botón
          ↓
subscriptionProvider.changePlan('premium')
          ↓
Backend verifica suscripción actual
          ↓
Crea nueva preferencia de pago
          ↓
Backend actualiza plan en BD
          ↓
Frontend notifica cambio exitoso
```

---

## 🔍 DEBUGGING

### Ver logs

```dart
// Agregar en cualquier lugar:
print('Autenticado: ${authProvider.isLoggedIn}');
print('Token: ${authProvider.token}');
print('Usuario: ${authProvider.user}');
print('Error: ${authProvider.error}');
```

### Ver en terminal

```bash
flutter run
# En terminal verás los print()
```

### DevTools

```bash
# Abrir DevTools en navegador
flutter pub global activate devtools
devtools

# En otra terminal:
flutter run --devtools-server-address=localhost:9100
```

---

**Próxima sección:** DOCUMENTACION_04_BACKEND.md
