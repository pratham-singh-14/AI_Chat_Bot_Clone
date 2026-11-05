import 'package:flutter/material.dart';
import '../../../../data/models/pdf_document_model.dart';

class PdfItemCard extends StatelessWidget {
  final PdfDocumentModel pdf;
  final bool isSelected;
  final ValueChanged<bool?> onSelectedChanged;
  final VoidCallback onDelete;

  const PdfItemCard({
    super.key,
    required this.pdf,
    required this.isSelected,
    required this.onSelectedChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: onSelectedChanged,
        secondary: const CircleAvatar(
          backgroundColor: Color(0xFFFFEBEE),
          child: Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 20),
        ),
        title: Text(
          pdf.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${pdf.pages} page${pdf.pages == 1 ? '' : 's'} • ${pdf.formattedSize}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        activeColor: const Color(0xFF10A37F),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}
