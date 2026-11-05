import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../chat/view/widgets/message_bubble.dart';
import '../controller/pdf_chat_controller.dart';
import 'widgets/pdf_item_card.dart';

class PdfChatView extends GetView<PdfChatController> {
  const PdfChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Knowledge Base (RAG)'),
        actions: [
          IconButton(
            tooltip: 'Upload new PDF',
            icon: const Icon(Icons.upload_file),
            onPressed: controller.uploadPdf,
          ),
          IconButton(
            tooltip: 'Refresh PDF List',
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadPdfList,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).cardColor,
            child: ExpansionTile(
              initiallyExpanded: true,
              leading: const Icon(Icons.library_books_outlined, color: Color(0xFF10A37F)),
              title: Obx(() => Text(
                    'Selected PDFs (${controller.selectedPdfIds.length} of ${controller.pdfList.length})',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  )),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: controller.selectAll,
                    child: const Text('All', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton(
                    onPressed: controller.clearSelection,
                    child: const Text('Clear', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              children: [
                Obx(() {
                  if (controller.isLoadingPdfs.value) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.pdfList.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'No documents indexed yet.',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: controller.uploadPdf,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload PDF to Knowledge Base'),
                          ),
                        ],
                      ),
                    );
                  }

                  return SizedBox(
                    height: 180,
                    child: ListView.builder(
                      itemCount: controller.pdfList.length,
                      itemBuilder: (context, index) {
                        final pdf = controller.pdfList[index];
                        return Obx(() => PdfItemCard(
                              pdf: pdf,
                              isSelected: controller.selectedPdfIds.contains(pdf.id),
                              onSelectedChanged: (_) => controller.togglePdfSelection(pdf.id),
                              onDelete: () => controller.deletePdf(pdf.id),
                            ));
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          Obx(() {
            if (controller.isUploading.value) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.orangeAccent.withAlpha(38),
                child: Row(
                  children: const [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text(
                      'Chunking, extracting text & embedding into vector store...',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          Expanded(
            child: Obx(() {
              if (controller.ragMessages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.find_in_page_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Ask anything about your selected PDFs',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Questions are answered strictly using retrieved vector chunks from only the checked documents with source page citations.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.ragMessages.length,
                itemBuilder: (context, index) {
                  final msg = controller.ragMessages[index];
                  return MessageBubble(
                    message: msg,
                    onPlayAudio: (_) {},
                    isPlaying: false,
                  );
                },
              );
            }),
          ),

          Obx(() {
            if (controller.isAsking.value) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).cardColor,
                child: Row(
                  children: const [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text('Searching vectors and synthesizing grounded answer...',
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(top: BorderSide(color: Colors.black.withAlpha(15))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.questionController,
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => controller.askPdfQuestion(),
                      decoration: InputDecoration(
                        hintText: 'Ask a question from selected PDFs...',
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
                  const SizedBox(width: 8),
                  Obx(() => IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: controller.selectedPdfIds.isEmpty
                              ? Colors.grey
                              : const Color(0xFF10A37F),
                        ),
                        icon: const Icon(Icons.arrow_upward, color: Colors.white),
                        onPressed: controller.selectedPdfIds.isEmpty
                            ? null
                            : controller.askPdfQuestion,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
