# 💳 Integración de Pagos en Flutter - Eva Strong

## 📋 ARCHIVOS CREADOS

| Archivo | Descripción |
|---------|-------------|
| `lib/services/payment_service.dart` | Servicio para comunicarse con el backend |
| `lib/providers/payment_provider.dart` | Provider para manejar el estado de pagos |
| `lib/widgets/pricing_cards.dart` | Widget reutilizable para tarjetas de precio |
| `lib/screens/payments_screen.dart` | Pantalla completa de planes de suscripción |

---

## 🚀 INSTALACIÓN RÁPIDA

### Paso 1: Actualizar dependencias
```bash
cd C:\Users\Carlos\Desktop\EvaStrong
flutter pub get
```

### Paso 2: Actualizar main.dart
En `lib/main.dart`, agrega los providers:

```dart
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/payment_provider.dart';
import 'screens/payments_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: MaterialApp(
        title: 'Eva Strong',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          useMaterial3: true,
        ),
        home: const MyHomePage(),
        routes: {
          '/payments': (context) => PaymentsScreen(
            jwtToken: context.read<AuthProvider>().token ?? '',
          ),
        },
      ),
    );
  }
}
```

### Paso 3: Actualizar base URL

En `lib/services/payment_service.dart`, cambia la base URL según tu entorno:

**Para desarrollo local:**
```dart
static const String baseUrl = 'http://localhost:5000/payments';
```

**Para Render (producción):**
```dart
static const String baseUrl = 'https://tu-servicio.onrender.com/payments';
```

---

## 🎨 CÓMO USAR LOS COMPONENTES

### Usar PaymentsScreen en tu app

**Opción 1: Como nueva ruta**
```dart
// En main.dart
routes: {
  '/payments': (context) => PaymentsScreen(
    jwtToken: context.read<AuthProvider>().token ?? '',
  ),
}

// Para navegar
Navigator.pushNamed(context, '/payments');
```

**Opción 2: Como widget dentro de otra pantalla**
```dart
import 'screens/payments_screen.dart';

// En tu pantalla
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Mi App')),
    body: PaymentsScreen(
      jwtToken: context.read<AuthProvider>().token ?? '',
    ),
  );
}
```

### Usar PricingCard individual
```dart
import 'widgets/pricing_cards.dart';

PricingCard(
  plan: 'premium',
  title: 'Plan Premium',
  price: '19.99',
  currency: 'USD',
  period: 'mes',
  features: [
    'Acceso ilimitado',
    'Soporte prioritario',
    'Contenido exclusivo',
  ],
  onPayPalPressed: () {
    // Lógica para PayPal
  },
  onMercadoPagoPressed: () {
    // Lógica para Mercado Pago
  },
)
```

---

## 📱 FLUJO COMPLETO

### 1. Usuario ve los planes
```
PaymentsScreen muestra:
- Selector de moneda (COP/USD)
- Selector de período (Mensual/Anual)
- 2 tarjetas: Plan Basic y Plan Premium
- Botones: PayPal, Mercado Pago
```

### 2. Usuario hace clic en "Pagar con PayPal"
```
- Se llama a PaymentProvider.createPayPalOrder()
- Se abre PayPal en navegador externo
- Usuario completa el pago
- PayPal redirige a tu app (si está configurado)
```

### 3. Usuario hace clic en "Pagar con Mercado Pago"
```
- Se llama a PaymentProvider.createMercadoPagoPreference()
- Se abre Mercado Pago en navegador externo
- Usuario completa el pago
- Mercado Pago redirige a tu app (si está configurado)
```

### 4. Suscripción se activa
```
- Backend recibe webhook
- Crea suscripción en MongoDB
- Actualiza estado del usuario
- App muestra "Suscripción Activa"
```

---

## 🔧 PERSONALIZACIÓN

### Cambiar precios
En `lib/screens/payments_screen.dart`, busca `_buildPricingCards()`:

```dart
// Cambiar precios en COP
price: selectedCurrency == 'COP'
    ? (selectedPeriod == 'monthly' ? '39.900' : '399.900')  // Cambia estos
    : (selectedPeriod == 'monthly' ? '9.99' : '99.99'),
```

### Cambiar características
En `lib/screens/payments_screen.dart`, busca `features:`:

```dart
features: [
  'Acceso a 50+ entrenamientos',  // Personaliza
  'Seguimiento de progreso',
  'Comunidad exclusiva',
  'Soporte por email',
],
```

### Cambiar colores
En `lib/widgets/pricing_cards.dart`:

```dart
// PayPal (azul)
backgroundColor: const Color(0xFF0070BA),

// Mercado Pago (azul claro)
backgroundColor: const Color(0xFF009EE3),
```

---

## 🧪 TESTING

### Test en Simulator/Emulator

1. **Inicia el servidor backend:**
```bash
cd C:\Users\Carlos\Desktop\EvaStrong-Backend
npm run dev
```

2. **En otra terminal, corre la app Flutter:**
```bash
flutter run
```

3. **Navega a PaymentsScreen**

4. **Haz clic en "Pagar con Mercado Pago COP"**

5. **Verifica en terminal backend:**
```
✅ Preferencia Mercado Pago creada: Plan basic, Período monthly, Monto: 39900 COP
```

### Test en dispositivo físico

Si quieres testear en tu Android/iPhone:

1. Conecta el dispositivo
2. Cambia baseUrl a tu IP local:
```dart
static const String baseUrl = 'http://192.168.1.X:5000/payments';
// Reemplaza X con tu IP
```

3. Corre: `flutter run -d <device-id>`

---

## 📝 VARIABLES DE ENTORNO (Opcional)

Si quieres usar `.env` en Flutter:

1. **Agregar dependencia:**
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

2. **Crear archivo `.env`:**
```
BACKEND_URL=http://localhost:5000
MERCADO_PAGO_PUBLIC_KEY=tu_key
```

3. **En `main.dart`:**
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}
```

4. **Usar en `payment_service.dart`:**
```dart
static String get baseUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000/payments';
```

---

## 🔐 CONSIDERACIONES DE SEGURIDAD

### ✅ Lo que está bien hecho
- JWT token se pasa solo cuando es necesario
- No se exponen credenciales de PayPal/Mercado Pago en Flutter
- URLs de callback no están hardcodeadas

### ⚠️ Mejoras para Producción
1. Usar HTTPS en lugar de HTTP
2. Validar JWT token en el cliente
3. Usar certificados SSL válidos
4. Implementar retry logic para fallos de conexión
5. Usar deeplinks para redirecciones post-pago

---

## 🚨 ERRORES COMUNES

### Error: "Failed to resolve: provider"
```
Solución: flutter pub get
```

### Error: "url_launcher not found"
```
Solución: flutter pub get
```

### Error: "Connection refused"
```
Causa: Backend no está corriendo
Solución: npm run dev en backend
```

### PayPal/Mercado Pago no abre
```
Causa: URL_LAUNCHER no está configurado correctamente
Solución: flutter pub add url_launcher
```

### Pago completa pero suscripción no aparece
```
Causa: Webhook no configurado
Solución: Verificar que el webhook llegue al backend
```

---

## 📊 ÁRBOL DE COMPONENTES

```
PaymentsScreen (Pantalla principal)
├── Dropdown: Selector de Moneda
├── Dropdown: Selector de Período
├── PricingCard: Plan Basic
│   ├── Botón PayPal
│   └── Botón Mercado Pago
├── PricingCard: Plan Premium (Popular)
│   ├── Botón PayPal
│   └── Botón Mercado Pago
└── Tarjeta de Suscripción Actual
    └── Botón Cancelar (si hay suscripción)
```

---

## 🎯 PRÓXIMOS PASOS

1. ✅ Archivos creados
2. ⏳ Ejecutar `flutter pub get`
3. ⏳ Actualizar `main.dart` con providers
4. ⏳ Cambiar base URL según tu entorno
5. ⏳ Prueba en simulator
6. ⏳ Probar pagos sandbox
7. ⏳ Deploy a producción

---

## 📞 REFERENCIA RÁPIDA

| Acción | Archivo | Método |
|--------|---------|--------|
| Crear orden PayPal | payment_provider.dart | `createPayPalOrder()` |
| Crear preferencia Mercado Pago | payment_provider.dart | `createMercadoPagoPreference()` |
| Obtener suscripción | payment_provider.dart | `fetchSubscription()` |
| Cancelar suscripción | payment_provider.dart | `cancelSubscription()` |
| Mostrar UI de precios | payments_screen.dart | `build()` |
| Tarjeta individual | pricing_cards.dart | `PricingCard()` |

---

## 💡 TIPS

**Tip 1:** Guarda el JWT token en SharedPreferences para no perderlo
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('jwt_token', token);
```

**Tip 2:** Usa Provider DevTools para debuggear
```dart
// En main.dart
navigatorObservers: [Provider.debugProvidersObserver],
```

**Tip 3:** Implementa deep links para cuando PayPal/Mercado Pago redirige
```dart
// Android: AndroidManifest.xml
// iOS: Info.plist
```

