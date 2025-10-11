import 'package:permission_handler/permission_handler.dart';

class PermissionsEvent {
  const PermissionsEvent();
}

class LoadPermissions extends PermissionsEvent {
  const LoadPermissions();
}

class RequestPermission extends PermissionsEvent {
  final Permission permission;

  const RequestPermission(this.permission);
}

class CheckAllPermissions extends PermissionsEvent {
  const CheckAllPermissions();
}
