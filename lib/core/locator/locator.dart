import 'package:get_it/get_it.dart';
import 'package:openstreetmap/features/map/data/datasources/location_remote_data_source.dart';
import 'package:openstreetmap/features/map/data/datasources/map_remote_data_source.dart';
import 'package:openstreetmap/features/map/data/datasources/trace_remote_data_source.dart';
import 'package:openstreetmap/features/map/data/datasources/trace_local_data_source.dart';
import 'package:openstreetmap/features/map/domain/repositories/trace_repository.dart';
import 'package:openstreetmap/features/map/domain/repositories/location_repository.dart';
import 'package:openstreetmap/features/map/domain/repositories/map_repository.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_current_location_use_case.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_map_tile_url_use_case.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_traces_use_case.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_cubit.dart';
import 'package:openstreetmap/core/database/local_database.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<LocalDatabase>(() => LocalDatabase());

  getIt.registerFactory<MapCubit>(
    () => MapCubit(
      getIt.get<GetMapConfigUseCase>(),
      getIt.get<GetCurrentLocationUseCase>(),
      getIt.get<GetTracesUseCase>(),
    ),
  );
  getIt.registerLazySingleton<GetMapConfigUseCase>(
    () => GetMapConfigUseCase(getIt.get<MapRepository>()),
  );
  getIt.registerLazySingleton<GetCurrentLocationUseCase>(
    () => GetCurrentLocationUseCase(getIt.get<LocationRepository>()),
  );
  getIt.registerLazySingleton<GetTracesUseCase>(
    () => GetTracesUseCase(getIt.get<TraceRepository>()),
  );
  getIt.registerLazySingleton<MapRepository>(
    () => MapRepository(getIt.get<MapRemoteDataSource>()),
  );
  getIt.registerLazySingleton<LocationRepository>(
    () => LocationRepository(getIt.get<LocationRemoteDataSource>()),
  );
  getIt.registerLazySingleton<TraceRepository>(
    () => TraceRepository(
      getIt.get<TraceRemoteDataSource>(),
      getIt.get<TraceLocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<MapRemoteDataSource>(() => MapRemoteDataSource());
  getIt.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSource(),
  );
  getIt.registerLazySingleton<TraceRemoteDataSource>(
    () => TraceRemoteDataSource(),
  );
  getIt.registerLazySingleton<TraceLocalDataSource>(
    () => TraceLocalDataSource(getIt.get<LocalDatabase>()),
  );
}
