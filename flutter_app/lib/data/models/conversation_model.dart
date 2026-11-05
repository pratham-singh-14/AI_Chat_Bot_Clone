class ConversationModel {
  final String conversationId;
  final String? title;

  ConversationModel({
    required this.conversationId,
    this.title,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      conversationId: json['conversationId']?.toString() ?? '',
      title: json['title']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'title': title,
    };
  }

  String get displayTitle => (title != null && title!.trim().isNotEmpty)
      ? title!.trim()
      : 'New Conversation';
}
