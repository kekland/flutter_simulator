// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui
    show
        ClipOp,
        Image,
        ImageByteFormat,
        Paragraph,
        Picture,
        PictureRecorder,
        PointMode,
        SceneBuilder,
        Vertices;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Signature for the builder callback used by
/// [WidgetInspector.selectButtonBuilder].
typedef InspectorSelectButtonBuilder = Widget Function(
    BuildContext context, VoidCallback onPressed);

/// Signature for a method that registers the service extension `callback` with
/// the given `name`.
///
/// Used as argument to [WidgetInspectorService.initServiceExtensions]. The
/// [BindingBase.registerServiceExtension] implements this signature.
typedef RegisterServiceExtensionCallback = void Function({
  required String name,
  required ServiceExtensionCallback callback,
});

/// A layer that mimics the behavior of another layer.
///
/// A proxy layer is used for cases where a layer needs to be placed into
/// multiple trees of layers.
class _ProxyLayer extends Layer {
  _ProxyLayer(this._layer);

  final Layer _layer;

  @override
  void addToScene(ui.SceneBuilder builder) {
    _layer.addToScene(builder);
  }

  @override
  @protected
  bool findAnnotations<S extends Object>(
    AnnotationResult<S> result,
    Offset localPosition, {
    required bool onlyFirst,
  }) {
    return _layer.findAnnotations(result, localPosition, onlyFirst: onlyFirst);
  }
}

/// A [Canvas] that multicasts all method calls to a main canvas and a
/// secondary screenshot canvas so that a screenshot can be recorded at the same
/// time as performing a normal paint.
class _MulticastCanvas implements Canvas {
  _MulticastCanvas({
    required Canvas main,
    required Canvas screenshot,
  })  : assert(main != null),
        assert(screenshot != null),
        _main = main,
        _screenshot = screenshot;

  final Canvas _main;
  final Canvas _screenshot;

  @override
  void clipPath(Path path, {bool doAntiAlias = true}) {
    _main.clipPath(path, doAntiAlias: doAntiAlias);
    _screenshot.clipPath(path, doAntiAlias: doAntiAlias);
  }

  @override
  void clipRRect(RRect rrect, {bool doAntiAlias = true}) {
    _main.clipRRect(rrect, doAntiAlias: doAntiAlias);
    _screenshot.clipRRect(rrect, doAntiAlias: doAntiAlias);
  }

  @override
  void clipRect(Rect rect,
      {ui.ClipOp clipOp = ui.ClipOp.intersect, bool doAntiAlias = true}) {
    _main.clipRect(rect, clipOp: clipOp, doAntiAlias: doAntiAlias);
    _screenshot.clipRect(rect, clipOp: clipOp, doAntiAlias: doAntiAlias);
  }

  @override
  void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter,
      Paint paint) {
    _main.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
    _screenshot.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  void drawAtlas(ui.Image atlas, List<RSTransform> transforms, List<Rect> rects,
      List<Color>? colors, BlendMode? blendMode, Rect? cullRect, Paint paint) {
    _main.drawAtlas(
        atlas, transforms, rects, colors, blendMode, cullRect, paint);
    _screenshot.drawAtlas(
        atlas, transforms, rects, colors, blendMode, cullRect, paint);
  }

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    _main.drawCircle(c, radius, paint);
    _screenshot.drawCircle(c, radius, paint);
  }

  @override
  void drawColor(Color color, BlendMode blendMode) {
    _main.drawColor(color, blendMode);
    _screenshot.drawColor(color, blendMode);
  }

  @override
  void drawDRRect(RRect outer, RRect inner, Paint paint) {
    _main.drawDRRect(outer, inner, paint);
    _screenshot.drawDRRect(outer, inner, paint);
  }

  @override
  void drawImage(ui.Image image, Offset p, Paint paint) {
    _main.drawImage(image, p, paint);
    _screenshot.drawImage(image, p, paint);
  }

  @override
  void drawImageNine(ui.Image image, Rect center, Rect dst, Paint paint) {
    _main.drawImageNine(image, center, dst, paint);
    _screenshot.drawImageNine(image, center, dst, paint);
  }

  @override
  void drawImageRect(ui.Image image, Rect src, Rect dst, Paint paint) {
    _main.drawImageRect(image, src, dst, paint);
    _screenshot.drawImageRect(image, src, dst, paint);
  }

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    _main.drawLine(p1, p2, paint);
    _screenshot.drawLine(p1, p2, paint);
  }

  @override
  void drawOval(Rect rect, Paint paint) {
    _main.drawOval(rect, paint);
    _screenshot.drawOval(rect, paint);
  }

  @override
  void drawPaint(Paint paint) {
    _main.drawPaint(paint);
    _screenshot.drawPaint(paint);
  }

  @override
  void drawParagraph(ui.Paragraph paragraph, Offset offset) {
    _main.drawParagraph(paragraph, offset);
    _screenshot.drawParagraph(paragraph, offset);
  }

  @override
  void drawPath(Path path, Paint paint) {
    _main.drawPath(path, paint);
    _screenshot.drawPath(path, paint);
  }

  @override
  void drawPicture(ui.Picture picture) {
    _main.drawPicture(picture);
    _screenshot.drawPicture(picture);
  }

  @override
  void drawPoints(ui.PointMode pointMode, List<Offset> points, Paint paint) {
    _main.drawPoints(pointMode, points, paint);
    _screenshot.drawPoints(pointMode, points, paint);
  }

  @override
  void drawRRect(RRect rrect, Paint paint) {
    _main.drawRRect(rrect, paint);
    _screenshot.drawRRect(rrect, paint);
  }

  @override
  void drawRawAtlas(
      ui.Image atlas,
      Float32List rstTransforms,
      Float32List rects,
      Int32List? colors,
      BlendMode? blendMode,
      Rect? cullRect,
      Paint paint) {
    _main.drawRawAtlas(
        atlas, rstTransforms, rects, colors, blendMode, cullRect, paint);
    _screenshot.drawRawAtlas(
        atlas, rstTransforms, rects, colors, blendMode, cullRect, paint);
  }

  @override
  void drawRawPoints(ui.PointMode pointMode, Float32List points, Paint paint) {
    _main.drawRawPoints(pointMode, points, paint);
    _screenshot.drawRawPoints(pointMode, points, paint);
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    _main.drawRect(rect, paint);
    _screenshot.drawRect(rect, paint);
  }

  @override
  void drawShadow(
      Path path, Color color, double elevation, bool transparentOccluder) {
    _main.drawShadow(path, color, elevation, transparentOccluder);
    _screenshot.drawShadow(path, color, elevation, transparentOccluder);
  }

  @override
  void drawVertices(ui.Vertices vertices, BlendMode blendMode, Paint paint) {
    _main.drawVertices(vertices, blendMode, paint);
    _screenshot.drawVertices(vertices, blendMode, paint);
  }

  @override
  int getSaveCount() {
    // The main canvas is used instead of the screenshot canvas as the main
    // canvas is guaranteed to be consistent with the canvas expected by the
    // normal paint pipeline so any logic depending on getSaveCount() will
    // behave the same as for the regular paint pipeline.
    return _main.getSaveCount();
  }

  @override
  void restore() {
    _main.restore();
    _screenshot.restore();
  }

  @override
  void rotate(double radians) {
    _main.rotate(radians);
    _screenshot.rotate(radians);
  }

  @override
  void save() {
    _main.save();
    _screenshot.save();
  }

  @override
  void saveLayer(Rect? bounds, Paint paint) {
    _main.saveLayer(bounds, paint);
    _screenshot.saveLayer(bounds, paint);
  }

  @override
  void scale(double sx, [double? sy]) {
    _main.scale(sx, sy);
    _screenshot.scale(sx, sy);
  }

  @override
  void skew(double sx, double sy) {
    _main.skew(sx, sy);
    _screenshot.skew(sx, sy);
  }

  @override
  void transform(Float64List matrix4) {
    _main.transform(matrix4);
    _screenshot.transform(matrix4);
  }

  @override
  void translate(double dx, double dy) {
    _main.translate(dx, dy);
    _screenshot.translate(dx, dy);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    super.noSuchMethod(invocation);
  }
}

Rect _calculateSubtreeBoundsHelper(RenderObject object, Matrix4 transform) {
  Rect bounds = MatrixUtils.transformRect(transform, object.semanticBounds);

  object.visitChildren((RenderObject child) {
    final Matrix4 childTransform = transform.clone();
    object.applyPaintTransform(child, childTransform);
    Rect childBounds = _calculateSubtreeBoundsHelper(child, childTransform);
    final Rect? paintClip = object.describeApproximatePaintClip(child);
    if (paintClip != null) {
      final Rect transformedPaintClip = MatrixUtils.transformRect(
        transform,
        paintClip,
      );
      childBounds = childBounds.intersect(transformedPaintClip);
    }

    if (childBounds.isFinite && !childBounds.isEmpty) {
      bounds =
          bounds.isEmpty ? childBounds : bounds.expandToInclude(childBounds);
    }
  });

  return bounds;
}

/// Calculate bounds for a render object and all of its descendants.
Rect _calculateSubtreeBounds(RenderObject object) {
  return _calculateSubtreeBoundsHelper(object, Matrix4.identity());
}

/// A layer that omits its own offset when adding children to the scene so that
/// screenshots render to the scene in the local coordinate system of the layer.
class _ScreenshotContainerLayer extends OffsetLayer {
  @override
  void addToScene(ui.SceneBuilder builder) {
    addChildrenToScene(builder);
  }
}

/// Data shared between nested [_ScreenshotPaintingContext] objects recording
/// a screenshot.
class _ScreenshotData {
  _ScreenshotData({
    required this.target,
  })  : assert(target != null),
        containerLayer = _ScreenshotContainerLayer();

  /// Target to take a screenshot of.
  final RenderObject target;

  /// Root of the layer tree containing the screenshot.
  final OffsetLayer containerLayer;

  /// Whether the screenshot target has already been found in the render tree.
  bool foundTarget = false;

  /// Whether paint operations should record to the screenshot.
  ///
  /// At least one of [includeInScreenshot] and [includeInRegularContext] must
  /// be true.
  bool includeInScreenshot = false;

  /// Whether paint operations should record to the regular context.
  ///
  /// This should only be set to false before paint operations that should only
  /// apply to the screenshot such rendering debug information about the
  /// [target].
  ///
  /// At least one of [includeInScreenshot] and [includeInRegularContext] must
  /// be true.
  bool includeInRegularContext = true;

  /// Offset of the screenshot corresponding to the offset [target] was given as
  /// part of the regular paint.
  Offset get screenshotOffset {
    assert(foundTarget);
    return containerLayer.offset;
  }

  set screenshotOffset(Offset offset) {
    containerLayer.offset = offset;
  }
}

/// A place to paint to build screenshots of [RenderObject]s.
///
/// Requires that the render objects have already painted successfully as part
/// of the regular rendering pipeline.
/// This painting context behaves the same as standard [PaintingContext] with
/// instrumentation added to compute a screenshot of a specified [RenderObject]
/// added. To correctly mimic the behavior of the regular rendering pipeline, the
/// full subtree of the first [RepaintBoundary] ancestor of the specified
/// [RenderObject] will also be rendered rather than just the subtree of the
/// render object.
class ScreenshotPaintingContext extends PaintingContext {
  ScreenshotPaintingContext({
    required ContainerLayer containerLayer,
    required Rect estimatedBounds,
    required _ScreenshotData screenshotData,
  })  : _data = screenshotData,
        super(containerLayer, estimatedBounds);

  final _ScreenshotData _data;

  // Recording state
  PictureLayer? _screenshotCurrentLayer;
  ui.PictureRecorder? _screenshotRecorder;
  Canvas? _screenshotCanvas;
  _MulticastCanvas? _multicastCanvas;

  @override
  Canvas get canvas {
    if (_data.includeInScreenshot) {
      if (_screenshotCanvas == null) {
        _startRecordingScreenshot();
      }
      assert(_screenshotCanvas != null);
      return _data.includeInRegularContext
          ? _multicastCanvas!
          : _screenshotCanvas!;
    } else {
      assert(_data.includeInRegularContext);
      return super.canvas;
    }
  }

  bool get _isScreenshotRecording {
    final bool hasScreenshotCanvas = _screenshotCanvas != null;
    assert(() {
      if (hasScreenshotCanvas) {
        assert(_screenshotCurrentLayer != null);
        assert(_screenshotRecorder != null);
        assert(_screenshotCanvas != null);
      } else {
        assert(_screenshotCurrentLayer == null);
        assert(_screenshotRecorder == null);
        assert(_screenshotCanvas == null);
      }
      return true;
    }());
    return hasScreenshotCanvas;
  }

  void _startRecordingScreenshot() {
    assert(_data.includeInScreenshot);
    assert(!_isScreenshotRecording);
    _screenshotCurrentLayer = PictureLayer(estimatedBounds);
    _screenshotRecorder = ui.PictureRecorder();
    _screenshotCanvas = Canvas(_screenshotRecorder!);
    _data.containerLayer.append(_screenshotCurrentLayer!);
    if (_data.includeInRegularContext) {
      _multicastCanvas = _MulticastCanvas(
        main: super.canvas,
        screenshot: _screenshotCanvas!,
      );
    } else {
      _multicastCanvas = null;
    }
  }

  @override
  void stopRecordingIfNeeded() {
    super.stopRecordingIfNeeded();
    _stopRecordingScreenshotIfNeeded();
  }

  void _stopRecordingScreenshotIfNeeded() {
    if (!_isScreenshotRecording) {
      return;
    }
    // There is no need to ever draw repaint rainbows as part of the screenshot.
    _screenshotCurrentLayer!.picture = _screenshotRecorder!.endRecording();
    _screenshotCurrentLayer = null;
    _screenshotRecorder = null;
    _multicastCanvas = null;
    _screenshotCanvas = null;
  }

  @override
  void appendLayer(Layer layer) {
    if (_data.includeInRegularContext) {
      super.appendLayer(layer);
      if (_data.includeInScreenshot) {
        assert(!_isScreenshotRecording);
        // We must use a proxy layer here as the layer is already attached to
        // the regular layer tree.
        _data.containerLayer.append(_ProxyLayer(layer));
      }
    } else {
      // Only record to the screenshot.
      assert(!_isScreenshotRecording);
      assert(_data.includeInScreenshot);
      layer.remove();
      _data.containerLayer.append(layer);
      return;
    }
  }

  @override
  PaintingContext createChildContext(ContainerLayer childLayer, Rect bounds) {
    if (_data.foundTarget) {
      // We have already found the screenshotTarget in the layer tree
      // so we can optimize and use a standard PaintingContext.
      return super.createChildContext(childLayer, bounds);
    } else {
      return ScreenshotPaintingContext(
        containerLayer: childLayer,
        estimatedBounds: bounds,
        screenshotData: _data,
      );
    }
  }

  @override
  void paintChild(RenderObject child, Offset offset) {
    final bool isScreenshotTarget = identical(child, _data.target);
    if (isScreenshotTarget) {
      assert(!_data.includeInScreenshot);
      assert(!_data.foundTarget);
      _data.foundTarget = true;
      _data.screenshotOffset = offset;
      _data.includeInScreenshot = true;
    }
    super.paintChild(child, offset);
    if (isScreenshotTarget) {
      _stopRecordingScreenshotIfNeeded();
      _data.includeInScreenshot = false;
    }
  }

  /// Captures an image of the current state of [renderObject] and its children.
  ///
  /// The returned [ui.Image] has uncompressed raw RGBA bytes, will be offset
  /// by the top-left corner of [renderBounds], and have dimensions equal to the
  /// size of [renderBounds] multiplied by [pixelRatio].
  ///
  /// To use [toImage], the render object must have gone through the paint phase
  /// (i.e. [debugNeedsPaint] must be false).
  ///
  /// The [pixelRatio] describes the scale between the logical pixels and the
  /// size of the output image. It is independent of the
  /// [window.devicePixelRatio] for the device, so specifying 1.0 (the default)
  /// will give you a 1:1 mapping between logical pixels and the output pixels
  /// in the image.
  ///
  /// The [debugPaint] argument specifies whether the image should include the
  /// output of [RenderObject.debugPaint] for [renderObject] with
  /// [debugPaintSizeEnabled] set to true. Debug paint information is not
  /// included for the children of [renderObject] so that it is clear precisely
  /// which object the debug paint information references.
  ///
  /// See also:
  ///
  ///  * [RenderRepaintBoundary.toImage] for a similar API for [RenderObject]s
  ///    that are repaint boundaries that can be used outside of the inspector.
  ///  * [OffsetLayer.toImage] for a similar API at the layer level.
  ///  * [dart:ui.Scene.toImage] for more information about the image returned.
  static Future<ui.Image> toImage(
    RenderObject renderObject,
    Rect renderBounds, {
    double pixelRatio = 1.0,
    bool debugPaint = false,
  }) {
    RenderObject repaintBoundary = renderObject;
    while (repaintBoundary != null && !repaintBoundary.isRepaintBoundary) {
      repaintBoundary = repaintBoundary.parent! as RenderObject;
    }
    assert(repaintBoundary != null);
    final _ScreenshotData data = _ScreenshotData(target: renderObject);
    final ScreenshotPaintingContext context = ScreenshotPaintingContext(
      containerLayer: repaintBoundary.debugLayer!,
      estimatedBounds: repaintBoundary.paintBounds,
      screenshotData: data,
    );

    if (identical(renderObject, repaintBoundary)) {
      // Painting the existing repaint boundary to the screenshot is sufficient.
      // We don't just take a direct screenshot of the repaint boundary as we
      // want to capture debugPaint information as well.
      data.containerLayer.append(_ProxyLayer(repaintBoundary.debugLayer!));
      data.foundTarget = true;
      final OffsetLayer offsetLayer =
          repaintBoundary.debugLayer! as OffsetLayer;
      data.screenshotOffset = offsetLayer.offset;
    } else {
      // Repaint everything under the repaint boundary.
      // We call debugInstrumentRepaintCompositedChild instead of paintChild as
      // we need to force everything under the repaint boundary to repaint.
      PaintingContext.debugInstrumentRepaintCompositedChild(
        repaintBoundary,
        customContext: context,
      );
    }

    // The check that debugPaintSizeEnabled is false exists to ensure we only
    // call debugPaint when it wasn't already called.
    if (debugPaint && !debugPaintSizeEnabled) {
      data.includeInRegularContext = false;
      // Existing recording may be to a canvas that draws to both the normal and
      // screenshot canvases.
      context.stopRecordingIfNeeded();
      assert(data.foundTarget);
      data.includeInScreenshot = true;

      debugPaintSizeEnabled = true;
      try {
        renderObject.debugPaint(context, data.screenshotOffset);
      } finally {
        debugPaintSizeEnabled = false;
        context.stopRecordingIfNeeded();
      }
    }

    // We must build the regular scene before we can build the screenshot
    // scene as building the screenshot scene assumes addToScene has already
    // been called successfully for all layers in the regular scene.
    repaintBoundary.debugLayer!.buildScene(ui.SceneBuilder());

    return data.containerLayer.toImage(renderBounds, pixelRatio: pixelRatio);
  }
}
