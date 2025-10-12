import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:openstreetmap/core/global.dart';
import 'package:openstreetmap/core/entities/activity_entity.dart';
import 'package:openstreetmap/core/entities/position_entity.dart';
import 'package:openstreetmap/features/map/bloc/map_bloc.dart';
import 'package:openstreetmap/features/map/bloc/map_state.dart';
import 'package:openstreetmap/features/map/bloc/map_event.dart';
import 'package:openstreetmap/core/entities/trace_entity.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MapBloc>();

    return MultiBlocListener(
      listeners: [
        BlocListener<MapBloc, MapState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage!.message,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
              context.read<MapBloc>().add(const ClearError());
            }
          },
        ),
        BlocListener<MapBloc, MapState>(
          listenWhen:
              (previous, current) =>
                  (previous.activity == null ||
                      previous.activity!.points.isEmpty) &&
                  current.activity != null &&
                  current.activity!.points.isNotEmpty,
          listener: (context, state) {
            final firstPoint = state.activity!.points.first;
            _mapController.move(firstPoint.position.toLatLng(), Global.maxZoom);
          },
        ),
      ],
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          final location =
              state.userLocation ??
              state.searchCenter ??
              PositionEntity(
                latitude: 48.8566,
                longitude: 2.3522,
                elevation: 0,
              );

          if (state.style == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            body: Stack(
              children: [
                Container(
                  color: Colors.grey[300],
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: location.toLatLng(),
                      initialZoom: Global.defaultZoom,
                      maxZoom: Global.maxZoom,
                    ),
                    children: [
                      VectorTileLayer(
                        maximumZoom: Global.maxZoom,
                        theme: state.style!.theme,
                        tileProviders: state.style!.providers,
                        sprites: state.style!.sprites,
                      ),
                      if (state.traces.isNotEmpty)
                        _buildTracesLayer(state.traces),
                      if (state.activity != null &&
                          state.activity!.points.isNotEmpty)
                        state.activity!.toPolylineLayer(),
                      if (state.userLocation != null)
                        _buildLocationMarker(
                          PositionEntity(
                            latitude: state.userLocation!.latitude,
                            longitude: state.userLocation!.longitude,
                            elevation: state.userLocation!.elevation,
                          ),
                        ),
                      if (state.searchCenter != null && state.isLoading)
                        _buildSquareOverlay(),
                    ],
                  ),
                ),
                if (state.isLoading)
                  const Center(child: CircularProgressIndicator()),
                if (state.activity != null) _buildActivityStatusWidget(),
              ],
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    if (state.userLocation == null) return;
                    _mapController.move(
                      LatLng(
                        state.userLocation!.latitude,
                        state.userLocation!.longitude,
                      ),
                      Global.maxZoom,
                    );
                  },
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () {
                    final center = _mapController.camera.center;
                    bloc.add(FetchTraces(center: center));
                  },
                  child: const Icon(Icons.search),
                ),

                if (state.isPaused && state.activity != null) ...[
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    onPressed: () => bloc.add(const CeaseActivity()),
                    child: const Icon(Icons.stop),
                  ),
                ],

                if (state.activity != null) ...[
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    onPressed: () => bloc.add(const PauseActivity()),
                    child:
                        state.isPaused
                            ? const Icon(Icons.play_arrow)
                            : const Icon(Icons.pause),
                  ),
                ],

                if (state.activity == null) ...[
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    onPressed: () {
                      bloc.add(const StartActivity());
                    },
                    child: const Icon(Icons.play_arrow),
                  ),
                ],
              ],
            ),
          );
        },
      ),
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

  Widget _buildLocationMarker(PositionEntity location) {
    return MarkerLayer(
      markers: [
        Marker(
          point: LatLng(location.latitude, location.longitude),
          width: 40,
          height: 40,
          child: const Icon(Icons.my_location, color: Colors.white, size: 24),
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
    const double kSearchHalfSideDegrees = 0.01425;
    return (
      north: center.latitude + kSearchHalfSideDegrees,
      south: center.latitude - kSearchHalfSideDegrees,
      east: center.longitude + kSearchHalfSideDegrees,
      west: center.longitude - kSearchHalfSideDegrees,
    );
  }

  Widget _buildActivityStatusWidget() {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        final activity = context.watch<MapBloc>().state.activity;

        return Positioned(
          top: 50,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recording Activity'),
                          Text(state.elapsedTime.toHHMMSS()),
                        ],
                      ),

                      const SizedBox(height: 4),

                      if (activity != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Active',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Duration: ${activity.activeDuration.toHHMMSS()}',
                                ),
                                Text(
                                  'Distance: ${activity.activeDistanceInKm.toStringAsFixed(2)} km',
                                ),
                                Text(
                                  'Speed: ${activity.activeSpeedKmh.toStringAsFixed(1)} km/h',
                                ),
                                Text(
                                  'Elevation: +${activity.activeElevation.gain.toStringAsFixed(0)}m / -${activity.activeElevation.loss.toStringAsFixed(0)}m',
                                ),
                              ],
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Paused',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Duration: ${activity.pausedDuration.toHHMMSS()}',
                                ),
                                Text(
                                  'Distance: ${activity.pausedDistanceInKm.toStringAsFixed(2)} km',
                                ),
                                Text(
                                  'Speed: ${activity.pausedSpeedKmh.toStringAsFixed(1)} km/h',
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
