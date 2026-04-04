import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../services/secure_storage_service.dart';
import '../theme/eva_colors.dart';
import 'chat_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final ChatService _chatService = ChatService.instance;

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _selected = [];
  bool _searching = false;
  bool _creating = false;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    SecureStorageService.getUserId().then((id) {
      if (id != null) setState(() => _currentUserId = id);
    });
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final token = await SecureStorageService.getToken();
      final uri = Uri.parse('${AppConfig.backendUrl}/users?search=${Uri.encodeComponent(query)}');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(AppConfig.apiTimeout);

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        final users = (body['data'] as List)
            .where((u) => u['_id'] != _currentUserId)
            .toList();
        if (mounted) setState(() => _searchResults = List<Map<String, dynamic>>.from(users));
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _toggleUser(Map<String, dynamic> user) {
    setState(() {
      if (_selected.any((u) => u['_id'] == user['_id'])) {
        _selected.removeWhere((u) => u['_id'] == user['_id']);
      } else {
        _selected.add(user);
      }
    });
  }

  Future<void> _createGroup() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre del grupo es requerido')),
      );
      return;
    }
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un participante')),
      );
      return;
    }

    setState(() => _creating = true);
    try {
      final participantIds = _selected.map((u) => u['_id'] as String).toList();
      final room = await _chatService.createGroupRoom(
        _nameController.text.trim(),
        participantIds,
      );
      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(room: room, currentUserId: _currentUserId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EvaColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Crear Grupo'),
        backgroundColor: EvaColors.vibrantPink,
        foregroundColor: EvaColors.textOnVibrant,
        elevation: 8,
        actions: [
          if (_creating)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
            )
          else
            TextButton(
              onPressed: _createGroup,
              child: const Text('Crear', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del grupo',
                prefixIcon: const Icon(Icons.group),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: EvaColors.vibrantPink, width: 2),
                ),
              ),
            ),
          ),
          if (_selected.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _selected.length,
                itemBuilder: (_, i) {
                  final u = _selected[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      avatar: CircleAvatar(
                        backgroundColor: EvaColors.vibrantPink,
                        child: Text(
                          (u['name'] as String? ?? '?')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      label: Text(u['name'] ?? ''),
                      onDeleted: () => _toggleUser(u),
                      deleteIconColor: EvaColors.vibrantPink,
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar usuarios',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searching ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))) : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: EvaColors.vibrantPink, width: 2),
                ),
              ),
              onChanged: _searchUsers,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (_, i) {
                final user = _searchResults[i];
                final isSelected = _selected.any((u) => u['_id'] == user['_id']);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: EvaColors.vibrantPink.withOpacity(0.15),
                    child: Text(
                      (user['name'] as String? ?? '?')[0].toUpperCase(),
                      style: TextStyle(color: EvaColors.vibrantPink, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(user['name'] ?? ''),
                  subtitle: Text(user['email'] ?? '', style: const TextStyle(fontSize: 12)),
                  trailing: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? EvaColors.vibrantPink : Colors.grey,
                  ),
                  onTap: () => _toggleUser(user),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
