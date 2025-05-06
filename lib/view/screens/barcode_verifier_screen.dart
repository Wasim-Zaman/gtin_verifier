import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/barcode_providers.dart';

class BarcodeVerifierScreen extends ConsumerStatefulWidget {
  const BarcodeVerifierScreen({super.key});

  @override
  ConsumerState<BarcodeVerifierScreen> createState() =>
      _BarcodeVerifierScreenState();
}

class _BarcodeVerifierScreenState extends ConsumerState<BarcodeVerifierScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _barcodeFocusNode = FocusNode();
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _barcodeFocusNode.dispose();
    _scanAnimationController.dispose();
    super.dispose();
  }

  void _processBarcode() {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) return;

    ref.read(barcodeScanProvider.notifier).state = barcode;
  }

  void _clearBarcode() {
    _barcodeController.clear();
    ref.read(barcodeScanProvider.notifier).state = '';
    _barcodeFocusNode.requestFocus();
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

  @override
  Widget build(BuildContext context) {
    final barcodeResultAsync = ref.watch(barcodeResultProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GTIN Verifier'),
        backgroundColor: colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.science),
            tooltip: 'Test Barcodes',
            onPressed: () => context.go('/test'),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.inversePrimary.withOpacity(0.1), Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner,
                          size: 80,
                          color: Colors.blue,
                        ),
                        AnimatedBuilder(
                          animation: _scanAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: 10 + 60 * _scanAnimation.value,
                              child: Container(
                                height: 2,
                                width: 60,
                                color: Colors.red.withOpacity(0.6),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan or Enter Barcode',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _barcodeController,
                  focusNode: _barcodeFocusNode,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Barcode',
                    hintText: 'Scan or enter barcode',
                    prefixIcon: const Icon(Icons.qr_code),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearBarcode,
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      // Debounce input
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_barcodeController.text == value) {
                          _processBarcode();
                        }
                      });
                    }
                  },
                  onSubmitted: (_) => _processBarcode(),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: barcodeResultAsync.when(
                    data: (result) {
                      if (result.scannedValue.isEmpty) {
                        return const Center(
                          child: Text('Scan a barcode to see results'),
                        );
                      }

                      return Column(
                        children: [
                          ResultCard(
                            title: 'Scanned Value:',
                            value: result.scannedValue,
                            icon: Icons.qr_code,
                          ),
                          ResultCard(
                            title: 'Barcode Type:',
                            value: _getBarcodeTypeText(result.type),
                            icon: _getBarcodeTypeIcon(result.type),
                          ),
                          if (result.gtin != null)
                            ResultCard(
                              title: 'GTIN:',
                              value: result.gtin!,
                              highlight: true,
                              icon: Icons.tag,
                            ),
                          if (result.additionalData != null &&
                              result.additionalData!.isNotEmpty)
                            ...result.additionalData!.entries.map(
                              (entry) => ResultCard(
                                title: 'AI (${entry.key}):',
                                value: entry.value.toString(),
                                icon: Icons.description,
                              ),
                            ),
                        ],
                      );
                    },
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (error, stackTrace) => Center(
                          child: ResultCard(
                            title: 'Error:',
                            value: error.toString(),
                            isError: true,
                            icon: Icons.error_outline,
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _barcodeFocusNode.requestFocus();
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('SCAN BARCODE'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
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
  final IconData icon;

  const ResultCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.highlight = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color:
          highlight
              ? colorScheme.primary.withOpacity(0.1)
              : isError
              ? Colors.red.shade50
              : Colors.white,
      elevation: highlight ? 2 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  highlight
                      ? colorScheme.primary
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
}
