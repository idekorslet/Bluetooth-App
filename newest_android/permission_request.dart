import 'dart:developer';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequest {

  static Future<bool> isPermissionAllowed() async {
    bool result = false;

    log('[permission_request] checking permission');

    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    // print('status:');
    // print(statuses);
    final scanPermissionStatus = statuses[Permission.bluetoothScan]!;
    final bluetoothConnectPermissionStatus = statuses[Permission.bluetoothConnect]!;

    log('[permission_request] scanPermissionStatus: $scanPermissionStatus');
    log('[permission_request] bluetoothConnectPermissionStatus: $bluetoothConnectPermissionStatus');

    if (scanPermissionStatus.isGranted && bluetoothConnectPermissionStatus.isGranted) {
      result = true;
    }
    else if (scanPermissionStatus.isDenied || bluetoothConnectPermissionStatus.isDenied) {
      log('[permission_request] permission denied');
    }
    if (scanPermissionStatus.isPermanentlyDenied && bluetoothConnectPermissionStatus.isPermanentlyDenied) {
      log('[permission_request] permission permanentlyDenied');
    }

    log('[permission_request] isPermissionAllowed: $result');
    return result;
  }

  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
