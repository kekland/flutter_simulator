import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';

mixin ScreenInterceptor on WidgetsFlutterBinding {
  ByteData? screenByteData;
  Size? screenByteDataSize;

  void initScreenInterceptor() {
    final binding = this as SimulatorWidgetsBinding;

    binding.renderView.onAfterBuildSceneNotifier.addListener(() {
      final image = binding.deviceScreenRenderObject.toImageSync();

      image.toByteData().then((byteData) {
        if (byteData == null) return;

        screenByteData = byteData;
        screenByteDataSize = Size(
          image.width.toDouble(),
          image.height.toDouble(),
        );

        image.dispose();
      });
    });
  }
}
