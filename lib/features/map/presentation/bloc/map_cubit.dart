import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_state.dart';
import '../../domain/usecases/get_map_tile_url.dart';

@injectable
class MapCubit extends Cubit<Object> {
  final GetMapConfig getMapConfig;

  MapCubit(this.getMapConfig) : super(MapInitial());

  Future<void> loadMap() async {
    emit(MapLoading());
    try {
      final style = await getMapConfig();
      emit(MapLoaded(style));
    } catch (e) {
      emit(MapError('Failed to load style: $e'));
    }
  }
}
