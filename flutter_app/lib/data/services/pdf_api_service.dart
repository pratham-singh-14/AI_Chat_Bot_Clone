import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/message_model.dart';
import '../models/pdf_document_model.dart';

class PdfApiService {
  final ApiClient _client;

  PdfApiService(this._client);

  Future<PdfDocumentModel> uploadPdf(String filePath, String fileName) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _client.dio.post(
      ApiConstants.pdfUpload,
      data: formData,
    );

    return PdfDocumentModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<PdfDocumentModel>> fetchPdfList() async {
    final response = await _client.dio.get(ApiConstants.pdfList);
    final List list = response.data as List;
    return list.map((item) => PdfDocumentModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<bool> deletePdf(String pdfId) async {
    final response = await _client.dio.delete(ApiConstants.deletePdf(pdfId));
    return response.statusCode == 200;
  }

  Future<MessageModel> askPdf({
    required List<String> pdfIds,
    required String question,
    String? conversationId,
  }) async {
    final payload = <String, dynamic>{
      'pdfIds': pdfIds,
      'question': question,
    };
    if (conversationId != null) payload['conversationId'] = conversationId;

    final response = await _client.dio.post(
      ApiConstants.pdfAsk,
      data: payload,
    );

    return MessageModel.fromJson(response.data as Map<String, dynamic>);
  }
}
