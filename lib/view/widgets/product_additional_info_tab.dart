import 'package:flutter/material.dart';

import '../../models/product.dart';
import 'certification_tab.dart';
import 'product_info_tab.dart';
import 'recall_info_tab.dart';
import 'sustainability_tab.dart';

class ProductAdditionalInfoTab extends StatefulWidget {
  final Products product;
  const ProductAdditionalInfoTab({super.key, required this.product});

  @override
  State<ProductAdditionalInfoTab> createState() =>
      _ProductAdditionalInfoTabState();
}

class _ProductAdditionalInfoTabState extends State<ProductAdditionalInfoTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final product = widget.product;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text(
              "Additional Information",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(icon: Icon(Icons.info_outline), text: 'Product'),
              Tab(icon: Icon(Icons.warning_amber_outlined), text: 'Recall'),
              Tab(icon: Icon(Icons.verified_outlined), text: 'Certification'),
              Tab(icon: Icon(Icons.eco_outlined), text: 'Sustainability'),
            ],
          ),
          Expanded(
            child: SizedBox(
              height: 300, // Fixed height for the tab content
              child: TabBarView(
                controller: _tabController,
                children: [
                  ProductInfoTab(product: product),
                  RecallInfoTab(barcode: product.barcode ?? ''),
                  CertificationTab(barcode: product.barcode ?? ''),
                  SustainabilityTab(barcode: product.barcode ?? ''),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
