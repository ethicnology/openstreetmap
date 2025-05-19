import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_state.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/get_map_tile_url.dart';

@injectable
class MapCubit extends Cubit<MapState> {
  final GetMapConfigUseCase getMapConfig;
  final GetCurrentLocationUseCase getCurrentLocation;

  MapCubit(this.getMapConfig, this.getCurrentLocation) : super(MapInitial());

  Future<void> loadMap() async {
    emit(MapLoading());
    try {
      final style = await getMapConfig();
      emit(MapLoaded(style));
    } catch (e) {
      emit(MapError('Failed to load style: $e'));
    }
  }

  Future<void> locateMe() async {
    try {
      final location = await getCurrentLocation();
      final currentState = state;
      if (currentState is MapLoaded) {
        emit(MapLoaded(currentState.style, currentLocation: location));
      }
    } catch (e) {
      emit(MapError('Failed to get location: $e'));
    }
  }
}
