import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_cubit.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_state.dart';
import 'package:openstreetmap/features/map/domain/entities/trace_entity.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  final _mapController = MapController();
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
      body: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          return state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (style) => _buildMap(style),
            loadedWithLocation:
                (
                  style,
                  currentLocation,
                  traces,
                  loadingGpsTraces,
                  showLocationMarker,
                  searchCenter,
                ) => _buildMapWithLocation(
                  style,
                  currentLocation,
                  traces,
                  loadingGpsTraces,
                  showLocationMarker,
                  searchCenter,
                ),
            error: (message) => Center(child: Text(message)),
            initial: () => const SizedBox(),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildMap(Style style) {
    return Container(
      color: Colors.grey[300],
      child: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(48.8566, 2.3522),
          initialZoom: 13.0,
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
    );
  }

  Widget _buildMapWithLocation(
    Style style,
    LatLng currentLocation,
    List<TraceEntity> traces,
    bool loadingGpsTraces,
    bool showLocationMarker,
    LatLng? searchCenter,
  ) {
    return Stack(
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
              if (traces.isNotEmpty) _buildTracesLayer(traces),
              if (showLocationMarker) _buildLocationMarker(currentLocation),
              if (searchCenter != null) _buildSearchMarker(searchCenter),
              _buildSquareOverlay(),
            ],
          ),
        ),
        if (loadingGpsTraces) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Map<List<LatLng>, int> _groupSegmentsByIntensity(List<TraceEntity> traces) {
    final Map<String, int> segmentCounts = {};
    final Map<String, List<LatLng>> segmentKeys = {};
    for (final trace in traces) {
      for (var i = 0; i < trace.points.length - 1; i++) {
        final a = LatLng(trace.points[i].latitude, trace.points[i].longitude);
        final b = LatLng(
          trace.points[i + 1].latitude,
          trace.points[i + 1].longitude,
        );
        final key = _segmentKey(a, b);
        segmentCounts[key] = (segmentCounts[key] ?? 0) + 1;
        segmentKeys[key] = [a, b];
      }
    }
    final Map<List<LatLng>, int> result = {};
    for (final entry in segmentCounts.entries) {
      result[segmentKeys[entry.key]!] = entry.value;
    }
    return result;
  }

  String _segmentKey(LatLng a, LatLng b) {
    final points = [
      '${a.latitude},${a.longitude}',
      '${b.latitude},${b.longitude}',
    ]..sort();
    return points.join('|');
  }

  Widget _buildTracesLayer(List<TraceEntity> traces) {
    final segments = _groupSegmentsByIntensity(traces);
    int maxIntensity = 1;
    if (segments.isNotEmpty) {
      maxIntensity = segments.values.reduce((a, b) => a > b ? a : b);
    }
    return PolylineLayer(
      polylines:
          segments.entries.map((entry) {
            final intensity = entry.value;
            final color =
                Color.lerp(
                  Colors.red.withAlpha(30),
                  Colors.red,
                  intensity / maxIntensity,
                )!;
            return Polyline(
              points: entry.key,
              color: color,
              strokeWidth: 3.0 + (intensity - 1) * 2.0,
            );
          }).toList(),
    );
  }

  Widget _buildLocationMarker(LatLng location) {
    return MarkerLayer(
      markers: [
        Marker(
          point: location,
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final scale = 1.0 + 0.5 * _animationController.value;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                    ),
                  );
                },
              ),
              const Icon(Icons.my_location, color: Colors.blue, size: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchMarker(LatLng location) {
    return MarkerLayer(
      markers: [
        Marker(
          point: location,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.location_searching,
            color: Colors.red,
            size: 32,
          ),
        ),
      ],
    );
  }

  Widget _buildSquareOverlay() {
    final center = _mapController.camera.center;
    final bounds = _calculateBounds(center);

    return PolygonLayer(
      polygons: [
        Polygon(
          points: [
            LatLng(bounds.north, bounds.west),
            LatLng(bounds.north, bounds.east),
            LatLng(bounds.south, bounds.east),
            LatLng(bounds.south, bounds.west),
          ],
          color: Colors.blue.withAlpha(30),
          borderColor: Colors.blue.withAlpha(60),
          borderStrokeWidth: 2.0,
        ),
      ],
    );
  }

  ({double north, double south, double east, double west}) _calculateBounds(
    LatLng center,
  ) {
    return (
      north: center.latitude + kSearchHalfSideDegrees,
      south: center.latitude - kSearchHalfSideDegrees,
      east: center.longitude + kSearchHalfSideDegrees,
      west: center.longitude - kSearchHalfSideDegrees,
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: () => context.read<MapCubit>().locateMe(),
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
    );
  }
}
