import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatApiService {
  final ApiClient _client;

  ChatApiService(this._client);

  Future<String> createSession() async {
    final response = await _client.dio.get(ApiConstants.session);
    return response.data['clientId'].toString();
  }

  Future<List<ConversationModel>> fetchConversations(String clientId) async {
    final response = await _client.dio.get(ApiConstants.conversationHistory(clientId));
    final List list = response.data as List;
    return list.map((item) => ConversationModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<String> createConversation(String clientId) async {
    final response = await _client.dio.post(
      ApiConstants.conversations,
      data: {'clientId': clientId},
    );
    return response.data['conversationId'].toString();
  }

  Future<bool> deleteConversation(String conversationId) async {
    final response = await _client.dio.delete(ApiConstants.deleteConversation(conversationId));
    return response.statusCode == 200;
  }

  Future<List<MessageModel>> fetchMessages(String conversationId) async {
    final response = await _client.dio.get(ApiConstants.messageList(conversationId));
    final List list = response.data as List;
    return list.map((item) => MessageModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String message,
    String? imageBase64,
    String? audioBase64,
    String? mimeType,
    bool generateAudio = false,
  }) async {
    final payload = <String, dynamic>{
      'conversationId': conversationId,
      'message': message,
      'generateAudio': generateAudio,
    };
    if (imageBase64 != null) payload['imageBase64'] = imageBase64;
    if (audioBase64 != null) payload['audioBase64'] = audioBase64;
    if (mimeType != null) payload['mimeType'] = mimeType;

    final response = await _client.dio.post(
      ApiConstants.messages,
      data: payload,
    );

    return MessageModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String> generateImage(String prompt, {String? conversationId}) async {
    final query = <String, dynamic>{
      'msg': prompt,
    };
    if (conversationId != null) query['conversationId'] = conversationId;

    final response = await _client.dio.post(
      ApiConstants.genImage,
      queryParameters: query,
    );
    return response.data['response'].toString();
  }
}
