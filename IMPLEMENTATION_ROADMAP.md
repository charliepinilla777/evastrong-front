# 🗺️ ROADMAP DE IMPLEMENTACIÓN - 2-3 HORAS

## ⏱️ TIMELINE ESTIMADO

| Fase | Tareas | Tiempo |
|------|--------|--------|
| Fase 1 | Setup y Dependencias | 15 min |
| Fase 2 | Deep Links | 30 min |
| Fase 3 | Push Notifications | 30 min |
| Fase 4 | Invoices/Recibos | 20 min |
| Fase 5 | Upgrade/Downgrade | 20 min |
| Fase 6 | Referral System | 20 min |
| Fase 7 | UI Screens | 40 min |
| Fase 8 | Testing & QA | 30 min |

**TOTAL: ~3 horas**

---

## 🚀 FASE 1: SETUP (15 min)

### Step 1.1: Actualizar pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_svg: ^2.2.3
  http: ^1.1.0
  provider: ^6.0.0
  url_launcher: ^6.2.0

  # ✨ NUEVAS DEPENDENCIAS
  uni_links: ^0.0.2
  firebase_messaging: ^14.7.0
  firebase_core: ^2.24.0
  flutter_local_notifications: ^14.1.0
  path_provider: ^2.1.0
  pdf: ^3.10.0
  printing: ^5.11.0
  share_plus: ^6.0.0
  open_file: ^3.5.0
```

### Step 1.2: Ejecutar pub get
```bash
cd C:\Users\Carlos\Desktop\EvaStrong
flutter pub get
```

### Step 1.3: Crear carpeta de servicios
```bash
# Los servicios ya están creados, solo verifica que existan:
lib/services/
├── payment_service.dart (✅ EXISTE)
├── deep_link_service.dart (✅ NUEVO)
├── notification_service.dart (✅ NUEVO)
├── invoice_service.dart (✅ NUEVO)
├── subscription_management_service.dart (✅ NUEVO)
└── referral_service.dart (✅ NUEVO)
```

---

## 🔗 FASE 2: DEEP LINKS (30 min)

### Step 2.1: Configurar Android (10 min)

**Archivo: android/app/src/main/AndroidManifest.xml**

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.evastrong">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

    <application
        android:label="Eva Strong"
        android:icon="@mipmap/ic_launcher">
        
        <activity
            android:name=".MainActivity"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>

            <!-- Deep Links para Pagos -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="evastrong" android:host="payment" />
            </intent-filter>

            <!-- Deep Links para Referrals -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="evastrong" android:host="referral" />
            </intent-filter>

        </activity>

        <!-- ... resto de configuración -->
    </application>
</manifest>
```

### Step 2.2: Configurar iOS (10 min)

**Archivo: ios/Runner/Info.plist**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ... configuración existente ... -->

    <!-- Deep Links para Eva Strong -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>com.evastrong</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>evastrong</string>
            </array>
        </dict>
    </array>

    <!-- ... resto de configuración ... -->
</dict>
</plist>
```

### Step 2.3: Inicializar en main.dart (10 min)

```dart
import 'package:flutter/material.dart';
import 'services/deep_link_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Deep Links
  DeepLinkService().init();
  
  // Inicializar Notificaciones
  await NotificationService().init();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    
    // Escuchar deep links
    _deepLinkSubscription = DeepLinkService().onDeepLink.listen(
      (deepLink) => _handleDeepLink(deepLink),
    );
  }

  void _handleDeepLink(String deepLink) {
    if (deepLink.startsWith('payment_success')) {
      // Navegar a pantalla de éxito
      Navigator.pushNamed(context, '/payment-success');
      
      // Mostrar notificación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Pago exitoso! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (deepLink == 'payment_cancel') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pago cancelado')),
      );
    } else if (deepLink.startsWith('referral_code')) {
      final code = deepLink.split(':').last;
      _applyReferralCode(code);
    }
  }

  void _applyReferralCode(String code) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Código referral aplicado: $code')),
    );
  }

  @override
  void dispose() {
    _deepLinkSubscription.cancel();
    DeepLinkService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eva Strong',
      theme: ThemeData(primarySwatch: Colors.purple, useMaterial3: true),
      home: const MyHomePage(),
      routes: {
        '/payment-success': (context) => const PaymentSuccessScreen(),
        '/payments': (context) => PaymentsScreen(
          jwtToken: 'token_aqui',
        ),
      },
    );
  }
}

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago Exitoso')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green.shade600),
            const SizedBox(height: 20),
            const Text(
              'Tu suscripción está activa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔔 FASE 3: PUSH NOTIFICATIONS (30 min)

### Step 3.1: Configurar Firebase Android (10 min)

1. Ve a https://firebase.google.com
2. Crea un proyecto o usa uno existente
3. Agrega Android como plataforma
4. Descarga `google-services.json`
5. Colócalo en: `android/app/google-services.json`

**Archivo: android/build.gradle**
```gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
  }
}
```

**Archivo: android/app/build.gradle**
```gradle
apply plugin: 'com.android.application'
apply plugin: 'com.google.gms.google-services'

dependencies {
  implementation 'com.google.firebase:firebase-messaging-ktx'
}
```

### Step 3.2: Configurar Firebase iOS (10 min)

1. Ve a Firebase Console
2. Agrega iOS como plataforma
3. Descarga configuración
4. Abre `ios/Runner.xcworkspace` en Xcode
5. Agrega GoogleService-Info.plist

### Step 3.3: Usar en tu app (10 min)

```dart
import 'services/notification_service.dart';

// En main.dart ya está inicializado

// Enviar notificación de pago exitoso
final notificationService = NotificationService();

await notificationService.notifyPaymentSuccess(
  plan: 'premium',
  amount: '19.99',
  currency: 'USD',
);

// Obtener FCM token para guardar en backend
final fcmToken = await notificationService.getFCMToken();
print('FCM Token: $fcmToken');

// Suscribirse a topics
await notificationService.subscribeToPaymentNotifications();
await notificationService.subscribeToReferralNotifications();
```

---

## 📄 FASE 4: INVOICES/RECIBOS (20 min)

### Step 4.1: Usar InvoiceService

```dart
import 'services/invoice_service.dart';

class ReceiptsScreen extends StatefulWidget {
  final String jwtToken;

  const ReceiptsScreen({Key? key, required this.jwtToken}) : super(key: key);

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  late InvoiceService _invoiceService;
  List<Map<String, dynamic>> _receipts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _invoiceService = InvoiceService(jwtToken: widget.jwtToken);
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    try {
      final receipts = await _invoiceService.getReceiptsHistory();
      setState(() {
        _receipts = receipts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _downloadReceipt(String paymentId) async {
    try {
      final file = await _invoiceService.downloadReceiptPDF(paymentId: paymentId);
      if (file != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Descargado: ${file.path}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Recibos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _receipts.length,
              itemBuilder: (context, index) {
                final receipt = _receipts[index];
                return ListTile(
                  title: Text('${receipt['plan'].toUpperCase()} - ${receipt['amount']} ${receipt['currency']}'),
                  subtitle: Text(receipt['createdAt'] ?? 'N/A'),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _downloadReceipt(receipt['_id']),
                  ),
                );
              },
            ),
    );
  }
}
```

---

## 📊 FASE 5: UPGRADE/DOWNGRADE (20 min)

### Step 5.1: Pantalla de Cambio de Plan

```dart
import 'services/subscription_management_service.dart';

class ChangeplanScreen extends StatefulWidget {
  final String jwtToken;
  final String currentPlan;

  const ChangePlanScreen({
    Key? key,
    required this.jwtToken,
    required this.currentPlan,
  }) : super(key: key);

  @override
  State<ChangePlanScreen> createState() => _ChangePlanScreenState();
}

class _ChangePlanScreenState extends State<ChangePlanScreen> {
  late SubscriptionManagementService _subService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subService = SubscriptionManagementService(jwtToken: widget.jwtToken);
  }

  Future<void> _changePlan(String newPlan) async {
    setState(() => _isLoading = true);
    try {
      final result = await _subService.changePlan(
        newPlan: newPlan,
        prorationStrategy: 'immediate',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan actualizado')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Plan Actual:'),
            Chip(label: Text(widget.currentPlan.toUpperCase())),
            const SizedBox(height: 40),
            const Text('Cambiar a:'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _changePlan('basic'),
              child: const Text('Plan Basic'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _changePlan('premium'),
              child: const Text('Plan Premium'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🎁 FASE 6: REFERRAL SYSTEM (20 min)

### Step 6.1: Pantalla de Referrals

```dart
import 'services/referral_service.dart';
import 'package:share_plus/share_plus.dart';

class ReferralScreen extends StatefulWidget {
  final String jwtToken;

  const ReferralScreen({Key? key, required this.jwtToken}) : super(key: key);

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  late ReferralService _referralService;
  String? _myCode;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _referralService = ReferralService(jwtToken: widget.jwtToken);
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    try {
      final code = await _referralService.getMyReferralCode();
      final stats = await _referralService.getReferralStats();
      
      setState(() {
        _myCode = code['referralCode'];
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _shareCode() {
    Share.share(
      'Únete a Eva Strong con mi código: $_myCode\n'
      'Obtén 20% de descuento en tu primer mes\n'
      'Descarga aquí: [link a tu app]',
      subject: 'Te invito a Eva Strong',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Programa de Referrals')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Mi código
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('Mi Código Referral'),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _myCode ?? 'Cargando...',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _shareCode,
                              child: const Text('Compartir'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Estadísticas
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('Mis Estadísticas'),
                            const SizedBox(height: 16),
                            ListTile(
                              title: const Text('Total Referrals'),
                              trailing: Text(
                                '${_stats?['totalReferrals'] ?? 0}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ListTile(
                              title: const Text('Convertidos'),
                              trailing: Text(
                                '${_stats?['convertedReferrals'] ?? 0}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ListTile(
                              title: const Text('Bonificación Total'),
                              trailing: Text(
                                '${_stats?['totalBonusEarned'] ?? 0} ${_stats?['bonusCurrency'] ?? 'USD'}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
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

## 🎨 FASE 7: UI SCREENS (40 min)

### Step 7.1: Actualizar ProfileScreen

```dart
class ProfileScreen extends StatelessWidget {
  final String jwtToken;

  const ProfileScreen({Key? key, required this.jwtToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: ListView(
        children: [
          // Suscripción
          ListTile(
            title: const Text('Mi Suscripción'),
            leading: const Icon(Icons.check_circle, color: Colors.green),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangePlanScreen(
                  jwtToken: jwtToken,
                  currentPlan: 'premium',
                ),
              ),
            ),
          ),

          // Cambiar Plan
          ListTile(
            title: const Text('Cambiar Plan'),
            leading: const Icon(Icons.upgrade),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangePlanScreen(
                  jwtToken: jwtToken,
                  currentPlan: 'premium',
                ),
              ),
            ),
          ),

          // Referrals
          ListTile(
            title: const Text('Mi Programa Referral'),
            leading: const Icon(Icons.share),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReferralScreen(jwtToken: jwtToken),
              ),
            ),
          ),

          // Recibos
          ListTile(
            title: const Text('Mis Recibos'),
            leading: const Icon(Icons.receipt),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReceiptsScreen(jwtToken: jwtToken),
              ),
            ),
          ),

          // Configuración
          ListTile(
            title: const Text('Configuración'),
            leading: const Icon(Icons.settings),
            onTap: () {},
          ),

          // Cerrar sesión
          ListTile(
            title: const Text('Cerrar Sesión'),
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
```

---

## 🧪 FASE 8: TESTING (30 min)

### Step 8.1: Testing Deep Links

```bash
# Terminal 1: Backend
cd C:\Users\Carlos\Desktop\EvaStrong-Backend
npm run dev

# Terminal 2: Frontend
cd C:\Users\Carlos\Desktop\EvaStrong
flutter run

# Terminal 3: Test deep link
adb shell am start -W -a android.intent.action.VIEW \
  -d "evastrong://payment/success?orderId=123" \
  com.example.evastrong
```

### Step 8.2: Testing Notificaciones

Usar Firebase Console para enviar mensaje de prueba

### Step 8.3: Testing Completo

1. ✅ Crear usuario
2. ✅ Hacer pago (sandbox)
3. ✅ Verificar Deep Link redirige
4. ✅ Verificar notificación push
5. ✅ Descargar recibo
6. ✅ Cambiar plan
7. ✅ Compartir código referral

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

### Fase 1
- [ ] pubspec.yaml actualizado
- [ ] flutter pub get ejecutado

### Fase 2
- [ ] AndroidManifest.xml configurado
- [ ] Info.plist configurado
- [ ] Deep Links inicializados en main.dart

### Fase 3
- [ ] Firebase configurado en Android
- [ ] Firebase configurado en iOS
- [ ] NotificationService inicializado

### Fase 4
- [ ] ReceiptsScreen creada
- [ ] Descargas de PDF funcionando

### Fase 5
- [ ] ChangePlanScreen creada
- [ ] Cambio de plan funcionando

### Fase 6
- [ ] ReferralScreen creada
- [ ] Compartir código funcionando

### Fase 7
- [ ] ProfileScreen actualizado
- [ ] Todas las pantallas accesibles

### Fase 8
- [ ] Deep Links testeados
- [ ] Push Notifications testeadas
- [ ] Todo funcionando correctamente

---

## 📞 RESUMEN DE ARCHIVOS MODIFICADOS

| Archivo | Cambios |
|---------|---------|
| pubspec.yaml | Agregar 8 nuevas dependencias |
| android/app/src/main/AndroidManifest.xml | Agregar intent-filters |
| ios/Runner/Info.plist | Agregar CFBundleURLTypes |
| lib/main.dart | Inicializar servicios |
| lib/screens/profile_screen.dart | Agregar menú de opciones |
| lib/screens/receipts_screen.dart | NUEVO |
| lib/screens/change_plan_screen.dart | NUEVO |
| lib/screens/referral_screen.dart | NUEVO |

---

## 🎯 DESPUÉS DE IMPLEMENTAR

1. **Deploy a TestFlight** (iOS) o **Google Play Beta** (Android)
2. **Testear en device real**
3. **Recopilar feedback**
4. **Hacer ajustes**
5. **Deploy a producción**

---

## 💡 TIPS IMPORTANTES

1. **Guarda FCM token en backend** para enviar notificaciones dirigidas
2. **Usa deep links para mejorar UX** post-pago
3. **Sistema referral es growth strategy poderosa**
4. **Permite pausar/reanudar** para retención
5. **Recibos PDF aumentan confianza** del usuario

