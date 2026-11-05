import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../data/models/message_model.dart';
import '../../../../data/models/source_citation_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final Function(String) onPlayAudio;
  final bool isPlaying;

  const MessageBubble({
    super.key,
    required this.message,
    required this.onPlayAudio,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isUser
        ? (isDark ? const Color(0xFF2B5278) : const Color(0xFFD0E6FF))
        : (isDark ? const Color(0xFF2E3035) : Colors.white);

    final textColor = isUser
        ? (isDark ? Colors.white : Colors.black87)
        : (isDark ? Colors.white : Colors.black87);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF10A37F),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imageUrl != null && message.imageUrl!.isNotEmpty) ...[
                    _buildImageWidget(context, message.imageUrl!),
                    const SizedBox(height: 10),
                  ],

                  if (message.message.isNotEmpty)
                    SelectableText(
                      message.message,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),

                  if (message.audioUrl != null && message.audioUrl!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => onPlayAudio(message.audioUrl!),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10A37F).withAlpha(38),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPlaying ? Icons.pause_circle : Icons.play_circle,
                              color: const Color(0xFF10A37F),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isPlaying ? 'Playing Audio...' : 'Listen Audio Response',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10A37F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  if (message.sources != null && message.sources!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    const Text(
                      'Sources Cited:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: message.sources!.map((s) => _buildCitationChip(context, s)).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageWidget(BuildContext context, String source) {
    if (source.startsWith('data:image')) {
      final commaIndex = source.indexOf(',');
      final base64String = commaIndex != -1 ? source.substring(commaIndex + 1) : source;
      try {
        final bytes = base64Decode(base64String);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            height: 220,
            width: double.infinity,
          ),
        );
      } catch (e) {
        return const Text('[Invalid Image Data]');
      }
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          source,
          fit: BoxFit.cover,
          height: 220,
          width: double.infinity,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 220,
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (ctx, err, stack) => const Text('[Failed to load image]'),
        ),
      );
    }
  }

  Widget _buildCitationChip(BuildContext context, SourceCitationModel citation) {
    return ActionChip(
      avatar: const Icon(Icons.description, size: 14, color: Colors.redAccent),
      label: Text(
        '${citation.pdfName} (p.${citation.page})',
        style: const TextStyle(fontSize: 11),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('${citation.pdfName} - Page ${citation.page}'),
            content: Text(
              citation.snippet,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
