# 📱 GUÍA: EMULADOR DE iOS EN WINDOWS - EVASTRONG

**Fecha**: 30 de Enero 2026  
**Objetivo**: Renderizar la app en emulador iOS desde Windows  

---

## 🎯 Opciones Disponibles

### Opción 1: Appetize.io (RECOMENDADA) ⭐⭐⭐⭐⭐
- **Costo**: Gratuito (hasta cierto uso) / Pago opcionales
- **Facilidad**: Muy fácil, todo en navegador
- **Compatibilidad**: Perfecto para Windows
- **Velocidad**: Muy rápido
- **Ventaja**: No requiere instalación

### Opción 2: Corellium ⭐⭐⭐⭐
- **Costo**: $30-99/mes (prueba 14 días gratuita)
- **Facilidad**: Muy fácil
- **Compatibilidad**: Windows, Mac, Linux
- **Velocidad**: Muy rápido
- **Ventaja**: Profesional

### Opción 3: UTM + iOS VM (Gratuito) ⭐⭐⭐
- **Costo**: Gratuito
- **Facilidad**: Complejo
- **Compatibilidad**: Windows 11 Pro
- **Velocidad**: Medio
- **Requisito**: Mucho setup

### Opción 4: Remote iOS Simulator (Si tienes Mac)
- **Costo**: Gratuito
- **Facilidad**: Fácil
- **Compatibilidad**: Windows + Mac en red
- **Velocidad**: Muy rápido

---

## 🚀 OPCIÓN 1: Appetize.io (RECOMENDADA)

### Paso 1: Compilar para iOS Simulator

```bash
cd C:\Users\Carlos\Desktop\EvaStrong
flutter clean
flutter pub get
flutter build ios --simulator
```

**Output esperado:**
```
Building iOS app for simulator...
✓ Built build/ios/iphonesimulator
```

### Paso 2: Preparar el Archivo

```bash
# Navegar a la carpeta
cd build/ios/iphonesimulator

# Opción A: Con 7-Zip (si tienes instalado)
7z a -tgzip evastrong.app.tar.gz Runner.app

# Opción B: Con PowerShell (nativo)
Compress-Archive -Path Runner.app -DestinationPath evastrong.app.zip
```

### Paso 3: Subir a Appetize.io

1. Abre https://appetize.io en tu navegador
2. Haz clic en "Upload an app"
3. Selecciona el archivo comprimido
4. Elige el dispositivo (iPhone 14, iPhone 13, etc.)
5. Haz clic en "Upload"
6. Espera 30-60 segundos
7. ¡Haz clic en "Play"!

### Paso 4: Usar el Emulador

- **Click**: Clic del ratón = toque en pantalla
- **Drag**: Arrastrar = deslizar
- **Scroll**: Rueda del ratón = scroll
- **Home**: Tecla H = botón home
- **Console**: Abre la consola del navegador para logs

---

## 🌐 OPCIÓN 2: Corellium (Premium)

### Paso 1: Registrarse

1. Ve a https://www.corellium.com
2. Crea una cuenta
3. Usa prueba gratuita (14 días)

### Paso 2: Crear Instancia

1. Dashboard → "Create Instance"
2. Selecciona iOS
3. Elige versión (15, 16, 17)
4. Espera 2-3 minutos

### Paso 3: Conectar Flutter

```bash
# Flutter debería detectar el dispositivo
flutter devices

# Ejecutar la app
flutter run
```

---

## 💡 Flujo Recomendado (Appetize.io)

### Primera vez:
```bash
# 1. Compilar
flutter build ios --simulator

# 2. Comprimir
cd build/ios/iphonesimulator
Compress-Archive -Path Runner.app -DestinationPath evastrong.app.zip

# 3. Ir a https://appetize.io
# 4. Subir archivo
# 5. ¡Jugar!
```

### Cambios posteriores:
```bash
# Solo recompila y sube
flutter build ios --simulator
# ... comprimir y subir nuevamente
```

---

## 📊 Comparativa

| Opción | Costo | Facilidad | Windows | Velocidad |
|--------|-------|-----------|---------|-----------|
| Appetize | Gratis | ⭐⭐⭐⭐⭐ | ✅ | Muy rápido |
| Corellium | Pago | ⭐⭐⭐⭐⭐ | ✅ | Muy rápido |
| UTM | Gratis | ⭐⭐ | ⚠️ | Medio |
| Remote iOS | Gratis | ⭐⭐⭐⭐ | ✅ (con Mac) | Muy rápido |

---

## ⚠️ Problemas Comunes

### "Build failed"
```bash
flutter clean
flutter pub get
flutter build ios --simulator -v
```

### "Archivo no se comprime"
```bash
# Usar tar manualmente
cd build/ios/iphonesimulator
tar -czf evastrong.tar.gz Runner.app
```

### "La app se ve mal"
- Verifica que `isDebugMode = true` en `app_config.dart`
- Prueba en diferentes dispositivos virtuales
- Revisa la consola del navegador

---

## ✅ Checklist

- [ ] Flutter instalado
- [ ] `flutter build ios --simulator` compila sin errores
- [ ] Archivo comprimido creado
- [ ] Cuenta en Appetize.io (gratuita)
- [ ] Archivo subido y app ejecutándose
- [ ] Probaste login

---

## 🎯 Script PowerShell (Automático)

Crea: `C:\Users\Carlos\Desktop\build_ios_appetize.ps1`

```powershell
Write-Host "🍎 Compilando para iOS..." -ForegroundColor Green

# 1. Compilar
flutter clean
flutter pub get
flutter build ios --simulator

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilación exitosa" -ForegroundColor Green
    
    # 2. Comprimir
    cd build/ios/iphonesimulator
    Compress-Archive -Path Runner.app -DestinationPath evastrong.app.zip -Force
    
    # 3. Copiar al Desktop
    Copy-Item evastrong.app.zip C:\Users\Carlos\Desktop\
    
    Write-Host "✅ Archivo listo en Desktop: evastrong.app.zip" -ForegroundColor Green
    Write-Host "📤 Siguiente: Sube a https://appetize.io" -ForegroundColor Cyan
} else {
    Write-Host "❌ Error en compilación" -ForegroundColor Red
}
```

**Ejecutar:**
```powershell
cd C:\Users\Carlos\Desktop\EvaStrong
..\build_ios_appetize.ps1
```

---

## 🚀 Resumen Rápido

```
1. flutter build ios --simulator
   ↓
2. Comprimir Runner.app
   ↓
3. Ir a appetize.io
   ↓
4. Subir archivo
   ↓
5. ¡Click en Play!
   ↓
6. Probar app en emulador iOS
```

---

## 📞 Enlaces

- **Appetize.io**: https://appetize.io
- **Corellium**: https://www.corellium.com
- **Flutter Docs**: https://flutter.dev/docs

---

**Recomendación**: Usa **Appetize.io** - es gratuito, fácil y perfecto para Windows.

¿Necesitas ayuda con algún paso?
