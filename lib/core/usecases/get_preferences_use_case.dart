import 'package:openstreetmap/core/entities/preferences_entity.dart';
import 'package:openstreetmap/core/repositories/preferences_repository.dart';

class GetPreferencesUseCase {
  final preferencesRepository = PreferencesRepository();

  GetPreferencesUseCase();

  Future<PreferencesEntity> call() async {
    return await preferencesRepository.fetch();
  }
}

