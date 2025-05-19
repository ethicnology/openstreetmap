import 'package:get_it/get_it.dart';
import 'package:openstreetmap/features/map/data/datasources/location_remote_data_source.dart';
import 'package:openstreetmap/features/map/data/datasources/map_remote_data_source.dart';
import 'package:openstreetmap/features/map/data/datasources/gps_trace_remote_data_source.dart';
import 'package:openstreetmap/features/map/domain/repositories/location_repository.dart';
import 'package:openstreetmap/features/map/domain/repositories/map_repository.dart';
import 'package:openstreetmap/features/map/domain/repositories/gps_trace_repository.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_current_location_use_case.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_map_tile_url_use_case.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_public_gps_traces_use_case.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_cubit.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerFactory<MapCubit>(
    () => MapCubit(
      getIt.get<GetMapConfigUseCase>(),
      getIt.get<GetCurrentLocationUseCase>(),
      getIt.get<GetPublicGpsTracesUseCase>(),
    ),
  );
  getIt.registerLazySingleton<GetMapConfigUseCase>(
    () => GetMapConfigUseCase(getIt.get<MapRepository>()),
  );
  getIt.registerLazySingleton<GetCurrentLocationUseCase>(
    () => GetCurrentLocationUseCase(getIt.get<LocationRepository>()),
  );
  getIt.registerLazySingleton<GetPublicGpsTracesUseCase>(
    () => GetPublicGpsTracesUseCase(getIt.get<GpsTraceRepository>()),
  );
  getIt.registerLazySingleton<MapRepository>(
    () => MapRepository(getIt.get<MapRemoteDataSource>()),
  );
  getIt.registerLazySingleton<LocationRepository>(
    () => LocationRepository(getIt.get<LocationRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GpsTraceRepository>(
    () => GpsTraceRepository(getIt.get<GpsTraceRemoteDataSource>()),
  );
  getIt.registerLazySingleton<MapRemoteDataSource>(() => MapRemoteDataSource());
  getIt.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSource(),
  );
  getIt.registerLazySingleton<GpsTraceRemoteDataSource>(
    () => GpsTraceRemoteDataSource(),
  );
}
