import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class PlatformUtils {
  const PlatformUtils._();

  static Future<String> getPlatformName() async {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    if (kIsWeb) {
      BrowserName browserName = (await plugin.deviceInfo).data['browserName'] ?? BrowserName.unknown;
      return browserName.name;
    } else {
      if (Platform.isAndroid) {
        return (await plugin.androidInfo).model;
      } else if (Platform.isIOS) {
        return (await plugin.iosInfo).name;
      }
    }
    return 'Unknown';
  }

  static Future<String?> getPlatformDescription() async {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    if (kIsWeb) {
      return (await plugin.deviceInfo).data['userAgent'];
    } else {
      if (Platform.isAndroid) {
        return (await plugin.androidInfo).model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await plugin.iosInfo;
        return '${iosInfo.utsname.machine}, iOS ${iosInfo.systemVersion}';
      }
    }
    return null;
  }
}
