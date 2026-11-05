import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/session_manager.dart';
import '../../../data/models/conversation_model.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../routes/app_routes.dart';

class ChatListController extends GetxController {
  final ChatRepository _chatRepository;
  final ApiClient _apiClient;

  ChatListController(this._chatRepository, this._apiClient);

  final conversations = <ConversationModel>[].obs;
  final isLoading = false.obs;
  final isCreating = false.obs;
  final clientId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initSession();
  }

  Future<void> initSession() async {
    isLoading.value = true;
    try {
      String? savedBaseUrl = await SessionManager.getSavedBaseUrl();
      if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
        _apiClient.updateBaseUrl(savedBaseUrl);
      }

      String? savedClientId = await SessionManager.getClientId();
      if (savedClientId == null || savedClientId.isEmpty) {
        savedClientId = await _chatRepository.getOrCreateSession();
        await SessionManager.saveClientId(savedClientId);
      }
      clientId.value = savedClientId;
      await fetchConversations();
    } catch (e) {
      Get.snackbar(
        'Connection Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withAlpha(204),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchConversations() async {
    if (clientId.value.isEmpty) return;
    try {
      final list = await _chatRepository.getConversations(clientId.value);
      conversations.assignAll(list.reversed.toList());
    } catch (_) {}
  }

  Future<void> createNewConversation() async {
    if (clientId.value.isEmpty) return;
    isCreating.value = true;
    try {
      final newConvId = await _chatRepository.createConversation(clientId.value);
      await fetchConversations();
      openConversation(newConvId, 'New Conversation');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create conversation: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> deleteConversation(String convId) async {
    try {
      final success = await _chatRepository.deleteConversation(convId);
      if (success) {
        conversations.removeWhere((c) => c.conversationId == convId);
        Get.snackbar(
          'Deleted',
          'Conversation deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not delete conversation: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void openConversation(String convId, String title) {
    Get.toNamed(
      AppRoutes.chat,
      arguments: {
        'conversationId': convId,
        'title': title,
      },
    )?.then((_) => fetchConversations());
  }

  Future<void> updateCustomBaseUrl(String newUrl) async {
    _apiClient.updateBaseUrl(newUrl);
    await SessionManager.saveBaseUrl(newUrl);
    await initSession();
  }
}
