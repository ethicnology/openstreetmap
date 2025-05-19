import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_state.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import '../bloc/map_cubit.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng? _lastLocation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: BlocListener<MapCubit, MapState>(
        listener: (context, state) {
          state.maybeWhen(
            loadedWithLocation: (
              style,
              currentLocation,
              gpsTraces,
              loadingGpsTraces,
              showLocationMarker,
              searchCenter,
            ) {
              if (_lastLocation != currentLocation) {
                _mapController.move(currentLocation, 15.0);
                _lastLocation = currentLocation;
              }
            },
            orElse: () {},
          );
        },
        child: BlocBuilder<MapCubit, MapState>(
          builder: (context, state) {
            return state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded:
                  (style) => Container(
                    color: Colors.grey[300],
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: const LatLng(48.8566, 2.3522),
                        initialZoom: 12.0,
                      ),
                      children: [
                        VectorTileLayer(
                          maximumZoom: 19,
                          theme: style.theme,
                          tileProviders: style.providers,
                          sprites: style.sprites,
                        ),
                      ],
                    ),
                  ),
              loadedWithLocation:
                  (
                    style,
                    currentLocation,
                    gpsTraces,
                    loadingGpsTraces,
                    showLocationMarker,
                    searchCenter,
                  ) => Stack(
                    children: [
                      Container(
                        color: Colors.grey[300],
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: currentLocation,
                            initialZoom: 15.0,
                          ),
                          children: [
                            VectorTileLayer(
                              maximumZoom: 19,
                              theme: style.theme,
                              tileProviders: style.providers,
                              sprites: style.sprites,
                            ),
                            if (gpsTraces.isNotEmpty)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points:
                                        gpsTraces
                                            .map((e) => LatLng(e.lat, e.lon))
                                            .toList(),
                                    color: Colors.red,
                                    strokeWidth: 3.0,
                                  ),
                                ],
                              ),
                            Builder(
                              builder: (context) {
                                if (searchCenter == null) {
                                  return const SizedBox.shrink();
                                }
                                return PolygonLayer(
                                  polygons: [
                                    Polygon(
                                      points: [
                                        LatLng(
                                          searchCenter.latitude -
                                              kSearchHalfSideDegrees,
                                          searchCenter.longitude -
                                              kSearchHalfSideDegrees,
                                        ),
                                        LatLng(
                                          searchCenter.latitude -
                                              kSearchHalfSideDegrees,
                                          searchCenter.longitude +
                                              kSearchHalfSideDegrees,
                                        ),
                                        LatLng(
                                          searchCenter.latitude +
                                              kSearchHalfSideDegrees,
                                          searchCenter.longitude +
                                              kSearchHalfSideDegrees,
                                        ),
                                        LatLng(
                                          searchCenter.latitude +
                                              kSearchHalfSideDegrees,
                                          searchCenter.longitude -
                                              kSearchHalfSideDegrees,
                                        ),
                                      ],
                                      color: Colors.blue.withValues(alpha: 0.2),
                                      borderColor: Colors.blue,
                                      borderStrokeWidth: 2.0,
                                    ),
                                  ],
                                );
                              },
                            ),
                            if (showLocationMarker)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: currentLocation,
                                    width: 60,
                                    height: 60,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        AnimatedBuilder(
                                          animation: _animationController,
                                          builder: (context, child) {
                                            final scale =
                                                1.0 +
                                                0.5 *
                                                    _animationController.value;
                                            return Transform.scale(
                                              scale: scale,
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.blue.withValues(
                                                    alpha: 0.3,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const Icon(
                                          Icons.my_location,
                                          color: Colors.blue,
                                          size: 32,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      if (loadingGpsTraces)
                        const Center(child: CircularProgressIndicator()),
                    ],
                  ),
              error: (msg) => Center(child: Text(msg)),
              initial: () => const SizedBox(),
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              context.read<MapCubit>().locateMe();
            },
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              final center = _mapController.camera.center;
              context.read<MapCubit>().searchTracesAt(center);
            },
            child: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
