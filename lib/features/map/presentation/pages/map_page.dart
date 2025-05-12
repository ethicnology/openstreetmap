import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:openstreetmap/core/locator/locator.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_state.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import '../bloc/map_cubit.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MapCubit>()..loadMap(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Map')),
        body: BlocBuilder<MapCubit, Object>(
          builder: (context, state) {
            if (state is MapLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MapLoaded) {
              return Container(
                color: Colors.grey[300],
                child: FlutterMap(
                  options: MapOptions(),
                  children: [
                    VectorTileLayer(
                      theme: state.style.theme,
                      tileProviders: state.style.providers,
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Implement getCurrentLocation logic here
          },
          child: const Icon(Icons.my_location),
        ),
      ),
    );
  }
}
