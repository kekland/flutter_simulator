import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/bindings/interceptable_binary_messenger.dart';

class FlutterSimulatorWidgetBinding extends WidgetsFlutterBinding
    with InterceptableDefaultBinaryMessengerBinding {
  static WidgetsBinding ensureInitialized() {
    if (instance != null) {
      return instance!;
    }

    instance = FlutterSimulatorWidgetBinding();
    return instance!;
  }

  static FlutterSimulatorWidgetBinding? instance;

  /// The widget that contains the device screen must be keyed with this key.
  ///
  /// The layer used to compute the system chrome from annotated regions is
  /// obtained from this key.
  final deviceScreenKey = GlobalKey();

  @override
  void drawFrame() {
    super.drawFrame();

    if (sendFramesToEngine) {
      _updateSystemChrome();
    }
  }

  /// Copy of [WidgetsFlutterBinding._updateSystemChrome]. Only change is that
  /// the layer is obtained from [_deviceScreenKey].
  void _updateSystemChrome() {
    final deviceRenderObject =
        deviceScreenKey.currentContext!.findRenderObject()!;

    final mediaQuery = MediaQuery.of(deviceScreenKey.currentContext!);

    // ignore: invalid_use_of_protected_member
    final layer = deviceRenderObject.layer!;
    // Take overlay style from the place where a system status bar and system
    // navigation bar are placed to update system style overlay.
    // The center of the system navigation bar and the center of the status bar
    // are used to get SystemUiOverlayStyle's to update system overlay appearance.
    //
    //         Horizontal center of the screen
    //                 V
    //    ++++++++++++++++++++++++++
    //    |                        |
    //    |    System status bar   |  <- Vertical center of the status bar
    //    |                        |
    //    ++++++++++++++++++++++++++
    //    |                        |
    //    |        Content         |
    //    ~                        ~
    //    |                        |
    //    ++++++++++++++++++++++++++
    //    |                        |
    //    |  System navigation bar | <- Vertical center of the navigation bar
    //    |                        |
    //    ++++++++++++++++++++++++++ <- bounds.bottom
    final Rect bounds = deviceRenderObject.paintBounds;
    // Center of the status bar
    final Offset top = Offset(
      // Horizontal center of the screen
      bounds.center.dx,
      // The vertical center of the system status bar. The system status bar
      // height is kept as top window padding.
      mediaQuery.padding.top / 2.0,
    );
    // Center of the navigation bar
    final Offset bottom = Offset(
      // Horizontal center of the screen
      bounds.center.dx,
      // Vertical center of the system navigation bar. The system navigation bar
      // height is kept as bottom window padding. The "1" needs to be subtracted
      // from the bottom because available pixels are in (0..bottom) range.
      // I.e. for a device with 1920 height, bound.bottom is 1920, but the most
      // bottom drawn pixel is at 1919 position.
      bounds.bottom - 1.0 - mediaQuery.padding.bottom / 2.0,
    );

    final layerOffset = (layer as OffsetLayer).offset;

    final SystemUiOverlayStyle? upperOverlayStyle =
        layer.find<SystemUiOverlayStyle>(top + layerOffset);
    // Only android has a customizable system navigation bar.
    SystemUiOverlayStyle? lowerOverlayStyle;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        lowerOverlayStyle = layer.find<SystemUiOverlayStyle>(
          bottom + layerOffset,
        );
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        break;
    }
    // If there are no overlay style in the UI don't bother updating.
    if (upperOverlayStyle == null && lowerOverlayStyle == null) {
      return;
    }

    // If both are not null, the upper provides the status bar properties and the lower provides
    // the system navigation bar properties. This is done for advanced use cases where a widget
    // on the top (for instance an app bar) will create an annotated region to set the status bar
    // style and another widget on the bottom will create an annotated region to set the system
    // navigation bar style.
    if (upperOverlayStyle != null && lowerOverlayStyle != null) {
      final SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
        statusBarBrightness: upperOverlayStyle.statusBarBrightness,
        statusBarIconBrightness: upperOverlayStyle.statusBarIconBrightness,
        statusBarColor: upperOverlayStyle.statusBarColor,
        systemStatusBarContrastEnforced:
            upperOverlayStyle.systemStatusBarContrastEnforced,
        systemNavigationBarColor: lowerOverlayStyle.systemNavigationBarColor,
        systemNavigationBarDividerColor:
            lowerOverlayStyle.systemNavigationBarDividerColor,
        systemNavigationBarIconBrightness:
            lowerOverlayStyle.systemNavigationBarIconBrightness,
        systemNavigationBarContrastEnforced:
            lowerOverlayStyle.systemNavigationBarContrastEnforced,
      );
      SystemChrome.setSystemUIOverlayStyle(overlayStyle);
      return;
    }
    // If only one of the upper or the lower overlay style is not null, it provides all properties.
    // This is done for developer convenience as it allows setting both status bar style and
    // navigation bar style using only one annotated region layer (for instance the one
    // automatically created by an [AppBar]).
    final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final SystemUiOverlayStyle definedOverlayStyle =
        (upperOverlayStyle ?? lowerOverlayStyle)!;
    final SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
      statusBarBrightness: definedOverlayStyle.statusBarBrightness,
      statusBarIconBrightness: definedOverlayStyle.statusBarIconBrightness,
      statusBarColor: definedOverlayStyle.statusBarColor,
      systemStatusBarContrastEnforced:
          definedOverlayStyle.systemStatusBarContrastEnforced,
      systemNavigationBarColor:
          isAndroid ? definedOverlayStyle.systemNavigationBarColor : null,
      systemNavigationBarDividerColor: isAndroid
          ? definedOverlayStyle.systemNavigationBarDividerColor
          : null,
      systemNavigationBarIconBrightness: isAndroid
          ? definedOverlayStyle.systemNavigationBarIconBrightness
          : null,
      systemNavigationBarContrastEnforced: isAndroid
          ? definedOverlayStyle.systemNavigationBarContrastEnforced
          : null,
    );
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
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
