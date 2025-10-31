import 'package:permission_handler/permission_handler.dart';
import 'package:furtive/features/permissions/domain/repositories/permission_repository.dart';

class RequestPermissionUseCase {
  final _repository = PermissionRepository();

  Future<PermissionStatus> call(Permission permission) =>
      _repository.requestPermission(permission);
}
