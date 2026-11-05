import 'dart:io';
import 'package:flutter/material.dart';

class AttachmentPreview extends StatelessWidget {
  final File? imageFile;
  final File? audioFile;
  final VoidCallback onClearImage;
  final VoidCallback onClearAudio;

  const AttachmentPreview({
    super.key,
    this.imageFile,
    this.audioFile,
    required this.onClearImage,
    required this.onClearAudio,
  });

  @override
  Widget build(BuildContext context) {
    if (imageFile == null && audioFile == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).cardColor.withAlpha(128),
      child: Row(
        children: [
          if (imageFile != null)
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    imageFile!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: -8,
                  right: -8,
                  child: GestureDetector(
                    onTap: onClearImage,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          if (imageFile != null && audioFile != null) const SizedBox(width: 16),
          if (audioFile != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mic, size: 18, color: Colors.white),
                  const SizedBox(width: 6),
                  const Text('Voice attached', style: TextStyle(fontSize: 12, color: Colors.white)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onClearAudio,
                    child: const Icon(Icons.close, size: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
