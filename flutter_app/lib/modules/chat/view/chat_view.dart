import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/chat_controller.dart';
import 'widgets/attachment_preview.dart';
import 'widgets/message_bubble.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'GPT-4o Multimodal',
              style: TextStyle(fontSize: 11, color: Color(0xFF10A37F)),
            ),
          ],
        ),
        actions: [
          Obx(() => IconButton(
                tooltip: controller.requestAudioReply.value
                    ? 'Audio replies enabled'
                    : 'Enable voice reply (TTS)',
                icon: Icon(
                  controller.requestAudioReply.value
                      ? Icons.volume_up
                      : Icons.volume_off_outlined,
                  color: controller.requestAudioReply.value
                      ? const Color(0xFF10A37F)
                      : Colors.grey,
                ),
                onPressed: () => controller.requestAudioReply.toggle(),
              )),
          IconButton(
            tooltip: 'Refresh conversation',
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoadingHistory.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10A37F).withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, size: 48, color: Color(0xFF10A37F)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'How can I help you today?',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• Ask questions or brainstorm\n• Attach photos for Vision analysis\n• Record voice notes for Whisper STT\n• Ask "/image <prompt>" for DALL-E generation',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  return Obx(() => MessageBubble(
                        message: msg,
                        onPlayAudio: controller.playAudio,
                        isPlaying: controller.isPlayingAudio.value &&
                            controller.currentlyPlayingUrl.value == msg.audioUrl,
                      ));
                },
              );
            }),
          ),

          Obx(() {
            if (controller.isSending.value) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).cardColor,
                child: Row(
                  children: const [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'AI is thinking...',
                      style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          Obx(() => AttachmentPreview(
                imageFile: controller.selectedImage.value,
                audioFile: controller.selectedAudio.value,
                onClearImage: controller.clearSelectedImage,
                onClearAudio: controller.clearSelectedAudio,
              )),

          Obx(() {
            if (controller.isRecording.value) {
              return Container(
                padding: const EdgeInsets.all(12),
                color: Colors.redAccent.withAlpha(38),
                child: Row(
                  children: [
                    const Icon(Icons.mic, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Recording audio... tap checkmark to stop & attach',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.redAccent, size: 28),
                      onPressed: controller.stopRecording,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(top: BorderSide(color: Colors.black.withAlpha(15))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    tooltip: 'Attach Image',
                    onPressed: () => _showImageSourceSheet(context),
                  ),

                  Obx(() => IconButton(
                        icon: Icon(
                          controller.isRecording.value ? Icons.stop_circle : Icons.mic_none,
                          color: controller.isRecording.value ? Colors.redAccent : null,
                        ),
                        tooltip: 'Voice message',
                        onPressed: controller.isRecording.value
                            ? controller.stopRecording
                            : controller.startRecording,
                      )),

                  Expanded(
                    child: TextField(
                      controller: controller.textController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => controller.sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Message AI Assistant...',
                        hintStyle: const TextStyle(fontSize: 14),
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF10A37F),
                    ),
                    icon: const Icon(Icons.arrow_upward, color: Colors.white),
                    onPressed: controller.sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                controller.pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                controller.pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
