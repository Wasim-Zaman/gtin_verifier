import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/barcode_providers.dart';

class BarcodeVerifierScreen extends ConsumerStatefulWidget {
  const BarcodeVerifierScreen({super.key});

  @override
  ConsumerState<BarcodeVerifierScreen> createState() =>
      _BarcodeVerifierScreenState();
}

class _BarcodeVerifierScreenState extends ConsumerState<BarcodeVerifierScreen> {
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _barcodeFocusNode = FocusNode();

  @override
  void dispose() {
    _barcodeController.dispose();
    _barcodeFocusNode.dispose();
    super.dispose();
  }

  void _processBarcode() {
    final barcode = _barcodeController.text.trim();
    ref.read(barcodeProvider.notifier).processBarcode(barcode);
  }

  String _getBarcodeTypeText(BarcodeType type) {
    switch (type) {
      case BarcodeType.barcode1D:
        return '1D Barcode';
      case BarcodeType.qrCode:
        return 'QR Code';
      case BarcodeType.dataMatrix:
        return 'Data Matrix';
      case BarcodeType.unknown:
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final barcodeState = ref.watch(barcodeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GTIN Verifier'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan or Enter Barcode',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _barcodeController,
              focusNode: _barcodeFocusNode,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                labelText: 'Barcode',
                hintText: 'Scan or enter barcode',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _barcodeController.clear();
                    ref.read(barcodeProvider.notifier).clearBarcode();
                    _barcodeFocusNode.requestFocus();
                  },
                ),
              ),
              onChanged: (value) {
                // Auto-process after a short delay if manually typing
                if (value.isNotEmpty) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_barcodeController.text == value) {
                      _processBarcode();
                    }
                  });
                }
              },
              onSubmitted: (_) => _processBarcode(),
            ),
            const SizedBox(height: 24),

            if (barcodeState.isProcessing)
              const Center(child: CircularProgressIndicator())
            else if (barcodeState.scannedValue.isNotEmpty) ...[
              ResultCard(
                title: 'Scanned Value:',
                value: barcodeState.scannedValue,
              ),

              ResultCard(
                title: 'Barcode Type:',
                value: _getBarcodeTypeText(barcodeState.type),
              ),

              if (barcodeState.gtin != null)
                ResultCard(
                  title: 'GTIN:',
                  value: barcodeState.gtin!,
                  highlight: true,
                ),

              if (barcodeState.errorMessage != null)
                ResultCard(
                  title: 'Error:',
                  value: barcodeState.errorMessage!,
                  isError: true,
                ),
            ],

            const Spacer(),

            // Scan button that would trigger hardware scanner or camera
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // This would integrate with Honeywell scanner hardware
                  // For now, just focus the text field
                  _barcodeFocusNode.requestFocus();
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('SCAN BARCODE'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final bool highlight;
  final bool isError;

  const ResultCard({
    super.key,
    required this.title,
    required this.value,
    this.highlight = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
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
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                color: isError ? Colors.red : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
