# 🔌 GUÍA DE CONEXIÓN FRONTEND-BACKEND - EVASTRONG

**Fecha**: 30 de Enero 2026  
**Estado**: ✅ CONFIGURACIÓN COMPLETADA

---

## 📋 Tabla de Contenidos

1. [Requisitos](#requisitos)
2. [Configuración del Backend](#configuración-del-backend)
3. [Configuración del Frontend](#configuración-del-frontend)
4. [Verificación de Conectividad](#verificación-de-conectividad)
5. [Endpoints Disponibles](#endpoints-disponibles)
6. [Troubleshooting](#troubleshooting)

---

## 🔧 Requisitos

### Backend (Node.js)
- Node.js 18.0.0+
- MongoDB local o Atlas
- npm o yarn

### Frontend (Flutter)
- Flutter 3.8.1+
- Dart 3.0+
- Android Studio o Xcode (para emuladores)

---

## ⚙️ Configuración del Backend

### 1. Instalar Dependencias

```bash
cd "C:\Users\Carlos\Desktop\EvaStrong-Backend"
npm install
```

### 2. Verificar Variables de Entorno

El archivo `.env` ya está configurado con:
- ✅ `PORT=5000` (Puerto del servidor)
- ✅ `NODE_ENV=development` (Ambiente de desarrollo)
- ✅ `MONGODB_URI` (Conexión a MongoDB Atlas)
- ✅ `JWT_SECRET` (Secreto JWT)
- ✅ `MERCADO_PAGO_*` (Tokens de prueba)

### 3. Iniciar el Backend

```bash
# Opción 1: Desarrollo con auto-reload
npm run dev

# Opción 2: Producción
npm start
```

**Salida esperada:**
```
╔════════════════════════════════════════════╗
║   🎉 Eva Strong Backend - Iniciado        ║
╠════════════════════════════════════════════╣
║   Servidor: http://localhost:5000         ║
║   Ambiente: development                    ║
║   Base de datos: Conectada                 ║
╚════════════════════════════════════════════╝
```

### 4. Verificar Salud del Backend

```bash
curl http://localhost:5000/health
```

**Respuesta esperada:**
```json
{
  "status": "OK",
  "timestamp": "2026-01-30T00:00:00.000Z"
}
```

---

## 📱 Configuración del Frontend

### 1. Cambiar a Modo Desarrollo Local

**Archivo**: `lib/config/app_config.dart`

```dart
class AppConfig {
  // ✅ CAMBIO: isDebugMode = true
  static const bool isDebugMode = true;

  // Backend local (se usa cuando isDebugMode = true)
  static const String _backendDevUrl = 'http://localhost:5000';
}
```

### 2. Obtener Dependencias

```bash
cd "C:\Users\Carlos\Desktop\EvaStrong"
flutter pub get
```

### 3. Ejecutar la App

```bash
# En emulador Android
flutter run

# O especificar el emulador
flutter run -d emulator-5554

# En iOS
flutter run -d all
```

---

## ✅ Verificación de Conectividad

### Paso 1: Verificar Backend

```bash
# Test del health endpoint
curl -X GET http://localhost:5000/health

# Esperado: { "status": "OK", "timestamp": "..." }
```

### Paso 2: Test de Registro

```bash
curl -X POST http://localhost:5000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123!",
    "name": "Test User"
  }'
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Usuario registrado exitosamente",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "_id": "...",
    "email": "test@example.com",
    "name": "Test User"
  }
}
```

### Paso 3: Test de Login

```bash
curl -X POST http://localhost:5000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123!"
  }'
```

### Paso 4: Test de Verificación de Token

```bash
TOKEN="tu_token_aqui"
curl -X GET http://localhost:5000/auth/verify \
  -H "Authorization: Bearer $TOKEN"
```

---

## 🌐 Endpoints Disponibles

### Autenticación

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/auth/register` | Registrar nuevo usuario |
| POST | `/auth/login` | Iniciar sesión |
| POST | `/auth/logout` | Cerrar sesión |
| GET | `/auth/verify` | Verificar token |
| POST | `/auth/refresh` | Refrescar token |

### Usuarios

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/users/profile` | Obtener perfil |
| PUT | `/users/profile` | Actualizar perfil |
| POST | `/users/change-password` | Cambiar contraseña |
| POST | `/users/upload-photo` | Subir foto de perfil |

### Pagos

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/payments/create-order` | Crear orden PayPal |
| POST | `/payments/capture-order/:id` | Capturar pago PayPal |
| POST | `/payments/mercado-pago/create-preference` | Crear preferencia MP |
| GET | `/payments/history` | Historial de pagos |
| GET | `/payments/mercado-pago/payment/:id` | Estado de pago MP |

### Suscripciones

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/subscriptions/current` | Suscripción actual |
| POST | `/subscriptions/change-plan` | Cambiar plan |
| POST | `/subscriptions/cancel` | Cancelar suscripción |

### Rutinas

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/routines` | Obtener rutinas |
| GET | `/routines/:id` | Detalle de rutina |
| POST | `/routines` | Crear rutina |

### Ejercicios

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/exercises` | Obtener ejercicios |
| GET | `/exercises/:id` | Detalle de ejercicio |

### Admin Dashboard

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/admin/users/stats` | Estadísticas de usuarios |
| GET | `/api/admin/revenue/stats` | Estadísticas de ingresos |
| POST | `/api/admin/subscriptions/send-reminder` | Enviar recordatorio |

---

## 🐛 Troubleshooting

### Problema: "Connection refused" en http://localhost:5000

**Solución:**
```bash
# 1. Verificar que el backend está corriendo
netstat -ano | findstr :5000

# 2. Si no está corriendo, iniciar:
cd "C:\Users\Carlos\Desktop\EvaStrong-Backend"
npm run dev

# 3. Si el puerto está en uso, cambiar en .env:
PORT=5001
```

### Problema: "CORS error" en Flutter

**Verificar:**
- ✅ Backend tiene CORS habilitado (ver server.js línea 32)
- ✅ FRONTEND_URL en .env está correcto
- ✅ Frontend usa `http://localhost:5000` (no `https` en desarrollo)

### Problema: "MongoDB connection failed"

**Solución:**
```bash
# 1. Verificar credenciales en .env
# 2. Verificar conexión de internet
# 3. Verificar que MongoDB Atlas está accesible

# Alternativa: Usar MongoDB local
# Cambiar MONGODB_URI a: mongodb://localhost:27017/evastrong
```

### Problema: "Token expired" inmediatamente

**Verificar:**
- ✅ JWT_SECRET en .env es igual en frontend y backend
- ✅ JWT_EXPIRE=7d está configurado
- ✅ Reloj del sistema está sincronizado

### Problema: "Token refresh no funciona"

**Solución:**
1. Verificar que AuthProviderV2 tiene `_scheduleTokenRefresh()`
2. Verificar endpoint `/auth/refresh` en backend
3. Revisar logs del backend: `npm run dev 2>&1 | grep -i "token"`

---

## 📊 Flujos de Integración Verificados

### ✅ Flujo de Autenticación
```
Frontend (Register) → Backend (/auth/register) → MongoDB
                   ↓
         Generar JWT Token
                   ↓
Frontend (Login) → Backend (/auth/login) → MongoDB
                ↓
    Verificación automática en AuthProviderV2
```

### ✅ Flujo de Pagos
```
Frontend (PaymentsScreen) → Backend (/payments/create-preference)
                         ↓
              Mercado Pago API
                         ↓
Frontend (Payment Complete) → Backend (/payments/history)
```

### ✅ Flujo de Token Refresh
```
AuthProviderV2._scheduleTokenRefresh()
         ↓
    Decodificar JWT
         ↓
   Calcular expiration
         ↓
  Programar refresh (5 min antes)
         ↓
Backend (/auth/refresh) → Nuevo token JWT
         ↓
   Guardar en SecureStorage
```

---

## 🚀 Comandos Útiles

### Backend

```bash
# Iniciar en desarrollo
npm run dev

# Iniciar en producción
npm start

# Ejecutar tests
npm test

# Ver logs en tiempo real
npm run dev 2>&1 | grep -E "✓|✗|error"
```

### Frontend

```bash
# Obtener dependencias
flutter pub get

# Limpiar build
flutter clean

# Ejecutar en modo debug
flutter run -v

# Ejecutar en emulador específico
flutter run -d <device-id>

# Build para producción
flutter build apk --release
flutter build ipa --release
```

### MongoDB

```bash
# Conectar a MongoDB local
mongo

# Ver bases de datos
show dbs

# Usar evastrong
use evastrong

# Ver colecciones
show collections

# Ver usuarios
db.users.find()
```

---

## 📝 Notas Importantes

### Seguridad
- ⚠️ No compartir JWT_SECRET del .env
- ⚠️ MERCADO_PAGO tokens en .env son de prueba
- ⚠️ En producción, usar variables de entorno seguras
- ⚠️ Cambiar GOOGLE_CLIENT_ID y APPLE credentials

### Performance
- ✅ Token refresh automático (5 min antes)
- ✅ Timeouts en requests (30 segundos)
- ✅ Rate limiting en backend (100 req/15min)
- ✅ Error handling completo

### Base de Datos
- ✅ MongoDB Atlas (producción)
- ✅ MongoDB local (desarrollo)
- ✅ Índices optimizados
- ✅ Logs de seguridad

---

## ✅ Checklist de Verificación

- [ ] Backend instalado (`npm install`)
- [ ] .env configurado correctamente
- [ ] MongoDB conectado
- [ ] Backend corriendo en puerto 5000
- [ ] Health endpoint responde
- [ ] Frontend en modo debug (`isDebugMode = true`)
- [ ] Flutter pub get ejecutado
- [ ] App ejecutándose en emulador
- [ ] Token register/login funciona
- [ ] Token refresh funciona
- [ ] Admin dashboard carga
- [ ] Pagos se pueden procesar

---

## 📞 Soporte

Si hay problemas:
1. Revisar los logs del backend: `npm run dev`
2. Revisar los logs del frontend: `flutter run -v`
3. Verificar conectividad: `curl http://localhost:5000/health`
4. Revisar archivo de configuración `.env`
5. Revisar `app_config.dart` (isDebugMode = true)

---

**Estado**: ✅ LISTA PARA DESARROLLO  
**Última actualización**: 30 de Enero 2026  
**Versión**: 1.0.0
