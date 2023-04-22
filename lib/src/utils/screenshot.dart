import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_simulator/flutter_simulator.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  required GlobalKey key,
}) async {
  final renderObject =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;

  final uiImage = await renderObject.toImage(
    pixelRatio: deviceInfo.devicePixelRatio,
  );

  final image = img.Image.fromBytes(
    width: uiImage.width,
    height: uiImage.height,
    bytes: (await uiImage.toByteData())!.buffer,
    numChannels: 4,
  );

  final path = await _generateScreenshotPath();
  final fileUrl = Uri.file(path);
  final canOpen = await canLaunchUrl(fileUrl);

  File(path).writeAsBytes(img.encodePng(image));

  // ignore: use_build_context_synchronously
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: const StadiumBorder(),
      margin: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
      content: const Text('Screenshot saved to Downloads'),
      action: canOpen
          ? SnackBarAction(
              label: 'Show',
              onPressed: () => launchUrl(fileUrl),
            )
          : null,
    ),
  );
}
