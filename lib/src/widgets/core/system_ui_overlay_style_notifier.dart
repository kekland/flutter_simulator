import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simulator/src/imports.dart';

/// Listens to [SystemChrome.setSystemUIOverlayStyle] calls and notifies 
/// listeners if the value changes.
class SystemUiOverlayStyleNotifier extends ChangeNotifier {
  SystemUiOverlayStyleNotifier() {
    init();
  }

  SystemUiOverlayStyle? value;

  /// Initialies the [SystemChannels.platform] mock method call handler.
  void init() {
    SimulatorWidgetsBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, _onMethodCall);
  }

  @override
  void dispose() {
    SimulatorWidgetsBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);

    super.dispose();
  }

  Future<Object?>? _onMethodCall(MethodCall message) {
    if (message.method == 'SystemChrome.setSystemUIOverlayStyle') {
      final data = message.arguments as Map<String, dynamic>;
      value = systemUiOverlayStyleFromJson(data);

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
