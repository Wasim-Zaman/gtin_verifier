import 'package:flutter/material.dart';

class CertificationTab extends StatelessWidget {
  final String barcode;

  const CertificationTab({super.key, required this.barcode});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_outlined, color: colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Certifications',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: colorScheme.secondaryContainer,
                  child: Icon(
                    Icons.check,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                title: Text(
                  'ISO 9001:2015',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Quality Management System'),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: colorScheme.tertiaryContainer,
                  child: Icon(
                    Icons.check,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
                title: Text(
                  'GS1 Certified',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Global Standards Compliant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
