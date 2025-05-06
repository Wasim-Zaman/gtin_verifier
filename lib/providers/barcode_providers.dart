import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gs1_barcode_parser/gs1_barcode_parser.dart';

enum BarcodeType { unknown, ean13, qrCode, dataMatrix, gs1DigitalLink }

class BarcodeResult {
  final String scannedValue;
  final BarcodeType type;
  final String? gtin;
  final Map<String, dynamic>? additionalData;

  BarcodeResult({
    required this.scannedValue,
    this.type = BarcodeType.unknown,
    this.gtin,
    this.additionalData,
  });
}

class BarcodeService {
  Future<BarcodeResult> processBarcode(String value, {String? codeType}) async {
    if (value.isEmpty) {
      return BarcodeResult(scannedValue: '');
    }

    try {
      // Use codeType if provided (from a real scanner)
      BarcodeType detectedType =
          codeType != null
              ? _convertToType(codeType)
              : _detectBarcodeType(value);

      String? gtin = await _extractGTIN(value, detectedType);
      Map<String, dynamic>? additionalData;

      // If we got a GS1 barcode with additional data
      if (detectedType == BarcodeType.dataMatrix) {
        final parser = GS1BarcodeParser.defaultParser();
        try {
          // The parse method returns a GS1Barcode that can be converted to a string for debugging
          // But we need to extract data differently than you were trying
          final result = parser.parse(value);
          additionalData = {};

          // Get values from different AIs within the parsed barcode
          // This is a simplified example - adjust based on actual barcode structure
          if (result.toString().contains("01 ")) {
            additionalData["01"] = _extractGtinFromGS1Result(result.toString());
          }

          // Look for other common AIs like batch/lot (10), serial (21), etc.
          if (result.toString().contains("10 ")) {
            additionalData["10"] = _extractValueByAI(result.toString(), "10");
          }

          if (result.toString().contains("21 ")) {
            additionalData["21"] = _extractValueByAI(result.toString(), "21");
          }

          if (result.toString().contains("17 ")) {
            additionalData["17"] = _extractValueByAI(result.toString(), "17");
          }
        } catch (e) {
          // Fallback to our own parsing if the GS1 parser fails
        }
      }

      return BarcodeResult(
        scannedValue: value,
        type: detectedType,
        gtin: gtin,
        additionalData: additionalData,
      );
    } catch (e) {
      return BarcodeResult(scannedValue: value, type: BarcodeType.unknown);
    }
  }

  // Helper method to extract GTIN from the GS1 parser result string
  String? _extractGtinFromGS1Result(String resultString) {
    RegExp gtinPattern = RegExp(r'01 [^:]+: (\d+)');
    Match? match = gtinPattern.firstMatch(resultString);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

  // Helper method to extract values by AI from the GS1 parser result string
  String? _extractValueByAI(String resultString, String ai) {
    RegExp pattern = RegExp('$ai [^:]+: ([^,\\n]+)');
    Match? match = pattern.firstMatch(resultString);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

  BarcodeType _convertToType(String codeType) {
    switch (codeType.toLowerCase()) {
      case 'ean13':
        return BarcodeType.ean13;
      case 'datamatrix':
        return BarcodeType.dataMatrix;
      case 'qrcode':
        return BarcodeType.qrCode;
      default:
        return BarcodeType.unknown;
    }
  }

  BarcodeType _detectBarcodeType(String value) {
    // Check for GS1 Digital Link URL first
    if (value.startsWith('http') &&
        (value.contains('/01/') || value.contains('?01='))) {
      return BarcodeType.gs1DigitalLink;
    }

    // Check for EAN-13
    if (value.length == 13 && RegExp(r'^\d+$').hasMatch(value)) {
      return BarcodeType.ean13;
    } else if (value.contains(RegExp(r'^\[\)>[>]\d{2}'))) {
      // GS1 DataMatrix often starts with this pattern
      return BarcodeType.dataMatrix;
    } else if (value.length > 13 || value.contains('(')) {
      // Check if it contains GS1 Application Identifiers
      if (RegExp(r'\(\d{2}\)').hasMatch(value)) {
        return BarcodeType.dataMatrix;
      }
      // Assume QR code for other longer values
      return BarcodeType.qrCode;
    }

    return BarcodeType.unknown;
  }

  Future<String?> _extractGTIN(String value, BarcodeType type) async {
    switch (type) {
      case BarcodeType.ean13:
        // Clean the barcode, removing any non-numeric characters
        String cleanedBarcode = value.replaceAll(RegExp(r'[^0-9]'), '');
        return cleanedBarcode.length == 13 ? cleanedBarcode : null;

      case BarcodeType.dataMatrix:
        // Try using the GS1 parser first
        try {
          final parser = GS1BarcodeParser.defaultParser();
          final result = parser.parse(value);
          // Extract GTIN (AI 01) from the parsed result string
          return _extractGtinFromGS1Result(result.toString());
        } catch (e) {
          // Fallback to regex-based approach if parser fails
        }

        // Fallback: Common GS1 Application Identifiers for GTIN are 01, 02
        RegExp gtinRegex = RegExp(r'(?:\(|\[>)?(01|02)(?:\)|\[>)?(\d{14})');
        final match = gtinRegex.firstMatch(value);
        if (match != null && match.groupCount >= 2) {
          return match.group(2);
        }
        return null;

      case BarcodeType.gs1DigitalLink:
        // Extract the GTIN from the URL pattern
        // Pattern like https://gtrack.online/01/6285561001275
        RegExp urlGtinRegex = RegExp(r'/01/(\d+)');
        var match = urlGtinRegex.firstMatch(value);

        if (match != null && match.groupCount >= 1) {
          return match.group(1);
        }

        // Also check for query parameter format like ?01=12345
        RegExp queryGtinRegex = RegExp(r'[?&]01=(\d+)');
        match = queryGtinRegex.firstMatch(value);

        if (match != null && match.groupCount >= 1) {
          return match.group(1);
        }

        return null;

      case BarcodeType.qrCode:
        // Check for embedded GS1 formats in QR codes
        RegExp gtinRegex = RegExp(r'(?:\(|\[>)?(01|02)(?:\)|\[>)?(\d{14})');
        final match = gtinRegex.firstMatch(value);
        if (match != null && match.groupCount >= 2) {
          return match.group(2);
        }
        return null;

      case BarcodeType.unknown:
      default:
        // Try to extract GTIN if it's a numeric string of correct length
        if (RegExp(r'^\d{8,14}$').hasMatch(value)) {
          return value;
        }
        return null;
    }
  }
}

final barcodeServiceProvider = Provider<BarcodeService>((ref) {
  return BarcodeService();
});

final barcodeScanProvider = StateProvider<String>((ref) => '');

final barcodeResultProvider = FutureProvider.autoDispose<BarcodeResult>((
  ref,
) async {
  final barcodeService = ref.watch(barcodeServiceProvider);
  final scannedValue = ref.watch(barcodeScanProvider);

  if (scannedValue.isEmpty) {
    return BarcodeResult(scannedValue: '');
  }

  return barcodeService.processBarcode(scannedValue);
});

// Add this for manual testing with barcode types
final barcodeTypeTestProvider = StateProvider<String?>((ref) => null);

final barcodeTestResultProvider = FutureProvider.autoDispose<BarcodeResult>((
  ref,
) async {
  final barcodeService = ref.watch(barcodeServiceProvider);
  final scannedValue = ref.watch(barcodeScanProvider);
  final codeType = ref.watch(barcodeTypeTestProvider);

  if (scannedValue.isEmpty) {
    return BarcodeResult(scannedValue: '');
  }

  return barcodeService.processBarcode(scannedValue, codeType: codeType);
});
