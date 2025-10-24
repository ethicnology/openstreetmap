import 'package:openstreetmap/core/entities/preferences_entity.dart';
import 'package:openstreetmap/core/repositories/preferences_repository.dart';

class UpdatePreferencesUseCase {
  final preferencesRepository = PreferencesRepository();

  UpdatePreferencesUseCase();

  Future<void> call(PreferencesEntity preferences) async {
    await preferencesRepository.store(preferences);
  }
}

