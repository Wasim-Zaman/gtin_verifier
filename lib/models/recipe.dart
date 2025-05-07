class Recipe {
  final int id;
  final String? logo;
  final String title;
  final String description;
  final String ingredients;
  final String linkType;
  final String gtin;
  final int? companyId;

  Recipe({
    required this.id,
    this.logo,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.linkType,
    required this.gtin,
    this.companyId,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['ID'] ?? 0,
      logo: json['logo'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      ingredients: json['ingredients'] ?? '',
      linkType: json['LinkType'] ?? '',
      gtin: json['GTIN'] ?? '',
      companyId: json['companyId'],
    );
  }
}
