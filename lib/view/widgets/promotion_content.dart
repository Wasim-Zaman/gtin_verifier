import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/promotion.dart';

class PromotionContent extends StatelessWidget {
  final List<Promotion> promotions;
  const PromotionContent({super.key, required this.promotions});

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No promotional offers available')),
      );
    }
    final dateFormat = DateFormat('MMM d, yyyy');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children:
            promotions.map((promo) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    Icons.local_offer_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    promo.promotionalOffers,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type: ${promo.linkType}'),
                      Text('Language: ${promo.lang}'),
                      Text('Price: ${promo.price}'),
                      Text('Expires: ${dateFormat.format(promo.expiryDate)}'),
                      if (promo.targetUrl.isNotEmpty)
                        Text(
                          'URL: ${promo.targetUrl}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  trailing:
                      promo.banner.isNotEmpty
                          ? Chip(label: Text(promo.banner))
                          : null,
                ),
              );
            }).toList(),
      ),
    );
  }
}
