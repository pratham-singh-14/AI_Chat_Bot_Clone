class PdfDocumentModel {
  final String id;
  final String name;
  final int pages;
  final int size;
  final String uploadTime;

  PdfDocumentModel({
    required this.id,
    required this.name,
    required this.pages,
    required this.size,
    required this.uploadTime,
  });

  factory PdfDocumentModel.fromJson(Map<String, dynamic> json) {
    return PdfDocumentModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Document.pdf',
      pages: (json['pages'] as num?)?.toInt() ?? 1,
      size: (json['size'] as num?)?.toInt() ?? 0,
      uploadTime: json['uploadTime']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pages': pages,
      'size': size,
      'uploadTime': uploadTime,
    };
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
