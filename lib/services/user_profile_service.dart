import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'effects_3d_service.dart';

class UserProfile {
  String id;
  String name;
  int age;
  String profileImagePath;
  double performance; // 0.0 a 100.0
  bool kneeSensitive; // Sensibilidad en las rodillas
  String fitnessLevel; // Nivel de condición física
  DateTime createdAt;
  DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    this.profileImagePath = '',
    this.performance = 0.0,
    this.kneeSensitive = false,
    this.fitnessLevel = 'principiante',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'profileImagePath': profileImagePath,
      'performance': performance,
      'kneeSensitive': kneeSensitive,
      'fitnessLevel': fitnessLevel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      profileImagePath: json['profileImagePath'] ?? '',
      performance: (json['performance'] ?? 0.0).toDouble(),
      kneeSensitive: json['kneeSensitive'] ?? false,
      fitnessLevel: json['fitnessLevel'] ?? 'principiante',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    int? age,
    String? profileImagePath,
    double? performance,
    bool? kneeSensitive,
    String? fitnessLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      performance: performance ?? this.performance,
      kneeSensitive: kneeSensitive ?? this.kneeSensitive,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserProfileService {
  static UserProfileService? _instance;
  static UserProfileService get instance {
    _instance ??= UserProfileService._();
    return _instance!;
  }

  UserProfileService._();

  UserProfile? _currentUser;
  final ImagePicker _imagePicker = ImagePicker();

  UserProfile? get currentUser => _currentUser;

  Future<void> initializeProfile() async {
    // Cargar perfil guardado o crear uno nuevo
    _currentUser = UserProfile(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Usuario Eva',
      age: 25,
      performance: 75.0,
      kneeSensitive: false,
      fitnessLevel: 'principiante',
    );
  }

  Future<void> updateProfile({
    String? name,
    int? age,
    String? profileImagePath,
    double? performance,
    bool? kneeSensitive,
    String? fitnessLevel,
  }) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name,
        age: age,
        profileImagePath: profileImagePath,
        performance: performance,
        kneeSensitive: kneeSensitive,
        fitnessLevel: fitnessLevel,
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<String?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      return image?.path;
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      return null;
    }
  }

  Future<String?> takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      return photo?.path;
    } catch (e) {
      print('Error al tomar foto: $e');
      return null;
    }
  }

  Widget buildProfileAvatar({double radius = 50, VoidCallback? onTap}) {
    if (_currentUser?.profileImagePath != null &&
        _currentUser!.profileImagePath.isNotEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: Effects3DService.elevatedShadow3D,
          ),
          child: ClipOval(
            child: Image.file(
              File(_currentUser!.profileImagePath),
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultAvatar(radius);
              },
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            gradient: Effects3DService.primaryGradient3D,
            shape: BoxShape.circle,
            boxShadow: Effects3DService.elevatedShadow3D,
          ),
          child: _buildDefaultAvatar(radius),
        ),
      );
    }
  }

  Widget _buildDefaultAvatar(double radius) {
    return Icon(Icons.person, size: radius, color: Colors.white);
  }

  Widget buildPerformanceIndicator({
    double height = 8,
    BorderRadius? borderRadius,
  }) {
    final performance = _currentUser?.performance ?? 0.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: performance / 100.0,
        child: Container(
          decoration: BoxDecoration(
            gradient: Effects3DService.buttonGradient3D,
            borderRadius: borderRadius ?? BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  String getPerformanceLevel() {
    final performance = _currentUser?.performance ?? 0.0;
    if (performance >= 90) return 'Excelente';
    if (performance >= 75) return 'Muy Bueno';
    if (performance >= 60) return 'Bueno';
    if (performance >= 40) return 'Regular';
    return 'Necesita Mejorar';
  }

  Color getPerformanceColor() {
    final performance = _currentUser?.performance ?? 0.0;
    if (performance >= 90) return Colors.green;
    if (performance >= 75) return Colors.lightGreen;
    if (performance >= 60) return Colors.yellow;
    if (performance >= 40) return Colors.orange;
    return Colors.red;
  }
}
