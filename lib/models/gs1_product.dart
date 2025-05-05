// This will be enhanced with freezed later
class GS1Product {
  final String gtin;
  final String? name;
  final String? description;
  final String? brand;
  final String? manufacturer;
  final Map<String, dynamic>? additionalData;

  GS1Product({
    required this.gtin,
    this.name,
    this.description,
    this.brand,
    this.manufacturer,
    this.additionalData,
  });

  // This will be replaced with freezed generated code
  factory GS1Product.fromJson(Map<String, dynamic> json) {
    return GS1Product(
      gtin: json['gtin'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      brand: json['brand'] as String?,
      manufacturer: json['manufacturer'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gtin': gtin,
      'name': name,
      'description': description,
      'brand': brand,
      'manufacturer': manufacturer,
      'additionalData': additionalData,
    };
  }
}
