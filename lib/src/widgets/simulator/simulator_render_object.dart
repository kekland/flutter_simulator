import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';
import 'dart:ui' as ui;

import 'package:matrix4_transform/matrix4_transform.dart';

/// Key that is inserted above the screen to paint content-aware foreground
/// items such as the home indicator on iPhone X.
final deviceContentAwareScreenForegroundKey = GlobalKey();

// TODO: Separate this into two render objects: one for the frame and one for
// the actual screen. This is needed so that the screen capture will include
// the foreground screen elements.
class SimulatorRenderObjectWidget extends SingleChildRenderObjectWidget {
  const SimulatorRenderObjectWidget({
    super.key,
    required this.params,
    required super.child,
  });

  final SimulatorParams params;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return SimulatorRenderObject(params);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    SimulatorRenderObject renderObject,
  ) {
    renderObject.params = params;
  }
}

class SimulatorRenderObject extends RenderBox with RenderObjectWithChildMixin {
  SimulatorRenderObject(this._params);

  SimulatorParams _params;
  set params(SimulatorParams value) {
    _params = value;
    markNeedsLayout();
  }

  late Size _screenSize;
  late Size _orientedScreenSize;
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

    _screenSize = _params.deviceScreenSize;
    _orientedScreenSize = _params.deviceScreenOrientation.transformSize(
      _screenSize,
    );

    _frameSize = _params.deviceInfo.deviceFrame.transformSize(
      _screenSize,
      _params,
    );

    _frameOffset = Offset.zero;

    _frameRect = Rect.fromCenter(
      center: _frameSize.center(Offset.zero),
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

    _computeTransformationMatrix();

    size = MatrixUtils.transformRect(_transformationMatrix, _frameRect).size;
    _frameRect = _frameOffset & size;

    _shouldResetScreenForegroundLayer = true;
  }

  RenderObject? get _screenForegroundRenderObject =>
      deviceContentAwareScreenForegroundKey.currentContext?.findRenderObject();

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

  ui.Picture? _paintContentAwareDeviceScreenForeground() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    if (SimulatorWidgetsBinding.instance.screenByteDataSize ==
        _orientedScreenSize) {
      _params.deviceFrame.paintContentAwareDeviceScreenForeground?.call(
        canvas,
        _params.deviceScreenOrientation.transformSize(_screenSize),
        _params,
        SimulatorWidgetsBinding.instance.screenByteData,
      );
    }

    return recorder.endRecording();
  }

  final _transformLayerHandle = LayerHandle<TransformLayer>();
  final _screenTransformLayerHandle = LayerHandle<TransformLayer>();
  final _customLayerHandle = LayerHandle<ContainerLayer>();

  late Matrix4 _transformationMatrix;
  late Matrix4 _screenTransformationMatrix;
  late Matrix4 _hitTestTransformationMatrix;
  late Matrix4 _hitTestScreenTransformationMatrix;

  void _computeTransformationMatrix() {
    final center = _frameRect.center;
    final offset = center - _screenSize.center(_screenOffset);

    _transformationMatrix = Matrix4Transform()
        .rotate(
          _params.deviceOrientationRad,
          origin: center,
        )
        .translateOffset(offset)
        .matrix4;

    _hitTestTransformationMatrix = Matrix4.zero()
      ..copyInverse(_transformationMatrix);
  }

  void _computeScreenTransformatrionMatrix() {
    switch (_params.deviceScreenOrientation) {
      case DeviceOrientation.portraitUp:
        _screenTransformationMatrix = Matrix4.identity();
        break;

      case DeviceOrientation.landscapeRight:
        _screenTransformationMatrix = Matrix4Transform()
            .translate(y: _screenSize.height)
            .rotate(-pi / 2)
            .matrix4;
        break;

      case DeviceOrientation.portraitDown:
        _screenTransformationMatrix = Matrix4Transform()
            .translate(x: _screenSize.width, y: _screenSize.height)
            .rotate(pi)
            .matrix4;
        break;

      case DeviceOrientation.landscapeLeft:
        _screenTransformationMatrix = Matrix4Transform()
            .translate(x: _screenSize.width)
            .rotate(pi / 2)
            .matrix4;
        break;
    }

    _hitTestScreenTransformationMatrix = Matrix4.zero()
      ..copyInverse(_screenTransformationMatrix);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _computeTransformationMatrix();
    _computeScreenTransformatrionMatrix();

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
    const resizableAreaPercentage = 0.2;

    var resizableRect = Rect.fromPoints(
      _frameRect.bottomRight -
          Offset(_frameRect.longestSide, _frameRect.longestSide) *
              resizableAreaPercentage,
      _frameRect.bottomRight,
    );

    final rrect = RRect.fromRectAndRadius(
      resizableRect,
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
