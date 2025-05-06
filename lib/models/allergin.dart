// lib/models/allergen.dart
class Allergen {
  final String id;
  final String barcode;
  final String productName;
  final String allergenName;
  final String allergenType;
  final String severity;
  final bool containsAllergen;
  final bool mayContain;
  final bool crossContaminationRisk;
  final String allergenSource;
  final String lotNumber;
  final DateTime productionDate;
  final DateTime expirationDate;
  final String brandOwnerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String lastModifiedBy;
  final String domainName;
  final String status;

  Allergen({
    required this.id,
    required this.barcode,
    required this.productName,
    required this.allergenName,
    required this.allergenType,
    required this.severity,
    required this.containsAllergen,
    required this.mayContain,
    required this.crossContaminationRisk,
    required this.allergenSource,
    required this.lotNumber,
    required this.productionDate,
    required this.expirationDate,
    required this.brandOwnerId,
    required this.createdAt,
    required this.updatedAt,
    required this.lastModifiedBy,
    required this.domainName,
    required this.status,
  });

  factory Allergen.fromJson(Map<String, dynamic> json) {
    return Allergen(
      id: json['id'] ?? '',
      barcode: json['barcode'] ?? '',
      productName: json['product_name'] ?? '',
      allergenName: json['allergen_name'] ?? '',
      allergenType: json['allergen_type'] ?? '',
      severity: json['severity'] ?? '',
      containsAllergen: json['contains_allergen'] ?? false,
      mayContain: json['may_contain'] ?? false,
      crossContaminationRisk: json['cross_contamination_risk'] ?? false,
      allergenSource: json['allergen_source'] ?? '',
      lotNumber: json['lot_number'] ?? '',
      productionDate:
          json['production_date'] != null
              ? DateTime.parse(json['production_date'])
              : DateTime.now(),
      expirationDate:
          json['expiration_date'] != null
              ? DateTime.parse(json['expiration_date'])
              : DateTime.now(),
      brandOwnerId: json['brand_owner_id'] ?? '',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
      lastModifiedBy: json['last_modified_by'] ?? '',
      domainName: json['domainName'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class AllergenResponse {
  final List<Allergen> allergens;

  AllergenResponse({required this.allergens});

  factory AllergenResponse.fromJson(Map<String, dynamic> json) {
    List<Allergen> allergens = [];
    if (json['allergens'] != null) {
      allergens =
          (json['allergens'] as List)
              .map((item) => Allergen.fromJson(item))
              .toList();
    }
    return AllergenResponse(allergens: allergens);
  }
}
