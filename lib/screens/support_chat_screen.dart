import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme/eva_colors.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _welcomeAdded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_welcomeAdded) {
      _welcomeAdded = true;
      _addWelcomeMessage();
    }
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          text: AppStrings.of(context).botWelcome,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    setState(() {
      _messages.add(
        ChatMessage(text: userMessage, isUser: true, timestamp: DateTime.now()),
      );
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simular respuesta del soporte
    _simulateSupportResponse(userMessage);
  }

  void _simulateSupportResponse(String userMessage) {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      String response = _generateResponse(userMessage);

      setState(() {
        _messages.add(
          ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
        );
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  String _generateResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    final s = AppStrings.of(context);

    if (lowerMessage.contains('rutina') || lowerMessage.contains('ejercicio') ||
        lowerMessage.contains('routine') || lowerMessage.contains('exercise')) {
      return s.botRoutineHelp;
    }
    if (lowerMessage.contains('pago') || lowerMessage.contains('suscripción') ||
        lowerMessage.contains('payment') || lowerMessage.contains('subscription')) {
      return s.botPaymentHelp;
    }
    if (lowerMessage.contains('perfil') || lowerMessage.contains('cuenta') ||
        lowerMessage.contains('profile') || lowerMessage.contains('account')) {
      return s.botProfileHelp;
    }
    if (lowerMessage.contains('hola') || lowerMessage.contains('buenos días') ||
        lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return s.botHelloResponse;
    }
    if (lowerMessage.contains('gracias') || lowerMessage.contains('thank')) {
      return s.botThanksResponse;
    }
    return s.botDefaultResponse;
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
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EvaColors.backgroundLight,
      appBar: AppBar(
        title: Text(AppStrings.of(context).supportChatTitle),
        backgroundColor: EvaColors.vibrantPink,
        foregroundColor: EvaColors.textOnVibrant,
        elevation: 8,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showChatInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Mensaje motivacional superior
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: EvaColors.primaryGradient),
            child: Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: EvaColors.textPrimary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.of(context).supportAvailable247,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: EvaColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }

                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Indicador de escritura y campo de entrada
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: AppStrings.of(context).writeMsgHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: EvaColors.vibrantPink),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: EvaColors.vibrantPink,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: EvaColors.surfaceLight,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined),
                        onPressed: _showQuickResponses,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: EvaColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: EvaColors.textOnVibrant,
                    ),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: EvaColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent,
                color: EvaColors.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? EvaColors.primaryGradient
                    : EvaColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: message.isUser
                          ? EvaColors.textOnVibrant
                          : EvaColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: message.isUser
                          ? EvaColors.textOnVibrant.withOpacity(0.8)
                          : EvaColors.textPrimary.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: EvaColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: EvaColors.textOnVibrant,
                size: 24,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: EvaColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent,
              color: EvaColors.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: EvaColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: EvaColors.textPrimary.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return AppStrings.of(context).justNow;
    } else if (difference.inHours < 1) {
      return AppStrings.of(context).minsAgoLong(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return AppStrings.of(context).hoursAgoLong(difference.inHours);
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showChatInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: EvaColors.vibrantPink),
            const SizedBox(width: 8),
            Text(AppStrings.of(context).chatInfoTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.of(context).virtualAssistant,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(AppStrings.of(context).autoResponse),
            const SizedBox(height: 16),
            Text(
              AppStrings.of(context).humanSupport,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(AppStrings.of(context).humanSupportHours),
            const SizedBox(height: 8),
            const Text('Email: soporte@evastrong.com'),
            const SizedBox(height: 16),
            Text(
              AppStrings.of(context).responseTimeTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(AppStrings.of(context).chatImmediate),
            Text(AppStrings.of(context).emailResponseTime),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.of(context).close,
              style: TextStyle(color: EvaColors.vibrantPink),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickResponses() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.of(context).quickReplies,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: EvaColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickChip(AppStrings.of(context).quickRepliesHelpRoutines),
                _buildQuickChip(AppStrings.of(context).quickRepliesPaymentIssue),
                _buildQuickChip(AppStrings.of(context).quickRepliesSetupProfile),
                _buildQuickChip(AppStrings.of(context).quickRepliesTechError),
                _buildQuickChip(AppStrings.of(context).quickRepliesCancelSub),
                _buildQuickChip(AppStrings.of(context).quickRepliesContactHuman),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String text) {
    return ActionChip(
      label: Text(text),
      backgroundColor: EvaColors.surfaceLight,
      labelStyle: TextStyle(color: EvaColors.textPrimary),
      onPressed: () {
        Navigator.pop(context);
        _messageController.text = text;
        _sendMessage();
      },
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
