import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';

mixin ScreenInterceptor on WidgetsFlutterBinding {
  ByteData? screenByteData;

  void initScreenInterceptor() {
    final binding = this as SimulatorWidgetsBinding;

    binding.renderView.onAfterBuildSceneNotifier.addListener(() {
      final image = binding.deviceScreenRenderObject.toImageSync();

      image.toByteData().then((byteData) {
        if (byteData == null) return;

        screenByteData = byteData;
        image.dispose();
      });
    });
  }
}
