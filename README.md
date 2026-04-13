# EvaStrong — App de Fitness Femenino

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![i18n](https://img.shields.io/badge/i18n-ES%20%2F%20EN-green.svg)]()
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-pink.svg)]()

**App de fitness dirigida a mujeres — entrenamiento personalizado, planes de dieta, voz entrenadora y estilo visual premium.**

[Características](#características) • [Arquitectura](#arquitectura) • [Instalación](#instalación) • [API](#integración-con-el-backend) • [Pantallas](#pantallas)

</div>

---

## Características

### Entrenamiento personalizado
- Rutinas adaptadas al nivel y objetivo de cada usuaria (free, basic, premium, exclusive)
- Fases de calentamiento, entrenamiento principal y enfriamiento
- Series, repeticiones y descansos configurables por ejercicio
- GIFs demostrativos de cada ejercicio (Wikimedia Commons)
- **Voz entrenadora** en tiempo real (flutter_tts, es-MX): anuncios de ejercicio, conteo regresivo, frases motivacionales
- Indicador de series con progreso visual, temporizador circular animado y glassmorphism

### Experiencia visual premium
- Fondo animado con degradado oscuro por fase (calentamiento / principal / enfriamiento)
- **Glassmorphism** con `BackdropFilter` blur en todas las cards
- Tipografía de alta costura: Cormorant Garamond (títulos), Raleway (UI), Playfair Display (frases motivacionales)
- Colores de marca: vibrantPink (#FF69B4), cosmicRed (#D71E49), wellnessPurple (#800080)
- Partículas decorativas (`particles_fly`) y degradados animados (`animate_gradient`)
- Dialog de transición de fase con animación scale+fade

### Planes de nutrición
- Catálogo de planes de dieta categorizados
- Recetas con ingredientes, instrucciones y macros
- Recomendaciones personalizadas por objetivo

### Sistema de suscripciones
| Plan | Nivel | Acceso |
|------|-------|--------|
| Free | `free` | Rutinas básicas |
| Básico ($9.99) | `basic` | + Rutinas intermedias |
| Premium ($19.99) | `premium` | + Rutinas avanzadas |
| Elite ($29.99) | `exclusive` | Acceso total |

- Pagos con MercadoPago y PayPal
- Dialog premium luxury con animación de entrada

### Internacionalización (i18n)
- Español e inglés — detección automática por preferencia guardada
- `AppStrings.of(context)` en todas las pantallas
- Traducciones de nombres de ejercicios, zonas musculares, tags de rutina y UI completa
- Backend: `?lang=en` en endpoints de rutinas

### Chat y comunidad
- Chat de soporte con entrenadores
- Salas de grupo y mensajería directa

### Logros y progreso
- Sistema de logros desbloqueables
- Historial de entrenamientos completados
- Gamificación y seguimiento de racha

### Otros
- Perfil de usuario con métricas de rendimiento
- Integración con wearables
- Pantalla de feedback (estrellas + categorías)
- Notificaciones de renovación vía WhatsApp (Twilio)
- Almacenamiento seguro con `flutter_secure_storage`

---

## Arquitectura

### Stack
- **Framework:** Flutter 3.0+ (Dart)
- **State management:** Provider
- **Almacenamiento local:** flutter_secure_storage + SharedPreferences
- **HTTP:** http package con interceptores JWT
- **Voz:** flutter_tts (entrenadora)
- **Animaciones:** animate_gradient, particles_fly, AnimationController
- **Tipografía:** google_fonts (Cormorant Garamond, Raleway, Playfair Display, Great Vibes)
- **Backend:** Node.js REST API en Render.com

### Estructura del proyecto
```
lib/
├── main.dart                        # App shell, TabBar, drawer, Home + Contact tabs
├── l10n/
│   └── app_strings.dart             # Sistema i18n ES/EN (AppStrings.of(context))
├── theme/
│   └── eva_colors.dart              # Paleta completa EvaColors + temas claro/oscuro
├── screens/
│   ├── routine_execution_screen.dart  # Ejecución de rutina (voz, timer, glassmorphism)
│   ├── routines_screen.dart           # Catálogo de rutinas + dialog premium
│   ├── diet_plans_screen.dart         # Planes de nutrición
│   ├── diet_screen.dart               # Detalle de dieta y recetas
│   ├── achievements_screen.dart       # Logros y progreso
│   ├── chat_screen.dart               # Chat con entrenadores
│   ├── feedback_screen.dart           # Feedback de usuarias
│   ├── payments_screen.dart           # Suscripciones y pagos
│   ├── settings_screen.dart           # Idioma, notificaciones, cuenta
│   ├── user_profile_screen.dart       # Perfil y métricas
│   ├── wearables_screen.dart          # Integración wearables
│   └── contact_screen.dart            # Información de contacto
├── services/
│   ├── routine_service.dart           # GET /routines con lang param
│   ├── routine_recommendation_service.dart  # Rutina personalizada
│   ├── exercise_gif_service.dart      # GIFs por ejercicio (Wikimedia)
│   ├── exercise_instructions_service.dart   # Instrucciones bilingüe paso a paso
│   ├── voice_coach_service.dart       # TTS entrenadora (singleton)
│   ├── history_service.dart           # Historial de entrenamientos
│   ├── favorites_service.dart         # Rutinas favoritas
│   ├── diet_service.dart              # Planes de dieta
│   ├── chat_service.dart              # Mensajería
│   ├── payment_service.dart           # MercadoPago / PayPal
│   └── secure_auth_service.dart       # JWT + secure storage
├── providers/
│   └── language_provider.dart         # LanguageProvider (SharedPreferences)
└── widgets/
    └── protected_screen.dart          # SubscriptionGate + AdminDenied screens
```

---

## Pantallas

| Pantalla | Descripción |
|----------|-------------|
| Home | Degradado animado, partículas, logo EVA STRONG, carrusel, planes de suscripción, acciones glassmorphism |
| Rutinas | Catálogo filtrable, rating, dialog premium luxury, rutina personalizada |
| Ejecución | Timer circular, voz entrenadora, GIF ejercicio, series, instrucciones, glassmorphism por fase |
| Dietas | Planes de nutrición y recetas con macros |
| Logros | Historial, gamificación, racha |
| Chat | Mensajería con entrenadores y salas de grupo |
| Perfil | Métricas personales, foto, ajustes |
| Contacto | Redes sociales con glassmorphism y gradientes |
| Configuración | Idioma (ES/EN), notificaciones, seguridad |
| Feedback | Estrellas + categorías + comentario libre |

---

## Instalación

### Requisitos
- Flutter 3.0+
- Dart 3.0+
- Android SDK API 24+ / iOS 12.0+
- Backend corriendo (local o Render.com)

### Pasos

```bash
# 1. Clonar
git clone https://github.com/charliepinilla777/evastrong-front.git
cd evastrong-front

# 2. Dependencias
flutter pub get

# 3. Ejecutar (desarrollo local con backend local)
flutter run --dart-define=APP_DEBUG=true

# 4. Ejecutar contra backend en Render
flutter run
```

### Build de producción

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## Integración con el backend

El frontend se conecta a [evastrong-backend](https://github.com/charliepinilla777/evastrong-backend) (desplegado en Render.com).

### Endpoints principales usados

| Endpoint | Uso |
|----------|-----|
| `POST /auth/register` | Registro (valida 8 chars + mayúscula + dígito) |
| `POST /auth/login` | Login JWT |
| `GET /routines?lang=en` | Rutinas con localización |
| `GET /routines/:id?lang=en` | Detalle de rutina |
| `POST /routines/:id/rate` | Calificar rutina (atómico) |
| `GET /diet-recommendations` | Planes de dieta |
| `GET /recipes` | Recetas |
| `POST /feedback` | Enviar feedback |
| `GET /subscriptions/current` | Suscripción activa |
| `POST /payments/create-preference` | Crear pago MercadoPago |

> Nota: Render.com free tier tiene cold start de ~30-50s tras inactividad.

---

## Seguridad

- JWT almacenado en `flutter_secure_storage` (Keychain/Keystore)
- Sin credenciales ni claves en el código fuente
- `.env`, `.claude/`, `keys/` excluidos del repositorio
- Sin rutas ni pantallas de administración en la app cliente

---

## Licencia

© 2024-2026 Carlos Andres Pinilla. Todos los derechos reservados.

Queda prohibido copiar, modificar o distribuir este código sin autorización escrita del propietario. Ver [LICENSE](LICENSE).

---

<div align="center">

Desarrollado por [Carlos Andres Pinilla](https://github.com/charliepinilla777)

</div>
