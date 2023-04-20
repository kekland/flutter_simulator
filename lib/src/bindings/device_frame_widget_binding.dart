import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/flutter_simulator.dart';
import 'dart:ui' as ui;
import 'package:flutter_simulator/src/bindings/interceptable_binary_messenger.dart';
import 'package:flutter_simulator/src/bindings/interceptable_renderer_binding.dart';
import 'package:flutter_simulator/src/flutter/widget_inspector.dart';

class FlutterSimulatorWidgetBinding extends WidgetsFlutterBinding
    with
        InterceptableDefaultBinaryMessengerBinding,
        InterceptableRendererBinding {
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
  final screenDependentPainterRepaintBoundaryKey = GlobalKey();

  var shouldReportFrame = false;

  DeviceInfo? _currentDevice;
  DeviceRotation? _currentRotation;
  DeviceScreenDependentPainter? _screenDependentPainter;

  @override
  InterceptableRenderView get renderView =>
      super.renderView as InterceptableRenderView;

  set currentDevice(DeviceInfo? device) {
    _currentDevice = device;
    _screenDependentPainter =
        _currentDevice?.frame?.screenDependentPainter?.call();

    if (device == null) {
      return;
    }
  }

  set currentRotation(DeviceRotation? rotation) {
    _currentRotation = rotation;
    renderView.markNeedsPaint();
  }

  ui.Picture? paintScreenDependentPainter(ByteData? byteData) {
    final screenRenderObject = deviceScreenKey.currentContext!
        .findRenderObject()! as RenderRepaintBoundary;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // print('paint!');
    _screenDependentPainter?.paint(
      canvas,
      screenRenderObject.size,
      screenRenderObject.size,
      _currentRotation ?? DeviceRotation.deg0,
      byteData,
    );

    return recorder.endRecording();
  }

  var didAttachScreenDependentPictureLayer = false;

  @override
  void drawFrame() {
    if (renderView.screenDependentPictureLayer?.parent == null) {
      final screenRenderObject = screenDependentPainterRepaintBoundaryKey
          .currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (screenRenderObject?.layer != null) {
        screenRenderObject!.layer!
            .append(renderView.screenDependentPictureLayer!);
      }
    }

    super.drawFrame();
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
