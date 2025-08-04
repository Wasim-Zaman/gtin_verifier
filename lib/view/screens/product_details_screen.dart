import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/product.dart';
import '../../providers/product_providers.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String barcode;

  const ProductDetailsScreen({super.key, required this.barcode});

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productProvider(widget.barcode));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: colorScheme.surfaceContainerHighest,
        elevation: 0,
        scrolledUnderElevation: 3,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        bottom: TabBar(
          controller: _mainTabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'Product Info'),
            Tab(icon: Icon(Icons.business), text: 'Company Info'),
            // Tab(
            //   icon: Icon(Icons.dashboard_customize_outlined),
            //   text: 'Additional Info',
            // ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              colorScheme.surface.withValues(alpha: 0.9),
            ],
            stops: const [0.0, 0.7],
          ),
        ),
        child: productAsync.when(
          data: (product) {
            if (product == null) {
              return _buildEmptyState(context);
            }

            // If product data is not available but company info exists, show only Company Info tab
            final hasProductData =
                product.toJson().containsKey('ProductDataAvailable')
                    ? product.toJson()['ProductDataAvailable']
                    : true;

            if (!hasProductData) {
              // Automatically switch to Company Info tab
              _mainTabController.animateTo(1);

              return TabBarView(
                controller: _mainTabController,
                children: [
                  _buildEmptyState(context), // Product Info tab is empty
                  _buildCompanyInfoTab(context, product), // Company Info tab
                  // ProductAdditionalInfoTab(
                  //   product: product,
                  // ), // Additional Info tab
                ],
              );
            }

            return TabBarView(
              controller: _mainTabController,
              children: [
                _buildProductInfoTab(context, product),
                _buildCompanyInfoTab(context, product),
                // ProductAdditionalInfoTab(product: product),
              ],
            );
          },
          loading: () => _buildLoadingShimmer(context),
          error: (error, stackTrace) => _buildErrorState(context, error),
        ),
      ),
    );
  }

  Widget _buildProductInfoTab(BuildContext context, Products product) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildGS1StatusCard(context, product),
          ),

          // Tabs Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildTabButton(
                    context: context,
                    label: 'Product information',
                    isSelected: true,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 8),
                  _buildTabButton(
                    context: context,
                    label: 'Company information',
                    isSelected: false,
                    colorScheme: colorScheme,
                    onTap: () {
                      _mainTabController.animateTo(1);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Product Information Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productnameenglish ?? 'No Name',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                _buildProductImage(context, product, colorScheme),
                const SizedBox(height: 32),

                // Product Details
                _buildInfoRow(
                  context: context,
                  label: 'GTIN',
                  value: product.barcode ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Brand Name',
                  value: product.brandName ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Product Description',
                  value: product.productnameenglish ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Global product category',
                  value: product.gpcCode ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Net Content',
                  value:
                      product.size != null && product.unit != null
                          ? '${product.size} ${product.unit}'
                          : product.size ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Country',
                  value: product.countrySale ?? '',
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoTab(BuildContext context, Products product) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateStr =
        product.toJson().containsKey('created_at') &&
                product.toJson()['created_at'] != null
            ? _formatDate(product.toJson()['created_at'])
            : product.createdAt != null
            ? _formatDate(product.createdAt!)
            : '';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildGS1StatusCard(context, product),
          ),

          // Tabs Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildTabButton(
                    context: context,
                    label: 'Product information',
                    isSelected: false,
                    colorScheme: colorScheme,
                    onTap: () {
                      _mainTabController.animateTo(0);
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildTabButton(
                    context: context,
                    label: 'Company information',
                    isSelected: true,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
          ),

          // Company Information Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.companyName?.isNotEmpty ?? false
                      ? product.companyName!
                      : 'Company Information',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 32),

                // Company Details
                _buildInfoRow(
                  context: context,
                  label: 'Company Name',
                  value: product.companyName ?? '',
                  colorScheme: colorScheme,
                ),
                _buildWebsiteRow(
                  context: context,
                  label: 'Website',
                  value: product.productUrl ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Licence Key',
                  value: product.licenceKey ?? product.memberID ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Licence Type',
                  value: product.licenceType ?? product.gcpType ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Global Location Number (GLN)',
                  value: product.gcpGLNID ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Licensing GS1 Member Organisation',
                  value: product.moName ?? 'GS1 SAUDI ARABIA',
                  colorScheme: colorScheme,
                ),
                if (product.formattedAddress != null &&
                    product.formattedAddress!.isNotEmpty)
                  _buildInfoRow(
                    context: context,
                    label: 'Address',
                    value: product.formattedAddress!,
                    colorScheme: colorScheme,
                  ),
                _buildInfoRow(
                  context: context,
                  label: 'Date of Registration',
                  value: dateStr,
                  colorScheme: colorScheme,
                ),
                // _buildInfoRow(
                //   context: context,
                //   label: 'GCP Expiry',
                //   value: product.expiry ?? '',
                //   colorScheme: colorScheme,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGS1StatusCard(BuildContext context, Products product) {
    final colorScheme = Theme.of(context).colorScheme;
    final companyName =
        product.toJson().containsKey('companyName')
            ? product.toJson()['companyName']
            : 'Company';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'GS1',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'This number is registered to ',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  TextSpan(
                    text: companyName,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required ColorScheme colorScheme,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border:
              isSelected
                  ? Border(
                    bottom: BorderSide(color: colorScheme.primary, width: 2),
                  )
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: colorScheme.outlineVariant, height: 1),
        ],
      ),
    );
  }

  Widget _buildWebsiteRow({
    required BuildContext context,
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _launchUrl(value),
            child: Text(
              value,
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: colorScheme.outlineVariant, height: 1),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat.yMMMMd().format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(
      urlString.startsWith('http') ? urlString : 'https://$urlString',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Card(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 40,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No product found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We couldn\'t find any product with this barcode',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () => context.go('/'),
                child: const Text('Return to Scanner'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final colorScheme = Theme.of(context).colorScheme;

    // Extract meaningful information from the error
    final String errorMessage = _getErrorMessage(error);
    final String userFriendlyTitle = _getUserFriendlyErrorTitle(error);
    final IconData errorIcon = _getErrorIcon(error);
    final bool isNotFoundError = _isNotFoundError(error);

    return Center(
      child: Card(
        elevation: 0,
        color:
            isNotFoundError
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.1)
                : colorScheme.errorContainer.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color:
                isNotFoundError
                    ? colorScheme.outlineVariant
                    : colorScheme.error.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color:
                      isNotFoundError
                          ? colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          )
                          : colorScheme.errorContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  errorIcon,
                  size: 40,
                  color:
                      isNotFoundError
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                userFriendlyTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      isNotFoundError
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for error handling
  bool _isNotFoundError(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('404') ||
        errorString.contains('not found') ||
        errorString.contains('no product');
  }

  String _getUserFriendlyErrorTitle(Object error) {
    if (_isNotFoundError(error)) {
      return 'Product Not Found';
    } else if (error.toString().toLowerCase().contains('timeout')) {
      return 'Connection Timeout';
    } else if (error.toString().toLowerCase().contains('network')) {
      return 'Network Error';
    } else {
      return 'Error Loading Product';
    }
  }

  String _getErrorMessage(Object error) {
    if (_isNotFoundError(error)) {
      return 'This barcode is not registered in the GS1 database. Please verify the barcode or try scanning a different product.';
    } else if (error.toString().toLowerCase().contains('timeout')) {
      return 'The connection timed out. Please check your internet connection and try again.';
    } else if (error.toString().toLowerCase().contains('network')) {
      return 'There was a problem with your network connection. Please check your internet and try again.';
    } else {
      // For debugging purposes, we'll still show the actual error
      // But with a more user-friendly introduction
      return 'Something went wrong while fetching the product information.';
    }
  }

  IconData _getErrorIcon(Object error) {
    if (_isNotFoundError(error)) {
      return Icons.search_off_outlined;
    } else if (error.toString().toLowerCase().contains('timeout') ||
        error.toString().toLowerCase().contains('network')) {
      return Icons.wifi_off_outlined;
    } else {
      return Icons.error_outline;
    }
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surfaceContainerLow,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 24),

            // Title placeholder
            Container(
              height: 32,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),

            // Brand placeholder
            Container(
              height: 24,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 16),

            // Chips placeholder
            Row(
              children: [
                Container(
                  height: 32,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 32,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Divider placeholder
            Container(height: 1, width: double.infinity, color: Colors.white),
            const SizedBox(height: 16),

            // Detail rows
            for (int i = 0; i < 8; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 24,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(
    BuildContext context,
    Products product,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 250,
          width: double.infinity,
          child:
              product.frontImage != null && product.frontImage!.isNotEmpty
                  ? CachedNetworkImage(
                    imageUrl: product.frontImage!,
                    fit: BoxFit.contain,
                    httpHeaders: {
                      'Accept':
                          'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
                      'Accept-Language': 'en-US,en;q=0.9',
                      'Referer': 'https://gs1.org.sa/',
                      'User-Agent':
                          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36',
                      'sec-ch-ua':
                          '"Chromium";v="136", "Google Chrome";v="136", "Not.A/Brand";v="99"',
                      'sec-ch-ua-mobile': '?0',
                      'sec-ch-ua-platform': '"macOS"',
                    },
                    placeholder:
                        (context, url) => _buildImagePlaceholder(colorScheme),
                    errorWidget:
                        (context, url, error) =>
                            _buildImageWithFallback(url, colorScheme),
                  )
                  : _buildImageError(colorScheme),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerLowest,
      child: Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      ),
    );
  }

  // Try to load image using http client with custom headers as fallback
  Widget _buildImageWithFallback(String url, ColorScheme colorScheme) {
    return FutureBuilder(
      future: _loadImageWithCustomHeaders(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildImagePlaceholder(colorScheme);
        } else if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(snapshot.data!, fit: BoxFit.contain);
        } else {
          return _buildImageError(colorScheme);
        }
      },
    );
  }

  Future<Uint8List?> _loadImageWithCustomHeaders(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept':
              'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
          'Referer': 'https://gs1.org.sa/',
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36',
          'sec-ch-ua':
              '"Chromium";v="136", "Google Chrome";v="136", "Not.A/Brand";v="99"',
          'sec-ch-ua-mobile': '?0',
          'sec-ch-ua-platform': '"macOS"',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading image with custom headers: $e');
      }
      return null;
    }
  }

  Widget _buildImageError(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 60,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            Text(
              'No image available',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
