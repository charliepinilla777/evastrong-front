class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final DateTime timestamp;
  final List<String> readBy;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.timestamp,
    this.readBy = const [],
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'];
    return ChatMessage(
      id: json['_id'] ?? '',
      senderId: sender is Map ? (sender['_id'] ?? '') : (sender ?? ''),
      senderName: sender is Map ? (sender['name'] ?? '') : '',
      senderAvatar: sender is Map ? sender['avatar'] : null,
      content: json['content'] ?? '',
      timestamp: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }
}

class ChatRoom {
  final String id;
  final String type; // 'direct' | 'group'
  final String? name;
  final List<ChatParticipant> participants;
  final ChatMessage? lastMessage;
  final DateTime? lastMessageAt;

  const ChatRoom({
    required this.id,
    required this.type,
    this.name,
    required this.participants,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['_id'] ?? '',
      type: json['type'] ?? 'direct',
      name: json['name'],
      participants: (json['participants'] as List? ?? [])
          .map((p) => ChatParticipant.fromJson(p))
          .toList(),
      lastMessage: json['lastMessage'] != null
          ? ChatMessage.fromJson(json['lastMessage'])
          : null,
      lastMessageAt: DateTime.tryParse(json['lastMessageAt'] ?? ''),
    );
  }

  /// Nombre para mostrar en la lista (nombre del grupo o del otro participante)
  String displayName(String currentUserId) {
    if (type == 'group') return name ?? 'Grupo';
    final other = participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => participants.isNotEmpty
          ? participants.first
          : ChatParticipant(id: '', name: 'Usuario'),
    );
    return other.name;
  }
}

class ChatParticipant {
  final String id;
  final String name;
  final String? avatar;

  const ChatParticipant({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
    );
  }
}
