# 🚀 INICIO RÁPIDO - FRONTEND EVA STRONG

## 📱 ESTADO ACTUAL DE LA APP

✅ **App corriendo en:** http://localhost:54321  
✅ **Plataforma:** Web (Chrome)  
✅ **Nombre:** Eva Strong  
✅ **Paleta:** Púrpura/Lila  
✅ **Fondos:** 3 SVG profesionales (Women's Power, Motivational, Energy)  

---

## 📂 ARCHIVOS PRINCIPALES

| Archivo | Ubicación | Función |
|---------|-----------|---------|
| **main.dart** | `lib/main.dart` | Código principal de la app |
| **pubspec.yaml** | `pubspec.yaml` | Dependencias y configuración |
| **Fondos SVG** | `assets/backgrounds/` | 3 fondos profesionales |
| **API Service** | `lib/services/api_service.dart` | Conexión con backend |

---

## 🎨 MODIFICACIONES RÁPIDAS

### Cambiar Colores

Edita estas líneas en `lib/main.dart` (líneas 11-13):

```dart
static const _brandPurple = Color(0xFF6D28D9);   // Púrpura
static const _brandLilac = Color(0xFFB46BFF);   // Lila
static const _brandDeep = Color(0xFF2E1065);    // Oscuro
```

**Ejemplos de nuevos colores:**
```dart
// Rosa vibrante
static const _brandPurple = Color(0xFFFF1493);
static const _brandLilac = Color(0xFFFF69B4);

// Azul
static const _brandPurple = Color(0xFF1E40AF);
static const _brandLilac = Color(0xFF60A5FA);

// Verde
static const _brandPurple = Color(0xFF16A34A);
static const _brandLilac = Color(0xFF86EFAC);
```

### Cambiar Fondo

En `lib/main.dart` línea 118:

```dart
child: SvgPicture.asset(
  'assets/backgrounds/womens_power_bg.svg',  // Cambiar aquí
  fit: BoxFit.cover,
),
```

**Opciones:**
- `womens_power_bg.svg` (Actual - Siluetas femeninas)
- `motivational_bg.svg` (Barras de energía)
- `energy_bg.svg` (Líneas dinámicas)

### Cambiar Textos

| Texto | Línea | Cómo cambiar |
|-------|-------|-------------|
| Título | 152 | `Text('¡Bienvenida a Eva Strong!')` |
| Subtítulo | 171 | `Text('Transforma tu cuerpo\n...')` |
| Botón | 217 | `Text('COMENZAR AHORA')` |
| Beneficios | 236-238 | `_buildBenefitIndicator('💪', 'Fuerza')` |

### Cambiar Icono Principal

En `lib/main.dart` línea 142:

```dart
child: const Icon(
  Icons.favorite,  // Cambiar aquí
  size: 60,
  color: Colors.white,
),
```

**Iconos disponibles:**
```dart
Icons.bolt              // ⚡ Rayo
Icons.star              // ⭐ Estrella
Icons.whatshot          // 🔥 Fuego
Icons.sports_gymnastics // 🤸 Gimnasia
Icons.favorite          // ❤️ Corazón (actual)
Icons.emoji_events      // 🏆 Trofeo
Icons.trending_up       // 📈 Gráfico
Icons.strength          // 💪 Fuerza
```

---

## ➕ AGREGAR NUEVAS PESTAÑAS (TABS)

### Paso 1: Aumentar número de tabs

En `lib/main.dart` línea 88:

```dart
// Cambiar de:
_tabController = TabController(length: 3, vsync: this);

// A:
_tabController = TabController(length: 4, vsync: this);
```

### Paso 2: Agregar tab en la barra

En `lib/main.dart` línea 102-108:

```dart
tabs: const [
  Tab(icon: Icon(Icons.home), text: 'Inicio'),
  Tab(icon: Icon(Icons.fitness_center), text: 'Rutinas'),
  Tab(icon: Icon(Icons.phone), text: 'Contacto'),
  Tab(icon: Icon(Icons.person), text: 'Perfil'),  // ← NUEVA
],
```

### Paso 3: Agregar contenido

En `lib/main.dart` línea 115-120:

```dart
children: [
  _buildHomeTab(scheme),
  _buildComingSoonTab('Rutinas', scheme),
  _buildContactoTab(scheme),
  _buildProfileTab(scheme),  // ← NUEVA
],
```

### Paso 4: Crear método para tab

Agregar este método en `_HomeScreenState`:

```dart
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
      child: Text(
        'Mi Perfil',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
```

---

## 🎯 CAMBIAR ACCIÓN DEL BOTÓN

En `lib/main.dart` línea 208:

```dart
// Actual: Ir a tab Rutinas
onTap: () => _tabController.animateTo(1),

// Alternativas:
// Ir a Tab Perfil
onTap: () => _tabController.animateTo(3),

// Mostrar diálogo
onTap: () => _showDialog('¿Comenzar?', 'Selecciona una rutina'),

// Navegar a nueva pantalla
onTap: () => Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const MiNuevaPantalla()),
),

// Llamar función
onTap: () => _miFunction(),
```

---

## 📦 AGREGAR COMPONENTES LISTOS

He creado un archivo con 10 componentes listos para copiar y pegar:

**Archivo:** `EJEMPLOS_COMPONENTES_FLUTTER.md`

Componentes disponibles:
1. ✅ Tarjeta de Planes/Precios
2. ✅ Tarjeta de Rutina/Entrenamiento
3. ✅ Diálogo/Modal
4. ✅ Barra de Progreso Circular
5. ✅ Botón con Icono
6. ✅ Lista de Logros
7. ✅ Campo de Búsqueda
8. ✅ Tarjeta de Perfil
9. ✅ Tarjeta de Estadísticas
10. ✅ Slider/Deslizador

### Cómo usar:

1. Abre `EJEMPLOS_COMPONENTES_FLUTTER.md`
2. Copia el código del componente
3. Pega en tu `main.dart` dentro de `_HomeScreenState`
4. Usa en cualquier widget

---

## 🔧 GUÍA COMPLETA

Para una referencia completa y detallada:

**Archivo:** `GUIA_FRONTEND_MODIFICACION.md`

Contiene:
- ✅ Estructura completa del proyecto
- ✅ Cómo modificar colores, textos, espacios
- ✅ Cómo agregar formularios
- ✅ Cómo agregar animaciones
- ✅ Cómo cambiar fondos dinámicamente
- ✅ Recursos útiles (iconos, colores)

---

## ⚡ CICLO DE DESARROLLO

### Para cada cambio que hagas:

```bash
# 1. Guarda el archivo (Ctrl+S)

# 2. La app se recarga automáticamente en Chrome
#    (Hot Reload - casi instantáneo)

# 3. Ve el resultado en http://localhost:54321

# 4. Si hay error, verás en la consola
```

---

## 🐛 COMÚN: ERRORES Y SOLUCIONES

### Error: "no matching function"
**Causa:** Sintaxis incorrecta  
**Solución:** Revisa los paréntesis y comas

### Error: "file not found"
**Causa:** Ruta de archivo incorrecta  
**Solución:** Verifica que el archivo existe en `assets/backgrounds/`

### Error: "type mismatch"
**Causa:** Tipo de dato incorrecto (ej: String en lugar de int)  
**Solución:** Verifica los tipos de parámetros

### App se ve distinto en móvil vs web
**Normal:** Flutter es responsive pero puede variar  
**Solución:** Usa `MediaQuery.of(context).size` para ajustar

---

## 📚 ESTRUCTURA PARA PROYECTO GRANDE

Si quieres organizar mejor cuando crezca:

```
lib/
├── main.dart
├── screens/
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   ├── payment_screen.dart
│   └── workout_screen.dart
├── widgets/
│   ├── pricing_card.dart
│   ├── workout_card.dart
│   └── stat_card.dart
├── providers/
│   ├── auth_provider.dart
│   └── subscription_provider.dart
└── services/
    ├── api_service.dart
    └── payment_service.dart
```

---

## 🎨 IDEAS PARA AGREGAR

### Fácil (30 min cada una):
- [ ] Página de "Planes/Precios"
- [ ] Página de "Mis Logros"
- [ ] Página de "Mi Perfil"
- [ ] Página de "Estadísticas"

### Medio (1-2 horas):
- [ ] Sistema de "Mis Entrenamientos" con lista
- [ ] Formulario de "Editar Perfil"
- [ ] Página de "Favoritos"
- [ ] Galería de "Rutinas por Categoría"

### Avanzado (3+ horas):
- [ ] Conexión real con backend (pagos)
- [ ] Sistema de autenticación
- [ ] Notificaciones push
- [ ] Integración Mercado Pago

---

## 📞 SOPORTE

¿Necesitas ayuda con:
- ❓ Modificar algún componente?
- ❓ Agregar nueva pantalla?
- ❓ Conectar con backend?
- ❓ Solucionar error específico?

**¡Cuéntame qué quieres hacer!**

---

## 📊 PRÓXIMAS ACCIONES RECOMENDADAS

1. **Prueba cambiar colores** → Entiende cómo funciona
2. **Agrega una nueva tab** → Practica la estructura
3. **Copia un componente** → Úsalo en tu app
4. **Conecta con backend** → Integra login/pagos
5. **Deploy en Google Play** → Publica tu app

---

**¿Qué quieres hacer ahora?** 🎯

Opciones:
- 🎨 Cambiar colores/tema
- ➕ Agregar nueva pantalla
- 📋 Usar componente lista
- 🔗 Conectar con backend
- 🚀 Deploy/Publicar
