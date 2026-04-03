import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../theme/eva_colors.dart';

class ChatScreen extends StatefulWidget {
  final ChatRoom room;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.room,
    required this.currentUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final ChatService _chatService = ChatService.instance;

  final List<ChatMessage> _messages = [];
  bool _loadingHistory = true;
  bool _isTyping = false;
  String? _typingUserName;
  int _currentPage = 1;
  bool _hasMoreMessages = true;
  bool _loadingMore = false;

  StreamSubscription<ChatMessage>? _messageSub;
  StreamSubscription<Map<String, dynamic>>? _typingSub;
  StreamSubscription<String>? _stopTypingSub;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _initialize();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initialize() async {
    await _chatService.connect();
    _chatService.joinRoom(widget.room.id);
    _chatService.markRead(widget.room.id);

    _messageSub = _chatService.messageStream.listen((msg) {
      if (msg.id.isNotEmpty && _messages.every((m) => m.id != msg.id)) {
        setState(() => _messages.add(msg));
        _scrollToBottom();
        _chatService.markRead(widget.room.id);
      }
    });

    _typingSub = _chatService.typingStream.listen((data) {
      if (data['userId']?.toString() != widget.currentUserId &&
          data['roomId']?.toString() == widget.room.id) {
        setState(() {
          _isTyping = true;
          _typingUserName = data['userName']?.toString();
        });
      }
    });

    _stopTypingSub = _chatService.stopTypingStream.listen((userId) {
      if (userId != widget.currentUserId) {
        setState(() { _isTyping = false; _typingUserName = null; });
      }
    });

    await _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final msgs = await _chatService.getMessages(widget.room.id, page: _currentPage);
      if (mounted) {
        setState(() {
          _messages.insertAll(0, msgs);
          _loadingHistory = false;
          _hasMoreMessages = msgs.length == 50;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_loadingMore || !_hasMoreMessages) return;
    setState(() => _loadingMore = true);
    try {
      final msgs = await _chatService.getMessages(widget.room.id, page: _currentPage + 1);
      if (mounted) {
        setState(() {
          _messages.insertAll(0, msgs);
          _currentPage++;
          _hasMoreMessages = msgs.length == 50;
          _loadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels <= 50 && !_loadingMore && _hasMoreMessages) {
      _loadMoreMessages();
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;
    _messageController.clear();
    _typingTimer?.cancel();
    _chatService.stopTyping(widget.room.id);
    _chatService.sendMessage(widget.room.id, content);
  }

  void _onTextChanged(String value) {
    if (value.isNotEmpty) {
      _chatService.sendTyping(widget.room.id);
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        _chatService.stopTyping(widget.room.id);
      });
    } else {
      _typingTimer?.cancel();
      _chatService.stopTyping(widget.room.id);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _chatService.leaveRoom(widget.room.id);
    _messageSub?.cancel();
    _typingSub?.cancel();
    _stopTypingSub?.cancel();
    _typingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomName = widget.room.displayName(widget.currentUserId);
    final isGroup = widget.room.type == 'group';

    return Scaffold(
      backgroundColor: EvaColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: EvaColors.vibrantPink,
        foregroundColor: EvaColors.textOnVibrant,
        elevation: 8,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(
                isGroup ? Icons.group : Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roomName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isGroup)
                    Text(
                      AppStrings.of(context).participantsCount(widget.room.participants.length),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_loadingHistory)
            const LinearProgressIndicator(color: EvaColors.vibrantPink),
          if (_loadingMore)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.senderId == widget.currentUserId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: EvaColors.vibrantPink.withOpacity(0.2),
              child: Text(
                message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : '?',
                style: TextStyle(color: EvaColors.vibrantPink, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isMe ? EvaColors.primaryGradient : null,
                color: isMe ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe && widget.room.type == 'group')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderName,
                        style: TextStyle(
                          color: EvaColors.vibrantPink,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? EvaColors.textOnVibrant : EvaColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isMe
                          ? EvaColors.textOnVibrant.withOpacity(0.7)
                          : EvaColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: EvaColors.vibrantPink.withOpacity(0.2),
            child: Icon(Icons.person, color: EvaColors.vibrantPink, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_typingUserName != null)
                  Text(_typingUserName!, style: TextStyle(color: EvaColors.vibrantPink, fontSize: 11, fontWeight: FontWeight.bold)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDot(0),
                    const SizedBox(width: 4),
                    _buildDot(1),
                    const SizedBox(width: 4),
                    _buildDot(2),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + index * 200),
      builder: (_, value, __) {
        return Transform.translate(
          offset: Offset(0, -4 * value),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: EvaColors.vibrantPink.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: _onTextChanged,
              onSubmitted: (_) => _sendMessage(),
              maxLines: null,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: AppStrings.of(context).typeMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: EvaColors.vibrantPink.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: EvaColors.vibrantPink, width: 2),
                ),
                filled: true,
                fillColor: EvaColors.surfaceLight,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(gradient: EvaColors.primaryGradient, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.send, color: EvaColors.textOnVibrant),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return AppStrings.of(context).justNow;
    if (diff.inHours < 1) return AppStrings.of(context).minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
    return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
