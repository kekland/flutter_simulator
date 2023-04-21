import 'package:flutter_simulator/src/imports.dart';
import 'iphone_14.dart' as iphone_14_library;

class AppleDevices {
  static DeviceInfo get iPhone14 => iphone_14_library.iPhone14;

  static List<DeviceInfo> get devices => [
        iPhone14,
      ];
}
