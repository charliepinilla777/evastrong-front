# 🚀 Resumen de Configuración para Producción - Eva Strong

## ✅ Cambios Técnicos Aplicados

### 1. **Configuración de Entorno (app_config.dart)**
- ✅ Cambié `isDebugMode` a usar `--dart-define=APP_DEBUG` (por defecto `false`)
- ✅ URLs del backend ahora se configuran por entorno
- ✅ En producción apunta a: `https://evastrong-backend.onrender.com`

**Compilar para desarrollo** (con backend local):
```powershell
flutter run --dart-define=APP_DEBUG=true
```

**Compilar para producción** (backend en Render):
```powershell
flutter build appbundle --release
# APP_DEBUG=false por defecto
```

---

### 2. **Firma de Android (Keystore)**
- ✅ Generado `android/evastrong-release.jks` con validez hasta 2053
- ✅ Creado `android/key.properties` con credenciales
- ✅ Configurado `build.gradle.kts` para firmar automáticamente en release
- ✅ Agregado a `.gitignore` para proteger credenciales

**Credenciales del Keystore**:
```
storePassword: puma2026
keyPassword: puma2026
keyAlias: evastrong
storeFile: C:\Users\Carlos\evastrong-front\android\evastrong-release.jks
```

⚠️ **IMPORTANTE**: Respalda el `.jks` en un lugar seguro. Si lo pierdes, no podrás actualizar la app.

---

### 3. **Configuración Android**
- ✅ NDK version actualizado a `27.0.12077973`
- ✅ Permisos agregados al `AndroidManifest.xml`:
  - `INTERNET` (conexión al backend)
  - `CAMERA` (foto de perfil)
  - `READ_MEDIA_IMAGES` (galería Android 13+)
  - `READ_EXTERNAL_STORAGE` (galería Android ≤12)
  - `WRITE_EXTERNAL_STORAGE` (Android ≤9)
- ✅ App name: "Eva Strong"
- ✅ Package name: `com.evastrong.app`
- ✅ Minify habilitado (reduce tamaño del APK)

---

### 4. **Configuración iOS (preparada, pendiente Mac)**
- ✅ Agregados strings de privacidad en `Info.plist`:
  - `NSCameraUsageDescription`
  - `NSPhotoLibraryUsageDescription`
  - `NSPhotoLibraryAddUsageDescription`
- ✅ Bundle ID: `com.evastrong.app`
- ⏳ **Pendiente**: Build IPA (requiere Mac o servicio CI/CD)

---

### 5. **Assets y Estructura**
- ✅ Creada carpeta `assets/images/` (requerida en `pubspec.yaml`)
- ✅ Íconos configurados en todas las densidades (`mipmap-*`)

---

## 📦 Build Release Generado

### Android (AAB)
- **Archivo**: `build/app/outputs/bundle/release/app-release.aab`
- **Tamaño**: 93.9 MB
- **Firmado**: ✅ Con keystore `evastrong-release.jks`
- **Versión**: 1.0.0+1 (versionName: 1.0.0, versionCode: 1)
- **Estado**: ✅ **Listo para subir a Play Store**

### iOS (IPA)
- ⏳ **Pendiente**: Requiere Xcode en Mac o CI/CD (Codemagic, GitHub Actions)

---

## 🔧 Comandos Útiles

### Generar AAB firmado (Android)
```powershell
cd C:\Users\Carlos\evastrong-front
& "C:\Users\Carlos\dev\flutter\bin\flutter.bat" build appbundle --release
```

### Verificar firma del AAB
```powershell
& "C:\Program Files\Java\jdk-24\bin\jarsigner.exe" -verify -verbose -certs "build\app\outputs\bundle\release\app-release.aab"
```

### Actualizar dependencias
```powershell
flutter pub get
flutter pub upgrade
```

### Incrementar versión (para actualizaciones)
Edita `pubspec.yaml`:
```yaml
version: 1.0.1+2  # 1.0.1 = versionName, 2 = versionCode
```

---

## 📝 Próximos Pasos

### Para publicar en Play Store:
1. ✅ **Revisar** `PLAY_STORE_CHECKLIST.md` (guía completa paso a paso)
2. 📝 Crear cuenta de Google Play Developer ($25 USD)
3. 🎨 Diseñar Feature Graphic (1024x500 px)
4. 📸 Capturar screenshots de la app
5. 📄 Redactar política de privacidad
6. 🚀 Subir AAB a Play Console y enviar a revisión

### Para iOS (cuando tengas Mac):
1. Abrir proyecto en Xcode: `ios/Runner.xcworkspace`
2. Configurar firma con tu Apple Developer Account
3. Generar IPA: `flutter build ipa --release`
4. Subir a App Store Connect con Transporter
5. Completar ficha de App Store y enviar a revisión

---

## 🔐 Seguridad

### Archivos sensibles (NO subir a Git):
- ✅ `android/key.properties`
- ✅ `android/*.jks`
- ✅ `android/*.keystore`
- ✅ `.env` (si usas variables de entorno)

**Ya están en `.gitignore`** ✅

### Backup recomendado:
1. Respalda `android/evastrong-release.jks` en USB o nube privada
2. Guarda las credenciales en un gestor de contraseñas
3. Documenta el proceso de firma para futuros desarrolladores

---

## 📊 Configuración Actual

| Concepto | Valor |
|----------|-------|
| **App Name** | Eva Strong |
| **Package ID (Android)** | com.evastrong.app |
| **Bundle ID (iOS)** | com.evastrong.app |
| **Versión** | 1.0.0+1 |
| **Backend Producción** | https://evastrong-backend.onrender.com |
| **Backend Desarrollo** | http://localhost:5000 |
| **Keystore Alias** | evastrong |
| **Certificado válido hasta** | 25/06/2053 |

---

## 🎯 Estado del Proyecto

### ✅ Completado
- [x] Configuración de entorno por `--dart-define`
- [x] Keystore Android generado y configurado
- [x] Permisos Android agregados
- [x] Privacidad iOS configurada
- [x] Build AAB generado y firmado
- [x] Warnings de build corregidos
- [x] Assets estructura creada
- [x] Documentación completa de publicación

### ⏳ Pendiente (para publicación)
- [ ] Crear cuenta Google Play Developer
- [ ] Diseñar assets gráficos (Feature Graphic, screenshots)
- [ ] Redactar política de privacidad
- [ ] Configurar ficha de Play Store
- [ ] Subir AAB y enviar a revisión
- [ ] Build iOS (requiere Mac)

---

## 📚 Archivos de Referencia

- **Checklist Play Store**: `PLAY_STORE_CHECKLIST.md`
- **Config Backend**: `../evastrong_backend/README.md`
- **App Config**: `lib/config/app_config.dart`
- **Android Manifest**: `android/app/src/main/AndroidManifest.xml`
- **iOS Info.plist**: `ios/Runner/Info.plist`

---

**¡El proyecto está listo para producción! 🎉**

Próximo paso crítico: Revisar `PLAY_STORE_CHECKLIST.md` y empezar con la publicación en Google Play.
