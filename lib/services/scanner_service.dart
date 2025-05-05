import 'dart:async';

import 'package:flutter/services.dart';

class ScannerService {
  static const MethodChannel _channel = MethodChannel(
    'com.nartec.gtin_verifier/scanner',
  );
  static const EventChannel _scannerEventChannel = EventChannel(
    'com.nartec.gtin_verifier/scanner_events',
  );

  // Stream for barcode scan results
  Stream<String>? _scannerStream;

  // Get scanner events stream
  Stream<String> get scannerStream {
    _scannerStream ??= _scannerEventChannel
        .receiveBroadcastStream()
        .map<String>((dynamic event) => event.toString());
    return _scannerStream!;
  }

  // Initialize the scanner
  Future<bool> initScanner() async {
    try {
      final bool result = await _channel.invokeMethod('initScanner');
      return result;
    } on PlatformException catch (e) {
      print('Failed to init scanner: ${e.message}');
      return false;
    }
  }

  // Trigger a scan programmatically
  Future<void> startScan() async {
    try {
      await _channel.invokeMethod('startScan');
    } on PlatformException catch (e) {
      print('Failed to start scan: ${e.message}');
    }
  }

  // Stop scanning
  Future<void> stopScan() async {
    try {
      await _channel.invokeMethod('stopScan');
    } on PlatformException catch (e) {
      print('Failed to stop scan: ${e.message}');
    }
  }
}
