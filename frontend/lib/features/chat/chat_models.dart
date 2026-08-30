class MessageModel {
  final String id;
  final String conversationId;
  final String role;
  final String content;
  final String createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      role: json['role'] ?? 'USER',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class ConversationModel {
  final String id;
  final String title;
  final String createdAt;
  final String updatedAt;
  final List<MessageModel> messages;

  ConversationModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List<dynamic>? ?? [];
    return ConversationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Dental Consultation',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      messages: rawMessages
          .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
