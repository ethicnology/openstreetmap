import 'package:furtive/features/permissions/domain/repositories/permission_repository.dart';

class OpenAppSettingsUseCase {
  final _repository = PermissionRepository();

  Future<bool> call() => _repository.openAppSettings();
}
