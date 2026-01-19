# 🔄 EVA STRONG - FLUJOS DE LA APLICACIÓN

## 📊 ¿QUÉ SON LOS FLUJOS?

Los flujos son las **secuencias de acciones** que sigue el usuario dentro de la app.

Ejemplo:
```
Usuario abre app
        ↓
Ve pantalla de inicio
        ↓
Presiona "Login"
        ↓
Ingresa email y contraseña
        ↓
...
        ↓
Ve pantalla principal
```

---

## 🔐 FLUJO 1: REGISTRO E LOGIN

### 1.1 Primer inicio (Usuario nuevo)

```
┌─────────────────────────────────────────────────┐
│ USUARIO ABRE LA APP (Primera vez)               │
└─────────────┬───────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────┐
│ PANTALLA: Bienvenida Eva Strong                 │
│ Opciones:                                       │
│ ├─ Botón: "Registrarse"                        │
│ ├─ Botón: "Login"                              │
│ └─ Botón: "Continuar con Google"               │
└─────────────┬───────────────────────────────────┘
              ↓ (Presiona "Registrarse")
┌─────────────────────────────────────────────────┐
│ PANTALLA: Formulario de Registro                │
│ Campos:                                         │
│ ├─ Email: usuario@example.com                  │
│ ├─ Nombre: Juan Pérez                          │
│ └─ Contraseña: ••••••••• (mín 8 caracteres)   │
└─────────────┬───────────────────────────────────┘
              ↓ (Presiona "Registrarse")
              
FRONTEND              BACKEND              BD
┌─────────────────────────────────────────────────┐
│ 1. Valida datos                                 │
│    ✓ Email válido                              │
│    ✓ Contraseña ≥ 8 caracteres                 │
│    ✓ Nombre no vacío                           │
└──────────┬──────────────────────────────────────┘
           │
           ├─ POST /auth/register
           │  {email, password, name}
           │           ↓
           │  ┌────────────────────────┐
           │  │ 2. Validar email       │
           │  │    ✓ Formato correcto  │
           │  └────────────────────────┘
           │           ↓
           │  ┌────────────────────────┐
           │  │ 3. Verificar email     │
           │  │    ✓ No existe en BD   │
           │  └────────────────────────┘
           │           ↓
           │  ┌────────────────────────┐
           │  │ 4. Hashear password    │
           │  │    password →          │
           │  │    $2b$10$R9h7c...     │
           │  └────────────────────────┘
           │           ↓
           │  ┌────────────────────────┐
           │  │ 5. Crear documento     │
           │  │    User en BD          │
           │  └────────────────────────┘
           │           ↓
           │  ┌────────────────────────┐
           │  │ 6. Generar JWT         │
           │  │    token: eyJh...      │
           │  └────────────────────────┘
           │           ↓
           ├─ Response: {token, user}
           │
           ↓
┌─────────────────────────────────────────────────┐
│ 7. Frontend: guardar token                      │
│    ApiService.setToken(token)                   │
│    AuthProvider.setUserAndToken()               │
│    → _isLoggedIn = true                         │
│    → _token = "eyJh..."                         │
│    → _user = {name, email, ...}                 │
└──────────┬──────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│ 8. AuthProvider notifica widgets                │
│    Consumer<AuthProvider> re-renderiza          │
└──────────┬──────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│ PANTALLA: HomeScreen                            │
│ Usuario autenticado como: "Juan Pérez"          │
│ Muestra:                                        │
│ ├─ Tab 1: Inicio                               │
│ ├─ Tab 2: Rutinas                              │
│ └─ Tab 3: Contacto                             │
└─────────────────────────────────────────────────┘
```

### 1.2 Login (Usuario existente)

```
Usuario presiona "Login" en pantalla de bienvenida
                ↓
Ingresa email y contraseña
                ↓
Frontend: authProvider.login()
                ↓
                POST /auth/login
                    {email, password}
                         ↓
                Backend busca usuario por email
                    ✓ Existe: Juan Pérez
                    ✗ No existe: Error 401
                         ↓ (Existe)
                Comparar password:
                - Ingresado: "contraseña123"
                - En BD: "$2b$10$R9h7c..." (hasheada)
                Comparar con bcrypt
                    ✓ Coinciden
                    ✗ No coinciden: Error 401
                         ↓ (Coinciden)
                Generar nuevo JWT
                Actualizar lastLogin = ahora
                         ↓
                Response: {token, user}
                         ↓
Frontend guarda token y usuario
Frontend navega a HomeScreen
                ↓
ÉXITO: Usuario autenticado
```

### 1.3 Login con Google (OAuth)

```
Usuario presiona "Login con Google"
                ↓
Frontend redirige a Google OAuth
                ↓
Usuario ve pantalla de Google:
"Eva Strong quiere acceder a tu cuenta"
                ↓
Usuario presiona "Permitir"
                ↓
Google redirige a backend:
GET /auth/google/callback?code=xxx
                ↓
Backend obtiene perfil de Google:
{
  id: "1234567890",
  email: "usuario@gmail.com",
  name: "Juan Pérez",
  photo: "https://..."
}
                ↓
Backend busca usuario con googleId = 1234567890
    ✓ Existe: usar ese usuario
    ✗ No existe: crear nuevo usuario
                ↓
Generar JWT token
                ↓
Frontend recibe deep link:
com.evastrong.app://auth?token=xxx&userId=yyy
                ↓
Frontend extrae token y usuario
Frontend guarda en AuthProvider
                ↓
Usuario autenticado ✅
```

---

## 💳 FLUJO 2: COMPRAR SUSCRIPCIÓN

### 2.1 Usuario elige plan

```
Usuario en HomeScreen
                ↓
Presiona Tab "Planes" (o en futuro agregar botón)
                ↓
Ve opciones:
┌──────────────────────────────────┐
│ Free Plan (ACTUAL)               │
│ - Acceso a inicio                │
│ - Botón: "Ya tienes este plan"   │
│ - Botón: "Actualizar"            │
└──────────────────────────────────┘
┌──────────────────────────────────┐
│ Basic Plan ($499/mes)            │
│ - Rutinas básicas                │
│ - Botón: "Comprar Basic"         │
└──────────────────────────────────┘
┌──────────────────────────────────┐
│ Premium Plan ($999/mes)          │
│ - Todo incluido                  │
│ - Botón: "Comprar Premium"       │
└──────────────────────────────────┘
                ↓
Usuario presiona "Comprar Premium"
                ↓
Frontend: subscriptionProvider.createPaymentPreference(
  plan: 'premium',
  period: 'monthly'
)
                ↓
POST /payments/create-preference
{
  plan: 'premium',
  period: 'monthly'
}
                ↓
Backend procesa:
1. Valida que plan exista ✓
2. Calcula precio = $999
3. Crea preferencia en Mercado Pago API:
   {
     items: [{
       title: "Eva Strong Premium - Mensual",
       price: 999,
       quantity: 1
     }],
     payer: {
       email: "usuario@example.com",
       name: "Juan Pérez"
     },
     notification_url: "http://localhost:5000/payments/webhook"
   }
                ↓
Mercado Pago retorna:
{
  preferenceId: "597642781",
  initPoint: "https://www.mercadopago.com/...",
  sandboxUrl: "https://sandbox.mercadopago.com/..."
}
                ↓
Backend guarda Payment en BD:
{
  userId: "xxxxx",
  amount: 999,
  plan: "premium",
  status: "pending",
  mercadoPagoPreferenceId: "597642781"
}
                ↓
Response al frontend:
{
  preferenceId: "597642781",
  initPoint: "https://...",
  sandboxUrl: "https://..."
}
                ↓
Frontend abre URL en navegador:
launchUrl(Uri.parse(initPoint))
                ↓
```

### 2.2 Usuario completa pago

```
Usuario ve pantalla de Mercado Pago
                ↓
Selecciona método de pago:
├─ Tarjeta de crédito
├─ Débito
├─ Transferencia bancaria
└─ Billetera virtual
                ↓
Ingresa datos y paga
                ↓
Mercado Pago procesa pago
                ↓
Si APROBADO:
                ↓
Mercado Pago envía webhook al backend:
POST /payments/webhook
{
  type: 'payment',
  data: { id: 123456789 }
}
                ↓
Backend procesa webhook:
1. Obtiene detalles del pago de MP
   {
     id: 123456789,
     status: 'approved',
     amount: 999,
     ...
   }
2. Busca Payment en BD por ID
3. Actualiza Payment:
   - status = 'approved'
   - approvedAt = ahora
4. Crea Subscription:
   {
     userId: "xxxxx",
     plan: "premium",
     status: "active",
     startDate: ahora,
     endDate: ahora + 1 mes,
     amount: 999
   }
5. Actualiza User:
   - subscription.plan = "premium"
   - subscription.active = true
   - subscription.endDate = fecha
                ↓
Response al usuario en navegador:
"¡Pago exitoso!"
"Bienvenido a Eva Strong Premium"
                ↓
Si RECHAZADO:
                ↓
Mercado Pago envía webhook:
{
  status: 'declined'
}
                ↓
Backend marca Payment como declined
Response: "Pago rechazado, intenta de nuevo"
```

### 2.3 Usuario obtiene acceso

```
Frontend detecta que usuario es Premium:
SubscriptionProvider.isPremium = true
                ↓
UI cambia:
├─ Barra de suscripción muestra "PREMIUM ⭐"
├─ Botón "Comprar" desaparece
├─ Muestra "Acceso Premium hasta: 08/02/2026"
└─ Puede acceder a todas las rutinas
                ↓
Usuario tiene acceso completo
```

---

## 🔄 FLUJO 3: CAMBIAR PLAN

### Usuario Premium quiere actualizar a anual

```
Usuario en pantalla de suscripción
                ↓
Ve: "Plan Premium (Mensual)"
Botón: "Cambiar a Anual"
                ↓
Presiona "Cambiar a Anual"
                ↓
Frontend: subscriptionProvider.changePlan('premium_annual')
                ↓
POST /subscriptions/change-plan
{
  newPlan: "premium"
}
                ↓
Backend:
1. Verifica que usuario tiene suscripción ✓
2. Verifica que plan es diferente ✓
3. Calcula diferencia de precio:
   - Básico (mensual): $499/mes = $5,988/año
   - Premium (mensual): $999/mes = $11,988/año
   - Premium (anual): $8,990/año
4. Si upgrade (basic→premium): cobra diferencia
5. Si downgrade: acredita diferencia
6. Actualiza plan en BD
7. Retorna confirmación
                ↓
Frontend muestra:
"Plan actualizado a Premium Anual"
"Acceso hasta: 08/01/2027"
                ↓
```

---

## ❌ FLUJO 4: CANCELAR SUSCRIPCIÓN

### Usuario quiere cancelar

```
Usuario en pantalla de suscripción
                ↓
Presiona botón "Cancelar suscripción"
                ↓
Aparece diálogo:
"¿Por qué cancelas?"
├─ No tengo dinero
├─ No uso la app
├─ Otra razón
│  └─ [Escribir aquí]
                ↓
Usuario selecciona razón y confirma
                ↓
Frontend: subscriptionProvider.cancelSubscription(
  reason: 'No tengo dinero'
)
                ↓
POST /subscriptions/cancel
{
  reason: 'No tengo dinero'
}
                ↓
Backend:
1. Busca suscripción del usuario ✓
2. Verifica que está activa ✓
3. Marca como cancelada:
   - status = 'cancelled'
   - cancelledAt = ahora
   - cancelReason = "No tengo dinero"
4. Actualiza User:
   - subscription.active = false
5. Retorna confirmación
                ↓
Frontend muestra:
"Suscripción cancelada"
"Vuelves a plan Free"
"Acceso actual hasta: 08/02/2026"
                ↓
Después de la fecha:
- User vuelve a plan Free
- Pierde acceso a Premium
```

---

## 📱 FLUJO 5: ACTUALIZAR PERFIL

### Usuario edita datos personales

```
Usuario presiona "Editar Perfil"
                ↓
Ve formulario con:
├─ Nombre: [Juan Pérez]
├─ Teléfono: [+549...]
├─ Edad: [28]
├─ Género: [Masculino]
├─ Nivel de fitness: [Intermedio]
└─ Objetivos: [✓ Pérdida de peso, ✓ Ganancia de músculo]
                ↓
Usuario cambia:
├─ Edad: 28 → 30
├─ Nivel de fitness: Intermedio → Avanzado
                ↓
Presiona "Guardar"
                ↓
Frontend: authProvider.updateProfile(
  age: 30,
  fitnessLevel: 'advanced'
)
                ↓
PUT /users/profile
{
  age: 30,
  fitnessLevel: 'advanced'
}
                ↓
Backend:
1. Valida datos ✓
2. Busca usuario ✓
3. Actualiza campos permitidos
4. Guarda en BD
5. Retorna usuario actualizado
                ↓
Frontend:
- Actualiza AuthProvider.user
- Notifica widgets
                ↓
UI muestra:
"Perfil actualizado ✓"
"Edad: 30"
"Nivel: Avanzado"
```

---

## 🔐 FLUJO 6: CAMBIAR CONTRASEÑA

### Usuario quiere cambiar password

```
Usuario presiona "Cambiar contraseña"
                ↓
Ve formulario:
├─ Contraseña actual: [••••••••]
└─ Nueva contraseña: [••••••••]
                ↓
Ingresa y presiona "Cambiar"
                ↓
Frontend: authProvider.changePassword(
  currentPassword: 'vieja123',
  newPassword: 'nueva456'
)
                ↓
POST /users/change-password
{
  currentPassword: 'vieja123',
  newPassword: 'nueva456'
}
                ↓
Backend:
1. Obtiene usuario autenticado ✓
2. Compara contraseña actual:
   - Ingresada: 'vieja123'
   - En BD: '$2b$10$...' (hasheada)
   - ✓ Coinciden
3. Valida nueva contraseña ≥ 8 caracteres ✓
4. Hashea nueva contraseña
5. Guarda en BD
6. Retorna éxito
                ↓
Frontend: "Contraseña cambiada ✓"
                ↓
Usuario debe hacer login de nuevo
con la nueva contraseña
```

---

## 🔄 CICLO DE VIDA DE SUSCRIPCIÓN

```
┌──────────────────────────────────────────────────┐
│ USUARIO COMPRA PREMIUM                           │
│ Plan: Premium (Mensual)                          │
│ Fecha inicio: 08/01/2026                         │
│ Fecha fin: 08/02/2026                            │
└──────────────┬───────────────────────────────────┘
               │
               ↓ (10 días después)
┌──────────────────────────────────────────────────┐
│ SUSCRIPCIÓN ACTIVA                               │
│ Usuario tiene acceso completo                    │
│ Días restantes: 20                               │
└──────────────┬───────────────────────────────────┘
               │
               ↓ (29 días después, casi vence)
┌──────────────────────────────────────────────────┐
│ NOTIFICACIÓN                                     │
│ "Tu suscripción vence en 1 día"                  │
│ Botón: "Renovar"                                 │
└──────────────┬───────────────────────────────────┘
               │
    ┌──────────┴──────────┐
    │                     │
    ↓                     ↓
Usuario         Usuario no renueva
presiona
"Renovar"           │
    │               ↓
    ↓      ┌─────────────────────────┐
POST /    │ SUSCRIPCIÓN EXPIRADA     │
subscriptions/    │ Status: expired      │
renew            │ Acceso: cancelado    │
    │             │ Vuelve a Free        │
    ↓             └─────────────────────┘
┌──────────────────────┐
│ RENOVADA             │
│ Nueva fecha fin:     │
│ 08/03/2026           │
│ Acceso: activo       │
└──────────────────────┘
```

---

**Próxima sección:** DOCUMENTACION_07_DESARROLLO.md
