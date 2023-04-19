import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/flutter_simulator.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

String _generateScreenshotName() {
  final now = DateTime.now();
  final iso = now.toIso8601String().replaceAll(':', '-');

  return 'flutter_simulator_$iso.png';
}

Future<String> _generateScreenshotPath() async {
  final downloads = await getDownloadsDirectory();

  return '${downloads!.path}\\${_generateScreenshotName()}';
}

Future<void> takeScreenshot(
  BuildContext context, {
  required DeviceInfo deviceInfo,
  required GlobalKey deviceFrameRepaintBoundaryKey,
}) async {
  final renderObject = deviceFrameRepaintBoundaryKey.currentContext!
      .findRenderObject()! as RenderRepaintBoundary;

  final uiImage = await renderObject.toImage(
    pixelRatio: deviceInfo.scaleFactor,
  );

  final image = img.Image.fromBytes(
    width: uiImage.width,
    height: uiImage.height,
    bytes: (await uiImage.toByteData())!.buffer,
    numChannels: 4,
  );

  final path = await _generateScreenshotPath();

  File(path).writeAsBytes(img.encodePng(image));

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Screenshot saved to ${path}'),
    ),
  );
}
