import 'package:permission_handler/permission_handler.dart';
import 'package:openstreetmap/features/permissions/data/models/permission_model.dart';

class PermissionDataSource {
  Future<List<PermissionModel>> getPermissions() async {
    final locationWhenInUseStatus = await Permission.locationWhenInUse.status;
    final locationAlwaysStatus = await Permission.locationAlways.status;

    final permissions = [
      PermissionModel(
        name: 'Location When In Use',
        description:
            'Required to track your position and display it on the map',
        permission: Permission.locationWhenInUse,
        status: locationWhenInUseStatus,
      ),
      PermissionModel(
        name: 'Location Always',
        description:
            'Optional: Allows tracking your activities while your lock phone.',
        permission: Permission.locationAlways,
        status: locationAlwaysStatus,
        isOptional: true,
      ),
    ];

    return permissions;
  }

  Future<PermissionStatus> checkPermission(Permission permission) async {
    return await permission.status;
  }

  Future<PermissionStatus> requestPermission(Permission permission) async {
    return await permission.request();
  }

  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
