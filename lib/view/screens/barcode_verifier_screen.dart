import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GTIN Verifier'),
        backgroundColor: colorScheme.inversePrimary,
        elevation: 0,
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
                    const Icon(
                      Icons.qr_code_scanner,
                      size: 80,
                      color: Colors.blue,
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
                      onPressed: () {
                        _barcodeController.clear();
                        ref.read(barcodeProvider.notifier).clearBarcode();
                        _barcodeFocusNode.requestFocus();
                      },
                    ),
                  ),
                  onChanged: (value) {
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
              ),
              const SizedBox(height: 32),

              if (barcodeState.isProcessing)
                Center(
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _scanAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * _scanAnimation.value),
                            child: const Icon(
                              Icons.qr_code_scanner,
                              size: 40,
                              color: Colors.blue,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Scanning...'),
                    ],
                  ),
                )
              else if (barcodeState.scannedValue.isNotEmpty) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ResultCard(
                          title: 'Scanned Value:',
                          value: barcodeState.scannedValue,
                          icon: Icons.qr_code,
                        ),
                        ResultCard(
                          title: 'Barcode Type:',
                          value: _getBarcodeTypeText(barcodeState.type),
                          icon: _getBarcodeTypeIcon(barcodeState.type),
                        ),
                        if (barcodeState.gtin != null)
                          ResultCard(
                            title: 'GTIN:',
                            value: barcodeState.gtin!,
                            highlight: true,
                            icon: Icons.tag,
                          ),
                        if (barcodeState.errorMessage != null)
                          ResultCard(
                            title: 'Error:',
                            value: barcodeState.errorMessage!,
                            isError: true,
                            icon: Icons.error_outline,
                          ),
                      ],
                    ),
                  ),
                ),
              ],

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

  IconData _getBarcodeTypeIcon(BarcodeType type) {
    switch (type) {
      case BarcodeType.barcode1D:
        return Icons.view_agenda;
      case BarcodeType.qrCode:
        return Icons.qr_code;
      case BarcodeType.dataMatrix:
        return Icons.grid_4x4;
      case BarcodeType.unknown:
      default:
        return Icons.help_outline;
    }
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
