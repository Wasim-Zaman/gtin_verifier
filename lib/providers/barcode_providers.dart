import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BarcodeType { unknown, barcode1D, qrCode, dataMatrix }

class BarcodeState {
  final String scannedValue;
  final BarcodeType type;
  final String? gtin;
  final bool isProcessing;
  final String? errorMessage;

  BarcodeState({
    this.scannedValue = '',
    this.type = BarcodeType.unknown,
    this.gtin,
    this.isProcessing = false,
    this.errorMessage,
  });

  BarcodeState copyWith({
    String? scannedValue,
    BarcodeType? type,
    String? gtin,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return BarcodeState(
      scannedValue: scannedValue ?? this.scannedValue,
      type: type ?? this.type,
      gtin: gtin ?? this.gtin,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class BarcodeNotifier extends StateNotifier<BarcodeState> {
  BarcodeNotifier() : super(BarcodeState());

  void processBarcode(String value) {
    if (value.isEmpty) {
      state = BarcodeState();
      return;
    }

    state = state.copyWith(
      scannedValue: value,
      isProcessing: true,
      errorMessage: null,
    );

    try {
      // Determine barcode type based on content and format
      BarcodeType detectedType = _detectBarcodeType(value);
      String? gtin = _extractGTIN(value, detectedType);

      state = state.copyWith(
        type: detectedType,
        gtin: gtin,
        isProcessing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Error processing barcode: ${e.toString()}',
      );
    }
  }

  BarcodeType _detectBarcodeType(String value) {
    // Simple detection logic - in real app, this would be more sophisticated
    if (value.length <= 13 && RegExp(r'^\d+$').hasMatch(value)) {
      return BarcodeType.barcode1D;
    } else if (value.contains(RegExp(r'^\[\)>[>]\d{2}'))) {
      // GS1 DataMatrix often starts with this pattern
      return BarcodeType.dataMatrix;
    } else if (value.length > 13) {
      // Assuming longer, non-numeric-only codes are QR codes
      return BarcodeType.qrCode;
    }

    return BarcodeType.unknown;
  }

  String? _extractGTIN(String value, BarcodeType type) {
    // Extract GTIN based on barcode type
    switch (type) {
      case BarcodeType.barcode1D:
        // For 1D, the whole value is usually the GTIN if it's numeric and 8-14 digits
        if (RegExp(r'^\d{8,14}$').hasMatch(value)) {
          return value;
        }
        return null;

      case BarcodeType.qrCode:
      case BarcodeType.dataMatrix:
        // Look for GTIN pattern in 2D codes (often prefixed with AI)
        // Common GS1 Application Identifiers for GTIN are 01, 02
        RegExp gtinRegex = RegExp(r'(01|02)(\d{14})');
        final match = gtinRegex.firstMatch(value);
        if (match != null) {
          return match.group(2);
        }
        return null;

      case BarcodeType.unknown:
      default:
        return null;
    }
  }

  void clearBarcode() {
    state = BarcodeState();
  }
}

final barcodeProvider = StateNotifierProvider<BarcodeNotifier, BarcodeState>((
  ref,
) {
  return BarcodeNotifier();
});
