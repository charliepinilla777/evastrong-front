# 📋 Checklist de Publicación en Google Play Store - Eva Strong

## ✅ Configuración Técnica Completada

### 1. Build Release (AAB)
- ✅ **AAB generado**: `build/app/outputs/bundle/release/app-release.aab` (93.9 MB)
- ✅ **Firmado con keystore**: `android/evastrong-release.jks`
- ✅ **Certificado válido hasta**: 25/06/2053
- ✅ **Package name**: `com.evastrong.app`
- ✅ **Versión**: `1.0.0+1` (versionName: 1.0.0, versionCode: 1)

### 2. Configuración Android
- ✅ **App name**: "Eva Strong"
- ✅ **Ícono**: Configurado en `mipmap-*/ic_launcher.png`
- ✅ **Permisos añadidos**:
  - `INTERNET` (conexión al backend)
  - `CAMERA` (para subir fotos de perfil)
  - `READ_MEDIA_IMAGES` (galería Android 13+)
  - `READ_EXTERNAL_STORAGE` (galería Android ≤12)
  - `WRITE_EXTERNAL_STORAGE` (Android ≤9)
- ✅ **NDK version**: 27.0.12077973
- ✅ **MinifyEnabled**: true (reduce tamaño del APK)

---

## 📝 Pasos para Publicar en Play Store

### Paso 1: Crear Cuenta de Google Play Developer
1. Ve a: https://play.google.com/console/signup
2. Paga la tarifa única de **$25 USD** (registro de desarrollador).
3. Completa tu perfil de desarrollador.

---

### Paso 2: Crear Nueva Aplicación en Play Console

1. **Accede a Play Console**: https://play.google.com/console
2. Haz clic en **"Crear aplicación"**
3. Completa los datos básicos:
   - **Nombre de la app**: `Eva Strong`
   - **Idioma predeterminado**: Español (Latinoamérica)
   - **Tipo de app**: Aplicación
   - **Gratis o de pago**: Gratis
4. Acepta las declaraciones de Play Store.

---

### Paso 3: Preparar Assets Gráficos

#### 📱 **Ícono de la aplicación** (obligatorio)
- **Formato**: PNG (sin transparencia)
- **Tamaño**: 512x512 px
- **Ubicación actual**: Ya configurado en Android (`ic_launcher`)
- ⚠️ **Recomendación**: Verifica que el ícono sea profesional y representativo.

#### 🖼️ **Feature Graphic** (obligatorio)
- **Formato**: JPG o PNG de 24 bits (sin transparencia)
- **Tamaño**: 1024x500 px
- **Descripción**: Banner horizontal para la página de la tienda
- ❌ **Pendiente**: Crear este gráfico

#### 📸 **Screenshots** (mínimo 2, máximo 8)
- **Formato**: JPG o PNG de 24 bits
- **Tamaño**: Entre 320px y 3840px (largo o ancho)
- **Relación de aspecto**: 16:9 o 9:16
- ❌ **Pendiente**: Capturar screenshots de las pantallas principales:
  - Login/Registro
  - Dashboard principal
  - Perfil de usuario
  - Planes de entrenamiento
  - Rutinas/Videos

#### 🎥 **Video promocional** (opcional)
- **Formato**: URL de YouTube
- ❌ **Pendiente**: Opcional

---

### Paso 4: Completar Ficha de la Tienda

#### **Título y Descripción**
```
Título corto (máx. 30 caracteres):
Eva Strong

Título completo (máx. 50 caracteres):
Eva Strong - Fitness & Entrenamiento

Descripción corta (máx. 80 caracteres):
Tu app de fitness personalizada con rutinas, planes y seguimiento completo

Descripción completa (máx. 4000 caracteres):
Eva Strong es tu compañera perfecta para alcanzar tus objetivos de fitness y transformación corporal.

🏋️‍♀️ CARACTERÍSTICAS PRINCIPALES:
• Planes de entrenamiento personalizados para mujeres
• Biblioteca de rutinas y ejercicios con videos demostrativos
• Seguimiento de progreso y métricas
• Perfil personalizado con fotos de antes/después
• Sistema de membresías (Básica, Premium, VIP)
• Interfaz moderna con visualización 3D

💪 ¿POR QUÉ EVA STRONG?
Eva Strong fue diseñada pensando en las necesidades de las mujeres que buscan un estilo de vida saludable y activo. Desde principiantes hasta atletas avanzadas, nuestra app se adapta a tu nivel.

✨ FUNCIONALIDADES:
• Acceso a rutinas categorizadas (Fuerza, Cardio, Flexibilidad)
• Videos de alta calidad para cada ejercicio
• Sistema de membresías con beneficios exclusivos
• Perfil personalizado con seguimiento visual
• Soporte y comunidad

📱 PLANES DISPONIBLES:
• BÁSICA: Acceso a rutinas esenciales
• PREMIUM: Rutinas avanzadas + seguimiento personalizado
• VIP: Todo incluido + asesoría directa

Descarga Eva Strong hoy y comienza tu transformación. 💜
```

#### **Categoría**
- **Categoría principal**: Salud y bienestar
- **Categoría secundaria**: Deportes (opcional)

#### **Tags/Palabras clave**
```
fitness, entrenamiento, mujeres, rutinas, gym, ejercicio, salud, bienestar, fuerza, cardio
```

---

### Paso 5: Configurar Contenido de la Aplicación

#### **1. Privacidad**
- ❌ **Política de privacidad**: Debes crear una y proporcionar URL pública
  - Debe incluir: datos recopilados, uso de datos, almacenamiento, terceros (backend, Google Fonts)
  - Herramientas gratuitas: https://www.freeprivacypolicy.com/

#### **2. Clasificación de contenido**
- Completa el cuestionario de clasificación
- Eva Strong probablemente sea: **PEGI 3 / Everyone**
- Sin violencia, sin contenido sexual, sin lenguaje ofensivo

#### **3. Seguridad de datos**
- Declara qué datos recopilas:
  - ✅ Información personal (nombre, email)
  - ✅ Fotos (para perfil)
  - ✅ Información de salud/fitness (opcional según features)
- Indica si compartes datos con terceros (backend en Render)
- Especifica si permites eliminar cuenta

#### **4. Público objetivo**
- **Edad objetivo**: 13+ (o 18+ si incluyes contenido sensible)
- **Contenido para niños**: No

#### **5. Contacto del desarrollador**
- Email de soporte público (ej: `soporte@evastrong.app` o tu email)
- Sitio web (opcional pero recomendado)

---

### Paso 6: Configurar Versión de Producción

#### **1. Subir AAB**
1. En Play Console, ve a **"Producción"** > **"Crear nueva versión"**
2. Sube el archivo: `build/app/outputs/bundle/release/app-release.aab`
3. Play Store validará el archivo automáticamente

#### **2. Notas de la versión**
```
Versión 1.0.0 - Lanzamiento inicial
• Acceso a rutinas y planes de entrenamiento
• Sistema de membresías (Básica, Premium, VIP)
• Perfil personalizado con fotos
• Visualización 3D y diseño moderno
• Conexión segura al backend
```

#### **3. Revisar warnings**
- Play Store puede mostrar advertencias sobre:
  - **Permisos sensibles** (CAMERA, STORAGE): Justifica su uso en el formulario
  - **Tamaño del APK**: 93.9 MB (normal para apps con 3D y assets)

---

### Paso 7: Configurar Precios y Distribución

#### **1. Países disponibles**
- Selecciona países donde quieres publicar (ej: Colombia, Latinoamérica, Global)

#### **2. Tipo de distribución**
- **Gratis**: La app es gratuita (monetización interna con membresías)
- **De pago**: Cobras por descargar (no aplica)

#### **3. Contenido de la app**
- ❌ **¿Contiene anuncios?**: No (o sí, según tu implementación)
- ❌ **¿Ofrece compras dentro de la app?**: Sí (membresías Premium/VIP)
  - Debes configurar productos en Google Play Billing si monetizas vía Google

---

### Paso 8: Pruebas Internas/Cerradas (Opcional pero recomendado)

Antes de publicar en producción, puedes crear un **track de prueba interna**:

1. Ve a **"Pruebas internas"** en Play Console
2. Sube el AAB
3. Agrega testers (emails de confianza)
4. Prueba que todo funcione (login, backend, membresías, etc.)
5. Recopila feedback

---

### Paso 9: Enviar a Revisión

1. Completa **todos los apartados obligatorios** (marcados con asterisco rojo en Play Console)
2. Haz clic en **"Revisar versión"**
3. Revisa el resumen de la app
4. Haz clic en **"Iniciar lanzamiento en producción"**

**⏱️ Tiempo de revisión**: Entre 1-7 días (generalmente 24-48 horas)

---

## 🔒 Seguridad del Keystore

### ⚠️ IMPORTANTE: Protege tu Keystore

El archivo `android/evastrong-release.jks` y `android/key.properties` contienen:
- **storePassword**: `puma2026`
- **keyPassword**: `puma2026`
- **keyAlias**: `evastrong`

**Nunca pierdas este keystore**. Si lo pierdes:
- ❌ No podrás actualizar la app en Play Store
- ❌ Tendrás que crear una nueva app con otro package name

**Recomendaciones**:
1. ✅ Haz backup del `.jks` en una ubicación segura (USB, nube privada)
2. ✅ **NO** subas `key.properties` ni `.jks` a Git (ya están en `.gitignore`)
3. ✅ Guarda las contraseñas en un gestor de contraseñas (1Password, Bitwarden, etc.)

---

## 🚀 Después de la Publicación

### Monitoreo
1. **Instala la app desde Play Store** para verificar que funcione
2. Monitorea reseñas y responde a usuarios
3. Revisa métricas en Play Console (descargas, crashes, ANRs)

### Actualizaciones Futuras
Para publicar una nueva versión:

1. Incrementa la versión en `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # versionName: 1.0.1, versionCode: 2
   ```

2. Genera nuevo AAB:
   ```powershell
   cd C:\Users\Carlos\evastrong-front
   & "C:\Users\Carlos\dev\flutter\bin\flutter.bat" build appbundle --release
   ```

3. Sube a Play Console (nueva versión) y publica

---

## 📋 Resumen de Pendientes

### ✅ Completado
- [x] AAB firmado y listo
- [x] Permisos configurados
- [x] Configuración Android completa
- [x] Keystore seguro y respaldado

### ❌ Por Hacer
- [ ] Crear cuenta de Google Play Developer ($25 USD)
- [ ] Diseñar Feature Graphic (1024x500 px)
- [ ] Capturar screenshots (mínimo 2, recomendado 4-6)
- [ ] Redactar política de privacidad
- [ ] Configurar email de soporte
- [ ] Completar formularios de Play Console
- [ ] Subir AAB y enviar a revisión

---

## 🔗 Enlaces Útiles

- **Play Console**: https://play.google.com/console
- **Documentación oficial**: https://developer.android.com/distribute/console
- **Política de privacidad generador**: https://www.freeprivacypolicy.com/
- **Asset Studio (íconos)**: https://romannurik.github.io/AndroidAssetStudio/

---

## 📞 Soporte

Si tienes dudas durante el proceso de publicación:
1. Consulta la ayuda de Play Console (botón "?" en cada sección)
2. Revisa la documentación oficial de Google
3. Contacta al desarrollador del proyecto

---

**¡Éxito con el lanzamiento de Eva Strong! 💪💜**
