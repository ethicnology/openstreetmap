import 'package:furtive/features/permissions/domain/entities/permission_entity.dart';
import 'package:furtive/features/permissions/domain/repositories/permission_repository.dart';

class GetPermissionsUseCase {
  final _repository = PermissionRepository();

  Future<List<PermissionEntity>> call() => _repository.getPermissions();
}
