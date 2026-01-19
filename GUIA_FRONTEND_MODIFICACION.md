# 📱 EVA STRONG - GUÍA COMPLETA DEL FRONTEND

## 🎯 ESTRUCTURA DEL PROYECTO

```
EvaStrong/
├── lib/
│   ├── main.dart                          ← ARCHIVO PRINCIPAL
│   ├── providers/
│   │   ├── auth_provider.dart             ← Gestión de autenticación
│   │   ├── payment_provider.dart          ← Gestión de pagos
│   │   └── subscription_provider.dart     ← Gestión de suscripciones
│   ├── screens/
│   │   └── payments_screen.dart           ← Pantalla de pagos
│   ├── services/
│   │   ├── api_service.dart               ← Cliente HTTP
│   │   ├── payment_service.dart           ← Servicio de pagos
│   │   ├── subscription_management_service.dart
│   │   ├── notification_service.dart      ← Notificaciones
│   │   ├── referral_service.dart          ← Sistema de referidos
│   │   ├── invoice_service.dart           ← Facturas
│   │   └── deep_link_service.dart         ← Links profundos
│   └── widgets/
│       └── pricing_cards.dart             ← Tarjetas de precios
├── assets/
│   └── backgrounds/
│       ├── womens_power_bg.svg            ← Fondo actual
│       ├── motivational_bg.svg
│       └── energy_bg.svg
├── pubspec.yaml                           ← Dependencias
└── web/
    ├── index.html
    └── manifest.json
```

---

## 🎨 ARCHIVO PRINCIPAL: main.dart

### Estructura General

```dart
// 1. IMPORTS
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 2. MAIN - Punto de entrada
void main() {
  runApp(const EvaStrongApp());
}

// 3. EvaStrongApp - Widget principal de la app
class EvaStrongApp extends StatelessWidget {
  // Define colores
  // Build tema
  // Retorna MaterialApp
}

// 4. HomeScreen - Pantalla principal
class HomeScreen extends StatefulWidget {
  // Tabs: Inicio, Rutinas, Contacto
}

// 5. _HomeScreenState - Estado de HomeScreen
class _HomeScreenState extends State<HomeScreen> {
  // TabController
  // Métodos para construir cada tab
}
```

---

## 🎨 CONFIGURACIÓN DE COLORES

### Ubicación: `lib/main.dart` líneas 11-13

```dart
static const _brandPurple = Color(0xFF6D28D9);   // Púrpura principal
static const _brandLilac = Color(0xFFB46BFF);   // Lila secundario
static const _brandDeep = Color(0xFF2E1065);    // Fondo oscuro
```

### Cómo Modificar:

**Opción 1: Cambiar valores hex**
```dart
static const _brandPurple = Color(0xFF8B00FF);  // Púrpura más brillante
static const _brandLilac = Color(0xFFFF69B4);   // Rosa vibrante
```

**Opción 2: Usar colores predefinidos**
```dart
static const _brandPurple = Colors.deepPurple;
static const _brandLilac = Colors.purple;
```

**Convertir hex a Color:**
- `#6D28D9` → `Color(0xFF6D28D9)`
- El `FF` al inicio es la opacidad (FF = 100% opaco)

---

## 🏗️ ESTRUCTURA DE TABS

### Cómo funciona:

```dart
// En build() método:
Scaffold(
  appBar: AppBar(
    bottom: TabBar(
      controller: _tabController,
      tabs: const [
        Tab(icon: Icon(Icons.home), text: 'Inicio'),        // Tab 0
        Tab(icon: Icon(Icons.fitness_center), text: 'Rutinas'),  // Tab 1
        Tab(icon: Icon(Icons.phone), text: 'Contacto'),     // Tab 2
      ],
    ),
  ),
  body: TabBarView(
    controller: _tabController,
    children: [
      _buildHomeTab(scheme),           // Tab 0 - Inicio
      _buildComingSoonTab('Rutinas', scheme),  // Tab 1 - Rutinas
      _buildContactoTab(scheme),       // Tab 2 - Contacto
    ],
  ),
);
```

### Agregar Nueva Tab:

```dart
// 1. Cambiar length de TabController
_tabController = TabController(length: 4, vsync: this);  // Era 3

// 2. Agregar nuevo Tab en TabBar
tabs: const [
  Tab(icon: Icon(Icons.home), text: 'Inicio'),
  Tab(icon: Icon(Icons.fitness_center), text: 'Rutinas'),
  Tab(icon: Icon(Icons.phone), text: 'Contacto'),
  Tab(icon: Icon(Icons.person), text: 'Perfil'),  // ← NUEVO
],

// 3. Agregar nuevo widget en TabBarView
children: [
  _buildHomeTab(scheme),
  _buildComingSoonTab('Rutinas', scheme),
  _buildContactoTab(scheme),
  _buildProfileTab(scheme),  // ← NUEVO
],

// 4. Crear método para la nueva tab
Widget _buildProfileTab(ColorScheme scheme) {
  return DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          scheme.secondary.withValues(alpha: 0.90),
          scheme.primary.withValues(alpha: 0.85),
        ],
      ),
    ),
    child: Center(
      child: Text('Contenido de Perfil'),
    ),
  );
}
```

---

## 🎯 PANTALLA DE INICIO: _buildHomeTab()

### Estructura Actual (líneas 110-248):

```
Stack (fondo + contenido)
├── SvgPicture.asset (fondo SVG)
└── Center → SingleChildScrollView → Column
    ├── Icono circular (corazón)
    ├── Título "¡Bienvenida a Eva Strong!"
    ├── Subtítulo motivacional
    ├── Botón "COMENZAR AHORA"
    └── Indicadores (Fuerza, Enfoque, Energía)
```

### Cómo Modificar Texto:

```dart
// Línea 152: Cambiar título
Text(
  '¡Bienvenida a Eva Strong!',  // ← AQUÍ
  style: ...,
),

// Línea 171: Cambiar subtítulo
Text(
  'Transforma tu cuerpo\nFortalece tu mente\nCambia tu vida',  // ← AQUÍ
  style: ...,
),

// Línea 217: Cambiar texto del botón
Text(
  'COMENZAR AHORA',  // ← AQUÍ
  style: ...,
),
```

### Cómo Cambiar Fondo SVG:

```dart
// Línea 118: Cambiar de fondo
child: SvgPicture.asset(
  'assets/backgrounds/womens_power_bg.svg',  // ← OPCIONES:
  // 'assets/backgrounds/motivational_bg.svg'
  // 'assets/backgrounds/energy_bg.svg'
  fit: BoxFit.cover,
),
```

### Cómo Cambiar Icono:

```dart
// Línea 142: Cambiar de icono (actualmente: corazón)
child: const Icon(
  Icons.favorite,  // ← CAMBIAR A:
  // Icons.bolt        (rayo)
  // Icons.star        (estrella)
  // Icons.whatshot    (fuego)
  // Icons.sports_gymnastics  (gimnasia)
  size: 60,
  color: Colors.white,
),
```

### Cómo Cambiar Indicadores de Beneficios:

```dart
// Línea 236-238: Cambiar emojis y texto
_buildBenefitIndicator('💪', 'Fuerza'),      // ← EMOJI, 'TEXTO'
_buildBenefitIndicator('🎯', 'Enfoque'),
_buildBenefitIndicator('⚡', 'Energía'),
```

---

## 🎨 ESTILOS Y TEMAS

### Texto - Ejemplos de Modificación:

```dart
// Cambiar tamaño de fuente
fontSize: 32,  // Aumentar/disminuir número

// Cambiar peso (grosor)
fontWeight: FontWeight.bold,    // bold, w700, w600, normal, w400, w300, etc.

// Cambiar color
color: Colors.white,
// color: Colors.black,
// color: scheme.primary,

// Agregar sombra
shadows: [
  Shadow(
    offset: const Offset(0, 2),  // x, y
    blurRadius: 4,
    color: Colors.black.withValues(alpha: 0.3),
  ),
],
```

### Espaciado:

```dart
const SizedBox(height: 32),    // Espacio vertical
const SizedBox(width: 16),     // Espacio horizontal

// O usar Padding
Padding(
  padding: const EdgeInsets.all(24),  // Todos lados
  // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  // padding: const EdgeInsets.only(top: 16, bottom: 8),
  child: ...,
),
```

### Bordes Redondeados:

```dart
borderRadius: BorderRadius.circular(12),  // Todos iguales
// borderRadius: const BorderRadius.only(
//   topLeft: Radius.circular(16),
//   topRight: Radius.circular(16),
// ),
```

---

## 🔘 BOTONES: Cómo Modificar

### Botón Principal Actual:

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        scheme.primary,
        scheme.secondary,
      ],
    ),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: scheme.primary.withValues(alpha: 0.4),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () => _tabController.animateTo(1),  // ← ACCIÓN AL CLICKEAR
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 48,
          vertical: 16,
        ),
        child: Text('COMENZAR AHORA'),
      ),
    ),
  ),
);
```

### Cambiar Acción del Botón:

```dart
// Opción 1: Navegar a otra tab
onTap: () => _tabController.animateTo(1),  // Rutinas

// Opción 2: Llamar a función
onTap: () => _mostrarDialog(),

// Opción 3: Navegar a pantalla nueva
onTap: () => Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const MiNuevaPantalla()),
),

// Opción 4: Ir a URL
onTap: () => launchUrl(Uri.parse('https://google.com')),
```

---

## 📦 AGREGAR NUEVAS PANTALLAS

### Paso 1: Crear archivo

```dart
// lib/screens/my_new_screen.dart
import 'package:flutter/material.dart';

class MiNuevaPantalla extends StatelessWidget {
  const MiNuevaPantalla({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Pantalla')),
      body: Center(
        child: Text('Contenido aquí'),
      ),
    );
  }
}
```

### Paso 2: Importar en main.dart

```dart
import 'screens/my_new_screen.dart';
```

### Paso 3: Usar la pantalla

```dart
// En un botón
onTap: () => Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const MiNuevaPantalla()),
),
```

---

## 🎬 AGREGAR ANIMACIONES

### Ejemplo: Animación de fade (aparición lenta)

```dart
AnimatedOpacity(
  opacity: _isVisible ? 1.0 : 0.0,
  duration: const Duration(milliseconds: 500),
  child: Text('Aparece/desaparece'),
)
```

### Ejemplo: Escala (crece/encoge)

```dart
AnimatedScale(
  scale: _isExpanded ? 1.2 : 1.0,
  duration: const Duration(milliseconds: 300),
  child: Container(width: 100, height: 100),
)
```

### Ejemplo: Transición de slide

```dart
SlideTransition(
  position: Tween<Offset>(
    begin: const Offset(0, 1),
    end: const Offset(0, 0),
  ).animate(_controller),
  child: Text('Desliza desde abajo'),
)
```

---

## 🌐 CAMBIAR ENTRE FONDOS

### Método 1: Cambio estático (en línea 118)

```dart
child: SvgPicture.asset(
  'assets/backgrounds/womens_power_bg.svg',
  fit: BoxFit.cover,
),
```

### Método 2: Cambio dinámico (con variable)

```dart
// Agregar variable en clase
String _selectedBackground = 'womens_power_bg';

// Usar en build
child: SvgPicture.asset(
  'assets/backgrounds/$_selectedBackground.svg',
  fit: BoxFit.cover,
),

// Cambiar desde botón
ElevatedButton(
  onPressed: () {
    setState(() {
      _selectedBackground = 'energy_bg';
    });
  },
  child: const Text('Cambiar fondo'),
),
```

---

## 📝 AGREGAR FORMULARIOS

### Ejemplo Simple: Campo de email

```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Ingresa tu email',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    prefixIcon: const Icon(Icons.email),
  ),
  controller: _emailController,
),
```

### Ejemplo: Formulario Completo

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        decoration: const InputDecoration(labelText: 'Nombre'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa tu nombre';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            print('Formulario válido');
          }
        },
        child: const Text('Enviar'),
      ),
    ],
  ),
)
```

---

## 🔗 RECURSOS ÚTILES

### Flutter Icons: https://fonts.google.com/icons
### Material Colors: https://material.io/resources/color/
### Flutter Docs: https://flutter.dev/docs

---

## ✨ PRÓXIMAS FUNCIONALIDADES A AGREGAR

- [ ] Pantalla de Planes/Precios
- [ ] Pantalla de Perfil de Usuario
- [ ] Pantalla de Historial de Entrenamientos
- [ ] Pantalla de Logros/Badges
- [ ] Chat/Soporte
- [ ] Notificaciones Push
- [ ] Integración con wearables
- [ ] Mapa de entrenamientos
- [ ] Comunidad/Social

---

**¿Qué quieres modificar o agregar?** 🚀
