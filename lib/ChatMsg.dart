class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.content, required this.role});

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
  };
}
