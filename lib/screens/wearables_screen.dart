import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
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
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: EvaColors.backgroundLight,
      appBar: AppBar(
        title: Text(s.wearablesTitle),
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
            _buildConnectionStatus(),
            const SizedBox(height: 24),
            if (_currentData != null) ...[
              _buildCurrentDataCard(),
              const SizedBox(height: 24),
            ],
            if (_currentGoals != null) ...[
              _buildGoalsCard(),
              const SizedBox(height: 24),
            ],
            _buildDevicesCard(),
            const SizedBox(height: 24),
            _buildSupportedMetricsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    final s = AppStrings.of(context);
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
                        isConnected ? s.wearableConnected : s.wearableNotConnected,
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
                        : Text(s.wearableConnect),
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
    final s = AppStrings.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.wearableCurrentData,
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
                _buildMetricCard(s.wearableSteps,         '${_currentData!.steps}',                           '👟'),
                _buildMetricCard(s.calories,              '${_currentData!.caloriesBurned.round()}',           '🔥'),
                _buildMetricCard(s.wearableHeartRate,     '${_currentData!.heartRate} bpm',                   '❤️'),
                _buildMetricCard(s.wearableActiveMinutes, '${_currentData!.activeMinutes}',                   '⏱️'),
                _buildMetricCard(s.wearableDistance,      '${_currentData!.distance.toStringAsFixed(1)} km',  '📍'),
                _buildMetricCard(s.wearableSleep,         '${_currentData!.sleepHours.toStringAsFixed(1)} h', '😴'),
                _buildMetricCard(s.wearableWeight,        '${_currentData!.weight.toStringAsFixed(1)} kg',    '⚖️'),
                _buildMetricCard(s.wearableBMI,           _currentData!.bmi.toStringAsFixed(1),               '📊'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              s.wearableBMICategory(_currentData!.bmiCategory),
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
    final s = AppStrings.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.wearableDailyGoals,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: EvaColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildGoalItem(s.wearableSteps,         _currentGoals!.dailySteps,                10000, '👟'),
            _buildGoalItem(s.wearableActiveMinutes, _currentGoals!.activeMinutes,             30,    '⏱️'),
            _buildGoalItem(s.calories,              _currentGoals!.caloriesBurned.round(),    500,   '🔥'),
            _buildGoalItem(s.wearableSleep,         _currentGoals!.sleepHours.round(),        8,     '😴'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _editGoals,
              icon: const Icon(Icons.edit),
              label: Text(s.editGoalsTitle),
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
                        color: isCompleted ? Colors.green : EvaColors.textPrimary,
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
    final s = AppStrings.of(context);
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
                  s.wearableAvailableDevices,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: EvaColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _scanDevices,
                  icon: const Icon(Icons.search),
                  label: Text(s.wearableScan),
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
                      s.wearableNoDevices,
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
    final s = AppStrings.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: device.batteryColor.withOpacity(0.2),
        child: Icon(Icons.watch, color: device.batteryColor),
      ),
      title: Text(device.name),
      subtitle: Text(s.wearableBattery(device.batteryLevel, device.batteryStatus)),
      trailing: device.isConnected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : ElevatedButton(
              onPressed: () => _connectToDevice(device),
              child: Text(s.wearableConnect),
            ),
    );
  }

  Widget _buildSupportedMetricsCard() {
    final s = AppStrings.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.wearableSupportedMetrics,
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
    setState(() => _isConnecting = true);
    try {
      final result = await _wearableService.connectDevice();
      if (result == WearableConnectionResult.success) {
        _currentData = await _wearableService.getCurrentData();
        _currentGoals = await _wearableService.getCurrentGoals();
        _devices = await _wearableService.getCompatibleDevices();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppStrings.of(context).wearableConnectedOk),
            backgroundColor: Colors.green,
          ));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppStrings.of(context).wearableConnectError),
            backgroundColor: Colors.red,
          ));
        }
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  Future<void> _disconnectDevice() async {
    await _wearableService.disconnectDevice();
    setState(() {
      _currentData = null;
      _currentGoals = null;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppStrings.of(context).wearableDisconnected),
        backgroundColor: Colors.orange,
      ));
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isSyncing = true);
    await _loadData();
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppStrings.of(context).wearableDataSynced),
        backgroundColor: EvaColors.vibrantPink,
      ));
    }
  }

  Future<void> _scanDevices() async {
    setState(() => _isSyncing = true);
    final devices = await _wearableService.getCompatibleDevices();
    setState(() {
      _devices = devices;
      _isSyncing = false;
    });
  }

  Future<void> _connectToDevice(WearableDevice device) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppStrings.of(context).wearableConnectingTo(device.name)),
        backgroundColor: EvaColors.vibrantPink,
      ));
    }
  }

  void _editGoals() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.of(context).editGoalsTitle),
        content: Text(AppStrings.of(context).editGoalsComingSoon),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.of(context).close),
          ),
        ],
      ),
    );
  }
}
