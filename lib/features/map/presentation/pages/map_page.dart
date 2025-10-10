import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:openstreetmap/core/global.dart';
import 'package:openstreetmap/features/map/domain/entities/activity_entity.dart';
import 'package:openstreetmap/features/map/domain/entities/position_entity.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_bloc.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_state.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_event.dart';
import 'package:openstreetmap/features/map/domain/entities/trace_entity.dart';
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
                  (previous.activity == null || previous.points.isEmpty) &&
                  current.activity != null &&
                  current.points.isNotEmpty,
          listener: (context, state) {
            final firstPoint = state.points.first;
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
                      if (state.activity != null && state.points.isNotEmpty)
                        _buildActivityPath(state.points),
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
                    bloc.add(const FetchLocation());
                    Future.delayed(Duration(seconds: 1), () {
                      if (state.userLocation == null) return;
                      _mapController.move(
                        LatLng(
                          state.userLocation!.latitude,
                          state.userLocation!.longitude,
                        ),
                        15,
                      );
                    });
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

  Widget _buildActivityPath(List<ActivityPointEntity> points) {
    if (points.isEmpty) return PolylineLayer(polylines: <Polyline>[]);

    final segments = <Polyline>[];
    var segmentPoints = <ActivityPointEntity>[];
    ActivityPointStatusEntity? previousStatus;

    for (final point in points) {
      final hasStatusChanged =
          previousStatus != null && point.status != previousStatus;

      if (hasStatusChanged) {
        segments.add(_createPathSegment(segmentPoints, previousStatus));
        segmentPoints = [];
      }

      segmentPoints.add(point);
      previousStatus = point.status;
    }

    if (segmentPoints.isNotEmpty && previousStatus != null) {
      segments.add(_createPathSegment(segmentPoints, previousStatus));
    }

    return PolylineLayer(polylines: segments);
  }

  Polyline _createPathSegment(
    List<ActivityPointEntity> points,
    ActivityPointStatusEntity status,
  ) {
    return Polyline(
      points: points.map((p) => p.position.toLatLng()).toList(),
      color:
          status == ActivityPointStatusEntity.active
              ? Colors.blue
              : Colors.yellow,
      strokeWidth: 4.0,
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
                          Text(
                            'Recording Activity',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            _formatDuration(state.elapsedTime),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      if (state.statistics != null)
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
                                  'Duration: ${_formatDuration(state.statistics!.activityDuration)}',
                                ),
                                Text(
                                  'Distance: ${state.statistics!.activeDistanceInKm.toStringAsFixed(2)} km',
                                ),
                                Text(
                                  'Speed: ${state.statistics!.activeAverageSpeedKmh.toStringAsFixed(1)} km/h',
                                ),
                                Text(
                                  'Elevation: +${state.statistics!.activeElevationGain.toStringAsFixed(0)}m / -${state.statistics!.activeElevationLoss.toStringAsFixed(0)}m',
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
                                  'Duration: ${_formatDuration(state.statistics!.pausedDuration)}',
                                ),
                                Text(
                                  'Distance: ${state.statistics!.pausedDistanceInKm.toStringAsFixed(2)} km',
                                ),
                                Text(
                                  'Speed: ${state.statistics!.pausedAverageSpeedKmh.toStringAsFixed(1)} km/h',
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}
