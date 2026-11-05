import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/chat_api_service.dart';

class ChatRepository {
  final ChatApiService _apiService;

  ChatRepository(this._apiService);

  Future<String> getOrCreateSession() => _apiService.createSession();

  Future<List<ConversationModel>> getConversations(String clientId) =>
      _apiService.fetchConversations(clientId);

  Future<String> createConversation(String clientId) =>
      _apiService.createConversation(clientId);

  Future<bool> deleteConversation(String conversationId) =>
      _apiService.deleteConversation(conversationId);

  Future<List<MessageModel>> getMessages(String conversationId) =>
      _apiService.fetchMessages(conversationId);

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String message,
    String? imageBase64,
    String? audioBase64,
    String? mimeType,
    bool generateAudio = false,
  }) =>
      _apiService.sendMessage(
        conversationId: conversationId,
        message: message,
        imageBase64: imageBase64,
        audioBase64: audioBase64,
        mimeType: mimeType,
        generateAudio: generateAudio,
      );

  Future<String> generateImage(String prompt, {String? conversationId}) =>
      _apiService.generateImage(prompt, conversationId: conversationId);
}
