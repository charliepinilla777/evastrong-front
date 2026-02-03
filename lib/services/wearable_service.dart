import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Servicio para integración con dispositivos wearables
class WearableService {
  static final WearableService _instance = WearableService._internal();
  factory WearableService() => _instance;
  WearableService._internal();

  bool _isConnected = false;
  String _connectedDevice = 'Ninguno';
  StreamController<WearableData>? _dataStreamController;

  /// Tipos de datos que podemos obtener de wearables
  static const List<String> supportedMetrics = [
    'Pasos',
    'Calorías quemadas',
    'Frecuencia cardíaca',
    'Minutos activos',
    'Distancia recorrida',
    'Sueño (horas)',
    'Peso',
    'Altura',
    'IMC',
  ];

  /// Verificar si hay dispositivos wearables disponibles
  Future<bool> checkWearableAvailability() async {
    // Simular verificación de disponibilidad
    await Future.delayed(const Duration(seconds: 2));

    // En una implementación real, aquí verificaríamos:
    // - Bluetooth disponible
    // - App de wearable instalada
    // - Permisos concedidos
    return true;
  }

  /// Conectar con dispositivo wearable
  Future<WearableConnectionResult> connectDevice() async {
    try {
      // Simular proceso de conexión
      await Future.delayed(const Duration(seconds: 3));

      // Simular conexión exitosa con probabilidad del 70%
      if (Random().nextDouble() > 0.3) {
        _isConnected = true;
        _connectedDevice = 'Fitbit Charge 5';
        _startDataStream();
        return WearableConnectionResult.success;
      } else {
        return WearableConnectionResult.failed;
      }
    } catch (e) {
      return WearableConnectionResult.error;
    }
  }

  /// Desconectar dispositivo wearable
  Future<void> disconnectDevice() async {
    _isConnected = false;
    _connectedDevice = 'Ninguno';
    _dataStreamController?.close();
    _dataStreamController = null;
  }

  /// Obtener datos actuales del wearable
  Future<WearableData> getCurrentData() async {
    if (!_isConnected) {
      return WearableData.empty();
    }

    // Simular obtención de datos
    await Future.delayed(const Duration(milliseconds: 500));

    return WearableData(
      steps: Random().nextInt(15000) + 5000,
      caloriesBurned: Random().nextInt(500) + 200,
      heartRate: Random().nextInt(40) + 60,
      activeMinutes: Random().nextInt(60) + 30,
      distance: Random().nextInt(10) + 2.0,
      sleepHours: Random().nextInt(3) + 6.0,
      weight: Random().nextInt(30) + 60.0,
      height: Random().nextInt(30) + 150.0,
      timestamp: DateTime.now(),
    );
  }

  /// Stream de datos en tiempo real
  Stream<WearableData> get dataStream {
    _dataStreamController ??= StreamController<WearableData>.broadcast();
    return _dataStreamController!.stream;
  }

  /// Iniciar stream de datos (simulación)
  void _startDataStream() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isConnected) {
        timer.cancel();
        return;
      }

      final data = WearableData(
        steps: Random().nextInt(100) + 50,
        caloriesBurned: Random().nextInt(20) + 5,
        heartRate: Random().nextInt(20) + 60,
        activeMinutes: Random().nextInt(5) + 1,
        distance: Random().nextInt(2) + 0.5,
        sleepHours: 0, // No cambia cada 5 segundos
        weight: 0, // No cambia cada 5 segundos
        height: 0, // No cambia cada 5 segundos
        timestamp: DateTime.now(),
      );

      _dataStreamController?.add(data);
    });
  }

  /// Sincronizar datos históricos
  Future<List<WearableData>> syncHistoricalData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!_isConnected) {
      return [];
    }

    // Simular sincronización
    await Future.delayed(const Duration(seconds: 5));

    final List<WearableData> historicalData = [];
    final days = endDate.difference(startDate).inDays;

    for (int i = 0; i <= days; i++) {
      final date = startDate.add(Duration(days: i));
      historicalData.add(
        WearableData(
          steps: Random().nextInt(15000) + 3000,
          caloriesBurned: Random().nextInt(600) + 150,
          heartRate: Random().nextInt(40) + 50,
          activeMinutes: Random().nextInt(120) + 30,
          distance: Random().nextInt(15) + 1.0,
          sleepHours: Random().nextInt(4) + 5.0,
          weight: Random().nextInt(20) + 65.0,
          height: 160.0, // Constante
          timestamp: date,
        ),
      );
    }

    return historicalData;
  }

  /// Establecer metas en el wearable
  Future<bool> setGoals(WearableGoals goals) async {
    if (!_isConnected) {
      return false;
    }

    // Simular establecimiento de metas
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  /// Obtener metas actuales
  Future<WearableGoals> getCurrentGoals() async {
    if (!_isConnected) {
      return WearableGoals.defaultGoals();
    }

    // Simular obtención de metas
    await Future.delayed(const Duration(milliseconds: 500));

    return WearableGoals(
      dailySteps: 10000,
      activeMinutes: 30,
      caloriesBurned: 500,
      sleepHours: 8,
      distance: 5.0,
    );
  }

  /// Estado de conexión
  bool get isConnected => _isConnected;
  String get connectedDevice => _connectedDevice;

  /// Obtener lista de dispositivos compatibles
  Future<List<WearableDevice>> getCompatibleDevices() async {
    // Simular búsqueda de dispositivos
    await Future.delayed(const Duration(seconds: 3));

    return [
      WearableDevice(
        name: 'Fitbit Charge 5',
        type: 'Fitbit',
        batteryLevel: 85,
        isConnected: _connectedDevice == 'Fitbit Charge 5',
      ),
      WearableDevice(
        name: 'Apple Watch Series 8',
        type: 'Apple Watch',
        batteryLevel: 92,
        isConnected: _connectedDevice == 'Apple Watch Series 8',
      ),
      WearableDevice(
        name: 'Samsung Galaxy Watch 5',
        type: 'Samsung',
        batteryLevel: 67,
        isConnected: _connectedDevice == 'Samsung Galaxy Watch 5',
      ),
      WearableDevice(
        name: 'Garmin Forerunner 945',
        type: 'Garmin',
        batteryLevel: 78,
        isConnected: _connectedDevice == 'Garmin Forerunner 945',
      ),
    ];
  }

  /// Liberar recursos
  void dispose() {
    _dataStreamController?.close();
  }
}

/// Resultado de conexión con wearable
enum WearableConnectionResult {
  success,
  failed,
  error,
  noDeviceFound,
  permissionDenied,
}

/// Datos de wearable
class WearableData {
  final int steps;
  final double caloriesBurned;
  final int heartRate;
  final int activeMinutes;
  final double distance;
  final double sleepHours;
  final double weight;
  final double height;
  final DateTime timestamp;

  WearableData({
    required this.steps,
    required this.caloriesBurned,
    required this.heartRate,
    required this.activeMinutes,
    required this.distance,
    required this.sleepHours,
    required this.weight,
    required this.height,
    required this.timestamp,
  });

  factory WearableData.empty() {
    return WearableData(
      steps: 0,
      caloriesBurned: 0.0,
      heartRate: 0,
      activeMinutes: 0,
      distance: 0.0,
      sleepHours: 0.0,
      weight: 0.0,
      height: 0.0,
      timestamp: DateTime.now(),
    );
  }

  /// Calcular IMC
  double get bmi {
    if (height <= 0) return 0.0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// Obtener categoría de IMC
  String get bmiCategory {
    if (bmi < 18.5) return 'Bajo peso';
    if (bmi < 25) return 'Peso normal';
    if (bmi < 30) return 'Sobrepeso';
    return 'Obesidad';
  }
}

/// Metas de wearable
class WearableGoals {
  final int dailySteps;
  final int activeMinutes;
  final double caloriesBurned;
  final double sleepHours;
  final double distance;

  WearableGoals({
    required this.dailySteps,
    required this.activeMinutes,
    required this.caloriesBurned,
    required this.sleepHours,
    required this.distance,
  });

  factory WearableGoals.defaultGoals() {
    return WearableGoals(
      dailySteps: 10000,
      activeMinutes: 30,
      caloriesBurned: 500,
      sleepHours: 8,
      distance: 5.0,
    );
  }
}

/// Dispositivo wearable
class WearableDevice {
  final String name;
  final String type;
  final int batteryLevel;
  final bool isConnected;

  WearableDevice({
    required this.name,
    required this.type,
    required this.batteryLevel,
    required this.isConnected,
  });

  String get batteryStatus {
    if (batteryLevel > 75) return 'Alta';
    if (batteryLevel > 25) return 'Media';
    return 'Baja';
  }

  Color get batteryColor {
    if (batteryLevel > 75) return Colors.green;
    if (batteryLevel > 25) return Colors.orange;
    return Colors.red;
  }
}
