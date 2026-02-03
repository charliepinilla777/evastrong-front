import 'package:flutter/material.dart';
import '../theme/eva_colors.dart';
import '../services/wearable_service.dart';

class WearablesScreen extends StatefulWidget {
  const WearablesScreen({super.key});

  @override
  State<WearablesScreen> createState() => _WearablesScreenState();
}

class _WearablesScreenState extends State<WearablesScreen> {
  final WearableService _wearableService = WearableService();
  bool _isConnecting = false;
  bool _isSyncing = false;
  WearableData? _currentData;
  List<WearableDevice> _devices = [];
  WearableGoals? _currentGoals;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _wearableService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EvaColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Wearables'),
        backgroundColor: EvaColors.vibrantPink,
        foregroundColor: EvaColors.textOnVibrant,
        elevation: 8,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado de conexión
            _buildConnectionStatus(),
            const SizedBox(height: 24),

            // Datos actuales
            if (_currentData != null) ...[
              _buildCurrentDataCard(),
              const SizedBox(height: 24),
            ],

            // Metas
            if (_currentGoals != null) ...[
              _buildGoalsCard(),
              const SizedBox(height: 24),
            ],

            // Dispositivos disponibles
            _buildDevicesCard(),
            const SizedBox(height: 24),

            // Métricas soportadas
            _buildSupportedMetricsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    final isConnected = _wearableService.isConnected;
    final connectedDevice = _wearableService.connectedDevice;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isConnected
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth_disabled,
                  color: isConnected ? EvaColors.vibrantPink : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConnected ? 'Conectado' : 'No Conectado',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isConnected
                              ? EvaColors.vibrantPink
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isConnected)
                        Text(
                          connectedDevice,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: EvaColors.textPrimary.withOpacity(0.8),
                              ),
                        ),
                    ],
                  ),
                ),
                if (!isConnected)
                  ElevatedButton(
                    onPressed: _isConnecting ? null : _connectDevice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: EvaColors.vibrantPink,
                      foregroundColor: EvaColors.textOnVibrant,
                    ),
                    child: _isConnecting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: EvaColors.textOnVibrant,
                            ),
                          )
                        : const Text('Conectar'),
                  ),
                if (isConnected)
                  IconButton(
                    icon: const Icon(Icons.bluetooth_disabled),
                    onPressed: _disconnectDevice,
                    color: Colors.red,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentDataCard() {
    if (_currentData == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos Actuales',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: EvaColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              children: [
                _buildMetricCard('Pasos', '${_currentData!.steps}', '👟'),
                _buildMetricCard(
                  'Calorías',
                  '${_currentData!.caloriesBurned.round()}',
                  '🔥',
                ),
                _buildMetricCard('FC', '${_currentData!.heartRate} bpm', '❤️'),
                _buildMetricCard(
                  'Min. Activos',
                  '${_currentData!.activeMinutes}',
                  '⏱️',
                ),
                _buildMetricCard(
                  'Distancia',
                  '${_currentData!.distance.toStringAsFixed(1)} km',
                  '📍',
                ),
                _buildMetricCard(
                  'Sueño',
                  '${_currentData!.sleepHours.toStringAsFixed(1)} h',
                  '😴',
                ),
                _buildMetricCard(
                  'Peso',
                  '${_currentData!.weight.toStringAsFixed(1)} kg',
                  '⚖️',
                ),
                _buildMetricCard(
                  'IMC',
                  _currentData!.bmi.toStringAsFixed(1),
                  '📊',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Categoría IMC: ${_currentData!.bmiCategory}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: EvaColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, String emoji) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: EvaColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: EvaColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: EvaColors.textPrimary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsCard() {
    if (_currentGoals == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metas Diarias',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: EvaColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildGoalItem('Pasos', _currentGoals!.dailySteps, 10000, '👟'),
            _buildGoalItem(
              'Min. Activos',
              _currentGoals!.activeMinutes,
              30,
              '⏱️',
            ),
            _buildGoalItem(
              'Calorías',
              _currentGoals!.caloriesBurned.round(),
              500,
              '🔥',
            ),
            _buildGoalItem('Sueño', _currentGoals!.sleepHours.round(), 8, '😴'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _editGoals,
              icon: const Icon(Icons.edit),
              label: const Text('Editar Metas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: EvaColors.vibrantPink,
                foregroundColor: EvaColors.textOnVibrant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(String label, int current, int goal, String emoji) {
    final progress = current / goal;
    final isCompleted = current >= goal;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: EvaColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$current/$goal',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isCompleted
                            ? Colors.green
                            : EvaColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: EvaColors.surfaceLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : EvaColors.vibrantPink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dispositivos Disponibles',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: EvaColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _scanDevices,
                  icon: const Icon(Icons.search),
                  label: const Text('Escanear'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_devices.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.bluetooth_searching,
                      size: 48,
                      color: EvaColors.textPrimary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No se encontraron dispositivos',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: EvaColors.textPrimary.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._devices.map((device) => _buildDeviceTile(device)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceTile(WearableDevice device) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: device.batteryColor.withOpacity(0.2),
        child: Icon(Icons.watch, color: device.batteryColor),
      ),
      title: Text(device.name),
      subtitle: Text(
        'Batería: ${device.batteryLevel}% (${device.batteryStatus})',
      ),
      trailing: device.isConnected
          ? Icon(Icons.check_circle, color: Colors.green)
          : ElevatedButton(
              onPressed: () => _connectToDevice(device),
              child: const Text('Conectar'),
            ),
    );
  }

  Widget _buildSupportedMetricsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métricas Soportadas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: EvaColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WearableService.supportedMetrics.map((metric) {
                return Chip(
                  label: Text(metric),
                  backgroundColor: EvaColors.surfaceLight,
                  labelStyle: TextStyle(color: EvaColors.textPrimary),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    if (_wearableService.isConnected) {
      _currentData = await _wearableService.getCurrentData();
      _currentGoals = await _wearableService.getCurrentGoals();
      _devices = await _wearableService.getCompatibleDevices();
      setState(() {});
    }
  }

  Future<void> _connectDevice() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      final result = await _wearableService.connectDevice();

      if (result == WearableConnectionResult.success) {
        _currentData = await _wearableService.getCurrentData();
        _currentGoals = await _wearableService.getCurrentGoals();
        _devices = await _wearableService.getCompatibleDevices();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dispositivo conectado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al conectar dispositivo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _disconnectDevice() async {
    await _wearableService.disconnectDevice();
    setState(() {
      _currentData = null;
      _currentGoals = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Dispositivo desconectado'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _isSyncing = true;
    });

    await _loadData();

    setState(() {
      _isSyncing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Datos sincronizados'),
        backgroundColor: EvaColors.vibrantPink,
      ),
    );
  }

  Future<void> _scanDevices() async {
    setState(() {
      _isSyncing = true;
    });

    final devices = await _wearableService.getCompatibleDevices();
    setState(() {
      _devices = devices;
      _isSyncing = false;
    });
  }

  Future<void> _connectToDevice(WearableDevice device) async {
    // Implementar conexión a dispositivo específico
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Conectando a ${device.name}...'),
        backgroundColor: EvaColors.vibrantPink,
      ),
    );
  }

  void _editGoals() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Metas'),
        content: const Text('Función de edición de metas próximamente...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
