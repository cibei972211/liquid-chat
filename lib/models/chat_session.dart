import 'message.dart';

class ChatSession {
  final String id;
  final String title;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  String get preview {
    if (messages.isEmpty) return '开始新对话';
    final last = messages.last;
    final prefix = last.role == MessageRole.user ? '我: ' : 'AI: ';
    final text = last.content.replaceAll('\n', ' ');
    return prefix + (text.length > 30 ? '${text.substring(0, 30)}...' : text);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': messages.map((m) => m.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'] as String,
        title: json['title'] as String? ?? '新对话',
        messages: (json['messages'] as List<dynamic>?)
                ?.map((m) => Message.fromJson(m as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  ChatSession copyWith({
    String? id,
    String? title,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ChatSession(
        id: id ?? this.id,
        title: title ?? this.title,
        messages: messages ?? this.messages,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
