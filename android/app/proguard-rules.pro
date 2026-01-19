# Reglas base para Flutter
# Flutter ya agrega reglas necesarias, aquí solo mantenemos lo esencial y evitamos warnings.

# Mantén clases del embedding
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Kotlin metadata (suele evitar warnings)
-dontwarn kotlin.**

# Si agregas plugins que usen reflection, añade sus reglas aquí.
