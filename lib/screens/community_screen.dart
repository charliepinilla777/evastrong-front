import 'package:flutter/material.dart';
import '../theme/eva_colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<CommunityPost> _posts = [
    CommunityPost(
      id: '1',
      author: 'María García',
      avatar: '👩‍🦰',
      content:
          '¡Hoy completé mi primera rutina de 30 días! 💪 Me siento increíblemente fuerte.',
      likes: 45,
      comments: 12,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      imageUrl: null,
    ),
    CommunityPost(
      id: '2',
      author: 'Carlos Rodríguez',
      avatar: '👨‍💼',
      content:
          'Compartiendo mi progreso de este mes. ¡La constancia es la clave! 📈',
      likes: 89,
      comments: 23,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      imageUrl: null,
    ),
    CommunityPost(
      id: '3',
      author: 'Ana Martínez',
      avatar: '👩‍🎓',
      content:
          '¡Nuevo logro desbloqueado! 🏆 100 días seguidos de rutinas. ¡Gracias Eva Strong!',
      likes: 156,
      comments: 34,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      imageUrl: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Comunidad'),
        backgroundColor: EvaColors.vibrantPink,
        foregroundColor: EvaColors.textOnVibrant,
        elevation: 8,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: EvaColors.textOnVibrant,
          labelColor: EvaColors.textOnVibrant,
          unselectedLabelColor: EvaColors.textOnVibrant.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Feed', icon: Icon(Icons.home)),
            Tab(text: 'Grupos', icon: Icon(Icons.group)),
            Tab(text: 'Retos', icon: Icon(Icons.emoji_events)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFeedTab(), _buildGroupsTab(), _buildChallengesTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: EvaColors.vibrantPink,
        child: const Icon(Icons.add, color: EvaColors.textOnVibrant),
      ),
    );
  }

  Widget _buildFeedTab() {
    return RefreshIndicator(
      onRefresh: _refreshFeed,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  Widget _buildGroupsTab() {
    final groups = [
      CommunityGroup(
        id: '1',
        name: 'Principiantes Eva Strong',
        description: 'Para quienes empiezan su transformación',
        members: 1234,
        icon: '🌱',
        isJoined: true,
      ),
      CommunityGroup(
        id: '2',
        name: 'Rutinas Matutinas',
        description: 'Grupo para madrugadores motivados',
        members: 856,
        icon: '🌅',
        isJoined: false,
      ),
      CommunityGroup(
        id: '3',
        name: 'Mamás Fuertes',
        description: 'Apoyo y motivación para mamás fitness',
        members: 2341,
        icon: '👩‍👧‍👦',
        isJoined: false,
      ),
      CommunityGroup(
        id: '4',
        name: 'Atletas Eva Strong',
        description: 'Para los más dedicados',
        members: 567,
        icon: '🏆',
        isJoined: false,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _buildGroupCard(group);
      },
    );
  }

  Widget _buildChallengesTab() {
    final challenges = [
      Challenge(
        id: '1',
        title: 'Reto 30 Días',
        description: 'Completa una rutina cada día por 30 días',
        participants: 4521,
        daysLeft: 15,
        difficulty: 'Media',
        icon: '🔥',
        isJoined: true,
      ),
      Challenge(
        id: '2',
        title: 'Reto 100 Sentadillas',
        description: 'Haz 100 sentadillas en un día',
        participants: 892,
        daysLeft: 7,
        difficulty: 'Alta',
        icon: '💪',
        isJoined: false,
      ),
      Challenge(
        id: '3',
        title: 'Reto Hidratación',
        description: 'Bebe 8 vasos de agua diarios por 21 días',
        participants: 1203,
        daysLeft: 12,
        difficulty: 'Baja',
        icon: '💧',
        isJoined: false,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return _buildChallengeCard(challenge);
      },
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: EvaColors.surfaceLight,
                  child: Text(
                    post.avatar,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: EvaColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        _formatTimestamp(post.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: EvaColors.textPrimary.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.content,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: EvaColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.favorite_border,
                        color: EvaColors.vibrantPink,
                      ),
                      onPressed: () => _likePost(post.id),
                    ),
                    Text(
                      post.likes.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: EvaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: Icon(
                        Icons.comment_outlined,
                        color: EvaColors.vibrantPink,
                      ),
                      onPressed: () => _showComments(post),
                    ),
                    Text(
                      post.comments.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: EvaColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.share_outlined,
                    color: EvaColors.vibrantPink,
                  ),
                  onPressed: () => _sharePost(post),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(CommunityGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: EvaColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(group.icon, style: const TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: EvaColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    group.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: EvaColors.textPrimary.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${group.members} miembros',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: EvaColors.textPrimary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _toggleGroupMembership(group),
              style: ElevatedButton.styleFrom(
                backgroundColor: group.isJoined
                    ? Colors.grey
                    : EvaColors.vibrantPink,
                foregroundColor: group.isJoined
                    ? Colors.black
                    : EvaColors.textOnVibrant,
              ),
              child: Text(group.isJoined ? 'Unido' : 'Unirse'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: EvaColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      challenge.icon,
                      style: const TextStyle(fontSize: 25),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: EvaColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        challenge.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: EvaColors.textPrimary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dificultad: ${challenge.difficulty}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: EvaColors.textPrimary.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '${challenge.participants} participantes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: EvaColors.textPrimary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${challenge.daysLeft} días',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: EvaColors.vibrantPink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _toggleChallengeParticipation(challenge),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: challenge.isJoined
                            ? Colors.grey
                            : EvaColors.vibrantPink,
                        foregroundColor: challenge.isJoined
                            ? Colors.black
                            : EvaColors.textOnVibrant,
                      ),
                      child: Text(challenge.isJoined ? 'Unido' : 'Unirse'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }

  Future<void> _refreshFeed() async {
    await Future.delayed(const Duration(seconds: 1));
    // Simular refresh
  }

  void _likePost(String postId) {
    setState(() {
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        _posts[postIndex] = _posts[postIndex].copyWith(
          likes: _posts[postIndex].likes + 1,
        );
      }
    });
  }

  void _showComments(CommunityPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Comentarios (${post.comments})'),
        content: const Text('Función de comentarios próximamente...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _sharePost(CommunityPost post) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Compartir próximamente...')));
  }

  void _toggleGroupMembership(CommunityGroup group) {
    setState(() {
      final groupIndex = _groups.indexWhere((g) => g.id == group.id);
      if (groupIndex != -1) {
        _groups[groupIndex] = _groups[groupIndex].copyWith(
          isJoined: !_groups[groupIndex].isJoined,
        );
      }
    });
  }

  void _toggleChallengeParticipation(Challenge challenge) {
    setState(() {
      final challengeIndex = _challenges.indexWhere(
        (c) => c.id == challenge.id,
      );
      if (challengeIndex != -1) {
        _challenges[challengeIndex] = _challenges[challengeIndex].copyWith(
          isJoined: !_challenges[challengeIndex].isJoined,
        );
      }
    });
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Publicación'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: '¿Qué quieres compartir?',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
  }

  // Datos simulados para grupos y retos
  List<CommunityGroup> get _groups => [];
  List<Challenge> get _challenges => [];
}

class CommunityPost {
  final String id;
  final String author;
  final String avatar;
  final String content;
  final int likes;
  final int comments;
  final DateTime timestamp;
  final String? imageUrl;

  CommunityPost({
    required this.id,
    required this.author,
    required this.avatar,
    required this.content,
    required this.likes,
    required this.comments,
    required this.timestamp,
    this.imageUrl,
  });

  CommunityPost copyWith({
    String? id,
    String? author,
    String? avatar,
    String? content,
    int? likes,
    int? comments,
    DateTime? timestamp,
    String? imageUrl,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      author: author ?? this.author,
      avatar: avatar ?? this.avatar,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class CommunityGroup {
  final String id;
  final String name;
  final String description;
  final int members;
  final String icon;
  final bool isJoined;

  CommunityGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.icon,
    required this.isJoined,
  });

  CommunityGroup copyWith({
    String? id,
    String? name,
    String? description,
    int? members,
    String? icon,
    bool? isJoined,
  }) {
    return CommunityGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      members: members ?? this.members,
      icon: icon ?? this.icon,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final int participants;
  final int daysLeft;
  final String difficulty;
  final String icon;
  final bool isJoined;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.participants,
    required this.daysLeft,
    required this.difficulty,
    required this.icon,
    required this.isJoined,
  });

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    int? participants,
    int? daysLeft,
    String? difficulty,
    String? icon,
    bool? isJoined,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      participants: participants ?? this.participants,
      daysLeft: daysLeft ?? this.daysLeft,
      difficulty: difficulty ?? this.difficulty,
      icon: icon ?? this.icon,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}
