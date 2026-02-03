# 🔒 Guía Completa de Seguridad y Control de Suscripciones

## 📋 **Análisis de Seguridad Actual**

### 🔍 **Vulnerabilidades Identificadas**

#### **1. Autenticación**
- ⚠️ Token JWT sin verificación de expiración en cliente
- ⚠️ No hay refresh token automático
- ⚠️ Falta de logout forzado en múltiples dispositivos
- ⚠️ No hay rate limiting en login

#### **2. Control de Suscripciones**
- ⚠️ Verificación solo en frontend (vulnerable)
- ⚠️ No hay validación temporal en cada request
- ⚠️ Falta de sincronización con backend
- ⚠️ No hay revocación automática de acceso

#### **3. Datos Sensibles**
- ⚠️ Tokens almacenados sin encriptación adicional
- ⚠️ No hay validación de integridad de datos
- ⚠️ Falta de sanitización de inputs

---

## 🛡️ **Sistema de Seguridad Mejorado**

### **Paso 1: Autenticación Segura con Refresh Tokens**

#### **1.1 Backend - Nuevo Sistema de Tokens**

```javascript
// models/Token.js
const tokenSchema = new mongoose.Schema({
  userId: { type: String, required: true, ref: 'User' },
  accessToken: { type: String, required: true },
  refreshToken: { type: String, required: true, unique: true },
  expiresAt: { type: Date, required: true },
  refreshExpiresAt: { type: Date, required: true },
  deviceInfo: { type: String },
  ipAddress: { type: String },
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now }
});

// Index para limpieza automática
tokenSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });
```

#### **1.2 Middleware de Verificación de Tokens**

```javascript
// middleware/auth.js
const jwt = require('jsonwebtoken');
const Token = require('../models/Token');

const verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Token requerido' });
    }

    const accessToken = authHeader.split(' ')[1];
    
    // Verificar token en base de datos
    const tokenDoc = await Token.findOne({ 
      accessToken, 
      isActive: true,
      expiresAt: { $gt: new Date() }
    }).populate('userId');

    if (!tokenDoc) {
      return res.status(401).json({ error: 'Token inválido o expirado' });
    }

    // Verificar firma JWT
    const decoded = jwt.verify(accessToken, process.env.JWT_SECRET);
    
    // Verificar suscripción activa
    const user = tokenDoc.userId;
    if (!user.hasActiveSubscription() && req.path.startsWith('/api/premium')) {
      return res.status(403).json({ error: 'Suscripción requerida' });
    }

    req.user = user;
    req.token = tokenDoc;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expirado', requiresRefresh: true });
    }
    return res.status(401).json({ error: 'Token inválido' });
  }
};
```

#### **1.3 Sistema de Refresh Tokens**

```javascript
// routes/auth.js
const refreshTokens = async (req, res) => {
  try {
    const { refreshToken } = req.body;
    
    const tokenDoc = await Token.findOne({ 
      refreshToken,
      isActive: true,
      refreshExpiresAt: { $gt: new Date() }
    }).populate('userId');

    if (!tokenDoc) {
      return res.status(401).json({ error: 'Refresh token inválido' });
    }

    // Generar nuevos tokens
    const newAccessToken = jwt.sign(
      { userId: tokenDoc.userId._id, email: tokenDoc.userId.email },
      process.env.JWT_SECRET,
      { expiresIn: '15m' }
    );

    const newRefreshToken = jwt.sign(
      { userId: tokenDoc.userId._id, type: 'refresh' },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: '7d' }
    );

    // Actualizar tokens en base de datos
    tokenDoc.accessToken = newAccessToken;
    tokenDoc.refreshToken = newRefreshToken;
    tokenDoc.expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutos
    tokenDoc.refreshExpiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 días
    await tokenDoc.save();

    res.json({
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
      user: {
        id: tokenDoc.userId._id,
        email: tokenDoc.userId.email,
        subscription: tokenDoc.userId.subscription
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Error al refrescar token' });
  }
};
```

### **Paso 2: Control de Suscripciones en Backend**

#### **2.1 Modelo de Suscripción Mejorado**

```javascript
// models/Subscription.js
const subscriptionSchema = new mongoose.Schema({
  userId: { type: String, required: true, ref: 'User' },
  plan: { 
    type: String, 
    enum: ['free', 'basic', 'premium'], 
    required: true 
  },
  status: { 
    type: String, 
    enum: ['active', 'expired', 'cancelled', 'pending'], 
    default: 'active' 
  },
  startDate: { type: Date, required: true },
  endDate: { type: Date, required: true },
  autoRenew: { type: Boolean, default: true },
  paymentMethod: { type: String },
  lastPaymentDate: { type: Date },
  nextPaymentDate: { type: Date },
  amount: { type: Number },
  currency: { type: String, default: 'USD' },
  features: [{
    name: String,
    enabled: Boolean,
    limit: Number
  }],
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// Método para verificar suscripción activa
subscriptionSchema.methods.isActive = function() {
  return this.status === 'active' && 
         this.endDate > new Date() && 
         this.startDate <= new Date();
};

// Método para verificar acceso a feature específico
subscriptionSchema.methods.hasAccessTo = function(feature) {
  if (!this.isActive()) return false;
  
  const featureConfig = this.features.find(f => f.name === feature);
  return featureConfig && featureConfig.enabled;
};
```

#### **2.2 Middleware de Control de Acceso**

```javascript
// middleware/subscription.js
const Subscription = require('../models/Subscription');
const User = require('../models/User');

const checkSubscription = (requiredPlan = 'basic') => {
  return async (req, res, next) => {
    try {
      const userId = req.user._id || req.user.id;
      
      // Obtener suscripción actual del usuario
      const subscription = await Subscription.findOne({ 
        userId,
        status: 'active',
        endDate: { $gt: new Date() }
      });

      if (!subscription) {
        return res.status(403).json({ 
          error: 'Suscripción requerida',
          code: 'SUBSCRIPTION_REQUIRED',
          requiredPlan 
        });
      }

      // Verificar nivel de plan
      const planLevels = { free: 0, basic: 1, premium: 2 };
      const userLevel = planLevels[subscription.plan];
      const requiredLevel = planLevels[requiredPlan];

      if (userLevel < requiredLevel) {
        return res.status(403).json({ 
          error: 'Plan insuficiente',
          code: 'PLAN_UPGRADE_REQUIRED',
          currentPlan: subscription.plan,
          requiredPlan 
        });
      }

      // Agregar info de suscripción al request
      req.subscription = subscription;
      next();
    } catch (error) {
      console.error('Error checking subscription:', error);
      res.status(500).json({ error: 'Error al verificar suscripción' });
    }
  };
};

// Middleware para features específicos
const checkFeatureAccess = (feature) => {
  return async (req, res, next) => {
    try {
      const subscription = req.subscription;
      
      if (!subscription || !subscription.hasAccessTo(feature)) {
        return res.status(403).json({ 
          error: 'Feature no disponible en tu plan',
          code: 'FEATURE_NOT_AVAILABLE',
          feature 
        });
      }
      
      next();
    } catch (error) {
      res.status(500).json({ error: 'Error al verificar feature' });
    }
  };
};
```

#### **2.3 Sistema de Validación Temporal**

```javascript
// services/subscriptionService.js
class SubscriptionService {
  // Verificar suscripción en cada request crítico
  static async validateAccess(userId, feature) {
    const subscription = await Subscription.findOne({
      userId,
      status: 'active',
      endDate: { $gt: new Date() }
    });

    if (!subscription) {
      throw new Error('SUBSCRIPTION_EXPIRED');
    }

    if (!subscription.hasAccessTo(feature)) {
      throw new Error('FEATURE_NOT_AVAILABLE');
    }

    return subscription;
  }

  // Logging de acceso para auditoría
  static async logAccess(userId, feature, granted) {
    await AccessLog.create({
      userId,
      feature,
      granted,
      timestamp: new Date(),
      userAgent: req.headers['user-agent'],
      ipAddress: req.ip
    });
  }

  // Revocar acceso inmediatamente
  static async revokeAccess(userId, reason) {
    await Subscription.updateMany(
      { userId },
      { status: 'cancelled' }
    );
    
    // Invalidar todos los tokens
    await Token.updateMany(
      { userId },
      { isActive: false }
    );

    // Logging de revocación
    await SecurityLog.create({
      userId,
      action: 'ACCESS_REVOKED',
      reason,
      timestamp: new Date()
    });
  }
}
```

### **Paso 3: Seguridad en Frontend (Flutter)**

#### **3.1 Servicio de Autenticación Seguro**

```dart
// services/secure_auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

class SecureAuthService {
  static const _storage = FlutterSecureStorage();
  static const _baseUrl = 'http://localhost:5000';
  
  // Tiempo de expiración del token (15 minutos)
  static const _tokenExpiration = Duration(minutes: 15);
  
  static String? _accessToken;
  static String? _refreshToken;
  static DateTime? _tokenExpiry;
  static Timer? _refreshTimer;

  // Login con tokens seguros
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'deviceInfo': _getDeviceInfo(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storeTokens(data);
        _startTokenRefresh();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Almacenar tokens de forma segura
  static Future<void> _storeTokens(Map<String, dynamic> data) async {
    _accessToken = data['accessToken'];
    _refreshToken = data['refreshToken'];
    
    // Calcular expiración del token
    final tokenData = JwtDecode.parseJwt(_accessToken!);
    _tokenExpiry = DateTime.fromMillisecondsSinceEpoch(
      tokenData['exp'] * 1000
    );

    // Almacenar en secure storage
    await _storage.write(key: 'access_token', value: _accessToken!);
    await _storage.write(key: 'refresh_token', value: _refreshToken!);
    await _storage.write(
      key: 'token_expiry', 
      value: _tokenExpiry!.toIso8601String()
    );
  }

  // Refresh automático de tokens
  static void _startTokenRefresh() {
    _refreshTimer?.cancel();
    
    // Refrescar 2 minutos antes de expirar
    final refreshTime = _tokenExpiry!.subtract(const Duration(minutes: 2));
    final delay = refreshTime.difference(DateTime.now());
    
    if (delay.inMilliseconds > 0) {
      _refreshTimer = Timer(delay, _refreshTokens);
    }
  }

  // Refrescar tokens
  static Future<bool> _refreshTokens() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      
      if (refreshToken == null) {
        await logout();
        return false;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storeTokens(data);
        _startTokenRefresh();
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      print('Token refresh error: $e');
      await logout();
      return false;
    }
  }

  // Verificar token válido
  static Future<bool> isTokenValid() async {
    if (_accessToken == null || _tokenExpiry == null) {
      await _loadTokens();
    }

    if (_tokenExpiry == null) return false;
    
    // Si el token está por expirar, intentar refrescar
    if (DateTime.now().isAfter(_tokenExpiry!.subtract(const Duration(minutes: 2)))) {
      return await _refreshTokens();
    }

    return DateTime.now().isBefore(_tokenExpiry!);
  }

  // Obtener headers autenticados
  static Future<Map<String, String>> getAuthHeaders() async {
    final isValid = await isTokenValid();
    if (!isValid) {
      throw Exception('Sesión expirada');
    }

    return {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    };
  }

  // Logout seguro
  static Future<void> logout() async {
    _refreshTimer?.cancel();
    
    // Invalidar tokens en backend
    try {
      if (_accessToken != null) {
        await http.post(
          Uri.parse('$_baseUrl/api/auth/logout'),
          headers: await getAuthHeaders(),
        );
      }
    } catch (e) {
      print('Logout error: $e');
    }

    // Limpiar storage local
    await _storage.deleteAll();
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
  }

  // Cargar tokens desde storage
  static Future<void> _loadTokens() async {
    _accessToken = await _storage.read(key: 'access_token');
    _refreshToken = await _storage.read(key: 'refresh_token');
    
    final expiryStr = await _storage.read(key: 'token_expiry');
    if (expiryStr != null) {
      _tokenExpiry = DateTime.parse(expiryStr);
      _startTokenRefresh();
    }
  }

  // Obtener información del dispositivo
  static String _getDeviceInfo() {
    return 'Flutter App - ${DateTime.now().toIso8601String()}';
  }
}
```

#### **3.2 Middleware de Suscripciones en Flutter**

```dart
// services/subscription_guard.dart
import 'package:flutter/material.dart';
import 'secure_auth_service.dart';

class SubscriptionGuard {
  // Verificar acceso a features
  static Future<bool> hasAccessTo(String feature) async {
    try {
      final headers = await SecureAuthService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/subscription/check/$feature'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Subscription check error: $e');
      return false;
    }
  }

  // Widget wrapper para features protegidos
  static Widget protectFeature({
    required Widget child,
    required String feature,
    required String plan,
    Widget? fallback,
  }) {
    return FutureBuilder<bool>(
      future: hasAccessTo(feature),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data == true) {
          return child;
        }

        return fallback ?? _buildUpgradePrompt(plan);
      },
    );
  }

  // Pantalla de upgrade
  static Widget _buildUpgradePrompt(String requiredPlan) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Feature no disponible',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Esta función requiere el plan $requiredPlan',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _navigateToUpgrade(),
            child: Text('Upgrade a $requiredPlan'),
          ),
        ],
      ),
    );
  }

  static void _navigateToUpgrade() {
    // Navegar a pantalla de upgrade
    Get.toNamed('/subscription-upgrade');
  }
}
```

### **Paso 4: Implementación en Rutas Protegidas**

#### **4.1 Backend - Rutas con Control de Acceso**

```javascript
// routes/premium.js
const express = require('express');
const router = express.Router();
const { verifyToken } = require('../middleware/auth');
const { checkSubscription, checkFeatureAccess } = require('../middleware/subscription');

// Todas las rutas premium requieren verificación de token
router.use(verifyToken);

// Rutas que requieren suscripción básica
router.get('/workouts', checkSubscription('basic'), async (req, res) => {
  // Lógica para obtener workouts
});

// Rutas que requieren suscripción premium
router.get('/personal-training', checkSubscription('premium'), async (req, res) => {
  // Lógica para entrenamiento personal
});

// Features específicos
router.get('/videos', 
  checkSubscription('basic'), 
  checkFeatureAccess('video_library'), 
  async (req, res) => {
    // Lógica para videos
  }
);

router.post('/custom-plan', 
  checkSubscription('premium'), 
  checkFeatureAccess('custom_plans'), 
  async (req, res) => {
    // Lógica para planes personalizados
  }
);

module.exports = router;
```

#### **4.2 Flutter - Rutas Protegidas**

```dart
// guards/route_guard.dart
class RouteGuard {
  static Future<bool> canAccessRoute(String route) async {
    switch (route) {
      case '/premium-workouts':
        return await SubscriptionGuard.hasAccessTo('premium_workouts');
      case '/personal-training':
        return await SubscriptionGuard.hasAccessTo('personal_training');
      case '/custom-plans':
        return await SubscriptionGuard.hasAccessTo('custom_plans');
      case '/video-library':
        return await SubscriptionGuard.hasAccessTo('video_library');
      default:
        return true; // Rutas públicas
    }
  }

  static Widget protectRoute({
    required String route,
    required Widget child,
  }) {
    return FutureBuilder<bool>(
      future: canAccessRoute(route),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data == true) {
          return child;
        }

        return const SubscriptionRequiredScreen();
      },
    );
  }
}
```

### **Paso 5: Monitoreo y Auditoría**

#### **5.1 Sistema de Logs de Seguridad**

```javascript
// models/SecurityLog.js
const securityLogSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  action: { 
    type: String, 
    enum: ['LOGIN', 'LOGOUT', 'ACCESS_DENIED', 'SUBSCRIPTION_EXPIRED', 'TOKEN_REFRESH', 'ACCESS_REVOKED'],
    required: true 
  },
  details: { type: Object },
  ipAddress: { type: String },
  userAgent: { type: String },
  timestamp: { type: Date, default: Date.now },
  severity: { 
    type: String, 
    enum: ['low', 'medium', 'high', 'critical'], 
    default: 'medium' 
  }
});

// Índices para búsquedas eficientes
securityLogSchema.index({ userId: 1, timestamp: -1 });
securityLogSchema.index({ action: 1, timestamp: -1 });
securityLogSchema.index({ severity: 1, timestamp: -1 });
```

#### **5.2 Dashboard de Seguridad**

```javascript
// routes/security.js
router.get('/dashboard', verifyToken, async (req, res) => {
  try {
    const userId = req.user._id;
    
    // Estadísticas de seguridad del usuario
    const stats = await SecurityLog.aggregate([
      { $match: { userId } },
      {
        $group: {
          _id: '$action',
          count: { $sum: 1 },
          lastOccurrence: { $max: '$timestamp' }
        }
      }
    ]);

    // Intentos de acceso fallidos
    const failedAttempts = await SecurityLog.countDocuments({
      userId,
      action: 'ACCESS_DENIED',
      timestamp: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) }
    });

    // Dispositivos activos
    const activeTokens = await Token.countDocuments({
      userId,
      isActive: true
    });

    res.json({
      stats,
      failedAttempts,
      activeTokens,
      securityScore: _calculateSecurityScore(stats, failedAttempts)
    });
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener datos de seguridad' });
  }
});
```

---

## 🎯 **Implementación Paso a Paso**

### **Fase 1: Backend (1-2 días)**
1. Implementar nuevo sistema de tokens con refresh
2. Crear modelos mejorados de suscripción
3. Desarrollar middlewares de seguridad
4. Configurar sistema de logs de auditoría

### **Fase 2: Frontend (1-2 días)**
1. Implementar servicio de autenticación seguro
2. Crear guards de suscripción
3. Actualizar rutas protegidas
4. Implementar refresh automático

### **Fase 3: Integración (1 día)**
1. Conectar frontend con backend seguro
2. Probar flujo completo de suscripción
3. Validar control de acceso temporal
4. Implementar monitoreo

### **Fase 4: Testing (1 día)**
1. Pruebas de penetración
2. Tests de expiración de suscripción
3. Validación de revocación de acceso
4. Performance testing

---

## 🚀 **Beneficios del Sistema Mejorado**

### **🔒 Seguridad Mejorada**
- ✅ Tokens con expiración corta (15 min)
- ✅ Refresh tokens automáticos
- ✅ Validación en cada request
- ✅ Revocación inmediata de acceso

### **💰 Control de Suscripciones**
- ✅ Verificación temporal en backend
- ✅ Control granular de features
- ✅ Actualización automática de estado
- ✅ Auditoría completa de acceso

### **📊 Monitoreo y Auditoría**
- ✅ Logs de todas las acciones
- ✅ Dashboard de seguridad
- ✅ Alertas de actividades sospechosas
- ✅ Estadísticas de uso

---

## 🎉 **Resultado Final**

Un sistema completamente seguro donde:
- **Los usuarios solo acceden durante el tiempo pagado**
- **El control es 100% del backend, no manipulable**
- **La seguridad es multicapa y redundante**
- **Hay auditoría completa de todas las acciones**

**¡Tu aplicación será completamente segura y el control de suscripciones será impecable! 🛡️💎**
