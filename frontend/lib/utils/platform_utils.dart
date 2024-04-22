import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class PlatformUtils {
  const PlatformUtils._();

  static Future<String?> getPlatformDescription() async {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    if (kIsWeb) {
      Map<String, dynamic> webBrowserInfo = (await plugin.deviceInfo).data;
      BrowserName browserName = webBrowserInfo['browserName'] ?? BrowserName.unknown;
      return browserName.name;
    } else {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await plugin.androidInfo;
        return androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await plugin.iosInfo;
        return iosInfo.utsname.machine;
      }
    }
    return null;
  }
}
