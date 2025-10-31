import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:furtive/core/global.dart';
import 'package:furtive/core/entities/activity_entity.dart';
import 'package:furtive/core/entities/position_entity.dart';
import 'package:furtive/core/usecases/get_map_tile_url_use_case.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

class ActivityDetailPage extends StatefulWidget {
  final ActivityEntity activity;

  const ActivityDetailPage({super.key, required this.activity});

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  final _mapController = MapController();
  final _getMapConfigUseCase = GetMapConfigUseCase();
  Style? _mapStyle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
  }

  Future<void> _loadMapStyle() async {
    try {
      final style = await _getMapConfigUseCase();
      setState(() {
        _mapStyle = style;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity.name),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Container(
                    color: Colors.grey[300],
                    child:
                        _mapStyle != null
                            ? FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter:
                                    widget.activity.points.isNotEmpty
                                        ? widget.activity.points.first.position
                                            .toLatLng()
                                        : const LatLng(48.8566, 2.3522),
                                initialZoom: Global.maxZoom,
                                maxZoom: Global.maxZoom,
                              ),
                              children: [
                                VectorTileLayer(
                                  maximumZoom: Global.maxZoom,
                                  theme: _mapStyle!.theme,
                                  tileProviders: _mapStyle!.providers,
                                  sprites: _mapStyle!.sprites,
                                ),
                                if (widget.activity.points.isNotEmpty)
                                  widget.activity.toPolylineLayer(),
                              ],
                            )
                            : const Center(child: Text('Failed to load map')),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: ElevatedButton.icon(
                      onPressed:
                          () => _showStatisticsBottomSheet(
                            context,
                            widget.activity,
                          ),
                      icon: const Icon(Icons.analytics),
                      label: const Text('View Statistics'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  void _showStatisticsBottomSheet(
    BuildContext context,
    ActivityEntity activity,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: _buildStatisticsPanel(activity),
          ),
    );
  }

  Widget _buildStatisticsPanel(ActivityEntity activity) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text('Duration: ${activity.activeDuration.toHHMMSS()}'),
              Text(
                'Distance: ${activity.activeDistanceInKm.toStringAsFixed(2)} km',
              ),
              Text('Speed: ${activity.activeSpeedKmh.toStringAsFixed(1)} km/h'),
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
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text('Duration: ${activity.pausedDuration.toHHMMSS()}'),
              Text(
                'Distance: ${activity.pausedDistanceInKm.toStringAsFixed(2)} km',
              ),
              Text('Speed: ${activity.pausedSpeedKmh.toStringAsFixed(1)} km/h'),
            ],
          ),
        ],
      ),
    );
  }
}
