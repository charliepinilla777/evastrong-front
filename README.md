# 🏋️ EvaStrong - Fitness App Frontend

> A modern, secure Flutter application for fitness enthusiasts with professional 3D effects, administrative dashboard, and real-time backend integration.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![3D Effects](https://img.shields.io/badge/3D_Effects-Professional-pink.svg)]()
[![Admin Dashboard](https://img.shields.io/badge/Admin_Dashboard-Real_Time-orange.svg)]()

---

## Features

### Professional 3D Effects System
- Elegant Pink Gradient Theme: Sophisticated color palette with pink-only gradients
- 3D Components: Cards, buttons, text, and icons with depth effects
- Glassmorphism Effects: Modern glass-like UI elements
- Neon Effects: Dynamic lighting and glow effects
- Shadows & Elevation: Multi-layered shadows for depth perception
- Gradient Text: Beautiful text effects with shader masks

### Authentication & Security
- Secure JWT-based authentication with 7-day token expiration
- Automatic token refresh without user interruption
- OAuth integration ready (Google, Apple)
- Encrypted credential storage using native Keychain/Keystore
- Input validation and sanitization
- Admin Authentication: Secure admin login with JWT tokens

### Advanced User Profiles
- Photo Upload: Gallery and camera integration for profile pictures
- Personal Information: Name, age, and performance tracking
- Performance Metrics: 0-100 scale with visual indicators
- Achievement System: Track user accomplishments
- Profile Management: Complete CRUD operations for user data

### Workout Management
- Browse and filter workout routines by category and difficulty
- 8 workout categories: Strength, Cardio, Flexibility, HIIT, Pilates, Yoga, Crossfit, Functional
- 4 difficulty levels: Beginner, Intermediate, Advanced, Expert
- Detailed exercise information with sets, reps, and rest times
- 5-star rating system for routines
- View counter to track popularity

### Video Library
- Upload and manage fitness videos (up to 500MB)
- Multiple video format support (MP4, WebM, MOV, AVI, MKV)
- Progressive video streaming (no full download required)
- Exercise categorization and tagging
- Video ratings with user comments
- Search functionality

### Subscription & Payments
- Multiple subscription tiers: Free, Basic, Premium
- Mercado Pago integration for secure payments
- Access control based on subscription level
- Transaction history and receipts
- Subscription Management: Track active, expiring, and expired subscriptions

### Administrative Dashboard
- Real-time Statistics: Live data from backend
- User Analytics: Total users, active users, new registrations
- Revenue Tracking: Daily/monthly revenue and sales data
- Achievement Monitoring: Track user accomplishments
- Subscription Management: Monitor and send renewal reminders
- Traffic Analytics: User sessions and engagement metrics
- Feedback System: User satisfaction and response management
- Interactive Charts: 7-day traffic trends with custom visualizations
- Action Controls: Send reminders and respond to feedback

---

## Architecture

### Tech Stack
- Frontend: Flutter (Dart)
- State Management: Provider pattern
- Local Storage: flutter_secure_storage (encrypted)
- HTTP Client: http package with custom interceptors
- Image Processing: image_picker for profile photos
- 3D Effects: Custom Effects3DService system
- Backend: Node.js REST API
- Database: MongoDB
- Payments: Mercado Pago API
- Authentication: JWT with Bearer tokens

### Project Structure
```
lib/
├── main.dart
├── screens/
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── routines_screen.dart
│   ├── videos_screen.dart
│   ├── video_upload_screen.dart
│   ├── payment_screen.dart
│   ├── profile_screen.dart
│   ├── user_profile_screen.dart          # Advanced user profiles
│   ├── admin_login_screen.dart           # Admin authentication
│   ├── admin_dashboard_screen.dart       # Administrative dashboard
│   ├── profile_setup_screen.dart
│   ├── support_chat_screen.dart
│   ├── achievements_screen.dart
│   ├── community_screen.dart
│   ├── video_tutorials_screen.dart
│   └── wearables_screen.dart
├── services/
│   ├── api_service_v2.dart
│   ├── secure_storage_service.dart
│   ├── routine_service.dart
│   ├── video_service.dart
│   ├── payment_service.dart
│   ├── user_profile_service.dart         # Profile management
│   ├── admin_service.dart                # Backend integration
│   └── effects_3d_service.dart           # 3D effects system
├── providers/
│   ├── auth_provider_v2.dart
│   ├── payment_provider.dart
│   └── subscription_provider.dart
├── theme/
│   └── eva_colors.dart                    # Color system
└── widgets/
    ├── routine_card.dart
    ├── video_card.dart
    ├── pricing_cards.dart
    └── [3D Components]                    # 3D UI components
```

---

## Getting Started

### Prerequisites
- Flutter 3.0 or higher
- Dart 3.0 or higher
- Android SDK (API level 24+)
- iOS 12.0 or higher
- Backend server running on `http://localhost:5000`

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/charliepinilla777/evastrong-front.git
cd evastrong-front
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure environment**
Create `.env` file:
```env
BACKEND_URL=http://localhost:5000
ENVIRONMENT=development
MERCADO_PAGO_PUBLIC_KEY=your_public_key
```

4. **Run the app**
```bash
flutter run -d web-server --web-port=8080
```

### Building for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

---

## Security Features

- **Encrypted Storage**: Credentials stored securely in Keychain/Keystore
- **Secure Communications**: HTTPS in production
- **Token Management**: JWT with automatic refresh
- **Input Validation**: Client-side and server-side validation
- **Rate Limiting**: API protection against brute force
- **CORS Protection**: Properly configured cross-origin access
- **XSS Prevention**: Input sanitization
- **Admin Authentication**: Role-based access control
- **Image Security**: Safe image upload and processing

---

## Key Features in Detail

### 3D Effects System
1. **Gradient Components**: Beautiful pink gradients throughout the app
2. **Shadow Effects**: Multi-layered shadows for depth
3. **Glass Effects**: Modern glassmorphism UI elements
4. **Interactive Animations**: Smooth transitions and hover effects
5. **Custom Components**: Reusable 3D widgets

### User Profile Management
1. **Photo Upload**: Camera or gallery selection
2. **Profile Editing**: Name, age, performance metrics
3. **Achievement Tracking**: Visual progress indicators
4. **Data Validation**: Input validation and error handling
5. **Secure Storage**: Encrypted profile data storage

### Administrative Dashboard
1. **Real-time Data**: Live statistics from backend
2. **User Analytics**: Comprehensive user metrics
3. **Revenue Tracking**: Financial performance data
4. **Subscription Management**: Active and expiring subscriptions
5. **Feedback System**: User satisfaction tracking
6. **Action Controls**: Send reminders and responses
7. **Interactive Charts**: Custom data visualizations

### Authentication Flow
1. User registers with email and password
2. Backend validates and creates JWT token
3. Token stored securely in encrypted storage
4. Token automatically refreshed before expiration
5. Graceful logout clears all credentials
6. **Admin Access**: Separate authentication for dashboard

---

## Testing

```bash
# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test
flutter test test/services/api_service_test.dart

# Test admin functionality
flutter test test/services/admin_service_test.dart
```

---

## Supported Platforms

| Platform | Version | Status | 3D Effects | Admin Dashboard |
|----------|---------|--------|------------|-----------------|
| Android  | 7.0+    | | | |
| iOS      | 12.0+   | | | |
| Web      | Latest  | | | |
| Windows  | 10+     | Planned | Planned | Planned |

---

## Backend Integration

### API Endpoints
- **Authentication**: `/api/auth/login`, `/api/auth/register`
- **User Management**: `/api/users/*`
- **Admin Dashboard**: `/api/admin/*`
- **Subscriptions**: `/api/subscriptions/*`
- **Payments**: `/api/payments/*`
- **Profiles**: `/api/profiles/*`

### Admin Dashboard Endpoints
- `GET /api/admin/users/stats` - User statistics
- `GET /api/admin/revenue/stats` - Revenue data
- `GET /api/admin/achievements/stats` - Achievement metrics
- `GET /api/admin/subscriptions/stats` - Subscription data
- `GET /api/admin/traffic/stats` - Traffic analytics
- `GET /api/admin/feedback/stats` - Feedback metrics
- `POST /api/admin/subscriptions/send-reminder` - Send reminders
- `POST /api/admin/feedback/respond` - Respond to feedback

---

## License

© 2024-2025 Carlos Andres Pinilla. Todos los derechos reservados.

Este software es propiedad exclusiva de Carlos Andres Pinilla. Queda estrictamente prohibido copiar, modificar, distribuir o usar este código sin autorización escrita previa del propietario. Ver archivo [LICENSE](LICENSE) para más detalles.

---

## Backend Repository

Frontend connects to: [evastrong-backend](https://github.com/charliepinilla777/evastrong-backend)

---

## Support

- **Issues**: [GitHub Issues](https://github.com/charliepinilla777/evastrong-front/issues)
- **Discussions**: [GitHub Discussions](https://github.com/charliepinilla777/evastrong-front/discussions)

---

## Documentation

- [Setup Guide](docs/SETUP.md)
- [API Integration](docs/API.md)
- [Architecture](docs/ARCHITECTURE.md)
- [3D Effects Guide](DOCUMENTACION_02_EFECTOS_3D.md)
- [Backend Connection](DOCUMENTACION_03_DASHBOARD_BACKEND.md)
- [Complete Implementation](DOCUMENTACION_04_IMPLEMENTACION_COMPLETA.md)
- [Contributing](CONTRIBUTING.md)

---

## Recent Updates

### Latest Features (v2.0)
- Professional 3D Effects System with elegant pink gradients
- Advanced User Profiles with photo upload and performance tracking
- Administrative Dashboard with real-time backend integration
- Admin Authentication with secure JWT tokens
- Real-time Analytics with interactive charts
- Feedback Management system
- Subscription Reminders functionality
- Live Data Updates from backend

### Technical Improvements
- Enhanced error handling with fallback to mock data
- Optimized HTTP requests with proper headers
- Secure token management for admin access
- Improved UI consistency with 3D effects
- Better user experience with loading states
- Comprehensive documentation and guides

---

<div align="center">

**Desarrollado por [Carlos Andres Pinilla](https://github.com/charliepinilla777)**

**© 2024-2025 Todos los derechos reservados**

</div>


# Deployment Update
- 2026-02-05 16:35:49
