import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simulator/flutter_simulator.dart';
import 'dart:ui' as ui;

mixin InterceptableRendererBinding on WidgetsFlutterBinding {
  @override
  void initRenderView() {
    renderView = InterceptableRenderView(
      configuration: createViewConfiguration(),
      window: window,
    );

    renderView.prepareInitialFrame();
  }
}

class InterceptableRenderView extends RenderView {
  InterceptableRenderView({
    required super.configuration,
    required super.window,
  });

  ByteData? _screenByteData;

  /// When a frame from the screen has been captured.
  ///
  /// Use [onFrameCaptured] to set this value.
  void Function(ByteData?)? _onFrameCaptured;

  @override
  void scheduleInitialPaint(ContainerLayer rootLayer) {
    super.scheduleInitialPaint(rootLayer);

    screenDependentPictureLayer = PictureLayer(
      Offset.zero & ui.window.physicalSize,
    );

    _screenDependentPictureLayerHandle = LayerHandle(
      screenDependentPictureLayer,
    );
  }

  // ignore: unused_field
  LayerHandle? _screenDependentPictureLayerHandle;
  PictureLayer? screenDependentPictureLayer;

  set onFrameCaptured(void Function(ByteData?)? onFrameCaptured) {
    _onFrameCaptured = onFrameCaptured;
  }

  @override
  void compositeFrame() {
    if (!kReleaseMode) {
      Timeline.startSync('COMPOSITING');
    }

    try {
      if (screenDependentPictureLayer != null) {
        final screenDependentPicture =
            FlutterSimulatorWidgetBinding.instance!.paintScreenDependentPainter(
          _screenByteData,
        );

        screenDependentPictureLayer!.picture = screenDependentPicture;
      }

      final ui.SceneBuilder builder = ui.SceneBuilder();
      final ui.Scene scene = layer!.buildScene(builder);

      if (automaticSystemUiAdjustment) {
        _updateSystemChrome();
      }

      final deviceScreenKey =
          FlutterSimulatorWidgetBinding.instance!.deviceScreenKey;

      final screenRenderObject = deviceScreenKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;

      final image = screenRenderObject.toImageSync();
      image.toByteData().then((v) {
        _screenByteData = v;
        image.dispose();
      });

      ui.window.render(scene);
      scene.dispose();
      assert(() {
        if (debugRepaintRainbowEnabled || debugRepaintTextRainbowEnabled) {
          debugCurrentRepaintColor = debugCurrentRepaintColor
              .withHue((debugCurrentRepaintColor.hue + 2.0) % 360.0);
        }
        return true;
      }());
    } finally {
      if (!kReleaseMode) {
        Timeline.finishSync();
      }
    }
  }

  void _updateSystemChrome() {
    final deviceScreenKey =
        FlutterSimulatorWidgetBinding.instance!.deviceScreenKey;

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
