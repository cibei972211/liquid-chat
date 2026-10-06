import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../utils/theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/message_bubble.dart';
import '../models/message.dart';
import '../models/chat_session.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ChatScreen extends StatefulWidget {
  final ChatSession session;

  const ChatScreen({super.key, required this.session});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();
  final Uuid _uuid = const Uuid();

  late List<Message> _messages;
  late ChatSession _session;
  bool _isStreaming = false;
  bool _isSending = false;
  StreamSubscription<String>? _streamSub;

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.session.messages);
    _session = widget.session;
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _streamSub?.cancel();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _inputController.clear();

    // 添加用户消息
    final userMsg = Message(
      id: _uuid.v4(),
      content: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
    setState(() => _messages.add(userMsg));

    // 如果是第一条消息，用它作为会话标题
    if (_messages.where((m) => m.role == MessageRole.user).length == 1) {
      _session = _session.copyWith(
        title: text.length > 15 ? '${text.substring(0, 15)}...' : text,
      );
    }

    _scrollToBottom();

    // 添加 AI 占位消息
    final aiMsg = Message(
      id: _uuid.v4(),
      content: '',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(aiMsg);
      _isStreaming = true;
    });

    // 流式请求
    final history = _messages.sublist(0, _messages.length - 1);
    String fullContent = '';

    _streamSub = _api.streamChat(history).listen(
      (chunk) {
        fullContent += chunk;
        final index = _messages.indexWhere((m) => m.id == aiMsg.id);
        if (index != -1) {
          setState(() {
            _messages[index] = _messages[index].copyWith(content: fullContent);
          });
        }
        _scrollToBottom();
      },
      onDone: () {
        setState(() {
          _isStreaming = false;
          _isSending = false;
        });
        _saveSession();
      },
      onError: (e) {
        fullContent += '\n\n[错误] $e';
        setState(() {
          _isStreaming = false;
          _isSending = false;
        });
        _saveSession();
      },
    );
  }

  void _stopStreaming() {
    _streamSub?.cancel();
    setState(() {
      _isStreaming = false;
      _isSending = false;
    });
    _saveSession();
  }

  Future<void> _saveSession() async {
    _session = _session.copyWith(
      messages: List.from(_messages),
      updatedAt: DateTime.now(),
    );
    final sessions = await _storage.loadSessions();
    final index = sessions.indexWhere((s) => s.id == _session.id);
    if (index != -1) {
      sessions[index] = _session;
    } else {
      sessions.add(_session);
    }
    await _storage.saveSessions(sessions);
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Column(
            children: [
              // 顶部导航栏
              _buildAppBar(),
              // 消息列表
              Expanded(
                child: _messages.isEmpty
                    ? _buildWelcome()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isLastAi = index == _messages.length - 1 &&
                              msg.role == MessageRole.assistant &&
                              _isStreaming;
                          return MessageBubble(
                            message: msg,
                            isStreaming: isLastAi,
                          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
                        },
                      ),
              ),
              // 输入区域
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return GlassContainer(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      borderRadius: 18,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
            iconSize: 20,
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _session.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _isStreaming ? '正在输入...' : '在线',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isStreaming ? AppTheme.primaryLight : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          if (_isStreaming)
            IconButton(
              onPressed: _stopStreaming,
              icon: const Icon(Icons.stop_circle, color: Colors.red),
              iconSize: 26,
            ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryLight.withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            '你好，我是 AI 助手',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '有什么可以帮你的吗？',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          // 快捷问题
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _buildQuickChip('帮我写首诗'),
              _buildQuickChip('解释一下量子力学'),
              _buildQuickChip('今天吃什么好'),
              _buildQuickChip('写个Python脚本'),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  Widget _buildQuickChip(String text) {
    return GlassContainer(
      onTap: () {
        _inputController.text = text;
        _sendMessage();
      },
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: 20,
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        borderRadius: 22,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: '输入消息...',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.6),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 发送按钮
            GestureDetector(
              onTap: _isSending ? null : _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: _isSending ? null : AppTheme.primaryGradient,
                  color: _isSending ? Colors.grey.withOpacity(0.3) : null,
                  shape: BoxShape.circle,
                  boxShadow: _isSending
                      ? null
                      : [
                          BoxShadow(
                            color: AppTheme.primaryLight.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Icon(
                  _isSending ? Icons.hourglass_empty : Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
