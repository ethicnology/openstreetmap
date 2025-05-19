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

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  LatLng? _lastLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: BlocListener<MapCubit, Object>(
        listener: (context, state) {
          if (state is MapLoaded && state.currentLocation != null) {
            if (_lastLocation != state.currentLocation) {
              _mapController.move(state.currentLocation!, 15.0);
              _lastLocation = state.currentLocation;
            }
          }
        },
        child: BlocBuilder<MapCubit, Object>(
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
                      theme: state.style.theme,
                      tileProviders: state.style.providers,
                    ),
                    if (state.currentLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: state.currentLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 40,
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
