import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  bool _isInitialized = false;

  /// Inicializar notificaciones
  Future<void> init() async {
    if (_isInitialized) return;

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Configuración Android
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración iOS
    final DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    // Solicitar permisos
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carefullyProvisional: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Obtener FCM token
    final String? fmcToken = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $fmcToken');

    // Escuchar mensajes
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    _isInitialized = true;
  }

  /// Manejar mensaje en foreground
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Mensaje recibido en foreground: ${message.notification?.title}');

    _showNotification(
      title: message.notification?.title ?? 'Eva Strong',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  /// Manejar cuando se abre mensaje
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('App abierto desde notificación: ${message.notification?.title}');
    _handleNotificationTap(message.data.toString());
  }

  /// Manejar tap en notificación
  void _handleNotificationTap(String? payload) {
    debugPrint('Notificación tocada: $payload');
    // Aquí puedes hacer navegación según el payload
  }

  /// Mostrar notificación local
  Future<void> _showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'eva_strong_channel',
      'Eva Strong Payments',
      channelDescription: 'Notificaciones de pagos',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Notificar pago completado
  Future<void> notifyPaymentSuccess({
    required String plan,
    required String amount,
    required String currency,
  }) async {
    await _showNotification(
      title: '¡Pago Exitoso! 🎉',
      body: 'Tu suscripción $plan por $amount $currency está activa',
      payload: 'payment_success',
    );
  }

  /// Notificar pago rechazado
  Future<void> notifyPaymentFailed({
    required String reason,
  }) async {
    await _showNotification(
      title: '❌ Pago Rechazado',
      body: 'Intenta de nuevo: $reason',
      payload: 'payment_failed',
    );
  }

  /// Notificar suscripción por vencer
  Future<void> notifySubscriptionExpiring({
    required String daysLeft,
  }) async {
    await _showNotification(
      title: '⏰ Suscripción por vencer',
      body: 'Tu suscripción vence en $daysLeft días',
      payload: 'subscription_expiring',
    );
  }

  /// Notificar bono referral
  Future<void> notifyReferralBonus({
    required String amount,
    required String currency,
  }) async {
    await _showNotification(
      title: '🎁 Bono Referral Recibido',
      body: 'Ganaste $amount $currency por referencia',
      payload: 'referral_bonus',
    );
  }

  /// Suscribirse a notificaciones de pagos
  Future<void> subscribeToPaymentNotifications() async {
    await _firebaseMessaging.subscribeToTopic('payments');
  }

  /// Suscribirse a notificaciones de referrals
  Future<void> subscribeToReferralNotifications() async {
    await _firebaseMessaging.subscribeToTopic('referrals');
  }

  /// Obtener FCM token actual
  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }
}
