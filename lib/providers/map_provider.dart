import 'package:flutter_riverpod/legacy.dart';
import '../notifiers/map_notifier.dart';

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
	return MapNotifier();
});
