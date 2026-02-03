# 🚀 Pasos para Conectar el Dashboard Administrativo con el Backend

## 📋 Requisitos Previos

### 1. Backend Corriendo
Asegúrate de que tu backend esté corriendo en `http://localhost:5000`

### 2. Dependencias Instaladas
```yaml
dependencies:
  http: ^1.1.0
  flutter_secure_storage: ^9.0.0
```

## 🔧 Configuración del Backend

### 1. Crear Endpoints del Dashboard

Crea los siguientes endpoints en tu backend:

#### **Estadísticas de Usuarios**
```javascript
// GET /api/admin/users/stats
{
  "totalUsers": 2847,
  "activeUsers": 1923,
  "newUsersToday": 47,
  "topUsers": [
    {
      "name": "María García",
      "achievements": 45,
      "performance": 98.5,
      "avatar": "👩‍💼"
    }
    // ... más usuarios
  ]
}
```

#### **Estadísticas de Ventas**
```javascript
// GET /api/admin/revenue/stats
{
  "dailyRevenue": 2847.50,
  "monthlyRevenue": 45678.90,
  "dailySales": 89,
  "recentSales": [
    {
      "userId": "USR2847",
      "plan": "Premium Mensual",
      "amount": 29.99,
      "time": "Hace 2 min"
    }
    // ... más ventas
  ]
}
```

#### **Estadísticas de Logros**
```javascript
// GET /api/admin/achievements/stats
{
  "totalAchievements": 12543,
  "achievementsUnlockedToday": 234,
  "recentAchievements": [
    {
      "userName": "María García",
      "achievement": "Rutina Perfecta",
      "time": "Hace 5 min"
    }
    // ... más logros
  ]
}
```

#### **Estadísticas de Suscripciones**
```javascript
// GET /api/admin/subscriptions/stats
{
  "activeSubscriptions": 892,
  "expiredThisMonth": 23,
  "expiringSubscriptions": [
    {
      "userId": "USR1234",
      "userName": "María García",
      "plan": "Premium Mensual",
      "daysLeft": 3
    }
    // ... más suscripciones
  ]
}
```

#### **Estadísticas de Tráfico**
```javascript
// GET /api/admin/traffic/stats
{
  "dailyActiveUsers": 1923,
  "sessionCount": 3847,
  "avgSessionDuration": 24.5,
  "trafficTrend": [
    {
      "date": "2024-01-20T00:00:00.000Z",
      "users": 1500,
      "sessions": 2000
    }
    // ... más días
  ]
}
```

#### **Estadísticas de Feedback**
```javascript
// GET /api/admin/feedback/stats
{
  "satisfactionScore": 4.6,
  "pendingResponses": 12,
  "recentFeedback": [
    {
      "userName": "María García",
      "rating": 5,
      "comment": "¡Excelente app! Me encanta",
      "time": "Hace 10 min"
    }
    // ... más feedback
  ]
}
```

### 2. Endpoints de Acciones

#### **Enviar Recordatorio**
```javascript
// POST /api/admin/subscriptions/send-reminder
{
  "userId": "USR1234",
  "userName": "María García"
}
```

#### **Responder Feedback**
```javascript
// POST /api/admin/feedback/respond
{
  "userId": "USR1234",
  "response": "Gracias por tu feedback..."
}
```

## 🔐 Autenticación

### 1. Middleware de Autenticación
```javascript
// Ejemplo en Node.js/Express
const adminAuth = (req, res, next) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  
  if (!token) {
    return res.status(401).json({ error: 'Token requerido' });
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (decoded.role !== 'admin') {
      return res.status(403).json({ error: 'Acceso denegado' });
    }
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Token inválido' });
  }
};
```

### 2. Aplicar Middleware
```javascript
// Aplicar a todos los endpoints del dashboard
app.use('/api/admin', adminAuth);
```

## 📱 Configuración en Flutter

### 1. Establecer Token de Autenticación
```dart
// Después del login del admin
AdminService.instance.setAuthToken('tu_jwt_token_aqui');
```

### 2. Modificar URL del Backend
```dart
// En lib/services/admin_service.dart
static const String _baseUrl = 'http://localhost:5000'; // Cambia si es necesario
```

## 🗄️ Base de Datos

### 1. Queries SQL para Estadísticas

#### **Usuarios**
```sql
-- Total usuarios
SELECT COUNT(*) as totalUsers FROM users;

-- Usuarios activos (últimos 30 días)
SELECT COUNT(*) as activeUsers FROM users 
WHERE last_login >= DATE_SUB(NOW(), INTERVAL 30 DAY);

-- Nuevos usuarios hoy
SELECT COUNT(*) as newUsersToday FROM users 
WHERE DATE(created_at) = CURDATE();

-- Top usuarios
SELECT u.name, u.avatar, COUNT(a.id) as achievements, 
       AVG(up.performance_score) as performance
FROM users u
LEFT JOIN achievements a ON u.id = a.user_id
LEFT JOIN user_performance up ON u.id = up.user_id
GROUP BY u.id, u.name, u.avatar
ORDER BY performance DESC
LIMIT 5;
```

#### **Ventas**
```sql
-- Ingresos diarios
SELECT SUM(amount) as dailyRevenue, COUNT(*) as dailySales
FROM payments 
WHERE DATE(created_at) = CURDATE();

-- Ingresos mensuales
SELECT SUM(amount) as monthlyRevenue
FROM payments 
WHERE MONTH(created_at) = MONTH(CURDATE()) 
  AND YEAR(created_at) = YEAR(CURDATE());

-- Ventas recientes
SELECT p.user_id, pp.plan_name, p.amount, 
       CONCAT('Hace ', TIMESTAMPDIFF(MINUTE, p.created_at, NOW()), ' min') as time
FROM payments p
JOIN payment_plans pp ON p.plan_id = pp.id
ORDER BY p.created_at DESC
LIMIT 5;
```

#### **Suscripciones por Vencer**
```sql
SELECT u.id as userId, u.name as userName, pp.plan_name as plan,
       DATEDIFF(s.end_date, CURDATE()) as daysLeft
FROM subscriptions s
JOIN users u ON s.user_id = u.id
JOIN payment_plans pp ON s.plan_id = pp.id
WHERE s.status = 'active'
  AND s.end_date <= DATE_ADD(CURDATE(), INTERVAL 14 DAY)
  AND s.end_date > CURDATE()
ORDER BY s.end_date ASC
LIMIT 10;
```

## 🧪 Testing

### 1. Probar Endpoints Manualmente
```bash
# Probar endpoint de usuarios
curl -H "Authorization: Bearer tu_token" \
     http://localhost:5000/api/admin/users/stats

# Probar envío de recordatorio
curl -X POST \
     -H "Authorization: Bearer tu_token" \
     -H "Content-Type: application/json" \
     -d '{"userId":"USR1234","userName":"María García"}' \
     http://localhost:5000/api/admin/subscriptions/send-reminder
```

### 2. Manejo de Errores
```dart
// El servicio ya tiene manejo de errores
try {
  final data = await AdminService.instance.getDashboardData();
  // Usar datos
} catch (e) {
  // Mostrar error al usuario
  print('Error: $e');
  // El servicio automáticamente retorna datos mock en caso de error
}
```

## 🚀 Despliegue

### 1. Configuración de Producción
```dart
// Cambiar URL para producción
static const String _baseUrl = 'https://tu-backend.com';
```

### 2. Variables de Entorno
```javascript
// En el backend
const API_URL = process.env.API_URL || 'http://localhost:5000';
const JWT_SECRET = process.env.JWT_SECRET;
```

## 🔍 Debugging

### 1. Logs en el Backend
```javascript
// Agregar logs para debugging
console.log('Dashboard request from:', req.user.email);
console.log('Data sent:', responseData);
```

### 2. Logs en Flutter
```dart
// Habilitar logs debug
print('AdminService: Requesting dashboard data');
print('AdminService: Response: $data');
```

## ✅ Verificación Final

1. **Backend corriendo** en el puerto correcto
2. **Endpoints creados** y funcionando
3. **Autenticación configurada**
4. **Token establecido** en Flutter
5. **URL del backend** correcta
6. **Base de datos** con las queries necesarias
7. **Testing** de todos los endpoints

## 🎯 Resultado Esperado

Una vez configurado, el dashboard mostrará:
- ✅ Datos reales del backend
- ✅ Actualización en tiempo real
- ✅ Funcionalidad de recordatorios
- ✅ Respuestas a feedback
- ✅ Estadísticas precisas
- ✅ Manejo de errores elegante

¡Listo! Tu dashboard administrativo estará completamente conectado al backend. 🎉
