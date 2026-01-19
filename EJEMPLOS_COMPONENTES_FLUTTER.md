# 🛠️ EJEMPLOS DE COMPONENTES FLUTTER - COPIAR Y PEGAR

Esta guía contiene componentes listos para usar que puedes copiar directamente a tu proyecto.

---

## 1️⃣ TARJETA DE PLANES/PRECIOS

```dart
Widget _buildPricingCard(
  String planName,
  String price,
  List<String> features,
  VoidCallback onTap,
  ColorScheme scheme,
  bool isPopular,
) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: isPopular ? scheme.primary : Colors.grey[300]!,
        width: isPopular ? 3 : 1,
      ),
      borderRadius: BorderRadius.circular(16),
      color: isPopular ? scheme.primary.withValues(alpha: 0.1) : Colors.white,
    ),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '⭐ MÁS POPULAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            planName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '\$$price/mes',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(feature)),
              ],
            ),
          )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? scheme.primary : Colors.grey[300],
              ),
              child: Text(
                'SELECCIONAR',
                style: TextStyle(
                  color: isPopular ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```

---

## 2️⃣ TARJETA DE RUTINA/ENTRENAMIENTO

```dart
Widget _buildWorkoutCard(
  String title,
  String duration,
  String difficulty,
  String description,
  VoidCallback onTap,
  ColorScheme scheme,
) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: 0.8),
              scheme.secondary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      difficulty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.timer, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    duration,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
```

---

## 3️⃣ DIÁLOGO/MODAL

```dart
void _showConfirmDialog(
  String title,
  String message,
  VoidCallback onConfirm,
  ColorScheme scheme,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
          ),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );
}

// Usar:
_showConfirmDialog(
  '¿Comprar plan?',
  'Confirma tu compra del plan Premium',
  () => print('Comprado'),
  scheme,
);
```

---

## 4️⃣ BARRA DE PROGRESO CIRCULAR

```dart
Widget _buildCircularProgress(
  double progress,
  String label,
  ColorScheme scheme,
) {
  return Column(
    children: [
      SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              backgroundColor: Colors.grey[300],
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Text(label),
    ],
  );
}

// Usar:
_buildCircularProgress(0.75, 'Progreso', scheme);
```

---

## 5️⃣ BOTÓN CON ICONO

```dart
Widget _buildIconButton(
  IconData icon,
  String label,
  VoidCallback onTap,
  ColorScheme scheme,
) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [scheme.primary, scheme.secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

// Usar:
_buildIconButton(Icons.fitness_center, 'Rutinas', () {}, scheme);
```

---

## 6️⃣ LISTA DE LOGROS/ACHIEVEMENTS

```dart
Widget _buildAchievementItem(
  String title,
  String description,
  IconData icon,
  bool unlocked,
  ColorScheme scheme,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: unlocked
          ? scheme.primary.withValues(alpha: 0.2)
          : Colors.grey[200],
      border: Border.all(
        color: unlocked ? scheme.primary : Colors.grey,
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unlocked ? scheme.primary : Colors.grey,
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        if (unlocked)
          Icon(Icons.check_circle, color: scheme.primary)
        else
          const Text('🔒', style: TextStyle(fontSize: 20)),
      ],
    ),
  );
}

// Usar:
_buildAchievementItem(
  'Primer Paso',
  'Completa tu primer entrenamiento',
  Icons.directions_run,
  true,
  scheme,
);
```

---

## 7️⃣ CAMPO DE BÚSQUEDA

```dart
Widget _buildSearchBar(
  TextEditingController controller,
  ColorScheme scheme,
) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: 'Buscar entrenamientos...',
      prefixIcon: Icon(Icons.search, color: scheme.primary),
      suffixIcon: controller.text.isNotEmpty
          ? GestureDetector(
              onTap: () {
                controller.clear();
              },
              child: Icon(Icons.clear, color: scheme.primary),
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary),
      ),
    ),
    onChanged: (value) {
      setState(() {});
    },
  );
}
```

---

## 8️⃣ TARJETA DE USUARIO/PERFIL

```dart
Widget _buildUserCard(
  String name,
  String email,
  String avatar,
  VoidCallback onEdit,
  ColorScheme scheme,
) {
  return Card(
    elevation: 0,
    color: scheme.primary.withValues(alpha: 0.1),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(avatar),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            label: const Text('Editar Perfil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
            ),
          ),
        ],
      ),
    ),
  );
}
```

---

## 9️⃣ TARJETA CON ESTADÍSTICAS

```dart
Widget _buildStatCard(
  String label,
  String value,
  String unit,
  IconData icon,
  ColorScheme scheme,
) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        colors: [
          scheme.primary.withValues(alpha: 0.8),
          scheme.secondary.withValues(alpha: 0.8),
        ],
      ),
    ),
    child: Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// Usar en grid:
GridView.count(
  crossAxisCount: 2,
  children: [
    _buildStatCard('Calorías', '450', 'kcal', Icons.local_fire_department, scheme),
    _buildStatCard('Duración', '45', 'min', Icons.timer, scheme),
    _buildStatCard('Ritmo', '120', 'bpm', Icons.favorite, scheme),
    _buildStatCard('Puntos', '280', 'pts', Icons.star, scheme),
  ],
)
```

---

## 🔟 SLIDER/DESLIZADOR

```dart
Widget _buildSlider(
  double value,
  double min,
  double max,
  String label,
  ValueChanged<double> onChanged,
  ColorScheme scheme,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('${value.toStringAsFixed(0)}'),
        ],
      ),
      const SizedBox(height: 8),
      Slider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
        activeColor: scheme.primary,
        inactiveColor: Colors.grey[300],
      ),
    ],
  );
}

// Usar:
_buildSlider(50, 0, 100, 'Intensidad', (val) {
  setState(() {
    intensity = val;
  });
}, scheme);
```

---

## ✅ TOGGLE/INTERRUPTOR

```dart
Widget _buildToggle(
  String label,
  bool value,
  ValueChanged<bool> onChanged,
  ColorScheme scheme,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label),
      Switch(
        value: value,
        onChanged: onChanged,
        activeColor: scheme.primary,
      ),
    ],
  );
}

// Usar:
_buildToggle('Notificaciones', true, (value) {
  setState(() {
    notificationsEnabled = value;
  });
}, scheme);
```

---

## 🚀 CÓMO USAR ESTOS COMPONENTES

1. **Copiar** el código del componente que necesitas
2. **Pegarlo** en tu `main.dart` dentro de la clase `_HomeScreenState`
3. **Llamarlo** desde donde lo necesites

Ejemplo:
```dart
// En _buildHomeTab o cualquier método
Widget resultado = _buildPricingCard(
  'Plan Premium',
  '999',
  ['Rutinas ilimitadas', 'Sin anuncios'],
  () => print('Comprado'),
  scheme,
  true,
);
```

---

**¿Necesitas más componentes o tienes dudas sobre cómo usarlos?** 🎯
