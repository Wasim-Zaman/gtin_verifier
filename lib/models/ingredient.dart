class Ingredient {
  final String id;
  final String productName;
  final String ingredient;
  final String quantity;
  final String unit;
  final String barcode;
  final String lotNumber;
  final DateTime productionDate;
  final DateTime expirationDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String brandOwnerId;
  final String lastModifiedBy;
  final String domainName;

  Ingredient({
    required this.id,
    required this.productName,
    required this.ingredient,
    required this.quantity,
    required this.unit,
    required this.barcode,
    required this.lotNumber,
    required this.productionDate,
    required this.expirationDate,
    required this.createdAt,
    required this.updatedAt,
    required this.brandOwnerId,
    required this.lastModifiedBy,
    required this.domainName,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] ?? '',
      productName: json['product_name'] ?? '',
      ingredient: json['ingredient'] ?? '',
      quantity: json['quantity'] ?? '',
      unit: json['unit'] ?? '',
      barcode: json['barcode'] ?? '',
      lotNumber: json['lot_number'] ?? '',
      productionDate:
          json['production_date'] != null
              ? DateTime.parse(json['production_date'])
              : DateTime.now(),
      expirationDate:
          json['expiration_date'] != null
              ? DateTime.parse(json['expiration_date'])
              : DateTime.now(),
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
      domainName: json['domainName'] ?? '',
    );
  }
}

class IngredientResponse {
  final List<Ingredient> ingredients;

  IngredientResponse({required this.ingredients});

  factory IngredientResponse.fromJson(Map<String, dynamic> json) {
    List<Ingredient> ingredients = [];
    if (json['data'] != null) {
      ingredients =
          (json['data'] as List)
              .map((item) => Ingredient.fromJson(item))
              .toList();
    }
    return IngredientResponse(ingredients: ingredients);
  }
}
