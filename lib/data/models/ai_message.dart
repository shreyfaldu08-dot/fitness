enum MessageRole { user, assistant, system }

class AiMessage {
  final String id;
  final String userId;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final List<String> suggestedQuestions;

  const AiMessage({
    required this.id,
    required this.userId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.suggestedQuestions = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'suggested_questions': suggestedQuestions,
    };
  }

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String? ?? 'assistant';
    MessageRole parsedRole = MessageRole.assistant;
    if (roleStr == 'user') parsedRole = MessageRole.user;
    if (roleStr == 'system') parsedRole = MessageRole.system;

    return AiMessage(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      role: parsedRole,
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      suggestedQuestions: (json['suggested_questions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
