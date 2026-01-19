# 🏋️ EvaStrong - Fitness App Frontend

> A modern, secure Flutter application for fitness enthusiasts. Manage workouts, watch exercise videos, and track your progress with a subscription-based model.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## ✨ Features

### 🔐 **Authentication & Security**
- Secure JWT-based authentication with 7-day token expiration
- Automatic token refresh without user interruption
- OAuth integration ready (Google, Apple)
- Encrypted credential storage using native Keychain/Keystore
- Input validation and sanitization

### 💪 **Workout Management**
- Browse and filter workout routines by category and difficulty
- 8 workout categories: Strength, Cardio, Flexibility, HIIT, Pilates, Yoga, Crossfit, Functional
- 4 difficulty levels: Beginner, Intermediate, Advanced, Expert
- Detailed exercise information with sets, reps, and rest times
- 5-star rating system for routines
- View counter to track popularity

### 🎥 **Video Library**
- Upload and manage fitness videos (up to 500MB)
- Multiple video format support (MP4, WebM, MOV, AVI, MKV)
- Progressive video streaming (no full download required)
- Exercise categorization and tagging
- Video ratings with user comments
- Search functionality

### 💳 **Subscription & Payments**
- Multiple subscription tiers: Free, Basic, Premium
- Mercado Pago integration for secure payments
- Access control based on subscription level
- Transaction history and receipts

### 📱 **User Profile**
- Customizable user profile with fitness information
- Instructor profile for content creators
- Password management and security settings
- Activity history and preferences

---

## 🎯 Architecture

### Tech Stack
- **Frontend**: Flutter (Dart)
- **State Management**: Provider pattern
- **Local Storage**: flutter_secure_storage (encrypted)
- **HTTP Client**: http package with custom interceptors
- **Backend**: Node.js REST API
- **Database**: MongoDB
- **Payments**: Mercado Pago API

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
│   └── profile_screen.dart
├── services/
│   ├── api_service_v2.dart
│   ├── secure_storage_service.dart
│   ├── routine_service.dart
│   ├── video_service.dart
│   └── payment_service.dart
├── providers/
│   ├── auth_provider_v2.dart
│   ├── payment_provider.dart
│   └── subscription_provider.dart
└── widgets/
    ├── routine_card.dart
    ├── video_card.dart
    └── pricing_cards.dart
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.0 or higher
- Dart 3.0 or higher
- Android SDK (API level 24+)
- iOS 12.0 or higher

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
flutter run
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

---

## 🔒 Security Features

- **Encrypted Storage**: Credentials stored securely in Keychain/Keystore
- **Secure Communications**: HTTPS in production
- **Token Management**: JWT with automatic refresh
- **Input Validation**: Client-side and server-side validation
- **Rate Limiting**: API protection against brute force
- **CORS Protection**: Properly configured cross-origin access
- **XSS Prevention**: Input sanitization

---

## 🎬 Key Features in Detail

### Authentication Flow
1. User registers with email and password
2. Backend validates and creates JWT token
3. Token stored securely in encrypted storage
4. Token automatically refreshed before expiration
5. Graceful logout clears all credentials

### Workout Management
1. Browse available routines with filters
2. Select by category and difficulty level
3. View detailed routine with exercises
4. Rate routine after completion
5. Track progress in profile

### Video Management
1. Instructors upload exercise videos
2. Videos are categorized and tagged
3. Users search and filter content
4. Progressive streaming for smooth playback
5. Rate and comment on videos

---

## 🧪 Testing

```bash
# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test
flutter test test/services/api_service_test.dart
```

---

## 📱 Supported Platforms

| Platform | Version | Status |
|----------|---------|--------|
| Android  | 7.0+    | ✅ |
| iOS      | 12.0+   | ✅ |
| Web      | Latest  | 🔄 Planned |
| Windows  | 10+     | 🔄 Planned |

---

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 🐛 Issue Reporting

Found a bug? Please use the [GitHub Issues](https://github.com/charliepinilla777/evastrong-front/issues) tracker:
- Detailed description
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
- Device and Flutter version

---

## 📄 License

This project is licensed under the MIT License.

---

## 🔗 Backend Repository

Frontend connects to: [evastrong-backend](https://github.com/charliepinilla777/evastrong-backend)

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/charliepinilla777/evastrong-front/issues)
- **Discussions**: [GitHub Discussions](https://github.com/charliepinilla777/evastrong-front/discussions)

---

## 📚 Documentation

- [Setup Guide](docs/SETUP.md)
- [API Integration](docs/API.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Contributing](CONTRIBUTING.md)

---

<div align="center">

**Made with ❤️ by [Carlos Andres Pinilla](https://github.com/charliepinilla777)**

⭐ If you find this helpful, please give it a star!

</div>

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
