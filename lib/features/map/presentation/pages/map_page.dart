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
          if (state is MapLoaded && state.currentLocation != null) {
            if (_lastLocation != state.currentLocation) {
              _mapController.move(state.currentLocation!, 15.0);
              _lastLocation = state.currentLocation;
            }
          }
        },
        child: BlocBuilder<MapCubit, MapState>(
          builder: (context, state) {
            if (state is MapLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MapLoaded) {
              return Container(
                color: Colors.grey[300],
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        state.currentLocation ?? const LatLng(48.8566, 2.3522),
                    initialZoom: state.currentLocation != null ? 15.0 : 12.0,
                  ),
                  children: [
                    VectorTileLayer(
                      maximumZoom: 19,
                      theme: state.style.theme,
                      tileProviders: state.style.providers,
                      sprites: state.style.sprites,
                    ),
                    if (state.currentLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: state.currentLocation!,
                            width: 60,
                            height: 60,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    final scale =
                                        1.0 + 0.5 * _animationController.value;
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
              );
            } else if (state is MapError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<MapCubit>().locateMe();
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
