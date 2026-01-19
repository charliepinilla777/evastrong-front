# 🚀 EVA STRONG - INSTALACIÓN PASO A PASO

## 📋 REQUISITOS PREVIOS

Antes de empezar, verifica que tienes instalado:

- **Node.js 18+** → [Descargar](https://nodejs.org)
- **Flutter** → [Descargar](https://flutter.dev/docs/get-started/install)
- **MongoDB** → [Descargar](https://www.mongodb.com/try/download/community)
- **Git** (opcional) → [Descargar](https://git-scm.com)

### Verificar instalación

```bash
# Node.js
node --version        # v18.0.0 o superior
npm --version         # 8.0.0 o superior

# Flutter
flutter --version     # 3.0.0 o superior
dart --version        # 2.18.0 o superior

# MongoDB
mongod --version      # 5.0.0 o superior
```

---

## 🔧 PASO 1: INSTALAR MONGODB

### Windows - Opción A: Local

1. **Descargar** → https://www.mongodb.com/try/download/community
2. **Instalar** archivo .msi
3. **Iniciar**:
   ```bash
   mongod
   ```

### Windows - Opción B: MongoDB Atlas (Cloud) ⭐ RECOMENDADO

1. Registrarse en https://www.mongodb.com/cloud/atlas
2. Crear proyecto y cluster
3. Obtener connection string
4. Guardar en .env:
   ```
   MONGODB_ATLAS_URI=mongodb+srv://user:pass@cluster.mongodb.net/evastrong
   ```

---

## 📦 PASO 2: INSTALAR BACKEND

```bash
cd C:\Users\Carlos\Desktop\EvaStrong-Backend

# Instalar dependencias
npm install

# Copiar template de variables
copy .env.example .env

# Editar .env con tus valores
notepad .env
```

**Campos obligatorios en .env:**
```
MONGODB_URI=mongodb://localhost:27017/evastrong
JWT_SECRET=tu_secreto_muy_largo_aleatorio
GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=xxxxx
MERCADO_PAGO_ACCESS_TOKEN=APP_xxxxx
PORT=5000
```

**Iniciar backend:**
```bash
npm run dev
```

✅ Backend en http://localhost:5000

---

## 📱 PASO 3: INSTALAR FLUTTER

1. Descargar desde https://flutter.dev/docs/get-started/install
2. Extraer en C:\flutter
3. Agregar C:\flutter\bin a PATH
4. Verificar:
   ```bash
   flutter --version
   flutter doctor
   ```

---

## 🎨 PASO 4: CONFIGURAR FRONTEND

```bash
cd C:\Users\Carlos\Desktop\EvaStrong

# Instalar dependencias
flutter pub get

# Verificar api_service.dart tiene URL correcta:
# static const String baseUrl = 'http://localhost:5000';
```

---

## ▶️ PASO 5: EJECUTAR LA APP

```bash
# En navegador Chrome
flutter run -d chrome

# O en emulador Android
flutter run -d android-emulator

# O en Windows
flutter run -d windows
```

---

## 🔑 PASO 6: CONFIGURAR GOOGLE OAUTH

1. Ir a https://console.cloud.google.com
2. Crear proyecto: "Eva Strong"
3. Habilitar "Google+ API"
4. Crear credenciales OAuth 2.0
5. URIs autorizados:
   ```
   http://localhost:5000
   http://localhost:5000/auth/google/callback
   ```
6. Copiar en .env:
   ```
   GOOGLE_CLIENT_ID=xxx
   GOOGLE_CLIENT_SECRET=xxx
   ```

---

## 💳 PASO 7: CONFIGURAR MERCADO PAGO

1. Registrarse en https://www.mercadopago.com.ar
2. Ir a Configuración → Credenciales
3. Copiar Access Token y Public Key
4. En .env:
   ```
   MERCADO_PAGO_ACCESS_TOKEN=APP_xxxxx
   MERCADO_PAGO_PUBLIC_KEY=APP_xxxxx
   ```
5. Webhook: http://localhost:5000/payments/webhook

---

## ✅ CHECKLIST FINAL

- [ ] MongoDB corriendo: `mongod`
- [ ] Backend corriendo: `npm run dev`
- [ ] Frontend corriendo: `flutter run`
- [ ] .env configurado
- [ ] Google OAuth configurado
- [ ] Mercado Pago configurado

---

## 🚀 PRIMERA EJECUCIÓN

**Terminal 1:**
```bash
mongod
```

**Terminal 2:**
```bash
cd EvaStrong-Backend
npm run dev
```

**Terminal 3:**
```bash
cd EvaStrong
flutter run -d chrome
```

¡Listo! La app debería estar en http://localhost:xxxxx

---

**Próxima sección:** DOCUMENTACION_06_FLUJOS.md
