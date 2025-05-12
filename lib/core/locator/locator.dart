import 'package:get_it/get_it.dart';
import 'package:openstreetmap/features/map/data/datasources/map_remote_data_source.dart';
import 'package:openstreetmap/features/map/domain/repositories/map_repository.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_map_tile_url.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_cubit.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerFactory<MapCubit>(() => MapCubit(getIt.get<GetMapConfig>()));
  getIt.registerLazySingleton<GetMapConfig>(
    () => GetMapConfig(getIt.get<MapRepository>()),
  );
  getIt.registerLazySingleton<MapRepository>(
    () => MapRepository(getIt.get<MapRemoteDataSource>()),
  );
  getIt.registerLazySingleton<MapRemoteDataSource>(() => MapRemoteDataSource());
}
