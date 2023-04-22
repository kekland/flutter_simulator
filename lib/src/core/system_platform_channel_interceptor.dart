import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simulator/src/imports.dart';

/// Listens to [SystemChrome.setSystemUIOverlayStyle] calls and notifies
/// listeners if the value changes.
class SystemPlatformChannelInterceptor extends ChangeNotifier {
  SystemPlatformChannelInterceptor();

  static SystemPlatformChannelInterceptor ensureInitialized() {
    if (SystemPlatformChannelInterceptor._instance != null) {
      return SystemPlatformChannelInterceptor._instance!;
    }

    final instance = SystemPlatformChannelInterceptor();
    SystemPlatformChannelInterceptor._instance = instance;

    SimulatorWidgetsBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform,
      instance._onMethodCall,
    );

    return instance;
  }

  static SystemPlatformChannelInterceptor get instance => _instance!;
  static SystemPlatformChannelInterceptor? _instance;

  SystemUiOverlayStyle? systemUiOverlayStyle;
  ApplicationSwitcherDescription? applicationSwitcherDescription;
  List<DeviceOrientation>? appPreferredOrientations;

  @override
  void dispose() {
    SimulatorWidgetsBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);

    _instance = null;

    super.dispose();
  }

  Future<Object?>? _onMethodCall(MethodCall message) {
    if (message.method == 'SystemChrome.setSystemUIOverlayStyle') {
      final data = message.arguments as Map<String, dynamic>;
      systemUiOverlayStyle = systemUiOverlayStyleFromJson(data);

      notifyListeners();
    } else if (message.method ==
        'SystemChrome.setApplicationSwitcherDescription') {
      if (message.arguments['label'] == 'simulator-app') {
        return null;
      }

      applicationSwitcherDescription = ApplicationSwitcherDescription(
        label: message.arguments['label'],
        primaryColor: message.arguments['primaryColor'],
      );

      notifyListeners();
    } else if (message.method == 'SystemChrome.setPreferredOrientations') {
      appPreferredOrientations = (message.arguments as List<dynamic>)
          .map((e) => deviceOrientationFromString(e))
          .toList();

      notifyListeners();
    }

    return null;
  }
}

/// Parses [SystemUiOverlayStyle] from JSON.
SystemUiOverlayStyle systemUiOverlayStyleFromJson(Map<String, dynamic> json) {
  Brightness? decodeBrightness(String? value) {
    switch (value) {
      case 'Brightness.dark':
        return Brightness.dark;
      case 'Brightness.light':
        return Brightness.light;
      default:
        return null;
    }
  }

  Color? decodeColor(int? value) {
    if (value == null) {
      return null;
    }

    return Color(value);
  }

  return SystemUiOverlayStyle(
    systemNavigationBarColor: decodeColor(json['systemNavigationBarColor']),
    systemNavigationBarDividerColor:
        decodeColor(json['systemNavigationBarDividerColor']),
    systemNavigationBarIconBrightness:
        decodeBrightness(json['systemNavigationBarIconBrightness']),
    systemNavigationBarContrastEnforced:
        json['systemNavigationBarContrastEnforced'],
    systemStatusBarContrastEnforced: json['systemStatusBarContrastEnforced'],
    statusBarColor: decodeColor(json['statusBarColor']),
    statusBarBrightness: decodeBrightness(json['statusBarBrightness']),
    statusBarIconBrightness: decodeBrightness(json['statusBarIconBrightness']),
  );
}

/// Parses [DeviceOrientation] from a string.
DeviceOrientation deviceOrientationFromString(String value) {
  switch (value) {
    case 'DeviceOrientation.portraitUp':
      return DeviceOrientation.portraitUp;
    case 'DeviceOrientation.portraitDown':
      return DeviceOrientation.portraitDown;
    case 'DeviceOrientation.landscapeLeft':
      return DeviceOrientation.landscapeLeft;
    case 'DeviceOrientation.landscapeRight':
      return DeviceOrientation.landscapeRight;
    default:
      throw Exception('Unknown device orientation: $value');
  }
}

class SystemApplicationSwitcherDescription {
  const SystemApplicationSwitcherDescription({
    required this.label,
    required this.primaryColor,
  });

  final String label;
  final Color primaryColor;
}
