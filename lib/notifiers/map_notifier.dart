import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';

class MapState {
	final double latitude;
	final double longitude;
	final bool isLoading;
	final String? error;

	const MapState({
		required this.latitude,
		required this.longitude,
		this.isLoading = false,
		this.error,
	});

	MapState copyWith({
		double? latitude,
		double? longitude,
		bool? isLoading,
		String? error,
	}) {
		return MapState(
			latitude: latitude ?? this.latitude,
			longitude: longitude ?? this.longitude,
			isLoading: isLoading ?? this.isLoading,
			error: error,
		);
	}
}

class MapNotifier extends StateNotifier<MapState> {
	MapNotifier()
			: super(const MapState(latitude: 20.5937, longitude: 78.9629));

	void setPosition(double latitude, double longitude) {
		state = state.copyWith(latitude: latitude, longitude: longitude, error: null);
	}

	Future<void> fetchCurrentLocation() async {
		state = state.copyWith(isLoading: true, error: null);
		try {
			final serviceEnabled = await Geolocator.isLocationServiceEnabled();
			if (!serviceEnabled) {
				state = state.copyWith(
					isLoading: false,
					error: 'Location services are disabled',
				);
				return;
			}

			var permission = await Geolocator.checkPermission();
			if (permission == LocationPermission.denied) {
				permission = await Geolocator.requestPermission();
			}

			if (permission == LocationPermission.denied ||
					permission == LocationPermission.deniedForever) {
				state = state.copyWith(
					isLoading: false,
					error: 'Location permission denied',
				);
				return;
			}

			final position = await Geolocator.getCurrentPosition(
				desiredAccuracy: LocationAccuracy.high,
			);

			state = state.copyWith(
				latitude: position.latitude,
				longitude: position.longitude,
				isLoading: false,
			);
		} catch (e) {
			state = state.copyWith(isLoading: false, error: e.toString());
		}
	}
}
