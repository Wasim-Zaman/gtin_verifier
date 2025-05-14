class ProductResponse {
  int? currentPage;
  int? pageSize;
  int? totalProducts;
  List<Products>? products;
  bool? productDataAvailable;

  ProductResponse({
    this.currentPage,
    this.pageSize,
    this.totalProducts,
    this.products,
    this.productDataAvailable,
  });

  ProductResponse.fromJson(Map<String, dynamic> json) {
    // Handle new API format
    if (json.containsKey('ProductDataAvailable')) {
      productDataAvailable = json['ProductDataAvailable'];
      if (json['data'] != null) {
        // Convert the single product format to our list format
        products = <Products>[Products.fromJson(json['data'])];
        currentPage = 1;
        pageSize = 1;
        totalProducts = 1;
      } else {
        products = [];
        currentPage = 0;
        pageSize = 0;
        totalProducts = 0;
      }
    } else {
      // Handle existing format for backward compatibility
      currentPage = json['currentPage'];
      pageSize = json['pageSize'];
      totalProducts = json['totalProducts'];
      if (json['products'] != null) {
        products = <Products>[];
        json['products'].forEach((v) {
          products!.add(Products.fromJson(v));
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currentPage'] = currentPage;
    data['pageSize'] = pageSize;
    data['totalProducts'] = totalProducts;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    data['ProductDataAvailable'] = productDataAvailable;
    return data;
  }
}

class Products {
  String? id;
  String? userId;
  String? gcpGLNID;
  dynamic? importCode;
  String? productnameenglish;
  String? productnamearabic;
  String? brandName;
  String? productType;
  String? origin;
  String? packagingType;
  dynamic? mnfCode;
  dynamic? mnfGLN;
  String? provGLN;
  String? unit;
  String? size;
  dynamic? frontImage;
  dynamic? backImage;
  dynamic? childProduct;
  dynamic? quantity;
  String? barcode;
  String? gpc;
  String? gpcCode;
  String? gpcName;
  String? countrySale;
  dynamic? hSCODES;
  String? hsDescription;
  String? gcpType;
  String? prodLang;
  String? detailsPage;
  String? detailsPageAr;
  int? status;
  dynamic? deletedAt;
  String? createdAt;
  String? updatedAt;
  String? memberID;
  int? adminId;
  String? saveAs;
  String? gtinType;
  String? productUrl;
  dynamic? productLinkUrl;
  String? brandNameAr;
  dynamic? digitalInfoType;
  String? readyForGepir;
  int? gepirPosted;
  dynamic? image1;
  dynamic? image2;
  dynamic? image3;
  String? gpcType;
  // String? productType;

  // New fields for the updated API response
  String? companyName;
  String? contactWebsite;
  String? formattedAddress;
  String? licenceKey;
  String? licenceType;
  String? moName;
  String? productImageUrl;

  Products({
    this.id,
    this.userId,
    this.gcpGLNID,
    this.importCode,
    this.productnameenglish,
    this.productnamearabic,
    this.brandName,
    this.productType,
    this.origin,
    this.packagingType,
    this.mnfCode,
    this.mnfGLN,
    this.provGLN,
    this.unit,
    this.size,
    this.frontImage,
    this.backImage,
    this.childProduct,
    this.quantity,
    this.barcode,
    this.gpc,
    this.gpcCode,
    this.gpcName,
    this.countrySale,
    this.hSCODES,
    this.hsDescription,
    this.gcpType,
    this.prodLang,
    this.detailsPage,
    this.detailsPageAr,
    this.status,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.memberID,
    this.adminId,
    this.saveAs,
    this.gtinType,
    this.productUrl,
    this.productLinkUrl,
    this.brandNameAr,
    this.digitalInfoType,
    this.readyForGepir,
    this.gepirPosted,
    this.image1,
    this.image2,
    this.image3,
    this.gpcType,
    // New API fields
    this.companyName,
    this.contactWebsite,
    this.formattedAddress,
    this.licenceKey,
    this.licenceType,
    this.moName,
    this.productImageUrl,
  });

  Products.fromJson(Map<String, dynamic> json) {
    // Check if we're receiving the new API format
    if (json.containsKey('gtin')) {
      // New API format
      barcode = json['gtin'];

      // Handle brand name which could be an object or string
      if (json['brandName'] != null) {
        if (json['brandName'] is Map) {
          brandName = json['brandName']['value'];
          prodLang = json['brandName']['language'];
        } else {
          brandName = json['brandName'].toString();
        }
      }

      // Handle product description which could be an object or string
      if (json['productDescription'] != null) {
        if (json['productDescription'] is Map) {
          detailsPage = json['productDescription']['value'];
          prodLang = json['productDescription']['language'] ?? prodLang;
        } else {
          detailsPage = json['productDescription'].toString();
        }
      }

      // Handle product name
      productnameenglish = json['productName'];

      // Handle product image URL
      if (json['productImageUrl'] != null) {
        if (json['productImageUrl'] is Map) {
          productImageUrl = json['productImageUrl']['value'];
          frontImage = productImageUrl;
        } else {
          productImageUrl = json['productImageUrl'].toString();
          frontImage = productImageUrl;
        }
      }

      // Handle GPC Category
      gpcCode = json['gpcCategoryCode'];
      gpcName = json['gpcCategoryName'];
      gpc = json['gpcCategoryName'];

      // Handle unit and size
      unit = json['unitCode'];
      size = json['unitValue'];

      // Handle country of sale
      countrySale = json['countryOfSaleName'];

      // Handle company information
      companyName = json['companyName'];
      licenceKey = json['licenceKey'];
      licenceType = json['licenceType'];
      gcpType = json['licenceType'];
      gcpGLNID = json['gcpGLNID'];
      contactWebsite = json['contactWebsite'];
      formattedAddress = json['formattedAddress'];
      moName = json['moName'];
      createdAt = json['companyRegistrationDate'];
      memberID = json['licenceKey'];
      productUrl = json['contactWebsite'];
    } else {
      // Original API format
      id = json['id'];
      userId = json['user_id'];
      gcpGLNID = json['gcpGLNID'];
      importCode = json['import_code'];
      productnameenglish = json['productnameenglish'];
      productnamearabic = json['productnamearabic'];
      brandName = json['BrandName'];
      productType = json['ProductType'];
      origin = json['Origin'];
      packagingType = json['PackagingType'];
      mnfCode = json['MnfCode'];
      mnfGLN = json['MnfGLN'];
      provGLN = json['ProvGLN'];
      unit = json['unit'];
      size = json['size'];
      frontImage = json['front_image'];
      backImage = json['back_image'];
      childProduct = json['childProduct'];
      quantity = json['quantity'];
      barcode = json['barcode'];
      gpc = json['gpc'];
      gpcCode = json['gpc_code'];
      countrySale = json['countrySale'];
      hSCODES = json['HSCODES'];
      hsDescription = json['HsDescription'];
      gcpType = json['gcp_type'];
      prodLang = json['prod_lang'];
      detailsPage = json['details_page'];
      detailsPageAr = json['details_page_ar'];
      status = json['status'];
      deletedAt = json['deleted_at'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
      memberID = json['memberID'];
      adminId = json['admin_id'];
      saveAs = json['save_as'];
      gtinType = json['gtin_type'];
      productUrl = json['product_url'];
      productLinkUrl = json['product_link_url'];
      brandNameAr = json['BrandNameAr'];
      digitalInfoType = json['digitalInfoType'];
      readyForGepir = json['readyForGepir'];
      gepirPosted = json['gepirPosted'];
      image1 = json['image_1'];
      image2 = json['image_2'];
      image3 = json['image_3'];
      gpcType = json['gpc_type'];
      productType = json['product_type'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['gcpGLNID'] = gcpGLNID;
    data['import_code'] = importCode;
    data['productnameenglish'] = productnameenglish;
    data['productnamearabic'] = productnamearabic;
    data['BrandName'] = brandName;
    data['ProductType'] = productType;
    data['Origin'] = origin;
    data['PackagingType'] = packagingType;
    data['MnfCode'] = mnfCode;
    data['MnfGLN'] = mnfGLN;
    data['ProvGLN'] = provGLN;
    data['unit'] = unit;
    data['size'] = size;
    data['front_image'] = frontImage;
    data['back_image'] = backImage;
    data['childProduct'] = childProduct;
    data['quantity'] = quantity;
    data['barcode'] = barcode;
    data['gpc'] = gpc;
    data['gpc_code'] = gpcCode;
    data['gpcName'] = gpcName;
    data['countrySale'] = countrySale;
    data['HSCODES'] = hSCODES;
    data['HsDescription'] = hsDescription;
    data['gcp_type'] = gcpType;
    data['prod_lang'] = prodLang;
    data['details_page'] = detailsPage;
    data['details_page_ar'] = detailsPageAr;
    data['status'] = status;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['memberID'] = memberID;
    data['admin_id'] = adminId;
    data['save_as'] = saveAs;
    data['gtin_type'] = gtinType;
    data['product_url'] = productUrl;
    data['product_link_url'] = productLinkUrl;
    data['BrandNameAr'] = brandNameAr;
    data['digitalInfoType'] = digitalInfoType;
    data['readyForGepir'] = readyForGepir;
    data['gepirPosted'] = gepirPosted;
    data['image_1'] = image1;
    data['image_2'] = image2;
    data['image_3'] = image3;
    data['gpc_type'] = gpcType;
    data['product_type'] = productType;
    // Add new API fields
    data['companyName'] = companyName;
    data['contactWebsite'] = contactWebsite;
    data['formattedAddress'] = formattedAddress;
    data['licenceKey'] = licenceKey;
    data['licenceType'] = licenceType;
    data['moName'] = moName;
    data['productImageUrl'] = productImageUrl;
    return data;
  }
}
