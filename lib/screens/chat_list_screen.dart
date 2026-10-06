import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/theme.dart';
import '../widgets/glass_container.dart';
import '../models/chat_session.dart';
import '../services/storage_service.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final StorageService _storage = StorageService();
  final Uuid _uuid = const Uuid();
  List<ChatSession> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await _storage.loadSessions();
    // 按更新时间排序
    sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    setState(() {
      _sessions = sessions;
      _loading = false;
    });
  }

  Future<void> _createNewChat() async {
    final now = DateTime.now();
    final session = ChatSession(
      id: _uuid.v4(),
      title: '新对话 ${_sessions.length + 1}',
      messages: [],
      createdAt: now,
      updatedAt: now,
    );
    setState(() => _sessions.insert(0, session));
    await _storage.saveSessions(_sessions);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(session: session),
      ),
    ).then((_) => _loadSessions());
  }

  Future<void> _deleteSession(String id, int index) async {
    final removed = _sessions.removeAt(index);
    setState(() {});
    await _storage.saveSessions(_sessions);

    // 撤销删除
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('对话已删除'),
        action: SnackBarAction(
          label: '撤销',
          onPressed: () {
            setState(() => _sessions.insert(index, removed));
            _storage.saveSessions(_sessions);
          },
        ),
        backgroundColor: AppTheme.primaryDark.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Column(
            children: [
              // 顶部标题栏
              _buildHeader(),
              // 会话列表
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _sessions.isEmpty
                        ? _buildEmptyState()
                        : _buildSessionList(),
              ),
            ],
          ),
        ),
      ),
      // 悬浮新建按钮
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '液态聊天',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_sessions.length} 个对话',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          // 设置按钮
          GlassContainer(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            padding: const EdgeInsets.all(10),
            borderRadius: 15,
            child: const Icon(Icons.settings, color: AppTheme.textPrimary, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryLight.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            '还没有对话',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮开始新对话吧',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9));
    );
  }

  Widget _buildSessionList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return Dismissible(
          key: Key(session.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(Icons.delete, color: Colors.red),
          ),
          onDismissed: (_) => _deleteSession(session.id, index),
          child: GlassContainer(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(session: session),
                ),
              ).then((_) => _loadSessions());
            },
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            borderRadius: 18,
            child: Row(
              children: [
                // 头像
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryLight.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                // 标题和预览
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.preview,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary.withOpacity(0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // 时间
                Text(
                  _formatDate(session.updatedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: index * 50)).slideX(begin: 0.1),
        );
      },
    );
  }

  Widget _buildFab() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryLight.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _createNewChat,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.month}/${date.day}';
  }
}
