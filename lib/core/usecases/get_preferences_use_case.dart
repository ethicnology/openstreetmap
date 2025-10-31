import 'package:furtive/core/entities/preferences_entity.dart';
import 'package:furtive/core/repositories/preferences_repository.dart';

class GetPreferencesUseCase {
  final preferencesRepository = PreferencesRepository();

  GetPreferencesUseCase();

  Future<PreferencesEntity> call() async {
    return await preferencesRepository.fetch();
  }
}
