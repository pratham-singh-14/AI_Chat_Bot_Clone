import 'package:flutter/material.dart';
import '../../../../data/models/conversation_model.dart';

class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(conversation.conversationId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Conversation'),
            content: const Text('Are you sure you want to delete this conversation and its history?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF10A37F),
          child: Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
        ),
        title: Text(
          conversation.displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
