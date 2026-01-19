# 🚀 GUÍA DE CARACTERÍSTICAS AVANZADAS - Eva Strong

## ✅ CARACTERÍSTICAS IMPLEMENTADAS

### 1️⃣ Deep Links - Redirecciones Post-Pago
### 2️⃣ Push Notifications - Notificaciones de Pagos
### 3️⃣ Receipt/Invoice - Descargar Comprobantes
### 4️⃣ Upgrade/Downgrade - Cambiar Planes
### 5️⃣ Referral System - Sistema de Referencias

---

## 📦 ARCHIVOS CREADOS

```
lib/services/
├── deep_link_service.dart              ✨ NUEVO
├── notification_service.dart            ✨ NUEVO
├── invoice_service.dart                 ✨ NUEVO
├── subscription_management_service.dart ✨ NUEVO
└── referral_service.dart                ✨ NUEVO
```

---

## 🔧 INSTALACIÓN DE DEPENDENCIAS

### Actualizar pubspec.yaml

```yaml
dependencies:
  # Dependencias existentes...
  
  # Deep Links
  uni_links: ^0.0.2
  
  # Push Notifications
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^14.1.0
  
  # Descargar PDF
  path_provider: ^2.1.0
  pdf: ^3.10.0
  printing: ^5.11.0
  
  # Otros
  http: ^1.1.0
  provider: ^6.0.0
```

### Ejecutar
```bash
flutter pub get
```

---

## 1️⃣ DEEP LINKS - REDIRECCIONES POST-PAGO

### ¿Qué son?
Los Deep Links permiten que cuando el usuario completa un pago en PayPal o Mercado Pago, se redirija automáticamente a tu app en una pantalla específica.

### Configuración Android

**archivo: android/app/src/main/AndroidManifest.xml**

```xml
<activity
    android:name=".MainActivity"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize">
    
    <!-- Tus intent-filter existentes... -->
    
    <!-- Deep Links para Eva Strong -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="evastrong" android:host="payment" />
    </intent-filter>
    
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="evastrong" android:host="referral" />
    </intent-filter>
</activity>
```

### Configuración iOS

**archivo: ios/Runner/Info.plist**

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>evastrong</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>evastrong</string>
        </array>
    </dict>
</array>
```

### Usar en main.dart

```dart
import 'services/deep_link_service.dart';

void main() {
  DeepLinkService().init();
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
    _deepLinkSubscription = DeepLinkService().onDeepLink.listen((deepLink) {
      _handleDeepLink(deepLink);
    });
  }

  void _handleDeepLink(String deepLink) {
    if (deepLink.startsWith('payment_success')) {
      // Navegar a pantalla de éxito de pago
      Navigator.pushNamed(context, '/payment-success');
    } else if (deepLink == 'payment_cancel') {
      // Mostrar mensaje de cancelación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pago cancelado')),
      );
    } else if (deepLink.startsWith('referral_code')) {
      // Aplicar código de referral
      final code = deepLink.split(':').last;
      _applyReferralCode(code);
    }
  }

  void _applyReferralCode(String code) {
    // Lógica para aplicar código
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
      home: const MyHomePage(),
      routes: {
        '/payment-success': (context) => const PaymentSuccessScreen(),
      },
    );
  }
}
```

---

## 2️⃣ PUSH NOTIFICATIONS

### Usar en tu app

```dart
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MyApp());
}
```

### Notificar pago exitoso

```dart
final notificationService = NotificationService();

// Cuando PayPal/Mercado Pago completa el pago
await notificationService.notifyPaymentSuccess(
  plan: 'premium',
  amount: '19.99',
  currency: 'USD',
);
```

### Notificar otras acciones

```dart
// Pago rechazado
await notificationService.notifyPaymentFailed(
  reason: 'Fondos insuficientes',
);

// Suscripción por vencer
await notificationService.notifySubscriptionExpiring(
  daysLeft: '3',
);

// Bono referral
await notificationService.notifyReferralBonus(
  amount: '10',
  currency: 'USD',
);
```

---

## 3️⃣ RECEIPT/INVOICE - DESCARGAR COMPROBANTES

### Usar en tu app

```dart
import 'services/invoice_service.dart';

final invoiceService = InvoiceService(jwtToken: jwtToken);

// Descargar PDF
final pdfFile = await invoiceService.downloadReceiptPDF(
  paymentId: 'payment_123',
);

// Mostrar PDF
if (pdfFile != null) {
  // Abrir con aplicación de PDF
  OpenFile.open(pdfFile.path);
}
```

### Obtener historial de recibos

```dart
final receipts = await invoiceService.getReceiptsHistory();

// Mostrar en UI
for (var receipt in receipts) {
  print('${receipt['plan']} - ${receipt['amount']} ${receipt['currency']}');
}
```

### Enviar recibo por email

```dart
await invoiceService.sendReceiptByEmail(
  paymentId: 'payment_123',
  email: 'usuario@example.com',
);
```

---

## 4️⃣ UPGRADE/DOWNGRADE - CAMBIAR PLANES

### Cambiar a otro plan

```dart
import 'services/subscription_management_service.dart';

final subService = SubscriptionManagementService(jwtToken: jwtToken);

// Cambiar a Premium
final result = await subService.changePlan(
  newPlan: 'premium',
  prorationStrategy: 'immediate', // Aplicar inmediatamente
);

// Resultado incluye:
// - Monto adicional a pagar (si upgrade)
// - Monto a reembolsar (si downgrade)
// - Fecha efectiva del cambio
```

### Cambiar período de facturación

```dart
// Cambiar de mensual a anual
await subService.changeBillingPeriod(
  newPeriod: 'annual',
);
```

### Pausar suscripción

```dart
// Pausar 30 días
await subService.pauseSubscription(
  daysToResume: 30,
);
```

### Reanudar suscripción

```dart
await subService.resumeSubscription();
```

---

## 5️⃣ REFERRAL SYSTEM - SISTEMA DE REFERENCIAS

### Obtener código referral propio

```dart
import 'services/referral_service.dart';

final referralService = ReferralService(jwtToken: jwtToken);

// Obtener mi código
final result = await referralService.getMyReferralCode();
final myCode = result['referralCode']; // ej: "EVA123ABC"

// Generar nuevo código
await referralService.generateNewReferralCode();
```

### Compartir código referral

```dart
import 'package:share_plus/share_plus.dart';

void shareReferralCode(String code) {
  Share.share(
    'Únete a Eva Strong con mi código: $code\n'
    'Obtén 20% de descuento en tu primer mes',
    subject: 'Te invito a Eva Strong',
  );
}
```

### Canjear código referral

```dart
// Usuario nuevo canjea código
await referralService.redeemReferralCode(
  referralCode: 'EVA123ABC',
);
```

### Obtener estadísticas

```dart
final stats = await referralService.getReferralStats();
print('Total referrals: ${stats['totalReferrals']}');
print('Convertidos: ${stats['convertedReferrals']}');
print('Bonificación total: ${stats['totalBonusEarned']}');
```

### Obtener lista de referrals

```dart
final myReferrals = await referralService.getMyReferrals();

for (var ref in myReferrals) {
  print('${ref['referredName']} - ${ref['isConverted'] ? 'Convertido' : 'Pendiente'}');
}
```

### Aplicar saldo de referral al pago

```dart
// Aplicar bono referral al siguiente pago
await referralService.applyReferralBalance(
  amountToApply: 10.00, // Usar $10 de bonus
);
```

---

## 📱 PANTALLA DE PERFIL MEJORADA

### Ejemplo de UI con todas las características

```dart
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: ListView(
        children: [
          // Suscripción actual
          ListTile(
            title: const Text('Suscripción'),
            subtitle: const Text('Plan Premium'),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
            onTap: () => _showSubscriptionOptions(),
          ),

          // Cambiar plan
          ListTile(
            title: const Text('Cambiar Plan'),
            leading: const Icon(Icons.upgrade),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PlansScreen()),
            ),
          ),

          // Mi referral
          ListTile(
            title: const Text('Mi Código Referral'),
            leading: const Icon(Icons.share),
            onTap: () => _showReferralCode(),
          ),

          // Mis referrals
          ListTile(
            title: const Text('Mis Referrals'),
            leading: const Icon(Icons.people),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyReferralsScreen()),
            ),
          ),

          // Recibos
          ListTile(
            title: const Text('Mis Recibos'),
            leading: const Icon(Icons.receipt),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReceiptsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Cambiar Plan'),
            onTap: () {
              Navigator.pop(context);
              // Navegar a cambiar plan
            },
          ),
          ListTile(
            title: const Text('Pausar Suscripción'),
            onTap: () {
              Navigator.pop(context);
              // Pausar
            },
          ),
          ListTile(
            title: const Text('Cancelar Suscripción'),
            textColor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              // Cancelar
            },
          ),
        ],
      ),
    );
  }

  void _showReferralCode() {
    // Mostrar código y botón de compartir
  }
}
```

---

## 🔗 CONFIGURAR PAYPAL Y MERCADO PAGO

### PayPal - URLs de retorno

En tu backend (routes/payments.js), actualiza:

```javascript
const PAYPAL_RETURN_URL = process.env.PAYPAL_RETURN_URL || 'evastrong://payment/success';
const PAYPAL_CANCEL_URL = process.env.PAYPAL_CANCEL_URL || 'evastrong://payment/cancel';
```

### Mercado Pago - Redirecciones

En preferenceData:

```javascript
back_urls: {
  success: 'evastrong://payment/success',
  pending: 'evastrong://payment/pending',
  failure: 'evastrong://payment/cancel',
},
```

---

## 📧 WEBHOOKS IMPORTANTES

### Backend debe soportar:

1. **Notificación de pago completado** → Enviar push notification
2. **Notificación de referral convertido** → Enviar bono
3. **Notificación de suscripción por vencer** → Avisar al usuario

---

## 🧪 TESTING

```bash
# Terminal 1: Backend
cd C:\Users\Carlos\Desktop\EvaStrong-Backend
npm run dev

# Terminal 2: Frontend
cd C:\Users\Carlos\Desktop\EvaStrong
flutter run
```

### Probar Deep Links

```bash
# En otra terminal
adb shell am start -W -a android.intent.action.VIEW \
  -d "evastrong://payment/success?orderId=123" \
  com.example.evastrong
```

### Probar Push Notifications

- Enviar mensaje desde Firebase Console
- O usar Postman para enviar a FCM endpoint

### Probar Referral

- Generar código: `EVA123ABC`
- Compartir con otro usuario
- Que lo canjee en signup

---

## 📊 RESUMEN

| Característica | Archivo | Estado |
|---|---|---|
| Deep Links | deep_link_service.dart | ✅ |
| Push Notifications | notification_service.dart | ✅ |
| Recibos/Invoices | invoice_service.dart | ✅ |
| Upgrade/Downgrade | subscription_management_service.dart | ✅ |
| Referral System | referral_service.dart | ✅ |

---

## 🎯 PRÓXIMOS PASOS

1. ✅ Actualizar pubspec.yaml
2. ✅ flutter pub get
3. ✅ Configurar deep links en Android/iOS
4. ✅ Inicializar servicios en main.dart
5. ✅ Crear pantallas de UI para cada feature
6. ✅ Testear en device físico

---

## 💡 TIPS

**Tip 1:** Guarda FCM token en backend para enviar push desde allá
**Tip 2:** Usa deep links para mejorar UX post-pago
**Tip 3:** Sistema referral es un potente growth strategy
**Tip 4:** Permite pausar/reanudar suscripción (retención)
**Tip 5:** Recibos PDF aumentan confianza del usuario

