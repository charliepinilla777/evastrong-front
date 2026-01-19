# 📚 EVA STRONG - DOCUMENTACIÓN COMPLETA

## 📖 Índice de Documentación

1. **DOCUMENTACION_01_INICIO.md** ← Estás aquí
   - Visión general del proyecto
   - Características principales
   - Stack tecnológico

2. **DOCUMENTACION_02_ESTRUCTURA.md**
   - Estructura del proyecto
   - Carpetas y archivos
   - Organización del código

3. **DOCUMENTACION_03_FRONTEND.md**
   - Componentes Flutter
   - Pantallas
   - Servicios API
   - Providers

4. **DOCUMENTACION_04_BACKEND.md**
   - Endpoints API
   - Modelos de datos
   - Rutas y controladores

5. **DOCUMENTACION_05_INSTALACION.md**
   - Guía paso a paso
   - Configuración inicial
   - Setup de servicios

6. **DOCUMENTACION_06_FLUJOS.md**
   - Flujo de autenticación
   - Flujo de pagos
   - Flujo de suscripciones

7. **DOCUMENTACION_07_DESARROLLO.md**
   - Cómo agregar features
   - Customización
   - Mejores prácticas

---

## 🎯 ¿QUÉ ES EVA STRONG?

Eva Strong es una **aplicación de fitness y entrenamiento** con características avanzadas:

- 💪 **Entrenamientos personalizados**
- 👩‍🦰 **Icono temático** (mujer fuerte/empoderamiento)
- 🎨 **Diseño moderno** (Material 3, Púrpura + Lila)
- 🔐 **Autenticación segura** (OAuth Google/Apple + JWT)
- 💳 **Pagos integrados** (Mercado Pago)
- 📱 **Multiplataforma** (Android, iOS, Web, Windows, macOS, Linux)
- ☁️ **Backend robusto** (Node.js + MongoDB)

---

## 🏗️ STACK TECNOLÓGICO

### Frontend
```
Flutter (Dart)
├── Material Design 3
├── Provider (state management)
├── HTTP (API calls)
└── Local storage
```

### Backend
```
Node.js + Express
├── MongoDB (base de datos)
├── Passport.js (OAuth)
├── JWT (autenticación)
├── Mercado Pago SDK (pagos)
└── Helmet + CORS (seguridad)
```

### Servicios Externos
```
Google Cloud (OAuth)
├── Google Sign-In
└── OAuth 2.0

Apple Developer (OAuth)
├── Sign in with Apple
└── OAuth 2.0

Mercado Pago
├── Pagos online
├── Suscripciones
└── Webhooks
```

---

## 📊 ARQUITECTURA GENERAL

```
┌─────────────────────────────────────────────────────────────┐
│                    USUARIO FINAL                            │
│              (Celular Android/iOS o Web)                    │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│                   FRONTEND (Flutter)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ UI Components│  │   Screens    │  │  Providers   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                 │              │
│         └──────────────────┴─────────────────┘              │
│                      │                                      │
│                      ▼                                      │
│              ┌─────────────────┐                           │
│              │   API Service   │                           │
│              │  (HTTP Client)  │                           │
│              └─────────────────┘                           │
└─────────────────┬───────────────────────────────────────────┘
                  │ HTTP/HTTPS
                  ▼
┌─────────────────────────────────────────────────────────────┐
│                   BACKEND (Node.js)                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │    Routes    │  │  Controllers │  │  Middleware  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                 │              │
│         └──────────────────┴─────────────────┘              │
│                      │                                      │
│                      ▼                                      │
│              ┌─────────────────┐                           │
│              │    MongoDB      │                           │
│              │  (Base de datos)│                           │
│              └─────────────────┘                           │
└─────────────────────────────────────────────────────────────┘
```

---

## 📂 UBICACIONES DE ARCHIVOS

```
Desktop/
│
├── EvaStrong/                          ← Frontend Flutter
│   ├── lib/
│   │   ├── main.dart                   ← Punto de entrada
│   │   ├── services/
│   │   │   └── api_service.dart        ← Cliente HTTP
│   │   ├── providers/
│   │   │   ├── auth_provider.dart      ← Lógica de autenticación
│   │   │   └── subscription_provider.dart ← Lógica de suscripciones
│   │   └── ...
│   ├── pubspec.yaml                    ← Dependencias
│   ├── android/                        ← Config Android
│   ├── ios/                            ← Config iOS
│   ├── web/                            ← Config Web
│   ├── build/                          ← Compilados
│   └── DOCUMENTACION_*.md              ← Esta documentación
│
└── EvaStrong-Backend/                  ← Backend Node.js
    ├── server.js                       ← Punto de entrada
    ├── config/
    │   └── passport.js                 ← Estrategias OAuth
    ├── models/
    │   ├── User.js                     ← Modelo de usuario
    │   ├── Payment.js                  ← Modelo de pagos
    │   └── Subscription.js             ← Modelo de suscripciones
    ├── routes/
    │   ├── auth.js                     ← Rutas de autenticación
    │   ├── users.js                    ← Rutas de usuarios
    │   ├── payments.js                 ← Rutas de pagos
    │   └── subscriptions.js            ← Rutas de suscripciones
    ├── middleware/
    │   └── auth.js                     ← Verificación de JWT
    ├── package.json                    ← Dependencias
    ├── .env                            ← Variables de ambiente
    └── README.md                       ← Documentación del backend
```

---

## 🎨 COLORES Y TEMA

### Paleta de Colores
```
Púrpura Principal:    #6D28D9
Lila Secundario:      #B46BFF
Fondo Oscuro:         #2E1065
```

### Material Design 3
- **Tema claro:** Blanco con acentos púrpura/lila
- **Tema oscuro:** Gris oscuro con acentos púrpura/lila
- **Tipografía:** Sistema moderno y limpio
- **Iconografía:** Material Icons

---

## 👤 USUARIOS Y ROLES

### Tipos de Usuarios

1. **Usuario Gratuito (Free)**
   - Acceso a pantalla de inicio
   - No puede ver rutinas completas
   - Puede cambiar a plan de pago

2. **Usuario Básico (Basic)**
   - Acceso a rutinas básicas
   - Seguimiento de ejercicios
   - Duración: 1 mes (renovable)

3. **Usuario Premium**
   - Acceso a todas las rutinas
   - Planes personalizados
   - Seguimiento avanzado
   - Duración: 1 mes o 1 año

---

## 🔐 SEGURIDAD

### Autenticación
- **OAuth 2.0** para Google y Apple
- **JWT tokens** para mantener sesión
- **Contraseñas hasheadas** con bcrypt
- **Tokens de expiración** (7 días por defecto)

### Encriptación
- **HTTPS** en producción
- **Helmet** para headers de seguridad
- **CORS** configurado
- **Rate limiting** (100 requests/15 min)

### Validación
- **Express-validator** para inputs
- **Mongoose schemas** en base de datos
- **Sanitización** de datos

---

## 💰 MONETIZACIÓN

### Planes y Precios

| Plan | Mensual | Anual | Características |
|------|---------|-------|-----------------|
| Free | Gratis | - | Acceso básico |
| Basic | $499 ARS | $4,490 ARS | Rutinas básicas |
| Premium | $999 ARS | $8,990 ARS | Todo incluido |

### Proceso de Pago
1. Usuario selecciona plan
2. Backend crea preferencia en Mercado Pago
3. Usuario completa pago (tarjeta/transferencia)
4. Mercado Pago envía webhook
5. Backend procesa y activa suscripción
6. Usuario obtiene acceso premium

---

## 📈 ESTADÍSTICAS DEL PROYECTO

| Métrica | Valor |
|---------|-------|
| Líneas de código (Frontend) | ~500 |
| Líneas de código (Backend) | ~1,500 |
| Endpoints API | 20+ |
| Modelos de datos | 3 |
| Providers Flutter | 2 |
| Pantallas | 3 |
| Plataformas soportadas | 6 |
| Tamaño APK | 18-20 MB |
| Tamaño Web | ~5 MB |

---

## ✅ CHECKLIST DE FEATURES

### Completadas
- ✅ Autenticación OAuth Google
- ✅ Autenticación OAuth Apple
- ✅ Registro/Login manual
- ✅ Gestión de perfiles
- ✅ JWT tokens
- ✅ Integración Mercado Pago
- ✅ Gestión de suscripciones
- ✅ Cambio de planes
- ✅ Reembolsos
- ✅ Webhooks
- ✅ UI Material 3
- ✅ Tema púrpura/lila
- ✅ Icono personalizado
- ✅ Multiplataforma

### Por Hacer (Opcionales)
- ⬜ Chat con soporte
- ⬜ Notificaciones push
- ⬜ Gamificación (badges/achievements)
- ⬜ Comunidad (foros/grupos)
- ⬜ Video tutoriales
- ⬜ Integración con wearables
- ⬜ Análiticas avanzadas

---

## 📞 PRÓXIMOS PASOS

1. **Revisar documentación frontend** → DOCUMENTACION_03_FRONTEND.md
2. **Revisar documentación backend** → DOCUMENTACION_04_BACKEND.md
3. **Instalar y configurar** → DOCUMENTACION_05_INSTALACION.md
4. **Entender flujos** → DOCUMENTACION_06_FLUJOS.md
5. **Empezar desarrollo** → DOCUMENTACION_07_DESARROLLO.md

---

**Versión:** 1.0.0  
**Última actualización:** 2026-01-08  
**Estado:** ✅ Producción
