import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/data/models/conversation_model.dart';
import 'package:flutter_app/data/models/message_model.dart';
import 'package:flutter_app/data/models/source_citation_model.dart';
import 'package:flutter_app/modules/chat/view/widgets/message_bubble.dart';
import 'package:flutter_app/modules/chat_list/view/widgets/conversation_tile.dart';

void main() {
  testWidgets('ConversationTile renders conversation title correctly', (WidgetTester tester) async {
    final conversation = ConversationModel(
      conversationId: 'c1',
      title: 'Interview Preparation Chat',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConversationTile(
            conversation: conversation,
            onTap: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Interview Preparation Chat'), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
  });

  testWidgets('MessageBubble renders user and AI messages', (WidgetTester tester) async {
    final userMsg = MessageModel(
      role: 'USER',
      message: 'Can you summarize this architecture?',
      type: 'text',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            message: userMsg,
            onPlayAudio: (_) {},
            isPlaying: false,
          ),
        ),
      ),
    );

    expect(find.text('Can you summarize this architecture?'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('MessageBubble renders source citations for RAG', (WidgetTester tester) async {
    final ragMsg = MessageModel(
      role: 'AI',
      message: 'Spring AI connects to OpenAI securely.',
      type: 'pdf_rag',
      sources: [
        SourceCitationModel(
          pdfId: 'doc1',
          pdfName: 'spring_ai.pdf',
          page: 4,
          snippet: 'Details about chat clients and advisors',
          score: 0.95,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            message: ragMsg,
            onPlayAudio: (_) {},
            isPlaying: false,
          ),
        ),
      ),
    );

    expect(find.text('Spring AI connects to OpenAI securely.'), findsOneWidget);
    expect(find.text('spring_ai.pdf (p.4)'), findsOneWidget);
    expect(find.text('Sources Cited:'), findsOneWidget);
  });
}
