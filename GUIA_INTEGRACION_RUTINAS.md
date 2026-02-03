# 🚀 Guía de Integración: Sistema de Rutinas Personalizadas

## 📋 Resumen de la Implementación

He creado un sistema completo de rutinas personalizadas que se integra perfectamente con tu backend existente. El sistema incluye:

### ✅ **Componentes Creados:**

1. **`routine_recommendation_service.dart`** - Servicio completo para API de rutinas
2. **`profile_setup_screen.dart`** - Pantalla de configuración de perfil
3. **`routines_screen.dart`** - Pantalla principal de rutinas
4. **`routine_execution_screen.dart`** - Pantalla de ejecución con timer
5. **Configuración actualizada** - URLs en `app_config.dart`

---

## 🔧 **Paso 1: Preparar el Backend**

### 1.1 Cargar los datos semilla:
```bash
# En la carpeta del backend
cd EvaStrong-Backend
npm run seed
```

### 1.2 Verificar que el backend esté corriendo:
```bash
npm run dev
# Debería mostrar: "Eva Strong Backend - Iniciado"
```

### 1.3 Probar endpoints (opcional):
```bash
# Probar endpoint de recomendaciones
curl http://localhost:5000/routine-recommendations/templates

# Probar endpoint de ejercicios
curl http://localhost:5000/exercises
```

---

## 📱 **Paso 2: Integrar en el Frontend**

### 2.1 Agregar las nuevas pantallas a tu `main.dart`:

```dart
import 'screens/routines_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/routine_execution_screen.dart';

// En tu MaterialApp, agrega las rutas:
routes: {
  '/routines': (context) => const RoutinesScreen(),
  '/profile-setup': (context) => const ProfileSetupScreen(),
  '/routine-execution': (context) => const RoutineExecutionScreen(),
},
```

### 2.2 Agregar navegación desde tu menú principal:

```dart
// En tu drawer o menú principal
ListTile(
  leading: const Icon(Icons.fitness_center),
  title: const Text('Mis Rutinas'),
  onTap: () {
    Navigator.pushNamed(context, '/routines');
  },
),
```

---

## 🎯 **Paso 3: Flujo de Usuario**

### 3.1 Primer Uso:
1. Usuario entra a "Mis Rutinas"
2. Sistema detecta que no tiene perfil
3. Redirige automáticamente a "Configurar Perfil"
4. Usuario completa su información
5. Sistema genera rutina personalizada automáticamente

### 3.2 Uso Regular:
1. Usuario ve su rutina personalizada en la pestaña "Para Ti"
2. Puede explorar otras plantillas en "Explorar"
3. Puede ejecutar la rutina con timer integrado
4. Puede actualizar su perfil cuando sea necesario

---

## 🔧 **Paso 4: Configuración de Ambiente**

### 4.1 Desarrollo (Backend Local):
```dart
// En app_config.dart
static const bool isDebugMode = true;
// Usará: http://localhost:5000
```

### 4.2 Producción (Backend en Render):
```dart
// En app_config.dart
static const bool isDebugMode = false;
// Usará: https://evastrong-backend.onrender.com
```

---

## 📊 **Paso 5: Estructura de Datos**

### 5.1 Perfil de Usuario:
```dart
UserProfile {
  ageRange: "18-35" | "36-55" | "55+",
  constitution: "bajo_peso" | "normopeso" | "sobrepeso" | "obesidad",
  fitnessLevel: "beginner" | "intermediate" | "advanced",
  kneeSensitive: bool,
  pathologies: "ninguna" | "cardiaca" | "respiratoria" | "metabolica" | "otra",
  dailyTime: 10 | 15 | 20
}
```

### 5.2 Rutina Personalizada:
```dart
PersonalizedRoutine {
  name: String,
  description: String,
  duration: int, // minutos
  mainCycles: int,
  blocks: {
    calentamiento: Exercise[],
    principal: Exercise[],
    enfriamiento: Exercise[]
  }
}
```

---

## 🎮 **Paso 6: Características Implementadas**

### ✅ **Pantalla de Configuración:**
- Formulario completo con validaciones
- Selectores para todas las opciones
- Guardado automático en backend
- Manejo de errores

### ✅ **Pantalla Principal:**
- Two tabs: "Para Ti" y "Explorar"
- Rutina personalizada automática
- Filtros para plantillas
- Actualización con pull-to-refresh

### ✅ **Pantalla de Ejecución:**
- Timer animado y preciso
- Indicadores de progreso
- Controles de pausa/siguiente
- Transiciones entre fases
- Diálogos de confirmación

### ✅ **Servicio Completo:**
- Todos los endpoints del backend
- Manejo de autenticación
- Gestión de errores
- Modelos de datos tipados

---

## 🔍 **Paso 7: Pruebas y Validación**

### 7.1 Probar Conexión:
```bash
# En el emulador o dispositivo físico
# Abrir Flutter DevTools
# Revisar pestaña Network para verificar llamadas API
```

### 7.2 Verificar Endpoints:
- ✅ GET `/routine-recommendations/profile`
- ✅ PUT `/routine-recommendations/profile`
- ✅ GET `/routine-recommendations/personalized`
- ✅ GET `/routine-recommendations/templates`
- ✅ POST `/routine-recommendations/generate`

### 7.3 Probar Flujo Completo:
1. Configurar perfil
2. Ver rutina generada
3. Ejecutar rutina
4. Explorar plantillas
5. Generar desde plantilla

---

## 🚨 **Paso 8: Solución de Problemas**

### 8.1 Error de Conexión:
```dart
// Verificar que AppConfig.backendUrl sea correcta
print(AppConfig.backendUrl);
```

### 8.2 Error de Autenticación:
```dart
// Verificar token almacenado
final token = await SecureStorageService.getToken();
print('Token: $token');
```

### 8.3 Error de Carga:
```dart
// Revisar respuesta del backend
try {
  final response = await RoutineRecommendationService.getPersonalizedRoutine();
  print(response);
} catch (e) {
  print('Error: $e');
}
```

---

## 🎨 **Paso 9: Personalización Visual**

### 9.1 Colores y Temas:
```dart
// Los colores principales son:
Colors.purple    // Color primario
Colors.orange     // Calentamiento
Colors.purple     // Principal
Colors.blue       // Enfriamiento
```

### 9.2 Iconos:
- `Icons.fitness_center` - Ejercicios
- `Icons.timer` - Tiempo
- `Icons.settings` - Configuración
- `Icons.refresh` - Actualizar

---

## 📱 **Paso 10: Deploy y Producción**

### 10.1 Verificar Configuración:
```dart
// Asegurar que isDebugMode = false para producción
static const bool isDebugMode = false;
```

### 10.2 Probar en Producción:
1. Cambiar a modo producción
2. Probar conexión con backend en Render
3. Verificar todas las funcionalidades

---

## 🎯 **Resumen de Integración**

### ✅ **¿Qué tienes que hacer?**

1. **Copiar los archivos** creados a tu proyecto
2. **Actualizar main.dart** con las nuevas rutas
3. **Agregar navegación** desde tu menú principal
4. **Configurar ambiente** (desarrollo/producción)
5. **Probar el flujo** completo

### ✅ **¿Qué ya está hecho?**

- ✅ Servicio API completo
- ✅ Modelos de datos
- ✅ Pantallas funcionales
- ✅ Navegación y flujo
- ✅ Manejo de errores
- ✅ Timer y animaciones
- ✅ Diseño responsive

### 🚀 **¡Listo para usar!**

El sistema está completamente funcional y listo para integrarse con tu aplicación existente. Solo necesitas copiar los archivos y agregar las rutas de navegación.

---

## 📞 **Soporte**

Si tienes algún problema durante la integración:

1. **Revisa la consola** para errores de conexión
2. **Verifica el backend** esté corriendo
3. **Confirma los tokens** de autenticación
4. **Prueba los endpoints** individualmente

¡El sistema de rutinas personalizadas está listo para revolucionar la experiencia de tus usuarias! 🎉💪
