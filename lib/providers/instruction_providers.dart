import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/instruction.dart';
import '../services/instruction_service.dart';

// Service provider
final instructionServiceProvider = Provider<InstructionService>((ref) {
  return InstructionService();
});

// State provider to track when to load instructions
final instructionLoadingStateProvider = StateProvider.family<bool, String>(
  (ref, barcode) => false,
);

// Provider to fetch instructions when triggered
final instructionsProvider = FutureProvider.family<List<Instruction>, String>((
  ref,
  barcode,
) async {
  // Check if loading has been triggered
  final shouldLoad = ref.watch(instructionLoadingStateProvider(barcode));

  if (!shouldLoad) {
    return []; // Return empty list if not triggered yet
  }

  final instructionService = ref.watch(instructionServiceProvider);
  final response = await instructionService.getInstructionsByBarcode(barcode);
  return response.instructions;
});
