import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import '../../../data/models/message_model.dart';
import '../../../data/repositories/chat_repository.dart';

class ChatController extends GetxController {
  final ChatRepository _chatRepository;

  ChatController(this._chatRepository);

  late final String conversationId;
  late final String title;

  final messages = <MessageModel>[].obs;
  final isLoadingHistory = false.obs;
  final isSending = false.obs;
  final isRecording = false.obs;
  final requestAudioReply = false.obs;

  final selectedImage = Rx<File?>(null);
  final selectedImageBase64 = Rx<String?>(null);
  final selectedMimeType = Rx<String?>('image/jpeg');

  final selectedAudio = Rx<File?>(null);
  final selectedAudioBase64 = Rx<String?>(null);

  final textController = TextEditingController();
  final scrollController = ScrollController();
  final imagePicker = ImagePicker();

  late final AudioPlayer audioPlayer;
  late final AudioRecorder audioRecorder;

  final isPlayingAudio = false.obs;
  final currentlyPlayingUrl = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    conversationId = args['conversationId']?.toString() ?? '';
    title = args['title']?.toString() ?? 'Chat';

    audioPlayer = AudioPlayer();
    audioRecorder = AudioRecorder();

    audioPlayer.onPlayerStateChanged.listen((state) {
      isPlayingAudio.value = state == PlayerState.playing;
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        currentlyPlayingUrl.value = null;
      }
    });

    loadMessages();
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    audioPlayer.dispose();
    audioRecorder.dispose();
    super.onClose();
  }

  Future<void> loadMessages() async {
    if (conversationId.isEmpty) return;
    isLoadingHistory.value = true;
    try {
      final list = await _chatRepository.getMessages(conversationId);
      messages.assignAll(list);
      scrollToBottom();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load messages: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await imagePicker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.readAsBytes();
        selectedImage.value = file;
        selectedImageBase64.value = base64Encode(bytes);
        selectedMimeType.value = picked.mimeType ?? 'image/jpeg';
      }
    } catch (e) {
      Get.snackbar('Image Picker Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void clearSelectedImage() {
    selectedImage.value = null;
    selectedImageBase64.value = null;
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecorder.hasPermission()) {
        final tempDir = Directory.systemTemp;
        final path = '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        isRecording.value = true;
      }
    } catch (e) {
      Get.snackbar('Recording Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await audioRecorder.stop();
      isRecording.value = false;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          selectedAudio.value = file;
          selectedAudioBase64.value = base64Encode(bytes);
        }
      }
    } catch (e) {
      isRecording.value = false;
      Get.snackbar('Recording Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void clearSelectedAudio() {
    selectedAudio.value = null;
    selectedAudioBase64.value = null;
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    final hasImage = selectedImageBase64.value != null;
    final hasAudio = selectedAudioBase64.value != null;

    if (text.isEmpty && !hasImage && !hasAudio) return;

    String userDisplayType = 'text';
    String? userImageUrl;
    if (hasImage) {
      userDisplayType = 'image';
      userImageUrl = 'data:${selectedMimeType.value};base64,${selectedImageBase64.value}';
    } else if (hasAudio) {
      userDisplayType = 'audio';
    }

    final userMsg = MessageModel(
      role: 'USER',
      message: text.isNotEmpty ? text : (hasImage ? '[Attached Image]' : '[Voice Note]'),
      type: userDisplayType,
      imageUrl: userImageUrl,
    );
    messages.add(userMsg);
    scrollToBottom();

    final sendingText = text;
    final sendingImageBase64 = selectedImageBase64.value;
    final sendingAudioBase64 = selectedAudioBase64.value;
    final sendingMime = selectedMimeType.value;
    final wantsAudio = requestAudioReply.value;

    textController.clear();
    clearSelectedImage();
    clearSelectedAudio();

    isSending.value = true;
    try {
      final reply = await _chatRepository.sendMessage(
        conversationId: conversationId,
        message: sendingText,
        imageBase64: sendingImageBase64,
        audioBase64: sendingAudioBase64,
        mimeType: sendingMime,
        generateAudio: wantsAudio,
      );

      messages.add(reply);
      scrollToBottom();
    } catch (e) {
      Get.snackbar(
        'Sending Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withAlpha(230),
        colorText: Colors.white,
      );
    } finally {
      isSending.value = false;
    }
  }

  Future<void> playAudio(String audioSource) async {
    try {
      if (currentlyPlayingUrl.value == audioSource && isPlayingAudio.value) {
        await audioPlayer.pause();
        return;
      }

      currentlyPlayingUrl.value = audioSource;
      if (audioSource.startsWith('data:audio')) {
        final commaIdx = audioSource.indexOf(',');
        final base64Data = commaIdx >= 0 ? audioSource.substring(commaIdx + 1) : audioSource;
        final bytes = base64Decode(base64Data);
        await audioPlayer.play(BytesSource(bytes));
      } else {
        await audioPlayer.play(UrlSource(audioSource));
      }
    } catch (e) {
      Get.snackbar('Audio Playback Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
