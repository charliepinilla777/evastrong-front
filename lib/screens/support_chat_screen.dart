import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          text:
              '¡Hola! 👋 Soy tu asistente virtual de Eva Strong.\n\n¿En qué puedo ayudarte hoy?\n\n💪 Puedo ayudarte con:\n• Rutinas y ejercicios\n• Problemas técnicos\n• Configuración de perfil\n• Pagos y suscripciones',
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

    // Respuestas inteligentes basadas en palabras clave
    if (lowerMessage.contains('rutina') || lowerMessage.contains('ejercicio')) {
      return '''💪 **Sobre Rutinas:**

Puedes acceder a tus rutinas personalizadas desde:
• Menú lateral → "Mis Rutinas"
• Pestaña "Rutinas" en la pantalla principal

¿Necesitas ayuda con algo específico de tu rutina?''';
    }

    if (lowerMessage.contains('pago') || lowerMessage.contains('suscripción')) {
      return '''💳 **Sobre Pagos:**

Para gestionar tu suscripción:
1. Ve a tu perfil
2. Selecciona "Configuración de pagos"
3. Elige tu plan (Mensual/Anual)

¿Problemas con un pago? Contacta a soporte@evastrong.com''';
    }

    if (lowerMessage.contains('perfil') || lowerMessage.contains('cuenta')) {
      return '''👤 **Sobre tu Perfil:**

Configura tu perfil completo:
• Menú lateral → "Configurar Perfil"
• Agrega tu edad, nivel y objetivos
• Esto personalizará tus rutinas

¿Qué sección de tu perfil quieres ajustar?''';
    }

    if (lowerMessage.contains('hola') || lowerMessage.contains('buenos días')) {
      return '''¡Hola! 😊 ¿Cómo estás hoy?

Recuerda que la consistencia es clave para tus objetivos.
¿Qué rutina vas a hacer hoy? 💪''';
    }

    if (lowerMessage.contains('gracias')) {
      return '''🌟 **¡De nada!**

Estoy aquí para ayudarte a alcanzar tus metas.
¡Sigue adelante, tú puedes! 💪✨

¿Necesitas algo más?''';
    }

    // Respuesta por defecto
    return '''🤔 **Entiendo tu consulta.**

Puedo ayudarte con:
• 📋 Rutinas y ejercicios personalizados
• 💳 Pagos y suscripciones  
• 👤 Configuración de perfil
• 🔧 Problemas técnicos
• 📈 Seguimiento de progreso

¿Podrías darme más detalles sobre lo que necesitas?

O si prefieres, puedes escribir "ayuda" para ver todas las opciones.''';
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
        title: const Text('Chat de Soporte'),
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
                    'Soporte disponible 24/7 • Respuesta rápida garantizada',
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
                      hintText: 'Escribe tu mensaje...',
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
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} h';
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
            const Text('Info del Chat'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🤖 **Asistente Virtual**',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Respuesta automática inteligente'),
            const SizedBox(height: 16),
            Text(
              '👨‍💼 **Soporte Humano**',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Disponible Lunes a Viernes, 9am-6pm'),
            const SizedBox(height: 8),
            Text('Email: soporte@evastrong.com'),
            const SizedBox(height: 16),
            Text(
              '⚡ **Tiempo de respuesta**',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Chat: Inmediato'),
            Text('Email: 2-4 horas'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
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
              'Respuestas Rápidas',
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
                _buildQuickChip('Ayuda con rutinas'),
                _buildQuickChip('Problemas de pago'),
                _buildQuickChip('Configurar perfil'),
                _buildQuickChip('Error técnico'),
                _buildQuickChip('Cancelar suscripción'),
                _buildQuickChip('Contactar humano'),
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
