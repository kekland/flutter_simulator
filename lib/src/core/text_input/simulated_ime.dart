import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_simulator/src/imports.dart';

class SimulatedIME {
  SimulatedIME({
    required this.id,
    required this.configuration,
  });

  final int id;
  TextEditingValue value = TextEditingValue.empty;

  TextInputConfiguration configuration;

  double? width;
  double? height;
  Matrix4? transform;

  Rect? markedTextRect;
  Rect? caretRect;

  String? fontFamily;
  double? fontSize;
  FontWeight? fontWeight;
  TextDirection? textDirection;
  TextAlign? textAlign;

  void setEditableSizeAndTransform(
    double width,
    double height,
    Matrix4 transform,
  ) {
    this.width = width;
    this.height = height;
    this.transform = transform;
  }

  void setMarkedTextRect(Rect rect) {
    markedTextRect = rect;
  }

  void setStyle(
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    TextDirection textDirection,
    TextAlign textAlign,
  ) {
    this.fontFamily = fontFamily;
    this.fontSize = fontSize;
    this.fontWeight = fontWeight;
    this.textDirection = textDirection;
    this.textAlign = textAlign;
  }

  void setEditingState(TextEditingValue value) {
    this.value = value;
  }

  void setCaretRect(Rect rect) {
    caretRect = rect;
  }

  void _appendCharacter(String character) {
    value = value.replaced(
      value.selection,
      character,
    );
  }

  void _deleteCharacter(int offset) {
    var selection = value.selection;

    if (selection.isCollapsed) {
      selection = selection.extendTo(TextPosition(
        offset: max(0, selection.baseOffset + offset),
        affinity: selection.affinity,
      ));

      final selectionLength = selection.extentOffset - selection.baseOffset;

      if (selection.isCollapsed ||
          !selection.isValid ||
          selectionLength > value.text.length) {
        return;
      }
    }

    value = value.replaced(
      selection,
      '',
    );
  }

  void handleKeyEvent(RawKeyEvent event) {
    final interceptor = SystemTextInputChannelInterceptor.instance;
    print(event);

    // TODO: Make this work for macOS
    if (event is RawKeyDownEvent) {
      if (event.character != null) {
        _appendCharacter(event.character!);
        interceptor.updateEditingState(id, value);
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        _deleteCharacter(-1);
        interceptor.updateEditingState(id, value);
      } else if (event.logicalKey == LogicalKeyboardKey.delete) {
        _deleteCharacter(1);
        interceptor.updateEditingState(id, value);
      }
    }
  }
}
