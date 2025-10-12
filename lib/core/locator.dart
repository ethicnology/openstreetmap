import 'package:get_it/get_it.dart';
import 'package:openstreetmap/features/activities/bloc/activities_bloc.dart';
import 'package:openstreetmap/core/data/datasources/location_remote_data_source.dart';
import 'package:openstreetmap/core/data/datasources/map_remote_data_source.dart';
import 'package:openstreetmap/core/data/datasources/trace_remote_data_source.dart';
import 'package:openstreetmap/core/data/datasources/trace_local_data_source.dart';
import 'package:openstreetmap/core/repositories/trace_repository.dart';
import 'package:openstreetmap/core/repositories/location_repository.dart';
import 'package:openstreetmap/core/repositories/map_repository.dart';
import 'package:openstreetmap/core/usecases/get_user_location_use_case.dart';
import 'package:openstreetmap/core/usecases/get_map_tile_url_use_case.dart';
import 'package:openstreetmap/core/usecases/get_traces_use_case.dart';
import 'package:openstreetmap/features/map/bloc/map_bloc.dart';
import 'package:openstreetmap/features/permissions/presentation/bloc/permissions_bloc.dart';
import 'package:openstreetmap/core/database/local_database.dart';

final getIt = GetIt.instance;

class Locator {
  static void setup() {
    getIt.registerLazySingleton<LocalDatabase>(() => LocalDatabase());

    getIt.registerFactory<MapBloc>(() => MapBloc());
    getIt.registerFactory<ActivitiesBloc>(() => ActivitiesBloc());

    getIt.registerFactory<PermissionsBloc>(() => PermissionsBloc());
    getIt.registerLazySingleton<GetMapConfigUseCase>(
      () => GetMapConfigUseCase(),
    );
    getIt.registerLazySingleton<GetUserLocationUseCase>(
      () => GetUserLocationUseCase(),
    );
    getIt.registerLazySingleton<GetTracesUseCase>(() => GetTracesUseCase());
    getIt.registerLazySingleton<MapRepository>(() => MapRepository());
    getIt.registerLazySingleton<LocationRepository>(() => LocationRepository());
    getIt.registerLazySingleton<TraceRepository>(() => TraceRepository());
    getIt.registerLazySingleton<MapRemoteDataSource>(
      () => MapRemoteDataSource(),
    );
    getIt.registerLazySingleton<LocationRemoteDataSource>(
      () => LocationRemoteDataSource(),
    );
    getIt.registerLazySingleton<TraceRemoteDataSource>(
      () => TraceRemoteDataSource(),
    );
    getIt.registerLazySingleton<TraceLocalDataSource>(
      () => TraceLocalDataSource(),
    );
  }
}
