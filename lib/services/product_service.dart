import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductApiService {
  static const String baseUrl =
      'https://gs1.org.sa/api/foreignGtin/getGtinProductDetails';

  Future<ProductResponse> getProductByBarcode(String barcode) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?barcode=$barcode'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log(response.body);

        if (data['ProductDataAvailable'] == true && data['data'] != null) {
          // Convert the new API response format to match our existing model structure
          final convertedData = {
            'currentPage': 1,
            'pageSize': 1,
            'totalProducts': 1,
            'products': [_convertToProductsFormat(data['data'])],
          };

          return ProductResponse.fromJson(convertedData);
        } else {
          // Return empty product response if no data available
          return ProductResponse(
            currentPage: 0,
            pageSize: 0,
            totalProducts: 0,
            products: [],
          );
        }
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching product: $e');
      }
      rethrow;
    }
  }

  // Helper method to convert the new API response format to our existing Products model
  Map<String, dynamic> _convertToProductsFormat(Map<String, dynamic> data) {
    // Extract brand name and language if available
    String? brandName;
    if (data['brandName'] != null) {
      if (data['brandName'] is Map) {
        brandName = data['brandName']['value'];
      } else {
        brandName = data['brandName'].toString();
      }
    }

    // Extract product description
    String? productDescription;
    if (data['productDescription'] != null) {
      if (data['productDescription'] is Map) {
        productDescription = data['productDescription']['value'];
      } else {
        productDescription = data['productDescription'].toString();
      }
    }

    // Extract product image URL
    String? productImageUrl;
    if (data['productImageUrl'] != null &&
        data['productImageUrl'] is Map &&
        data['productImageUrl']['value'] != null) {
      productImageUrl = data['productImageUrl']['value'];
    }

    return {
      'id': data['productId'] ?? '',
      'barcode': data['gtin'] ?? '',
      'user_id': '',
      'gcpGLNID': data['gcpGLNID'] ?? '',
      'productnameenglish': data['productName'] ?? productDescription ?? '',
      'productnamearabic': '', // Not explicitly provided in new API
      'BrandName': brandName ?? '',
      'ProductType': '', // Not explicitly provided in new API
      'Origin': '', // Not explicitly provided in new API
      'PackagingType': '', // Not explicitly provided in new API
      'unit': data['unitCode'] ?? '',
      'size': data['unitValue'] ?? '',
      'front_image': productImageUrl,
      'gpc': '', // Not explicitly provided
      'gpc_code': data['gpcCategoryCode'] ?? '',
      'countrySale':
          data['countryOfSaleName'] ?? data['countryOfSaleCode'] ?? '',
      'gcp_type': data['licenceType'] ?? '',
      'prod_lang':
          data['productDescription'] != null &&
                  data['productDescription'] is Map
              ? data['productDescription']['language'] ?? ''
              : '',
      'memberID': data['licenceKey'] ?? '',
      'created_at': data['companyRegistrationDate'] ?? '',
      'status': data['status'] == 'InActive' ? 0 : 1,
      'details_page': productDescription ?? '',
      'details_page_ar': '', // Not provided in new API
      'product_url': data['contactWebsite'] ?? '',
      'companyName': data['companyName'] ?? '',
    };
  }
}
