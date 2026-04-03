import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../services/secure_storage_service.dart';
import '../theme/eva_colors.dart';
import 'chat_screen.dart';
import 'create_group_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ChatService _chatService = ChatService.instance;

  List<ChatRoom> _conversations = [];
  List<ChatRoom> _publicRooms = [];
  bool _loadingConversations = true;
  bool _loadingPublic = true;
  String? _error;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    _currentUserId = await SecureStorageService.getUserId() ?? '';
    await Future.wait([_loadConversations(), _loadPublicRooms()]);
  }

  Future<void> _loadConversations() async {
    try {
      final rooms = await _chatService.getConversations();
      if (mounted) setState(() { _conversations = rooms; _loadingConversations = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loadingConversations = false; });
    }
  }

  Future<void> _loadPublicRooms() async {
    try {
      final rooms = await _chatService.getPublicRooms();
      if (mounted) setState(() { _publicRooms = rooms; _loadingPublic = false; });
    } catch (e) {
      if (mounted) setState(() { _loadingPublic = false; });
    }
  }

  void _openRoom(ChatRoom room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(room: room, currentUserId: _currentUserId),
      ),
    ).then((_) => _loadConversations());
  }

  Future<void> _joinAndOpenRoom(ChatRoom room) async {
    try {
      final joined = await _chatService.joinGroupRoom(room.id);
      if (mounted) _openRoom(joined);
      await _loadConversations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EvaColors.backgroundLight,
      appBar: AppBar(
        title: Text(AppStrings.of(context).chat),
        backgroundColor: EvaColors.vibrantPink,
        foregroundColor: EvaColors.textOnVibrant,
        elevation: 8,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: EvaColors.textOnVibrant,
          labelColor: EvaColors.textOnVibrant,
          unselectedLabelColor: EvaColors.textOnVibrant.withOpacity(0.7),
          tabs: [
            Tab(text: AppStrings.of(context).myChats),
            Tab(text: AppStrings.of(context).groupRooms),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
              ).then((_) => _loadConversations());
            },
            tooltip: AppStrings.of(context).createGroup,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConversationsList(),
          _buildPublicRoomsList(),
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    if (_loadingConversations) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: EvaColors.vibrantPink.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              AppStrings.of(context).noConversationsYet,
              style: TextStyle(color: EvaColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.of(context).goToGroupRooms,
              style: TextStyle(color: EvaColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _conversations.length,
        itemBuilder: (_, i) => _buildRoomTile(_conversations[i], isMember: true),
      ),
    );
  }

  Widget _buildPublicRoomsList() {
    if (_loadingPublic) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_publicRooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_outlined, size: 64, color: EvaColors.vibrantPink.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              AppStrings.of(context).noGroupRoomsAvailable,
              style: TextStyle(color: EvaColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPublicRooms,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _publicRooms.length,
        itemBuilder: (_, i) {
          final room = _publicRooms[i];
          final isMember = room.participants.any((p) => p.id == _currentUserId);
          return _buildRoomTile(room, isMember: isMember);
        },
      ),
    );
  }

  Widget _buildRoomTile(ChatRoom room, {required bool isMember}) {
    final name = room.type == 'group'
        ? room.name ?? AppStrings.of(context).defaultGroupName
        : room.displayName(_currentUserId);
    final lastMsg = room.lastMessage;
    final isGroup = room.type == 'group';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: EvaColors.vibrantPink.withOpacity(0.15),
        child: Icon(
          isGroup ? Icons.group : Icons.person,
          color: EvaColors.vibrantPink,
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: lastMsg != null
          ? Text(
              lastMsg.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: EvaColors.textSecondary, fontSize: 13),
            )
          : Text(
              isGroup
                  ? AppStrings.of(context).participantsCount(room.participants.length)
                  : AppStrings.of(context).noMessagesYet,
              style: TextStyle(color: EvaColors.textSecondary, fontSize: 13),
            ),
      trailing: room.lastMessageAt != null
          ? Text(
              _formatTime(room.lastMessageAt!),
              style: TextStyle(color: EvaColors.textSecondary, fontSize: 11),
            )
          : null,
      onTap: () {
        if (isMember) {
          _openRoom(room);
        } else {
          _joinAndOpenRoom(room);
        }
      },
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return AppStrings.of(context).justNow;
    if (diff.inHours < 1) return AppStrings.of(context).minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return AppStrings.of(context).hoursAgo(diff.inHours);
    if (diff.inDays < 7) return AppStrings.of(context).daysAgo(diff.inDays);
    return '${dt.day}/${dt.month}';
  }
}
