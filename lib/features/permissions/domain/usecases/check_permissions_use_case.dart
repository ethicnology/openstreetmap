import 'package:openstreetmap/features/permissions/domain/repositories/permission_repository.dart';

class CheckPermissionsUseCase {
  final _repository = PermissionRepository();

  Future<
    ({bool areRequiredPermissionsGranted, bool areOptionalPermissionsGranted})
  >
  call() async {
    final permissions = await _repository.getPermissions();

    final requiredPermissions = permissions.where((p) => !p.isOptional);
    final optionalPermissions = permissions.where((p) => p.isOptional);

    final areRequiredPermissionsGranted =
        requiredPermissions.isNotEmpty &&
        requiredPermissions.every((p) => p.isGranted);
    final areOptionalPermissionsGranted =
        optionalPermissions.isEmpty ||
        optionalPermissions.every((p) => p.isGranted);

    return (
      areRequiredPermissionsGranted: areRequiredPermissionsGranted,
      areOptionalPermissionsGranted: areOptionalPermissionsGranted,
    );
  }
}
