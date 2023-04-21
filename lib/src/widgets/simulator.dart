import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';
import 'package:flutter_simulator/src/widgets/core/resizable_gesture_detector.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:window_manager/window_manager.dart';

/// A widget that builds the simulator.
///
/// This builds the app and the device frame.
class SimulatorWidget extends StatefulWidget {
  const SimulatorWidget({
    super.key,
    required this.params,
    required this.appChild,
  });

  final SimulatorParams params;
  final Widget appChild;

  @override
  State<SimulatorWidget> createState() => _SimulatorWidgetState();
}

class _SimulatorWidgetState extends State<SimulatorWidget>
    with WidgetsBindingObserver {
  /// The [MediaQueryData] of the surrounding platform.
  ///
  /// This is transformed in [_buildAppWidget()] to provide one suitable for the
  /// simulated app.
  late MediaQueryData _mediaQueryData;

  @override
  void initState() {
    super.initState();

    _mediaQueryData = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    _mediaQueryData = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  SimulatorParams get params => widget.params;
  DeviceInfo get deviceInfo => params.deviceInfo;
  DeviceOrientation get deviceScreenOrientation =>
      params.deviceScreenOrientation;

  Brightness get simulatorBrightness => params.simulatorBrightness;

  /// Builds the app widget.
  ///
  /// This is wrapped in a [RepaintBoundary] to prevent the simulator stuff
  /// from being repainted when the stuff in the app is repainted.
  ///
  /// This also wraps the app with appropriate [MediaQuery] data, as well as
  /// sizing it to the size of the device.
  Widget _buildAppWidget(BuildContext context) {
    final size = params.screenSize;

    final mediaQueryData = _mediaQueryData.copyWith(
      size: size,
      viewPadding: params.viewPadding,
      padding: params.viewPadding,
      platformBrightness: simulatorBrightness,
    );

    return SizedBox.fromSize(
      size: size,
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        hitTestBehavior: HitTestBehavior.opaque,
        child: MediaQuery(
          data: mediaQueryData,
          child: RepaintBoundary(
            key: _deviceContentAwareScreenForegroundKey,
            child: RepaintBoundary(
              key: SimulatorWidgetsBinding.instance.deviceScreenKey,
              child: widget.appChild,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: SimulatorWidgetsBinding.instance.deviceFrameKey,
      child: FittedBox(
        fit: BoxFit.fill,
        child: ResizableGestureDetectorWidget(
          child: _SimulatorRenderObjectWidget(
            key: const Key('simulator-render-object'),
            params: widget.params,
            child: _buildAppWidget(context),
          ),
        ),
      ),
    );
  }
}

/// Key that is inserted above the screen to paint content-aware foreground
/// items such as the home indicator on iPhone X.
final _deviceContentAwareScreenForegroundKey = GlobalKey();

class _SimulatorRenderObjectWidget extends SingleChildRenderObjectWidget {
  const _SimulatorRenderObjectWidget({
    super.key,
    required this.params,
    required super.child,
  });

  final SimulatorParams params;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _SimulatorRenderObject(params);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _SimulatorRenderObject renderObject,
  ) {
    renderObject.params = params;
  }
}

class _SimulatorRenderObject extends RenderBox with RenderObjectWithChildMixin {
  _SimulatorRenderObject(this._params);

  SimulatorParams _params;
  set params(SimulatorParams value) {
    if (_params == value) {
      return;
    }

    _params = value;
    markNeedsLayout();
  }

  late Size _screenSize;
  late Offset _screenOffset;
  late Rect _frameRect;

  late Size _frameSize;
  late Offset _frameOffset;
  late Rect _screenRect;

  final _screenForegroundLayerHandle = LayerHandle<PictureLayer>();

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    SimulatorWidgetsBinding.instance.renderView.onBeforeBuildSceneNotifier
        .addListener(_paintAndSetScreenForegroundLayerPicture);

    SimulatorWidgetsBinding.instance.renderView.onAfterBuildSceneNotifier
        .addListener(_tryResetScreenForegroundLayer);
  }

  @override
  void dispose() {
    _setScreenForegroundLayerHandle(null);
    _transformLayerHandle.layer = null;
    _screenTransformLayerHandle.layer = null;
    _customLayerHandle.layer = null;

    SimulatorWidgetsBinding.instance.renderView.onBeforeBuildSceneNotifier
        .removeListener(_paintAndSetScreenForegroundLayerPicture);

    SimulatorWidgetsBinding.instance.renderView.onAfterBuildSceneNotifier
        .removeListener(_tryResetScreenForegroundLayer);

    super.dispose();
  }

  @override
  void performLayout() {
    final frame = _params.deviceFrame;

    _screenSize = _params.deviceInfo.screenSize;

    _frameSize = _params.deviceInfo.deviceFrame.transformSize(
      _screenSize,
      _params,
    );

    final rect = Offset.zero & Size.square(_frameSize.longestSide);

    _frameOffset = Offset.zero;

    _frameRect = Rect.fromCenter(
      center: rect.center,
      width: _frameSize.width,
      height: _frameSize.height,
    );

    _screenOffset = _frameOffset +
        frame.transformScreenOffset(
          _frameSize,
          _screenSize,
          _params,
        );

    _screenRect = _screenOffset & _screenSize;

    child!.parentData = BoxParentData()..offset = _screenOffset;
    child!.layout(
      BoxConstraints.tight(
        _params.deviceScreenOrientation.transformSize(_screenSize),
      ),
    );

    size = _params.rawDeviceScreenOrientation.transformSize(_frameSize);
    _shouldResetScreenForegroundLayer = true;

    // windowManager.setSize(size);
  }

  RenderObject? get _screenForegroundRenderObject =>
      _deviceContentAwareScreenForegroundKey.currentContext?.findRenderObject();

  var _shouldResetScreenForegroundLayer = false;
  void _tryResetScreenForegroundLayer() {
    if (_screenForegroundRenderObject?.layer == null) return;

    if (_shouldResetScreenForegroundLayer) {
      _setScreenForegroundLayerHandle(PictureLayer(_screenRect));
      _shouldResetScreenForegroundLayer = false;
    }
  }

  void _setScreenForegroundLayerHandle(PictureLayer? layer) {
    _screenForegroundLayerHandle.layer = layer;

    if (layer != null) {
      _screenForegroundRenderObject?.layer?.append(
        _screenForegroundLayerHandle.layer!,
      );
    }
  }

  void _paintAndSetScreenForegroundLayerPicture() {
    final picture = _paintContentAwareDeviceScreenForeground();
    _screenForegroundLayerHandle.layer?.picture = picture;
  }

  ui.Picture _paintContentAwareDeviceScreenForeground() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    _params.deviceFrame.paintContentAwareDeviceScreenForeground?.call(
      canvas,
      _params.deviceScreenOrientation.transformSize(_screenSize),
      _params,
      SimulatorWidgetsBinding.instance.screenByteData,
    );

    return recorder.endRecording();
  }

  final _transformLayerHandle = LayerHandle<TransformLayer>();
  final _screenTransformLayerHandle = LayerHandle<TransformLayer>();
  final _customLayerHandle = LayerHandle<ContainerLayer>();

  late Matrix4 _transformationMatrix;
  late Matrix4 _screenTransformationMatrix;
  late Matrix4 _hitTestTransformationMatrix;
  late Matrix4 _hitTestScreenTransformationMatrix;

  Matrix4 _computeTransformationMatrix() {
    final offset = size.center(Offset.zero) - _screenSize.center(_screenOffset);

    return Matrix4Transform()
        .rotate(_params.deviceOrientationRad, origin: size.center(Offset.zero))
        .translateOffset(offset)
        .matrix4;
  }

  Matrix4 _computeScreenTransformatrionMatrix() {
    switch (_params.deviceScreenOrientation) {
      case DeviceOrientation.portraitUp:
        return Matrix4.identity();

      case DeviceOrientation.landscapeRight:
        return Matrix4Transform()
            .translate(y: _screenSize.height)
            .rotate(-pi / 2)
            .matrix4;

      case DeviceOrientation.portraitDown:
        return Matrix4Transform()
            .translate(x: _screenSize.width, y: _screenSize.height)
            .rotate(pi)
            .matrix4;

      case DeviceOrientation.landscapeLeft:
        return Matrix4Transform()
            .translate(x: _screenSize.width)
            .rotate(pi / 2)
            .matrix4;
      default:
        return Matrix4.identity();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _transformationMatrix = _computeTransformationMatrix();

    _hitTestTransformationMatrix = Matrix4.identity()
      ..copyInverse(_transformationMatrix);

    _screenTransformationMatrix = _computeScreenTransformatrionMatrix();
    _hitTestScreenTransformationMatrix = Matrix4.identity()
      ..copyInverse(_screenTransformationMatrix);

    _transformLayerHandle.layer = context.pushTransform(
      true,
      offset,
      _transformationMatrix,
      _paintSimulator,
      oldLayer: _transformLayerHandle.layer,
    );

    // context.canvas.drawRect(_frameRect, Paint()..color = Colors.green);
    // context.canvas.drawRect(_screenRect, Paint()..color = Colors.red);
  }

  void _paintSimulator(PaintingContext context, Offset offset) {
    final frame = _params.deviceFrame;

    // Paint order:
    // 1. Physical device frame
    // 2. Device screen
    // 3. Screen foreground (i.e. status bar)
    // 4. Content-aware screen foreground (i.e. home indicator)
    // 5. Foreground physical device frame (i.e. notch)

    frame.paintPhysicalDeviceFrame?.call(
      context,
      offset + _frameOffset,
      _frameSize,
      _screenRect,
      _params,
    );

    _screenTransformLayerHandle.layer = context.pushTransform(
      true,
      offset + _screenOffset,
      _screenTransformationMatrix,
      (context, offset) {
        _customLayerHandle.layer = frame.paintDeviceScreen(
          context,
          offset,
          _screenOffset &
              _params.deviceScreenOrientation.transformSize(_screenSize),
          _params,
          child!,
          _customLayerHandle.layer,
        );
      },
      oldLayer: _screenTransformLayerHandle.layer,
    );

    frame.paintDeviceScreenForeground?.call(
      context,
      offset + _screenOffset,
      _screenRect,
      _params,
    );

    frame.paintForegroundPhysicalDeviceFrame?.call(
      context,
      _frameOffset,
      _frameSize,
      _screenRect,
      _params,
    );
  }

  Offset _transformOffsetForHitTesting(Offset offset) {
    switch (_params.deviceScreenOrientation) {
      case DeviceOrientation.portraitUp:
        return offset;

      case DeviceOrientation.landscapeRight:
        return Offset(-offset.dy, offset.dx);

      case DeviceOrientation.portraitDown:
        return -offset;

      case DeviceOrientation.landscapeLeft:
        return Offset(offset.dy, -offset.dx);
    }
  }

  RRect get _clippedScreenRect {
    if (_customLayerHandle.layer is ClipRRectLayer) {
      return (_customLayerHandle.layer as ClipRRectLayer).clipRRect!;
    } else {
      return RRect.fromRectAndRadius(_screenRect, Radius.zero);
    }
  }

  @override
  bool hitTestSelf(Offset position) {
    final rect = MatrixUtils.transformRect(_transformationMatrix, _frameRect);
    final rrect = RRect.fromRectAndRadius(
      rect,
      _params.deviceFrame.frameRadius,
    );

    return rrect.contains(position) && !_clippedScreenRect.contains(position);
  }

  @override
  bool hitTestChildren(
    BoxHitTestResult result, {
    required Offset position,
  }) {
    return result.addWithRawTransform(
      transform:
          _hitTestScreenTransformationMatrix * _hitTestTransformationMatrix,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        final transformedPosition =
            position - _transformOffsetForHitTesting(_screenOffset);

        if (_clippedScreenRect.contains(position)) {
          return (child as RenderBox).hitTest(
            result,
            position: transformedPosition,
          );
        }

        return false;
      },
    );
  }
}
