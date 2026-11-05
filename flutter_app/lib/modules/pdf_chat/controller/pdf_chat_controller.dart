import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/pdf_document_model.dart';
import '../../../data/repositories/pdf_repository.dart';

class PdfChatController extends GetxController {
  final PdfRepository _pdfRepository;

  PdfChatController(this._pdfRepository);

  final pdfList = <PdfDocumentModel>[].obs;
  final selectedPdfIds = <String>{}.obs;
  final ragMessages = <MessageModel>[].obs;

  final isLoadingPdfs = false.obs;
  final isUploading = false.obs;
  final isAsking = false.obs;

  final questionController = TextEditingController();
  final scrollController = ScrollController();

  String? conversationId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    conversationId = args['conversationId']?.toString();
    loadPdfList();
  }

  @override
  void onClose() {
    questionController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadPdfList() async {
    isLoadingPdfs.value = true;
    try {
      final list = await _pdfRepository.getPdfList();
      pdfList.assignAll(list);
      if (selectedPdfIds.isEmpty && list.isNotEmpty) {
        selectedPdfIds.addAll(list.map((p) => p.id));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch PDF list: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingPdfs.value = false;
    }
  }

  void togglePdfSelection(String pdfId) {
    if (selectedPdfIds.contains(pdfId)) {
      selectedPdfIds.remove(pdfId);
    } else {
      selectedPdfIds.add(pdfId);
    }
  }

  void selectAll() {
    selectedPdfIds.addAll(pdfList.map((p) => p.id));
  }

  void clearSelection() {
    selectedPdfIds.clear();
  }

  Future<void> uploadPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final name = result.files.single.name;

        isUploading.value = true;
        final uploaded = await _pdfRepository.uploadPdf(path, name);
        pdfList.insert(0, uploaded);
        selectedPdfIds.add(uploaded.id);

        Get.snackbar(
          'PDF Indexed',
          '${uploaded.name} (${uploaded.pages} pages) chunked and embedded into vector store',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10A37F).withAlpha(230),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Upload Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> deletePdf(String pdfId) async {
    try {
      final success = await _pdfRepository.deletePdf(pdfId);
      if (success) {
        pdfList.removeWhere((p) => p.id == pdfId);
        selectedPdfIds.remove(pdfId);
        Get.snackbar(
          'Deleted',
          'PDF file and vector store removed',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not delete PDF: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> askPdfQuestion() async {
    final query = questionController.text.trim();
    if (query.isEmpty) return;
    if (selectedPdfIds.isEmpty) {
      Get.snackbar(
        'No PDF Selected',
        'Please check at least one PDF from the list to query.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
      );
      return;
    }

    final userMsg = MessageModel(
      role: 'USER',
      message: query,
      type: 'pdf_rag',
    );
    ragMessages.add(userMsg);
    questionController.clear();
    scrollToBottom();

    isAsking.value = true;
    try {
      final response = await _pdfRepository.askPdf(
        pdfIds: selectedPdfIds.toList(),
        question: query,
        conversationId: conversationId,
      );

      ragMessages.add(response);
      scrollToBottom();
    } catch (e) {
      Get.snackbar(
        'RAG Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withAlpha(230),
        colorText: Colors.white,
      );
    } finally {
      isAsking.value = false;
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
