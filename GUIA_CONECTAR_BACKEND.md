# 🔗 GUÍA: CONECTAR FRONTEND CON BACKEND

## ✅ ESTADO ACTUAL

✅ **Frontend:** Corriendo en http://localhost:54321  
⚠️ **Backend:** Necesita iniciarse en http://localhost:5000  
✅ **ApiService:** Ya existe en `lib/services/api_service.dart`  
✅ **Providers:** Auth y Subscription ya creados  

---

## 🚀 PASO 1: INICIAR BACKEND

### Terminal 1 - MongoDB

```bash
mongod
# Output esperado: waiting for connections on port 27017
```

### Terminal 2 - Backend Node.js

```bash
cd C:\Users\Carlos\Desktop\EvaStrong-Backend
npm run dev

# Output esperado:
# ✓ MongoDB conectado
# 🎉 Eva Strong Backend - Iniciado
# Servidor: http://localhost:5000
```

### Verificar que funciona

```bash
# Terminal 3 - Test
curl http://localhost:5000/health
# Output: {"status":"OK","timestamp":"2026-01-08T..."}
```

---

## 📝 PASO 2: CREAR PANTALLA DE LOGIN

### Crear archivo: `lib/screens/login_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;  // true = Login, false = Register
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Por favor completa todos los campos');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      
      if (_isLogin) {
        // LOGIN
        bool success = await authProvider.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
        
        if (success && mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (mounted) {
          setState(() => _error = authProvider.error ?? 'Error desconocido');
        }
      } else {
        // REGISTRO
        if (_nameController.text.isEmpty) {
          setState(() => _error = 'Por favor ingresa tu nombre');
          return;
        }
        
        bool success = await authProvider.register(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
        );
        
        if (success && mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (mounted) {
          setState(() => _error = authProvider.error ?? 'Error desconocido');
        }
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              
              // Logo/Título
              Icon(
                Icons.favorite,
                size: 80,
                color: scheme.primary,
              ),
              const SizedBox(height: 24),
              
              Text(
                'Eva Strong',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                _isLogin ? 'Inicia sesión' : 'Crea tu cuenta',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 32),
              
              // Nombre (solo en registro)
              if (!_isLogin)
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Tu nombre',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              if (!_isLogin) const SizedBox(height: 16),
              
              // Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              // Contraseña
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              
              // Error
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red[900]),
                  ),
                ),
              if (_error != null) const SizedBox(height: 16),
              
              // Botón principal
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          _isLogin ? 'INICIA SESIÓN' : 'CREAR CUENTA',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Cambiar entre login/registro
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _error = null;
                  });
                },
                child: Text(
                  _isLogin
                      ? '¿No tienes cuenta? Regístrate'
                      : '¿Ya tienes cuenta? Inicia sesión',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 🔐 PASO 3: INTEGRAR LOGIN EN main.dart

En `lib/main.dart`, importa y usa el `LoginScreen`:

```dart
import 'screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

// En build() método de EvaStrongApp:
@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Eva Strong',
    theme: _buildTheme(Brightness.light),
    darkTheme: _buildTheme(Brightness.dark),
    themeMode: ThemeMode.system,
    home: Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Si no está autenticado → mostrar LoginScreen
        if (!authProvider.isLoggedIn) {
          return const LoginScreen();
        }
        
        // Si está autenticado → mostrar HomeScreen
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
          ],
          child: const HomeScreen(title: 'Eva Strong'),
        );
      },
    ),
    routes: {
      '/home': (context) => const HomeScreen(title: 'Eva Strong'),
      '/login': (context) => const LoginScreen(),
    },
  );
}
```

---

## 💳 PASO 4: AGREGAR PANTALLA DE PAGOS

### Crear archivo: `lib/screens/payment_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../providers/subscription_provider.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  final String plan;  // 'basic' o 'premium'
  final String period; // 'monthly' o 'annual'

  const PaymentScreen({
    Key? key,
    required this.plan,
    required this.period,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  String? _error;

  Future<void> _procesarPago() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final subProvider = context.read<SubscriptionProvider>();
      
      Map<String, dynamic>? preference = 
          await subProvider.createPaymentPreference(
        plan: widget.plan,
        period: widget.period,
      );

      if (preference != null && mounted) {
        // Aquí irías a Mercado Pago
        // Por ahora mostramos un mock
        _showPaymentSuccess();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPaymentSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Pago Exitoso!'),
        content: Text(
          'Bienvenida al plan ${widget.plan.toUpperCase()}\nYa tienes acceso a todas las rutinas.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    final prices = {
      'basic': {'monthly': 499, 'annual': 4490},
      'premium': {'monthly': 999, 'annual': 8990},
    };
    
    final amount = prices[widget.plan]?[widget.period] ?? 0;
    final description = 'Plan ${widget.plan} ${widget.period}';

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Pago')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen de Pago',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Plan:'),
                        Text(
                          widget.plan.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Período:'),
                        Text(
                          widget.period == 'monthly' ? 'Mensual' : 'Anual',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '\$$amount ARS',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Error
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red[900]),
                  ),
                ),
              if (_error != null) const SizedBox(height: 16),
              
              // Botón pagar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _procesarPago,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'PROCEDER AL PAGO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 🏠 PASO 5: BOTÓN PARA ACCEDER A PAGOS

En `lib/main.dart`, modifica el botón "COMENZAR AHORA":

```dart
// Línea ~208 en _buildHomeTab():
onTap: () => Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const PaymentScreen(
      plan: 'premium',
      period: 'monthly',
    ),
  ),
),
```

---

## 🧪 PASO 6: PRUEBAS RÁPIDAS

### Test 1: Registro

```
Email: test@example.com
Nombre: Test User
Contraseña: password123

Esperado: ✓ Registro exitoso → Home
```

### Test 2: Login

```
Email: test@example.com
Contraseña: password123

Esperado: ✓ Login exitoso → Home
```

### Test 3: Pago

```
Presiona "COMENZAR AHORA"
→ PaymentScreen aparece
→ Presiona "PROCEDER AL PAGO"

Esperado: ✓ Diálogo "¡Pago Exitoso!"
```

---

## 🐛 ERRORES COMUNES

### "connection refused" al hacer login
**Problema:** Backend no está corriendo  
**Solución:**
```bash
cd C:\Users\Carlos\Desktop\EvaStrong-Backend
npm run dev
```

### "EvaluationException: Invalid argument"
**Problema:** URL incorrecta en `ApiService.baseUrl`  
**Solución:** Verifica que sea `http://localhost:5000`

### "Provider not found"
**Problema:** Olvidaste agregar `Provider` en el widget  
**Solución:** Usa `Consumer<AuthProvider>` o `context.read<AuthProvider>()`

---

## 📋 PASO 7: AGREGAR LOGOUT

En `lib/main.dart`, agregar botón de logout en HomeScreen:

```dart
// En el AppBar o en un menú:
IconButton(
  icon: const Icon(Icons.logout),
  onPressed: () async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  },
)
```

---

## 🎯 FLUJO COMPLETO

```
App inicia
    ↓
¿Está autenticado?
    ├─ No → LoginScreen (Registro/Login)
    │      ↓
    │   Login exitoso
    │      ↓
    └─ Sí → HomeScreen
            ├─ Tab: Inicio
            ├─ Tab: Rutinas (Coming soon)
            └─ Tab: Contacto (Coming soon)
                    ↓
                Botón "COMENZAR AHORA"
                    ↓
                PaymentScreen
                    ↓
                "PROCEDER AL PAGO"
                    ↓
                ✓ Pago exitoso
```

---

## 📚 RECURSOS

- **Api Service:** `lib/services/api_service.dart` (todos los endpoints)
- **Auth Provider:** `lib/providers/auth_provider.dart` (estado de auth)
- **Subscription Provider:** `lib/providers/subscription_provider.dart` (pagos)
- **Backend Docs:** `DOCUMENTACION_04_BACKEND.md`

---

**¿Necesitas ayuda con algo específico?** 🚀

- ¿Agregar más pantallas?
- ¿Conectar base de datos local?
- ¿Integrar notificaciones?
