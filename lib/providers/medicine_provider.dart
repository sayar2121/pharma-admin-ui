import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../notifiers/medicine_notifier.dart';
import '../services/medicine_services.dart';

final medicineServiceProvider = Provider<MedicineService>(
  (ref) => MedicineService(),
);

final medicineProvider = StateNotifierProvider<MedicineNotifier, MedicineState>(
  (ref) {
    final medicineService = ref.watch(medicineServiceProvider);
    return MedicineNotifier(medicineService);
  },
);
