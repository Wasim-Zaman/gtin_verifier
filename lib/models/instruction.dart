class Instruction {
  final String id;
  final String barcode;
  final String pdfDoc;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String brandOwnerId;
  final String lastModifiedBy;

  Instruction({
    required this.id,
    required this.barcode,
    required this.pdfDoc,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.brandOwnerId,
    required this.lastModifiedBy,
  });

  factory Instruction.fromJson(Map<String, dynamic> json) {
    return Instruction(
      id: json['id'] ?? '',
      barcode: json['barcode'] ?? '',
      pdfDoc: json['pdfDoc'] ?? '',
      description: json['description'] ?? '',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
      brandOwnerId: json['brand_owner_id'] ?? '',
      lastModifiedBy: json['last_modified_by'] ?? '',
    );
  }

  // Helper to get the full PDF URL
  String get fullPdfUrl {
    if (pdfDoc.startsWith('http')) {
      return pdfDoc;
    }
    return 'https://upchub.online$pdfDoc';
  }
}

class InstructionResponse {
  final List<Instruction> instructions;

  InstructionResponse({required this.instructions});

  factory InstructionResponse.fromJson(Map<String, dynamic> json) {
    List<Instruction> instructions = [];
    if (json['data'] != null) {
      instructions =
          (json['data'] as List)
              .map((item) => Instruction.fromJson(item))
              .toList();
    }
    return InstructionResponse(instructions: instructions);
  }
}
