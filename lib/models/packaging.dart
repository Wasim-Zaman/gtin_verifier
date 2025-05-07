class Packaging {
  final String id;
  final String status;
  final String barcode;
  final String packagingType;
  final String material;
  final String? dimensions;
  final String weight;
  final String? capacity;
  final bool recyclable;
  final bool biodegradable;
  final String? packagingSupplier;
  final String? costPerUnit;
  final String color;
  final String labeling;
  final String brandOwnerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> images;
  final String lastModifiedBy;
  final String domainName;

  Packaging({
    required this.id,
    required this.status,
    required this.barcode,
    required this.packagingType,
    required this.material,
    this.dimensions,
    required this.weight,
    this.capacity,
    required this.recyclable,
    required this.biodegradable,
    this.packagingSupplier,
    this.costPerUnit,
    required this.color,
    required this.labeling,
    required this.brandOwnerId,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
    required this.lastModifiedBy,
    required this.domainName,
  });

  factory Packaging.fromJson(Map<String, dynamic> json) {
    return Packaging(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      barcode: json['barcode'] ?? '',
      packagingType: json['packaging_type'] ?? '',
      material: json['material'] ?? '',
      dimensions: json['dimensions'],
      weight: json['weight'] ?? '',
      capacity: json['capacity'],
      recyclable: json['recyclable'] ?? false,
      biodegradable: json['biodegradable'] ?? false,
      packagingSupplier: json['packaging_supplier'],
      costPerUnit: json['cost_per_unit'],
      color: json['color'] ?? '',
      labeling: json['labeling'] ?? '',
      brandOwnerId: json['brand_owner_id'] ?? '',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      lastModifiedBy: json['last_modified_by'] ?? '',
      domainName: json['domainName'] ?? '',
    );
  }

  // Helper to get full image URLs
  List<String> get fullImageUrls {
    return images.map((image) {
      if (image.startsWith('http')) {
        return image;
      }
      // Replace backslashes with forward slashes
      final normalizedPath = image.replaceAll('\\', '/');
      return 'https://upchub.online$normalizedPath';
    }).toList();
  }
}

class PackagingResponse {
  final List<Packaging> packagings;
  final int currentPage;
  final int pageSize;
  final int totalProducts;
  final int totalPages;

  PackagingResponse({
    required this.packagings,
    required this.currentPage,
    required this.pageSize,
    required this.totalProducts,
    required this.totalPages,
  });

  factory PackagingResponse.fromJson(Map<String, dynamic> json) {
    List<Packaging> packagings = [];
    if (json['packagings'] != null) {
      packagings =
          (json['packagings'] as List)
              .map((item) => Packaging.fromJson(item))
              .toList();
    }
    return PackagingResponse(
      packagings: packagings,
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalProducts: json['totalProducts'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}
