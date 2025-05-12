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

  // Password dialog controller
  final TextEditingController _passwordController = TextEditingController();
  static const String _exitPassword = '1122';

  // Add last processed barcode to avoid duplicate navigation
  String? _lastNavigatedGtin;

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
    _passwordController.dispose();
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
    _lastNavigatedGtin = null;
  }

  // Show password dialog when back button is pressed
  Future<bool> _onWillPop() async {
    _passwordController.clear(); // Clear any previous input

    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Password to Exit'),
          content: TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              hintText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            keyboardType: TextInputType.number,
            autofocus: true,
            onSubmitted: (_) {
              if (_passwordController.text == _exitPassword) {
                Navigator.of(context).pop(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Incorrect password'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop(false);
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_passwordController.text == _exitPassword) {
                  Navigator.of(context).pop(true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect password'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.of(context).pop(false);
                }
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );

    return result ?? false;
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

    // Check for valid GTIN and navigate automatically
    barcodeResultAsync.whenData((result) {
      if (result.gtin != null &&
          result.gtin!.isNotEmpty &&
          result.gtin != _lastNavigatedGtin) {
        // Store the GTIN we're about to navigate to
        String gtin = result.gtin!;
        _lastNavigatedGtin = gtin;

        // Schedule navigation after the build is complete
        Future.microtask(() {
          // Clear everything
          _barcodeController.clear();
          ref.read(barcodeScanProvider.notifier).state = '';

          // Navigate to product details
          context.go('/product/$gtin');
        });
      }
    });

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GTIN Verifier'),
          backgroundColor: colorScheme.surfaceContainerHighest,
          elevation: 0,
          scrolledUnderElevation: 3,
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.only(right: 8.0),
          //     child: IconButton(
          //       icon: const Icon(Icons.science_outlined),
          //       tooltip: 'Test Barcodes',
          //       style: IconButton.styleFrom(
          //         foregroundColor: colorScheme.primary,
          //         backgroundColor: colorScheme.primaryContainer.withValues(
          //           alpha: 0.4,
          //         ),
          //       ),
          //       onPressed: () => context.go('/test'),
          //     ),
          //   ),
          // ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.surfaceContainerHighest.withOpacity(0.3),
                colorScheme.surface.withOpacity(0.9),
              ],
              stops: const [0.0, 0.7],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 32),
                  _buildSearchBox(context, colorScheme),
                  const SizedBox(height: 24),
                  Expanded(child: _buildResults(barcodeResultAsync)),
                  const SizedBox(height: 16),
                  _buildScanButton(context, colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.qr_code_scanner,
                    size: 40,
                    color: colorScheme.primary,
                  ),
                ),
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: 26 + 28 * _scanAnimation.value,
                      child: Container(
                        height: 2,
                        width: 50,
                        decoration: BoxDecoration(
                          color: colorScheme.tertiary.withValues(alpha: 0.8),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.tertiary.withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GTIN Verifier',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan or enter a barcode to verify',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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

  Widget _buildSearchBox(BuildContext context, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.outline, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: colorScheme.surface,
          labelText: 'Barcode',
          labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          hintText: 'Scan or enter barcode',
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(Icons.qr_code, color: colorScheme.primary),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            color: colorScheme.onSurfaceVariant,
            onPressed: _clearBarcode,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
        style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
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
    );
  }

  Widget _buildResults(AsyncValue<BarcodeResult> barcodeResultAsync) {
    return barcodeResultAsync.when(
      data: (result) {
        if (result.scannedValue.isEmpty) {
          return _buildEmptyState();
        }
        return _buildResultCards(result);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stackTrace) => Center(
            child: ResultCard(
              title: 'Error:',
              value: error.toString(),
              isError: true,
              icon: Icons.error_outline,
            ),
          ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_scanner,
              size: 40,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Scan a barcode to see results',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a barcode in the field above\nor use the scanner button',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCards(BarcodeResult result) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.1),
                  colorScheme.primaryContainer.withValues(alpha: 0.3),
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
                  'Scan Results',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
          if (result.gtin != null)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go('/product/${result.gtin}');
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('VIEW PRODUCT DETAILS'),
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanButton(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _barcodeFocusNode.requestFocus();
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('SCAN BARCODE'),
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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

    final Color cardColor =
        highlight
            ? colorScheme.primaryContainer.withValues(alpha: 0.7)
            : isError
            ? colorScheme.errorContainer.withValues(alpha: 0.7)
            : colorScheme.surface;

    final Color iconColor =
        highlight
            ? colorScheme.primary
            : isError
            ? colorScheme.error
            : colorScheme.primary.withValues(alpha: 0.7);

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
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : isError
                  ? colorScheme.error.withValues(alpha: 0.3)
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
                        ? colorScheme.primary.withValues(alpha: 0.1)
                        : isError
                        ? colorScheme.error.withValues(alpha: 0.1)
                        : colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
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
                      fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
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
  }
}
