import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:furtive/core/widgets/activity_stats_widget.dart';
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
                    bottom: Global.padding,
                    left: Global.padding,
                    right: Global.padding,
                    child: ElevatedButton.icon(
                      onPressed:
                          () => _showStatisticsBottomSheet(
                            context,
                            widget.activity,
                          ),
                      icon: const Icon(Icons.analytics),
                      label: const Text('View Statistics'),
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
    final stoppedAt = activity.stoppedAt ?? activity.points.last.time;

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
            child: ActivityStatsWidget(
              activity: activity,
              elapsedTime: stoppedAt.difference(activity.startedAt),
            ),
          ),
    );
  }
}
