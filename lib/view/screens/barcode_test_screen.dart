import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/barcode_providers.dart';

class BarcodeTestScreen extends ConsumerWidget {
  const BarcodeTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barcodeResultAsync = ref.watch(barcodeTestResultProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Test'),
        backgroundColor: colorScheme.surfaceContainerHighest,
        elevation: 0,
        scrolledUnderElevation: 3,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surfaceContainerHighest.withOpacity(0.3),
              colorScheme.surface,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildTestTypeSelection(context, ref),
              const SizedBox(height: 24),
              _buildTestSection(context, 'EAN-13 Samples', [
                '5901234123457', // Valid GTIN-13
                '6285561001275', // Your example
                '12345678', // Valid GTIN-8
                '123456789012', // Valid GTIN-12
                '12345678901234', // Valid GTIN-14
              ], ref),
              const SizedBox(height: 24),
              _buildTestSection(context, 'GS1 DataMatrix Samples', [
                '(01)5901234123457', // GTIN with AI
                '(01)5901234123457(21)123456', // GTIN with AI and Serial
                '(01)5901234123457(10)ABC123', // GTIN with AI and Batch
                '[)>[>]01[>]5901234123457', // GTIN with Data Matrix format
                '[)>[>]01[>]5901234123457[>]21[>]123456', // With Serial
              ], ref),
              const SizedBox(height: 24),
              _buildTestSection(context, 'GS1 Digital Link URLs', [
                'https://gtrack.online/01/6285561001275', // Your scanned QR
                'https://id.gs1.org/01/9506000134352', // Sample GS1 Digital Link
                'https://example.com/01/5901234123457', // Another sample
              ], ref),
              const SizedBox(height: 32),
              barcodeResultAsync.when(
                data: (result) {
                  if (result.scannedValue.isEmpty) {
                    return _buildEmptyResultState(context);
                  }
                  return _buildResultSection(context, result);
                },
                loading:
                    () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                error:
                    (error, stackTrace) => _buildResultCard(
                      'Error',
                      error.toString(),
                      Icons.error_outline,
                      isError: true,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.qr_code_scanner,
            color: Theme.of(context).colorScheme.primary,
            size: 36,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Barcode Test Suite',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Test various barcode formats and verify parsing',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestTypeSelection(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(barcodeTypeTestProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
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
                Icon(Icons.settings, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Override Barcode Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Manually set the barcode format for testing',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChoiceChip('Auto-Detect', selectedType == null, () {
                  ref.read(barcodeTypeTestProvider.notifier).state = null;
                }, context),
                _buildChoiceChip('EAN-13', selectedType == 'ean13', () {
                  ref.read(barcodeTypeTestProvider.notifier).state = 'ean13';
                }, context),
                _buildChoiceChip(
                  'DataMatrix',
                  selectedType == 'datamatrix',
                  () {
                    ref.read(barcodeTypeTestProvider.notifier).state =
                        'datamatrix';
                  },
                  context,
                ),
                _buildChoiceChip('QR Code', selectedType == 'qrcode', () {
                  ref.read(barcodeTypeTestProvider.notifier).state = 'qrcode';
                }, context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(
    String label,
    bool selected,
    VoidCallback onSelected,
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      backgroundColor: colorScheme.surfaceContainerHighest,
      selectedColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color:
            selected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      elevation: selected ? 2 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildTestSection(
    BuildContext context,
    String title,
    List<String> samples,
    WidgetRef ref,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
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
                _getCategoryIcon(title, colorScheme),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children:
                  samples.map((sample) {
                    return _buildActionChip(context, sample, ref);
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String title, ColorScheme colorScheme) {
    IconData iconData;
    if (title.contains('EAN-13')) {
      iconData = Icons.view_agenda;
    } else if (title.contains('DataMatrix')) {
      iconData = Icons.grid_4x4;
    } else if (title.contains('Digital Link')) {
      iconData = Icons.link;
    } else {
      iconData = Icons.qr_code_2;
    }

    return Icon(iconData, color: colorScheme.primary, size: 20);
  }

  Widget _buildActionChip(BuildContext context, String sample, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(barcodeScanProvider.notifier).state = sample;
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_arrow, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                sample.length > 25 ? '${sample.substring(0, 22)}...' : sample,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyResultState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.touch_app,
            size: 48,
            color: colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap any test barcode above',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Results will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(BuildContext context, BarcodeResult result) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.1),
                colorScheme.primaryContainer.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.analytics, color: colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Test Results',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildResultCard('Scanned Value', result.scannedValue, Icons.qr_code),
        _buildResultCard(
          'Barcode Type',
          _getBarcodeTypeText(result.type),
          _getBarcodeTypeIcon(result.type),
        ),
        if (result.gtin != null)
          _buildResultCard('GTIN', result.gtin!, Icons.tag, highlight: true),
        if (result.additionalData != null && result.additionalData!.isNotEmpty)
          ...result.additionalData!.entries.map(
            (entry) => _buildResultCard(
              'AI (${entry.key})',
              entry.value.toString(),
              Icons.description,
            ),
          ),
      ],
    );
  }

  Widget _buildResultCard(
    String title,
    String value,
    IconData icon, {
    bool highlight = false,
    bool isError = false,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        final Color cardColor =
            highlight
                ? colorScheme.primaryContainer.withOpacity(0.7)
                : isError
                ? colorScheme.errorContainer.withOpacity(0.7)
                : colorScheme.surface;

        final Color iconColor =
            highlight
                ? colorScheme.primary
                : isError
                ? colorScheme.error
                : colorScheme.primary.withOpacity(0.7);

        final Color titleColor =
            highlight
                ? colorScheme.onPrimaryContainer
                : isError
                ? colorScheme.error
                : colorScheme.onSurfaceVariant;

        final Color valueColor =
            highlight
                ? colorScheme.onPrimaryContainer
                : isError
                ? colorScheme.onErrorContainer
                : colorScheme.onSurface;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: cardColor,
          elevation: highlight ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color:
                  highlight
                      ? colorScheme.primary.withOpacity(0.3)
                      : isError
                      ? colorScheme.error.withOpacity(0.3)
                      : colorScheme.outlineVariant,
              width: highlight || isError ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color:
                        highlight
                            ? colorScheme.primary.withOpacity(0.1)
                            : isError
                            ? colorScheme.error.withOpacity(0.1)
                            : colorScheme.surfaceContainerHighest.withOpacity(
                              0.5,
                            ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              highlight ? FontWeight.bold : FontWeight.w500,
                          color: valueColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getBarcodeTypeText(BarcodeType type) {
    switch (type) {
      case BarcodeType.ean13:
        return 'EAN-13';
      case BarcodeType.qrCode:
        return 'QR Code';
      case BarcodeType.dataMatrix:
        return 'Data Matrix';
      case BarcodeType.gs1DigitalLink:
        return 'GS1 Digital Link';
      case BarcodeType.unknown:
      default:
        return 'Unknown';
    }
  }

  IconData _getBarcodeTypeIcon(BarcodeType type) {
    switch (type) {
      case BarcodeType.ean13:
        return Icons.view_agenda;
      case BarcodeType.qrCode:
        return Icons.qr_code;
      case BarcodeType.dataMatrix:
        return Icons.grid_4x4;
      case BarcodeType.gs1DigitalLink:
        return Icons.link;
      case BarcodeType.unknown:
      default:
        return Icons.help_outline;
    }
  }
}
