import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/data/models/conversation_model.dart';
import 'package:flutter_app/data/models/message_model.dart';
import 'package:flutter_app/data/models/pdf_document_model.dart';
import 'package:flutter_app/data/models/source_citation_model.dart';

void main() {
  group('Data Models Unit Tests', () {
    test('ConversationModel fromJson and toJson', () {
      final json = {
        'conversationId': 'conv-123',
        'title': 'Test Chat',
      };
      final model = ConversationModel.fromJson(json);

      expect(model.conversationId, 'conv-123');
      expect(model.title, 'Test Chat');
      expect(model.displayTitle, 'Test Chat');
      expect(model.toJson()['conversationId'], 'conv-123');
    });

    test('ConversationModel fallback displayTitle when title is null or blank', () {
      final model1 = ConversationModel(conversationId: 'c1', title: null);
      final model2 = ConversationModel(conversationId: 'c2', title: '   ');

      expect(model1.displayTitle, 'New Conversation');
      expect(model2.displayTitle, 'New Conversation');
    });

    test('SourceCitationModel fromJson and toJson', () {
      final json = {
        'pdfId': 'doc-1',
        'pdfName': 'manual.pdf',
        'page': 3,
        'snippet': 'OpenAI integration overview',
        'score': 0.92,
      };
      final model = SourceCitationModel.fromJson(json);

      expect(model.pdfId, 'doc-1');
      expect(model.pdfName, 'manual.pdf');
      expect(model.page, 3);
      expect(model.score, 0.92);
      expect(model.toJson()['page'], 3);
    });

    test('MessageModel user and assistant roles parsing', () {
      final userJson = {
        'role': 'USER',
        'message': 'Hello AI',
        'type': 'text',
      };
      final userMsg = MessageModel.fromJson(userJson);
      expect(userMsg.isUser, isTrue);
      expect(userMsg.message, 'Hello AI');

      final aiJson = {
        'role': 'AI',
        'response': 'Hello human! How can I assist you?',
        'type': 'text',
      };
      final aiMsg = MessageModel.fromJson(aiJson);
      expect(aiMsg.isUser, isFalse);
      expect(aiMsg.message, 'Hello human! How can I assist you?');
    });

    test('MessageModel with multimodal image, audio, and source citations', () {
      final json = {
        'role': 'AI',
        'response': 'Grounded response from documents',
        'type': 'pdf_rag',
        'imageUrl': 'https://image.url/photo.png',
        'audioUrl': 'https://audio.url/tts.wav',
        'sources': [
          {
            'pdfId': 'pdf-1',
            'pdfName': 'report.pdf',
            'page': 1,
            'snippet': 'Annual summary',
            'score': 0.88,
          }
        ],
      };
      final model = MessageModel.fromJson(json);

      expect(model.type, 'pdf_rag');
      expect(model.imageUrl, 'https://image.url/photo.png');
      expect(model.audioUrl, 'https://audio.url/tts.wav');
      expect(model.sources, isNotNull);
      expect(model.sources!.length, 1);
      expect(model.sources!.first.pdfName, 'report.pdf');
    });

    test('PdfDocumentModel formattedSize calculations', () {
      final doc1 = PdfDocumentModel(id: '1', name: 'small.pdf', pages: 1, size: 500, uploadTime: '');
      final doc2 = PdfDocumentModel(id: '2', name: 'medium.pdf', pages: 10, size: 204800, uploadTime: '');
      final doc3 = PdfDocumentModel(id: '3', name: 'large.pdf', pages: 100, size: 5242880, uploadTime: '');

      expect(doc1.formattedSize, '500 B');
      expect(doc2.formattedSize, '200.0 KB');
      expect(doc3.formattedSize, '5.0 MB');
    });
  });
}
