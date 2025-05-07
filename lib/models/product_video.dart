class ProductVideo {
  final String id;
  final String barcode;
  final String videos;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String brandOwnerId;
  final String lastModifiedBy;
  final String domainName;

  ProductVideo({
    required this.id,
    required this.barcode,
    required this.videos,
    required this.createdAt,
    required this.updatedAt,
    required this.brandOwnerId,
    required this.lastModifiedBy,
    required this.domainName,
  });

  factory ProductVideo.fromJson(Map<String, dynamic> json) {
    return ProductVideo(
      id: json['id'] ?? '',
      barcode: json['barcode'] ?? '',
      videos: json['videos'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      brandOwnerId: json['brand_owner_id'] ?? '',
      lastModifiedBy: json['last_modified_by'] ?? '',
      domainName: json['domainName'] ?? '',
    );
  }

  String get fullVideoUrl {
    final normalized = videos.replaceAll('\\', '/');
    return 'https://upchub.online$normalized';
  }
}

class ProductVideoResponse {
  final List<ProductVideo> videos;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  ProductVideoResponse({
    required this.videos,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory ProductVideoResponse.fromJson(Map<String, dynamic> json) {
    return ProductVideoResponse(
      videos:
          (json['data'] as List).map((e) => ProductVideo.fromJson(e)).toList(),
      total: json['pagination']?['total'] ?? 0,
      page: json['pagination']?['page'] ?? 1,
      pageSize: json['pagination']?['pageSize'] ?? 10,
      totalPages: json['pagination']?['totalPages'] ?? 1,
    );
  }
}
