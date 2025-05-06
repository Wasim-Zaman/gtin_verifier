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
        backgroundColor: colorScheme.inversePrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Barcodes',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTestTypeSelection(context, ref),
            const SizedBox(height: 16),
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
                  return const Center(
                    child: Text('Select a test barcode above to see results'),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Test Results',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildResultCard(
                      'Scanned Value',
                      result.scannedValue,
                      Icons.qr_code,
                    ),
                    _buildResultCard(
                      'Barcode Type',
                      _getBarcodeTypeText(result.type),
                      _getBarcodeTypeIcon(result.type),
                    ),
                    if (result.gtin != null)
                      _buildResultCard(
                        'GTIN',
                        result.gtin!,
                        Icons.tag,
                        highlight: true,
                      ),
                    if (result.additionalData != null &&
                        result.additionalData!.isNotEmpty)
                      ...result.additionalData!.entries.map(
                        (entry) => _buildResultCard(
                          'AI (${entry.key})',
                          entry.value.toString(),
                          Icons.description,
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
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
    );
  }

  Widget _buildTestTypeSelection(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(barcodeTypeTestProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Override Barcode Type (Optional):',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Auto-Detect'),
              selected: selectedType == null,
              onSelected: (_) {
                ref.read(barcodeTypeTestProvider.notifier).state = null;
              },
            ),
            ChoiceChip(
              label: const Text('EAN-13'),
              selected: selectedType == 'ean13',
              onSelected: (_) {
                ref.read(barcodeTypeTestProvider.notifier).state = 'ean13';
              },
            ),
            ChoiceChip(
              label: const Text('DataMatrix'),
              selected: selectedType == 'datamatrix',
              onSelected: (_) {
                ref.read(barcodeTypeTestProvider.notifier).state = 'datamatrix';
              },
            ),
            ChoiceChip(
              label: const Text('QR Code'),
              selected: selectedType == 'qrcode',
              onSelected: (_) {
                ref.read(barcodeTypeTestProvider.notifier).state = 'qrcode';
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestSection(
    BuildContext context,
    String title,
    List<String> samples,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              samples
                  .map(
                    (sample) => ActionChip(
                      label: Text(
                        sample.length > 25
                            ? '${sample.substring(0, 22)}...'
                            : sample,
                      ),
                      tooltip: sample.length > 25 ? sample : null,
                      onPressed: () {
                        ref.read(barcodeScanProvider.notifier).state = sample;
                      },
                    ),
                  )
                  .toList(),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color:
          highlight
              ? Colors.blue.shade50
              : isError
              ? Colors.red.shade50
              : null,
      elevation: highlight ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  highlight
                      ? Colors.blue
                      : isError
                      ? Colors.red
                      : Colors.black54,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isError ? Colors.red : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          highlight ? FontWeight.bold : FontWeight.normal,
                      color: isError ? Colors.red : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
