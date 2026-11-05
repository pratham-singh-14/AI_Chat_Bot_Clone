import '../models/message_model.dart';
import '../models/pdf_document_model.dart';
import '../services/pdf_api_service.dart';

class PdfRepository {
  final PdfApiService _apiService;

  PdfRepository(this._apiService);

  Future<PdfDocumentModel> uploadPdf(String filePath, String fileName) =>
      _apiService.uploadPdf(filePath, fileName);

  Future<List<PdfDocumentModel>> getPdfList() => _apiService.fetchPdfList();

  Future<bool> deletePdf(String pdfId) => _apiService.deletePdf(pdfId);

  Future<MessageModel> askPdf({
    required List<String> pdfIds,
    required String question,
    String? conversationId,
  }) =>
      _apiService.askPdf(
        pdfIds: pdfIds,
        question: question,
        conversationId: conversationId,
      );
}
