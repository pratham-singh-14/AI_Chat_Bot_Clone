class SourceCitationModel {
  final String pdfId;
  final String pdfName;
  final int page;
  final String snippet;
  final double score;

  SourceCitationModel({
    required this.pdfId,
    required this.pdfName,
    required this.page,
    required this.snippet,
    required this.score,
  });

  factory SourceCitationModel.fromJson(Map<String, dynamic> json) {
    return SourceCitationModel(
      pdfId: json['pdfId']?.toString() ?? '',
      pdfName: json['pdfName']?.toString() ?? 'Document',
      page: (json['page'] as num?)?.toInt() ?? 1,
      snippet: json['snippet']?.toString() ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pdfId': pdfId,
      'pdfName': pdfName,
      'page': page,
      'snippet': snippet,
      'score': score,
    };
  }
}
