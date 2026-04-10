import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/app_config.dart';
import '../models/chat_message.dart';
import 'secure_storage_service.dart';

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  IO.Socket? _socket;

  final _messageController = StreamController<ChatMessage>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _stopTypingController = StreamController<String>.broadcast();

  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<String> get stopTypingStream => _stopTypingController.stream;

  bool get isConnected => _socket?.connected ?? false;

  // ========== CONEXIÓN ==========

  Future<void> connect() async {
    if (_socket?.connected == true) return;

    final token = await SecureStorageService.getToken();
    if (token == null) return;

    try {
      _socket = IO.io(
        AppConfig.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(2000)
            .build(),
      );
    } catch (e) {
      debugPrint('ChatService: error inicializando socket $e');
      _socket = null;
      return;
    }

    _socket?.onConnect((_) {
      debugPrint('ChatService: conectado al socket');
    });

    _socket?.onDisconnect((_) {
      debugPrint('ChatService: desconectado del socket');
    });

    _socket?.onConnectError((err) {
      debugPrint('ChatService: error de conexión $err');
    });

    _socket?.on('new_message', (data) {
      try {
        final msg = ChatMessage.fromJson(data as Map<String, dynamic>);
        _messageController.add(msg);
      } catch (e) {
        debugPrint('ChatService: error parseando mensaje $e');
      }
    });

    _socket?.on('user_typing', (data) {
      _typingController.add(Map<String, dynamic>.from(data));
    });

    _socket?.on('user_stop_typing', (data) {
      _stopTypingController.add(data['userId']?.toString() ?? '');
    });

    _socket?.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  // ========== EVENTOS SOCKET ==========

  void joinRoom(String roomId) {
    _socket?.emit('join_room', {'roomId': roomId});
  }

  void leaveRoom(String roomId) {
    _socket?.emit('leave_room', {'roomId': roomId});
  }

  void sendMessage(String roomId, String content) {
    _socket?.emit('send_message', {'roomId': roomId, 'content': content});
  }

  void sendTyping(String roomId) {
    _socket?.emit('typing', {'roomId': roomId});
  }

  void stopTyping(String roomId) {
    _socket?.emit('stop_typing', {'roomId': roomId});
  }

  void markRead(String roomId) {
    _socket?.emit('mark_read', {'roomId': roomId});
  }

  // ========== HTTP ==========

  static String get _baseUrl => '${AppConfig.backendUrl}/chat';

  static Future<Map<String, String>> _authHeaders() async {
    final token = await SecureStorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<ChatRoom>> getConversations() async {
    final headers = await _authHeaders();
    final response = await http
        .get(Uri.parse('$_baseUrl/conversations'), headers: headers)
        .timeout(AppConfig.apiTimeout);

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return (body['data'] as List).map((r) => ChatRoom.fromJson(r)).toList();
    }
    throw Exception(body['message'] ?? 'Error al obtener conversaciones');
  }

  Future<List<ChatMessage>> getMessages(String roomId, {int page = 1}) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('$_baseUrl/messages/$roomId?page=$page');
    final response = await http
        .get(uri, headers: headers)
        .timeout(AppConfig.apiTimeout);

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return (body['data'] as List).map((m) => ChatMessage.fromJson(m)).toList();
    }
    throw Exception(body['message'] ?? 'Error al obtener mensajes');
  }

  Future<List<ChatRoom>> getPublicRooms() async {
    final headers = await _authHeaders();
    final response = await http
        .get(Uri.parse('$_baseUrl/rooms/public'), headers: headers)
        .timeout(AppConfig.apiTimeout);

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return (body['data'] as List).map((r) => ChatRoom.fromJson(r)).toList();
    }
    throw Exception(body['message'] ?? 'Error al obtener salas');
  }

  Future<ChatRoom> joinGroupRoom(String roomId) async {
    final headers = await _authHeaders();
    final response = await http
        .post(Uri.parse('$_baseUrl/rooms/$roomId/join'), headers: headers)
        .timeout(AppConfig.apiTimeout);

    final body = jsonDecode(response.body);
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['success'] == true) {
      return ChatRoom.fromJson(body['data']);
    }
    throw Exception(body['message'] ?? 'Error al unirse a la sala');
  }

  Future<ChatRoom> createDirectChat(String recipientId) async {
    final headers = await _authHeaders();
    final response = await http
        .post(Uri.parse('$_baseUrl/direct/$recipientId'), headers: headers)
        .timeout(AppConfig.apiTimeout);

    final body = jsonDecode(response.body);
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['success'] == true) {
      return ChatRoom.fromJson(body['data']);
    }
    throw Exception(body['message'] ?? 'Error al crear chat directo');
  }

  Future<ChatRoom> createGroupRoom(
      String name, List<String> participantIds) async {
    final headers = await _authHeaders();
    final response = await http
        .post(
          Uri.parse('$_baseUrl/rooms'),
          headers: headers,
          body: jsonEncode({'name': name, 'participantIds': participantIds}),
        )
        .timeout(AppConfig.apiTimeout);

    final body = jsonDecode(response.body);
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['success'] == true) {
      return ChatRoom.fromJson(body['data']);
    }
    throw Exception(body['message'] ?? 'Error al crear grupo');
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _stopTypingController.close();
  }
}
