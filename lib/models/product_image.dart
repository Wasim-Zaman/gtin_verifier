class ProductImage {
  final String id;
  final String barcode;
  final String photos;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String brandOwnerId;
  final String lastModifiedBy;
  final String domainName;

  ProductImage({
    required this.id,
    required this.barcode,
    required this.photos,
    required this.createdAt,
    required this.updatedAt,
    required this.brandOwnerId,
    required this.lastModifiedBy,
    required this.domainName,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? '',
      barcode: json['barcode'] ?? '',
      photos: json['photos'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      brandOwnerId: json['brand_owner_id'] ?? '',
      lastModifiedBy: json['last_modified_by'] ?? '',
      domainName: json['domainName'] ?? '',
    );
  }

  String get fullImageUrl {
    final normalized = photos.replaceAll('\\', '/');
    return 'https://upchub.online$normalized';
  }
}

class ProductImageResponse {
  final List<ProductImage> images;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  ProductImageResponse({
    required this.images,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory ProductImageResponse.fromJson(Map<String, dynamic> json) {
    return ProductImageResponse(
      images:
          (json['data'] as List).map((e) => ProductImage.fromJson(e)).toList(),
      total: json['pagination']?['total'] ?? 0,
      page: json['pagination']?['page'] ?? 1,
      pageSize: json['pagination']?['pageSize'] ?? 10,
      totalPages: json['pagination']?['totalPages'] ?? 1,
    );
  }
}
