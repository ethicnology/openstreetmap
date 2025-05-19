import 'package:get_it/get_it.dart';
import 'package:openstreetmap/features/map/data/datasources/location_remote_data_source.dart';
import 'package:openstreetmap/features/map/data/datasources/map_remote_data_source.dart';
import 'package:openstreetmap/features/map/domain/repositories/location_repository.dart';
import 'package:openstreetmap/features/map/domain/repositories/map_repository.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_current_location.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_map_tile_url.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_cubit.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerFactory<MapCubit>(
    () => MapCubit(
      getIt.get<GetMapConfigUseCase>(),
      getIt.get<GetCurrentLocationUseCase>(),
    ),
  );
  getIt.registerLazySingleton<GetMapConfigUseCase>(
    () => GetMapConfigUseCase(getIt.get<MapRepository>()),
  );
  getIt.registerLazySingleton<GetCurrentLocationUseCase>(
    () => GetCurrentLocationUseCase(getIt.get<LocationRepository>()),
  );
  getIt.registerLazySingleton<MapRepository>(
    () => MapRepository(getIt.get<MapRemoteDataSource>()),
  );
  getIt.registerLazySingleton<LocationRepository>(
    () => LocationRepository(getIt.get<LocationRemoteDataSource>()),
  );
  getIt.registerLazySingleton<MapRemoteDataSource>(() => MapRemoteDataSource());
  getIt.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSource(),
  );
}
