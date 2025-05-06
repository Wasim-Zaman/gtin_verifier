class Retailer {
  final String id;
  final String productSku;
  final String barcode;
  final String storeId;
  final String storeName;
  final String storeGln;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String brandOwnerId;
  final String lastModifiedBy;
  final String domainName;

  Retailer({
    required this.id,
    required this.productSku,
    required this.barcode,
    required this.storeId,
    required this.storeName,
    required this.storeGln,
    required this.createdAt,
    required this.updatedAt,
    required this.brandOwnerId,
    required this.lastModifiedBy,
    required this.domainName,
  });

  factory Retailer.fromJson(Map<String, dynamic> json) {
    return Retailer(
      id: json['id'] ?? '',
      productSku: json['product_sku'] ?? '',
      barcode: json['barcode'] ?? '',
      storeId: json['store_id'] ?? '',
      storeName: json['store_name'] ?? '',
      storeGln: json['store_gln'] ?? '',
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

class RetailerResponse {
  final List<Retailer> retailers;

  RetailerResponse({required this.retailers});

  factory RetailerResponse.fromJson(Map<String, dynamic> json) {
    List<Retailer> retailers = [];
    if (json['data'] != null) {
      retailers =
          (json['data'] as List)
              .map((item) => Retailer.fromJson(item))
              .toList();
    }
    return RetailerResponse(retailers: retailers);
  }
}
