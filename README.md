# flutter_simulator

Warning: still highly experimental.

[Video](./assets/demo.mp4)

Installation:

Add this package with a git reference to `pubspec.yaml`:

```yaml
flutter_simulator:
  git:
    url: https://github.com/kekland/flutter_simulator
    ref: f8368c5
```

Edit `main.dart` or create another entrypoint (something like `simulator.main.dart`), and tweak a couple of things:

- Instead of calling `WidgetsFlutterBinding.ensureInitialized()`, call `await SimulatorWidgetsBinding.ensureInitialized()`.
- Instead of calling `runApp(...)`, call `runFlutterSimulatorApp(...)`
- Doesn't work with `FlutterNativeSplash`. Remove any calls to `FlutterNativeSplash.preserve()` in the entrypoint.