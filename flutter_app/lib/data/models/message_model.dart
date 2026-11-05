import 'source_citation_model.dart';

class MessageModel {
  final String role; // "USER" or "AI"
  final String message;
  final String type; // "text", "image", "audio", "multimodal", "pdf_rag"
  final String? imageUrl;
  final String? audioUrl;
  final List<SourceCitationModel>? sources;
  final DateTime timestamp;

  MessageModel({
    required this.role,
    required this.message,
    this.type = 'text',
    this.imageUrl,
    this.audioUrl,
    this.sources,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role.toUpperCase() == 'USER';

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    List<SourceCitationModel>? parsedSources;
    if (json['sources'] is List) {
      parsedSources = (json['sources'] as List)
          .map((s) => SourceCitationModel.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    return MessageModel(
      role: json['role']?.toString() ?? 'AI',
      message: (json['message'] ?? json['response'])?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      imageUrl: json['imageUrl']?.toString(),
      audioUrl: json['audioUrl']?.toString(),
      sources: parsedSources,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'message': message,
      'type': type,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (audioUrl != null) 'audioUrl': audioUrl,
      if (sources != null) 'sources': sources!.map((s) => s.toJson()).toList(),
    };
  }
}
