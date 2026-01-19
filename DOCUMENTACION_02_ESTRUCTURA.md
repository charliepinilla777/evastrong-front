# 📂 EVA STRONG - ESTRUCTURA DEL PROYECTO

## 🗂️ ESTRUCTURA GENERAL

```
C:\Users\Carlos\Desktop\
│
├── EvaStrong/                          ← FRONTEND (Flutter)
│   ├── lib/
│   │   ├── main.dart                   ← Punto de entrada de la app
│   │   ├── services/
│   │   │   └── api_service.dart        ← Cliente HTTP para backend
│   │   ├── providers/
│   │   │   ├── auth_provider.dart      ← State management de autenticación
│   │   │   └── subscription_provider.dart ← State management de suscripciones
│   │   └── ...
│   ├── android/                        ← Configuración Android
│   ├── ios/                            ← Configuración iOS
│   ├── web/                            ← Configuración Web
│   ├── windows/                        ← Configuración Windows
│   ├── macos/                          ← Configuración macOS
│   ├── linux/                          ← Configuración Linux
│   ├── pubspec.yaml                    ← Dependencias Flutter
│   ├── pubspec.lock                    ← Versiones bloqueadas
│   ├── build/                          ← Archivos compilados
│   ├── PROYECTO_RESUMEN.md             ← Resumen del proyecto
│   └── DOCUMENTACION_*.md              ← Documentación
│
└── EvaStrong-Backend/                  ← BACKEND (Node.js)
    ├── server.js                       ← Servidor principal
    ├── config/
    │   └── passport.js                 ← Configuración de OAuth
    ├── models/
    │   ├── User.js                     ← Esquema de usuario
    │   ├── Payment.js                  ← Esquema de pagos
    │   └── Subscription.js             ← Esquema de suscripciones
    ├── routes/
    │   ├── auth.js                     ← Endpoints de autenticación
    │   ├── users.js                    ← Endpoints de usuarios
    │   ├── payments.js                 ← Endpoints de pagos
    │   └── subscriptions.js            ← Endpoints de suscripciones
    ├── middleware/
    │   └── auth.js                     ← Verificación de autenticación
    ├── package.json                    ← Dependencias Node.js
    ├── package-lock.json               ← Versiones bloqueadas
    ├── .env                            ← Variables de ambiente
    ├── .env.example                    ← Template de variables
    ├── .gitignore                      ← Archivos a ignorar en git
    ├── README.md                       ← Documentación del backend
    └── SETUP_COMPLETO.md               ← Guía de setup
```

---

## 📄 FRONTEND - CARPETAS Y ARCHIVOS

### `/lib/main.dart`
**¿Qué es?**
- Punto de entrada principal de la aplicación Flutter
- Define la estructura base de la app
- Configura temas (Material 3)
- Establece las rutas principales

**Componentes principales:**
```dart
- EvaStrongApp
  └─ ThemeData (Material 3)
     ├─ ColorScheme (púrpura + lila)
     └─ AppBarTheme
- HomeScreen
  ├─ TabBar (3 pestañas)
  ├─ Tab 1: Inicio (bienvenida)
  ├─ Tab 2: Rutinas (Coming soon)
  └─ Tab 3: Contacto (Coming soon)
```

**Responsabilidades:**
- Crear MaterialApp
- Definir tema visual
- Renderizar pantalla principal
- Manejar navegación entre tabs

---

### `/lib/services/api_service.dart`
**¿Qué es?**
- Cliente HTTP que comunica con el backend
- Centraliza todas las llamadas API
- Maneja tokens JWT
- Gestiona headers

**Métodos principales:**
```
AUTENTICACIÓN
├── register()              → POST /auth/register
├── login()                 → POST /auth/login
├── verifyToken()           → GET /auth/verify
├── refreshToken()          → POST /auth/refresh
└── logout()                → POST /auth/logout

USUARIOS
├── getProfile()            → GET /users/profile
├── updateProfile()         → PUT /users/profile
└── changePassword()        → POST /users/change-password

PAGOS
├── createPaymentPreference() → POST /payments/create-preference
├── getPaymentHistory()     → GET /payments/history
└── refundPayment()         → POST /payments/:paymentId/refund

SUSCRIPCIONES
├── getCurrentSubscription() → GET /subscriptions/current
├── changePlan()            → POST /subscriptions/change-plan
├── cancelSubscription()    → POST /subscriptions/cancel
└── renewSubscription()     → POST /subscriptions/renew
```

**Ejemplo de uso:**
```dart
// En un Provider o Widget
final result = await ApiService.login(
  email: 'usuario@example.com',
  password: 'contraseña123',
);

// ApiService establece automáticamente el token
if (result['success']) {
  print('Login exitoso: ${result['token']}');
}
```

---

### `/lib/providers/auth_provider.dart`
**¿Qué es?**
- Gestor de estado para autenticación
- Mantiene tokens, usuario, estado de carga
- Notifica a widgets cuando cambia el estado
- Patrón: Provider + ChangeNotifier

**Variables internas:**
```dart
_isLoggedIn    → bool (¿usuario autenticado?)
_token         → String (JWT token)
_user          → Map (datos del usuario)
_isLoading     → bool (¿está cargando?)
_error         → String (último error)
```

**Métodos principales:**
```dart
// Autenticación
register()     → Registrar nuevo usuario
login()        → Iniciar sesión
logout()       → Cerrar sesión

// Perfil
getProfile()   → Obtener datos del usuario
updateProfile()→ Actualizar perfil
changePassword()→ Cambiar contraseña

// Token
verifyToken()  → Verificar si token es válido
refreshToken() → Renovar token expirado

// Gestión
setUserAndToken() → Establecer usuario (para OAuth)
clearError()      → Limpiar mensaje de error
```

**Ejemplo de uso en Widget:**
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    if (authProvider.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (authProvider.isLoggedIn) {
      return Text('Bienvenido: ${authProvider.user['name']}');
    }
    
    return Text('No autenticado');
  },
);
```

---

### `/lib/providers/subscription_provider.dart`
**¿Qué es?**
- Gestor de estado para suscripciones y pagos
- Mantiene info de plan actual y historial
- Maneja cambios de plan
- Patrón: Provider + ChangeNotifier

**Variables internas:**
```dart
_subscription       → Map (suscripción actual)
_paymentHistory    → List (historial de pagos)
_isLoading         → bool (¿está cargando?)
_error             → String (último error)
```

**Métodos principales:**
```dart
// Suscripción
getCurrentSubscription()  → Obtener suscripción activa
changePlan()             → Cambiar a otro plan
cancelSubscription()     → Cancelar suscripción
renewSubscription()      → Renovar suscripción

// Pagos
createPaymentPreference()→ Crear pago en Mercado Pago
getPaymentHistory()      → Obtener historial
refundPayment()          → Reembolsar un pago
```

**Getters útiles:**
```dart
isPremium  → bool (¿usuario es premium?)
isActive   → bool (¿suscripción activa?)
```

---

## 🔙 BACKEND - CARPETAS Y ARCHIVOS

### `/server.js`
**¿Qué es?**
- Archivo principal del servidor
- Inicializa Express
- Conecta a MongoDB
- Configura middlewares
- Define rutas principales

**Lo que hace:**
```javascript
1. Cargar variables de ambiente (.env)
2. Crear app Express
3. Configurar seguridad (Helmet, CORS)
4. Configurar límite de requests
5. Conectar a MongoDB
6. Inicializar Passport.js
7. Registrar rutas
8. Manejo de errores
9. Iniciar servidor en puerto 5000
```

**Middlewares aplicados:**
```
┌─ Helmet              → Headers de seguridad
├─ CORS                → Acceso desde frontend
├─ Rate Limiter        → Max 100 requests/15min
├─ Body Parser         → Parsear JSON
├─ Session             → Sesiones de usuario
├─ Passport            → Autenticación OAuth
└─ Error Handler       → Capturar errores
```

---

### `/config/passport.js`
**¿Qué es?**
- Configura estrategias de autenticación
- Implementa Google OAuth
- Implementa Apple OAuth
- Serializa/deserializa usuarios

**Estrategias:**
```javascript
GoogleStrategy
├─ clientID        → ID de Google Cloud
├─ clientSecret    → Secret de Google
├─ callbackURL     → localhost:5000/auth/google/callback
└─ perfil → Usuario

AppleStrategy
├─ clientID        → ID de Apple
├─ teamID          → Team ID de Apple
├─ keyID           → Key ID de Apple
└─ perfil → Usuario
```

---

### `/models/User.js`
**¿Qué es?**
- Define la estructura de datos de usuario en MongoDB
- Valida y procesa datos
- Tiene métodos útiles

**Campos:**
```javascript
{
  email              → String (único)
  name               → String
  avatar             → String (URL de foto)
  password           → String (hasheada con bcrypt)
  googleId           → String (ID de Google)
  appleId            → String (ID de Apple)
  provider           → String (google, apple, local)
  emailVerified      → Boolean
  phone              → String
  age                → Number
  gender             → String (male, female, other)
  fitnessLevel       → String (beginner, intermediate, advanced)
  goals              → [String] (array de objetivos)
  subscription       → {
    plan             → String (free, basic, premium)
    active           → Boolean
    startDate        → Date
    endDate          → Date
  }
  createdAt          → Date
  updatedAt          → Date
  lastLogin          → Date
}
```

**Métodos:**
```javascript
comparePassword()  → Compara contraseña ingresada con hasheada
generateJWT()      → Crea token JWT
toJSON()           → Retorna usuario sin datos sensibles
```

---

### `/models/Payment.js`
**¿Qué es?**
- Define la estructura de datos de pagos
- Relaciona pagos con usuarios
- Guarda info de Mercado Pago

**Campos:**
```javascript
{
  userId                    → ObjectId (referencia a User)
  amount                    → Number (monto en ARS)
  currency                  → String (ARS por defecto)
  status                    → String (pending, approved, declined, etc)
  mercadoPagoPaymentId      → String (ID del pago en MP)
  plan                      → String (basic, premium)
  subscriptionPeriod        → String (monthly, annual)
  description               → String
  createdAt                 → Date
  approvedAt                → Date
  refundedAt                → Date
}
```

---

### `/models/Subscription.js`
**¿Qué es?**
- Define la estructura de suscripciones
- Controla período de acceso
- Relaciona con usuario

**Campos:**
```javascript
{
  userId                    → ObjectId (referencia a User)
  plan                      → String (basic, premium)
  period                    → String (monthly, annual)
  startDate                 → Date
  endDate                   → Date
  nextBillingDate           → Date (próxima renovación)
  status                    → String (active, expired, cancelled)
  amount                    → Number
  autoRenew                 → Boolean
  cancelledAt               → Date
  createdAt                 → Date
}
```

---

### `/routes/auth.js`
**¿Qué es?**
- Define endpoints de autenticación
- Maneja OAuth Google y Apple
- Registro y login manual

**Endpoints:**
```
GET    /auth/google                 → Iniciar login Google
GET    /auth/google/callback        → Callback Google
GET    /auth/apple                  → Iniciar login Apple
GET    /auth/apple/callback         → Callback Apple
POST   /auth/register               → Registro manual
POST   /auth/login                  → Login manual
POST   /auth/logout                 → Logout
GET    /auth/verify                 → Verificar token
POST   /auth/refresh                → Renovar token
```

---

### `/routes/users.js`
**¿Qué es?**
- Endpoints para gestión de perfil
- Cambio de contraseña
- Información del usuario

**Endpoints:**
```
GET    /users/profile               → Obtener perfil
PUT    /users/profile               → Actualizar perfil
POST   /users/change-password       → Cambiar contraseña
GET    /users/:userId               → Obtener usuario por ID
DELETE /users/account/delete        → Eliminar cuenta
```

---

### `/routes/payments.js`
**¿Qué es?**
- Endpoints para gestión de pagos
- Integración con Mercado Pago
- Webhooks

**Endpoints:**
```
POST   /payments/create-preference  → Crear pago
POST   /payments/webhook            → Webhook Mercado Pago
GET    /payments/history            → Historial de pagos
GET    /payments/:paymentId         → Detalles de pago
POST   /payments/:paymentId/refund  → Reembolsar
```

---

### `/routes/subscriptions.js`
**¿Qué es?**
- Endpoints para gestión de suscripciones
- Cambio de plan
- Cancelación y renovación

**Endpoints:**
```
GET    /subscriptions/current       → Suscripción actual
GET    /subscriptions/history       → Historial
POST   /subscriptions/change-plan   → Cambiar plan
POST   /subscriptions/cancel        → Cancelar
POST   /subscriptions/renew         → Renovar
```

---

### `/middleware/auth.js`
**¿Qué es?**
- Middleware que verifica JWT
- Se ejecuta antes de rutas protegidas
- Extrae usuario del token

**Proceso:**
```
1. Leer header "Authorization: Bearer TOKEN"
2. Verificar que el token es válido
3. Decodificar token y obtener ID de usuario
4. Buscar usuario en BD
5. Adjuntar usuario al request
6. Continuar a la ruta
```

**Ejemplo:**
```javascript
// En una ruta protegida
router.get('/profile', authMiddleware, async (req, res) => {
  // req.user contiene el usuario autenticado
  console.log(req.user); // { _id, email, name, ... }
});
```

---

## 🔗 FLUJO DE DATOS

### Autenticación Manual
```
User clicks "Login"
        ↓
Frontend recibe email/password
        ↓
ApiService.login() (HTTP POST)
        ↓
Backend: POST /auth/login
        ↓
Buscar usuario por email
        ↓
Comparar password con hash
        ↓
Generar JWT token
        ↓
Retornar token + usuario
        ↓
Frontend: guardar token
        ↓
AuthProvider: actualizar estado
        ↓
UI re-renderiza → usuario autenticado
```

### Flujo de Pago
```
User selecciona plan
        ↓
Frontend: createPaymentPreference()
        ↓
Backend: POST /payments/create-preference
        ↓
Crear preferencia en Mercado Pago
        ↓
Retornar init_point (URL de pago)
        ↓
Frontend: abrir Mercado Pago en navegador
        ↓
Usuario completa pago
        ↓
Mercado Pago envía webhook
        ↓
Backend: POST /payments/webhook
        ↓
Verificar pago → crear suscripción
        ↓
Actualizar usuario
        ↓
Retornar al usuario con acceso premium
```

---

## 📦 DEPENDENCIAS IMPORTANTES

### Frontend (pubspec.yaml)
```yaml
flutter              # Framework UI
http                 # Cliente HTTP
provider             # State management
```

### Backend (package.json)
```json
"express"            # Framework web
"mongoose"           # ODM para MongoDB
"passport"           # Autenticación
"jsonwebtoken"       # JWT tokens
"bcryptjs"           # Hash de contraseñas
"mercadopago"        # SDK de Mercado Pago
"dotenv"             # Variables de ambiente
"helmet"             # Seguridad
"cors"               # Control de origen
"express-validator"  # Validación
```

---

**Próxima sección:** DOCUMENTACION_03_FRONTEND.md
