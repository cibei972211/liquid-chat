enum MessageRole { user, assistant, system }

class Message {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'role': role.toString().split('.').last,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String,
        content: json['content'] as String,
        role: MessageRole.values.firstWhere(
          (e) => e.toString().split('.').last == json['role'],
          orElse: () => MessageRole.user,
        ),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Message copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
  }) =>
      Message(
        id: id ?? this.id,
        content: content ?? this.content,
        role: role ?? this.role,
        timestamp: timestamp ?? this.timestamp,
      );
}
