import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_state.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_current_location_use_case.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_map_tile_url_use_case.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_public_gps_traces_use_case.dart';

@injectable
class MapCubit extends Cubit<MapState> {
  final GetMapConfigUseCase getMapConfig;
  final GetCurrentLocationUseCase getCurrentLocation;
  final GetPublicGpsTracesUseCase getPublicGpsTraces;

  MapCubit(this.getMapConfig, this.getCurrentLocation, this.getPublicGpsTraces)
    : super(const MapState.initial());

  Future<void> loadMap() async {
    emit(const MapState.loading());
    try {
      final style = await getMapConfig.run();
      emit(MapState.loaded(style: style));
    } catch (e) {
      emit(MapState.error('Failed to load style: $e'));
    }
  }

  Future<void> locateMe() async {
    try {
      final location = await getCurrentLocation.run();
      final double lat = location.latitude;
      final double lon = location.longitude;
      final double halfBox = 0.125;
      final double left = lon - halfBox;
      final double right = lon + halfBox;
      final double bottom = lat - halfBox;
      final double top = lat + halfBox;
      final style = state.maybeWhen(
        loaded: (style) => style,
        loadedWithLocation: (style, _, __, ___) => style,
        orElse: () => null,
      );
      if (style != null) {
        emit(
          MapState.loadedWithLocation(
            style: style,
            currentLocation: location,
            gpsTraces: const [],
            loadingGpsTraces: true,
          ),
        );
        getPublicGpsTraces
            .run(left, bottom, right, top, 0)
            .then((traces) {
              emit(
                MapState.loadedWithLocation(
                  style: style,
                  currentLocation: location,
                  gpsTraces: traces,
                  loadingGpsTraces: false,
                ),
              );
            })
            .catchError((e) {
              emit(MapState.error('Failed to get traces: $e'));
            });
      }
    } catch (e) {
      emit(MapState.error('Failed to get location or traces: $e'));
    }
  }
}
