import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
import '../../../routes/app_routes.dart';
import '../controller/chat_list_controller.dart';
import 'widgets/conversation_tile.dart';

class ChatListView extends GetView<ChatListController> {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF10A37F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('AI Assistant'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'PDF Knowledge Base (RAG)',
            icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.redAccent),
            onPressed: () => Get.toNamed(AppRoutes.pdfChat),
          ),
          IconButton(
            tooltip: 'Server Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.conversations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary.withAlpha(128),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No conversations yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start a new chat to talk with OpenAI GPT-4o, generate images, analyze photos, or upload PDFs for grounded RAG.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: controller.createNewConversation,
                    icon: const Icon(Icons.add),
                    label: const Text('Start New Chat'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchConversations,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.conversations.length,
            separatorBuilder: (_, unused) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final conv = controller.conversations[index];
              return ConversationTile(
                conversation: conv,
                onTap: () => controller.openConversation(conv.conversationId, conv.displayTitle),
                onDelete: () => controller.deleteConversation(conv.conversationId),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.createNewConversation,
        icon: const Icon(Icons.add),
        label: const Text('New Chat'),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final textController = TextEditingController(text: ApiConstants.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Backend Configuration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Base URL (e.g. http://10.0.2.2:8080 for Android emulator, http://localhost:8080 for web/desktop):',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
                labelText: 'Backend URL',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newUrl = textController.text.trim();
              if (newUrl.isNotEmpty) {
                controller.updateCustomBaseUrl(newUrl);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save & Reconnect'),
          ),
        ],
      ),
    );
  }
}
