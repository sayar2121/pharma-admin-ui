import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import '../../notifiers/map_notifier.dart';
import '../../providers/map_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';

class MapScreen extends ConsumerStatefulWidget {
	final double? initialLatitude;
	final double? initialLongitude;

	const MapScreen({super.key, this.initialLatitude, this.initialLongitude});

	@override
	ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
	final MapController _mapController = MapController();
	bool _mapReady = false;

	@override
	void initState() {
		super.initState();
		WidgetsBinding.instance.addPostFrameCallback((_) {
			final notifier = ref.read(mapProvider.notifier);
			if (widget.initialLatitude != null && widget.initialLongitude != null) {
				notifier.setPosition(widget.initialLatitude!, widget.initialLongitude!);
			} else {
				notifier.fetchCurrentLocation();
			}
		});
	}

	@override
	Widget build(BuildContext context) {
		final mapState = ref.watch(mapProvider);
		final center = LatLng(mapState.latitude, mapState.longitude);

		if (_mapReady) {
			_mapController.move(center, _mapController.camera.zoom);
		}

		return Scaffold(
			backgroundColor: AppColors.background,
			appBar: const CustomAppBar(
				title: 'Pick Location',
				subtitle: 'Drag the map to adjust',
				showBackButton: true,
			),
			body: Stack(
				children: [
					FlutterMap(
						mapController: _mapController,
						options: MapOptions(
							initialCenter: center,
							initialZoom: 15,
							onPositionChanged: (position, hasGesture) {
								if (hasGesture) {
									final newCenter = position.center;
									ref
											.read(mapProvider.notifier)
											.setPosition(newCenter.latitude, newCenter.longitude);
								}
							},
							onMapReady: () => setState(() => _mapReady = true),
						),
						children: [
							TileLayer(
								urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
								userAgentPackageName: 'pharma_app',
							),
						],
					),
					Align(
						alignment: Alignment.center,
						child: Icon(
							Iconsax.location5,
							size: 36,
							color: AppColors.primary,
						),
					),
					Positioned(
						right: 16,
						bottom: 160,
						child: FloatingActionButton(
							heroTag: 'current-location',
							onPressed: () async {
								await ref.read(mapProvider.notifier).fetchCurrentLocation();
								final updated = ref.read(mapProvider);
								_mapController.move(
									LatLng(updated.latitude, updated.longitude),
									16,
								);
							},
							backgroundColor: Colors.white,
							child: mapState.isLoading
									? const SizedBox(
											height: 20,
											width: 20,
											child: CircularProgressIndicator(strokeWidth: 2),
										)
									: const Icon(Iconsax.gps, color: AppColors.primary),
						),
					),
					Positioned(
						left: 16,
						right: 16,
						bottom: 24,
						child: _buildBottomCard(mapState),
					),
				],
			),
		);
	}

	Widget _buildBottomCard(MapState state) {
		return Container(
			padding: const EdgeInsets.all(16),
			decoration: AppCardStyles.sleekCard.copyWith(
				borderRadius: BorderRadius.circular(20),
			),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text('Selected location', style: AppTextStyles.caption),
					const SizedBox(height: 8),
					Row(
						children: [
							Expanded(
								child: Text(
									'Lat: ${state.latitude.toStringAsFixed(6)}',
									style: AppTextStyles.description.copyWith(
										fontWeight: FontWeight.w600,
									),
								),
							),
							Expanded(
								child: Text(
									'Lng: ${state.longitude.toStringAsFixed(6)}',
									style: AppTextStyles.description.copyWith(
										fontWeight: FontWeight.w600,
									),
								),
							),
						],
					),
					if (state.error != null) ...[
						const SizedBox(height: 8),
						Text(
							state.error!,
							style: AppTextStyles.caption.copyWith(color: AppColors.error),
						),
					],
					const SizedBox(height: 12),
					SizedBox(
						width: double.infinity,
						child: ElevatedButton(
							onPressed: () {
								context.pop({
									'latitude': state.latitude.toString(),
									'longitude': state.longitude.toString(),
								});
							},
							child: const Text('USE THIS LOCATION'),
						),
					),
				],
			),
		);
	}
}
