class Leaflet {
  final int id;
  final String productLeafletInformation;
  final String lang;
  final String linkType;
  final String targetUrl;
  final String gtin;
  final String? pdfDoc;
  final int? companyId;

  Leaflet({
    required this.id,
    required this.productLeafletInformation,
    required this.lang,
    required this.linkType,
    required this.targetUrl,
    required this.gtin,
    this.pdfDoc,
    this.companyId,
  });

  factory Leaflet.fromJson(Map<String, dynamic> json) {
    return Leaflet(
      id: json['ID'] ?? 0,
      productLeafletInformation: json['ProductLeafletInformation'] ?? '',
      lang: json['Lang'] ?? '',
      linkType: json['LinkType'] ?? '',
      targetUrl: json['TargetURL'] ?? '',
      gtin: json['GTIN'] ?? '',
      pdfDoc: json['PdfDoc'],
      companyId: json['companyId'],
    );
  }

  String? get fullPdfUrl {
    if (pdfDoc == null || pdfDoc!.isEmpty) return null;
    final normalized = pdfDoc!.replaceAll('\\', '/');
    return 'https://backend.gtrack.online/$normalized';
  }
}
