import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simulator/src/imports.dart';

class SystemTextInputChannelInterceptor {
  final Map<int, SimulatedIME> _simulatedIMEs = {};

  SimulatedIME? get maybeActiveIME => _activeIMEId != null ? activeIME : null;
  SimulatedIME get activeIME => _simulatedIMEs[_activeIMEId]!;

  int? get _activeIMEId => activeIMEIdNotifier.value;
  final activeIMEIdNotifier = ValueNotifier<int?>(null);
  final keyboardVisibilityNotifier = ValueNotifier(false);

  static SystemTextInputChannelInterceptor ensureInitialized() {
    if (SystemTextInputChannelInterceptor._instance != null) {
      return SystemTextInputChannelInterceptor._instance!;
    }

    final instance = SystemTextInputChannelInterceptor();
    SystemTextInputChannelInterceptor._instance = instance;

    SimulatorWidgetsBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.textInput,
      instance._handleMessage,
    );

    RawKeyboard.instance.addListener(instance._onKeyboardEvent);
    return instance;
  }

  static SystemTextInputChannelInterceptor get instance => _instance!;
  static SystemTextInputChannelInterceptor? _instance;

  void _onKeyboardEvent(RawKeyEvent event) {
    maybeActiveIME?.handleKeyEvent(event);
  }

  Future<Object?>? _handleMessage(MethodCall message) async {
    print(message);

    if (message.method == 'TextInput.setClient') {
      return _onSetClient(message.arguments);
    } else if (message.method == 'TextInput.setEditableSizeAndTransform') {
      return _onSetEditableSizeAndTransform(message.arguments);
    } else if (message.method == 'TextInput.setMarkedTextRect') {
      return _onSetMarkedTextRect(message.arguments);
    } else if (message.method == 'TextInput.setSelectionRects') {
      return _onSetSelectionRects(message.arguments);
    } else if (message.method == 'TextInput.setStyle') {
      return _onSetStyle(message.arguments);
    } else if (message.method == 'TextInput.setEditingState') {
      return _onSetEditingState(message.arguments);
    } else if (message.method == 'TextInput.show') {
      return _onShow();
    } else if (message.method == 'TextInput.requestAutofill') {
      return _onRequestAutofill(message.arguments);
    } else if (message.method == 'TextInput.setCaretRect') {
      return _onSetCaretRect(message.arguments);
    } else if (message.method == 'TextInput.clearClient') {
      return _onClearClient();
    } else if (message.method == 'TextInput.hide') {
      return _onHide();
    } else {
      throw UnimplementedError('Method ${message.method} not implemented');
    }
  }

  Future<Object?> _onSetClient(dynamic arguments) async {
    final id = arguments[0] as int;
    final configuration = _textInputConfigurationFromJson(arguments[1]);

    _simulatedIMEs[id] = SimulatedIME(
      id: id,
      configuration: configuration,
    );

    activeIMEIdNotifier.value = id;

    return null;
  }

  Future<Object?> _onSetEditableSizeAndTransform(dynamic arguments) async {
    final width = arguments['width'] as double;
    final height = arguments['height'] as double;
    final transform = Matrix4.fromList(
      arguments['transform'].cast<double>().toList(),
    );

    activeIME.setEditableSizeAndTransform(width, height, transform);
    return null;
  }

  Future<Object?> _onSetMarkedTextRect(dynamic arguments) async {
    final width = arguments['width'] as double;
    final height = arguments['height'] as double;
    final x = arguments['x'] as double;
    final y = arguments['y'] as double;

    final rect = Rect.fromLTWH(x, y, width, height);
    activeIME.setMarkedTextRect(rect);

    return null;
  }

  Future<Object?> _onSetSelectionRects(dynamic arguments) async {
    final rects = (arguments as List<dynamic>)
        .map((rect) => Rect.fromLTWH(
              rect[0] as double,
              rect[1] as double,
              rect[2] as double,
              rect[3] as double,
            ))
        .toList();

    activeIME.setSelectionRects(rects);
    return null;
  }

  Future<Object?> _onSetStyle(dynamic arguments) async {
    final fontFamily = arguments['fontFamily'] as String?;
    final fontSize = arguments['fontSize'] as double?;
    final fontWeightIndex = arguments['fontWeightIndex'] as int?;
    final fontWeight =
        fontWeightIndex != null ? FontWeight.values[fontWeightIndex] : null;

    final textAlignIndex = arguments['textAlignIndex'] as int;
    final textAlign = TextAlign.values[textAlignIndex];

    final textDirectionIndex = arguments['textDirectionIndex'] as int;
    final textDirection = TextDirection.values[textDirectionIndex];

    activeIME.setStyle(
      fontFamily,
      fontSize,
      fontWeight,
      textDirection,
      textAlign,
    );

    return null;
  }

  Future<Object?> _onSetEditingState(dynamic arguments) async {
    final textEditingValue = TextEditingValue.fromJSON(arguments);
    activeIME.setEditingState(textEditingValue);

    return null;
  }

  Future<Object?> _onShow() async {
    keyboardVisibilityNotifier.value = true;
    return null;
  }

  Future<Object?> _onRequestAutofill(dynamic arguments) async {
    // TODO: Figure out what to do here
    return null;
  }

  Future<Object?> _onSetCaretRect(dynamic arguments) async {
    final width = arguments['width'] as double;
    final height = arguments['height'] as double;
    final x = arguments['x'] as double;
    final y = arguments['y'] as double;

    final rect = Rect.fromLTWH(x, y, width, height);
    activeIME.setCaretRect(rect);

    return null;
  }

  Future<Object?> _onClearClient() async {
    // TODO: Dipose the active IME
    activeIMEIdNotifier.value = null;
    return null;
  }

  Future<Object?> _onHide() async {
    keyboardVisibilityNotifier.value = false;
    return null;
  }

  Future<void> focusElement({
    required String scribbleClientId,
    required double dx,
    required double dy,
  }) {
    final method = MethodCall(
      'TextInputClient.focusElement',
      [scribbleClientId, dx, dy],
    );

    return _sendMethodCall(method);
  }

  Future<void> requestElementsInRect({
    required double left,
    required double top,
    required double width,
    required double height,
  }) {
    final method = MethodCall(
      'TextInputClient.requestElementsInRect',
      [left, top, width, height],
    );

    // TODO: Decode return envelope
    return _sendMethodCall(method);
  }

  Future<void> scribbleInteractionBegan() {
    const method = MethodCall('TextInputClient.scribbleInteractionBegan');
    return _sendMethodCall(method);
  }

  Future<void> scribbleInteractionFinished() {
    const method = MethodCall('TextInputClient.scribbleInteractionFinished');
    return _sendMethodCall(method);
  }

  Future<void> requestExistingInputState() async {
    const method = MethodCall('TextInputClient.requestExistingInputState');
    return _sendMethodCall(method);
  }

  Future<void> updateEditingStateWithTag(
    int id,
    Map<String, TextEditingValue> taggedEditingValues,
  ) async {
    final method = MethodCall(
      'TextInputClient.updateEditingStateWithTag',
      [id, taggedEditingValues.map((k, v) => MapEntry(k, v.toJSON()))],
    );

    return _sendMethodCall(method);
  }

  Future<void> updateEditingState(
    int id,
    TextEditingValue value,
  ) async {
    final method = MethodCall(
      'TextInputClient.updateEditingState',
      [id, value.toJSON()],
    );

    return _sendMethodCall(method);
  }

  Future<void> updateEditingStateWithDeltas(
    int id,
    List<TextEditingDelta> deltas,
  ) async {
    // TODO: Add support for delta editing
    // final method = MethodCall(
    //   'TextInputClient.updateEditingStateWithDeltas',
    //   [id, {'deltas': deltas.map((d) => d.toJson()).toList()}],
    // );

    // return _sendMethodCall(method);
  }

  Future<void> performAction(int id, TextInputAction action) async {
    final method = MethodCall(
      'TextInputClient.performAction',
      [id, 'TextInputAction.${action.name}'],
    );

    return _sendMethodCall(method);
  }

  Future<void> performSelector(int id, List<String> selectors) async {
    final method = MethodCall(
      'TextInputClient.performSelectors',
      [id, selectors],
    );

    return _sendMethodCall(method);
  }

  Future<void> performPrivateCommand(
    int id, {
    required String action,
    Map<String, dynamic>? data,
  }) async {
    final method = MethodCall(
      'TextInputClient.performPrivateCommand',
      [
        id,
        {'action': action, 'data': data}
      ],
    );

    return _sendMethodCall(method);
  }

  Future<void> updateFloatingCursor(
    int id, {
    required FloatingCursorDragState floatingCursorDragState,
    required Offset offset,
  }) async {
    final method = MethodCall(
      'TextInputClient.updateFloatingCursor',
      [
        id,
        'FloatingCursorDragState.${floatingCursorDragState.name.toLowerCase()}',
        {
          'X': offset.dx,
          'Y': offset.dy,
        },
      ],
    );

    return _sendMethodCall(method);
  }

  Future<void> onConnectionClosed(int id) {
    final method = MethodCall(
      'TextInputClient.onConnectionClosed',
      [id],
    );

    return _sendMethodCall(method);
  }

  Future<void> showAutocorrectionPromptRect(
    int id, {
    required int start,
    required int end,
  }) {
    final method = MethodCall(
      'TextInputClient.showAutocorrectionPromptRect',
      [id, start, end],
    );

    return _sendMethodCall(method);
  }

  Future<void> showToolbar(int id) {
    final method = MethodCall(
      'TextInputClient.showToolbar',
      [id],
    );

    return _sendMethodCall(method);
  }

  Future<void> insertTextPlaceholder(int id, Size size) {
    final method = MethodCall(
      'TextInputClient.insertTextPlaceholder',
      [id, size.width, size.height],
    );

    return _sendMethodCall(method);
  }

  Future<void> removeTextPlaceholder() {
    const method = MethodCall('TextInputClient.removeTextPlaceholder');

    return _sendMethodCall(method);
  }

  Future<dynamic> _sendMethodCall(MethodCall methodCall) async {
    final bytes = SystemChannels.textInput.codec.encodeMethodCall(methodCall);

    final completer = Completer();

    SimulatorWidgetsBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      SystemChannels.textInput.name,
      bytes,
      (bytes) {
        if (bytes == null) {
          print('Result for ${methodCall.method}: null');
          completer.complete(null);
        }
        final response = SystemChannels.textInput.codec.decodeEnvelope(bytes!);
        print('Result for ${methodCall.method}: $response');
        completer.complete(response);
      },
    );

    return completer.future;
  }

  void dispose() {
    RawKeyboard.instance.removeListener(instance._onKeyboardEvent);
    SimulatorWidgetsBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.textInput,
      null,
    );

    _instance = null;
  }
}

TextInputType _textInputTypeFromJson(Map<String, dynamic> data) {
  final name = data['name'] as String;
  final signed = data['signed'] as bool?;
  final decimal = data['decimal'] as bool?;

  switch (name) {
    case 'text':
      return TextInputType.text;
    case 'multiline':
      return TextInputType.multiline;
    case 'number':
      return TextInputType.numberWithOptions(
        signed: signed ?? false,
        decimal: decimal ?? false,
      );
    case 'phone':
      return TextInputType.phone;
    case 'datetime':
      return TextInputType.datetime;
    case 'emailAddress':
      return TextInputType.emailAddress;
    case 'url':
      return TextInputType.url;
    case 'visiblePassword':
      return TextInputType.visiblePassword;
    case 'name':
      return TextInputType.name;
    case 'address':
      return TextInputType.streetAddress;
    case 'none':
      return TextInputType.none;
    default:
      return TextInputType.none;
  }
}

TextInputAction _textInputActionFromJson(String value) {
  switch (value) {
    case 'TextInputAction.none':
      return TextInputAction.none;
    case 'TextInputAction.unspecified':
      return TextInputAction.unspecified;
    case 'TextInputAction.done':
      return TextInputAction.done;
    case 'TextInputAction.go':
      return TextInputAction.go;
    case 'TextInputAction.search':
      return TextInputAction.search;
    case 'TextInputAction.send':
      return TextInputAction.send;
    case 'TextInputAction.next':
      return TextInputAction.next;
    case 'TextInputAction.previous':
      return TextInputAction.previous;
    case 'TextInputAction.continueAction':
      return TextInputAction.continueAction;
    case 'TextInputAction.join':
      return TextInputAction.join;
    case 'TextInputAction.route':
      return TextInputAction.route;
    case 'TextInputAction.emergencyCall':
      return TextInputAction.emergencyCall;
    case 'TextInputAction.newline':
      return TextInputAction.newline;
    default:
      return TextInputAction.none;
  }
}

TextCapitalization _textCapitalizationFromJson(String value) {
  switch (value) {
    case 'TextCapitalization.none':
      return TextCapitalization.none;
    case 'TextCapitalization.characters':
      return TextCapitalization.characters;
    case 'TextCapitalization.words':
      return TextCapitalization.words;
    case 'TextCapitalization.sentences':
      return TextCapitalization.sentences;
    default:
      return TextCapitalization.none;
  }
}

Brightness _brightnessFromJson(String value) {
  switch (value) {
    case 'Brightness.light':
      return Brightness.light;
    case 'Brightness.dark':
      return Brightness.dark;
    default:
      return Brightness.light;
  }
}

TextInputConfiguration _textInputConfigurationFromJson(
    Map<String, dynamic> data) {
  return TextInputConfiguration(
    inputType: _textInputTypeFromJson(data['inputType']),
    obscureText: data['obscureText'],
    autocorrect: data['autocorrect'],
    inputAction: _textInputActionFromJson(data['inputAction']),
    textCapitalization: _textCapitalizationFromJson(data['textCapitalization']),
    keyboardAppearance: _brightnessFromJson(data['keyboardAppearance']),
    actionLabel: data['actionLabel'],
  );
}
