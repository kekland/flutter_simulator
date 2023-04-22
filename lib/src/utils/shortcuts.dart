import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FlutterSimulatorShortcuts {
  // These shortcuts are shared between all platforms except Apple platforms,
  // because they use different modifier keys as the line/word modifier.
  static final Map<ShortcutActivator, Intent> _commonShortcuts =
      <ShortcutActivator, Intent>{
    // Delete Shortcuts.
    for (final bool pressShift in const <bool>[
      true,
      false
    ]) ...<SingleActivator, Intent>{
      SingleActivator(LogicalKeyboardKey.backspace, shift: pressShift):
          const DeleteCharacterIntent(forward: false),
      SingleActivator(LogicalKeyboardKey.backspace,
              control: true, shift: pressShift):
          const DeleteToNextWordBoundaryIntent(forward: false),
      SingleActivator(LogicalKeyboardKey.backspace,
          alt: true,
          shift: pressShift): const DeleteToLineBreakIntent(forward: false),
      SingleActivator(LogicalKeyboardKey.delete, shift: pressShift):
          const DeleteCharacterIntent(forward: true),
      SingleActivator(LogicalKeyboardKey.delete,
              control: true, shift: pressShift):
          const DeleteToNextWordBoundaryIntent(forward: true),
      SingleActivator(LogicalKeyboardKey.delete, alt: true, shift: pressShift):
          const DeleteToLineBreakIntent(forward: true),
    },

    // Arrow: Move selection.
    const SingleActivator(LogicalKeyboardKey.arrowLeft):
        const ExtendSelectionByCharacterIntent(
            forward: false, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.arrowRight):
        const ExtendSelectionByCharacterIntent(
            forward: true, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.arrowUp):
        const ExtendSelectionVerticallyToAdjacentLineIntent(
            forward: false, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.arrowDown):
        const ExtendSelectionVerticallyToAdjacentLineIntent(
            forward: true, collapseSelection: true),

    // Shift + Arrow: Extend selection.
    const SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true):
        const ExtendSelectionByCharacterIntent(
            forward: false, collapseSelection: false),
    const SingleActivator(LogicalKeyboardKey.arrowRight, shift: true):
        const ExtendSelectionByCharacterIntent(
            forward: true, collapseSelection: false),
    const SingleActivator(LogicalKeyboardKey.arrowUp, shift: true):
        const ExtendSelectionVerticallyToAdjacentLineIntent(
            forward: false, collapseSelection: false),
    const SingleActivator(LogicalKeyboardKey.arrowDown, shift: true):
        const ExtendSelectionVerticallyToAdjacentLineIntent(
            forward: true, collapseSelection: false),

    const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true):
        const ExtendSelectionToLineBreakIntent(
            forward: false, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.arrowRight, alt: true):
        const ExtendSelectionToLineBreakIntent(
            forward: true, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.arrowUp, alt: true):
        const ExtendSelectionToDocumentBoundaryIntent(
            forward: false, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true):
        const ExtendSelectionToDocumentBoundaryIntent(
            forward: true, collapseSelection: true),

    const SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true, alt: true):
        const ExtendSelectionToLineBreakIntent(
            forward: false, collapseSelection: false),
    const SingleActivator(LogicalKeyboardKey.arrowRight,
            shift: true, alt: true):
        const ExtendSelectionToLineBreakIntent(
            forward: true, collapseSelection: false),
    const SingleActivator(LogicalKeyboardKey.arrowUp, shift: true, alt: true):
        const ExtendSelectionToDocumentBoundaryIntent(
            forward: false, collapseSelection: false),
    const SingleActivator(LogicalKeyboardKey.arrowDown, shift: true, alt: true):
        const ExtendSelectionToDocumentBoundaryIntent(
            forward: true, collapseSelection: false),

    const SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
        const ExtendSelectionToNextWordBoundaryIntent(
            forward: false, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.arrowRight, control: true):
        const ExtendSelectionToNextWordBoundaryIntent(
            forward: true, collapseSelection: true),

    const SingleActivator(LogicalKeyboardKey.arrowLeft,
            shift: true, control: true):
        const ExtendSelectionToNextWordBoundaryIntent(
            forward: false, collapseSelection: false),
    const SingleActivator(LogicalKeyboardKey.arrowRight,
            shift: true, control: true):
        const ExtendSelectionToNextWordBoundaryIntent(
            forward: true, collapseSelection: false),

    // Page Up / Down: Move selection by page.
    const SingleActivator(LogicalKeyboardKey.pageUp):
        const ExtendSelectionVerticallyToAdjacentPageIntent(
            forward: false, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.pageDown):
        const ExtendSelectionVerticallyToAdjacentPageIntent(
            forward: true, collapseSelection: true),

    // Shift + Page Up / Down: Extend selection by page.
    const SingleActivator(LogicalKeyboardKey.pageUp, shift: true):
        const ExtendSelectionVerticallyToAdjacentPageIntent(
            forward: false, collapseSelection: false),
    const SingleActivator(LogicalKeyboardKey.pageDown, shift: true):
        const ExtendSelectionVerticallyToAdjacentPageIntent(
            forward: true, collapseSelection: false),

    const SingleActivator(LogicalKeyboardKey.keyX, control: true):
        const CopySelectionTextIntent.cut(SelectionChangedCause.keyboard),
    const SingleActivator(LogicalKeyboardKey.keyC, control: true):
        CopySelectionTextIntent.copy,
    const SingleActivator(LogicalKeyboardKey.keyV, control: true):
        const PasteTextIntent(SelectionChangedCause.keyboard),
    const SingleActivator(LogicalKeyboardKey.keyA, control: true):
        const SelectAllTextIntent(SelectionChangedCause.keyboard),
    const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
        const UndoTextIntent(SelectionChangedCause.keyboard),
    const SingleActivator(LogicalKeyboardKey.keyZ, shift: true, control: true):
        const RedoTextIntent(SelectionChangedCause.keyboard),
    // These keys should go to the IME when a field is focused, not to other
    // Shortcuts.
    const SingleActivator(LogicalKeyboardKey.space):
        const DoNothingAndStopPropagationTextIntent(),
    const SingleActivator(LogicalKeyboardKey.enter):
        const DoNothingAndStopPropagationTextIntent(),
  };

  // The following key combinations have no effect on text editing on this
  // platform:
  //   * End
  //   * Home
  //   * Meta + X
  //   * Meta + C
  //   * Meta + V
  //   * Meta + A
  //   * Meta + shift? + Z
  //   * Meta + shift? + arrow down
  //   * Meta + shift? + arrow left
  //   * Meta + shift? + arrow right
  //   * Meta + shift? + arrow up
  //   * Shift + end
  //   * Shift + home
  //   * Meta + shift? + delete
  //   * Meta + shift? + backspace
  static final Map<ShortcutActivator, Intent> _androidShortcuts =
      _commonShortcuts;

  static final Map<ShortcutActivator, Intent> _fuchsiaShortcuts =
      _androidShortcuts;

  static final Map<ShortcutActivator, Intent> _linuxShortcuts =
      <ShortcutActivator, Intent>{
    ..._commonShortcuts,
    const SingleActivator(LogicalKeyboardKey.home):
        const ExtendSelectionToLineBreakIntent(
            forward: false, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.end):
        const ExtendSelectionToLineBreakIntent(
            forward: true, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.home, shift: true):
        const ExtendSelectionToLineBreakIntent(
            forward: false, collapseSelection: false),
    const SingleActivator(LogicalKeyboardKey.end, shift: true):
        const ExtendSelectionToLineBreakIntent(
            forward: true, collapseSelection: false),
    // The following key combinations have no effect on text editing on this
    // platform:
    //   * Control + shift? + end
    //   * Control + shift? + home
    //   * Meta + X
    //   * Meta + C
    //   * Meta + V
    //   * Meta + A
    //   * Meta + shift? + Z
    //   * Meta + shift? + arrow down
    //   * Meta + shift? + arrow left
    //   * Meta + shift? + arrow right
    //   * Meta + shift? + arrow up
    //   * Meta + shift? + delete
    //   * Meta + shift? + backspace
  };

  // macOS document shortcuts: https://support.apple.com/en-us/HT201236.
  // The macOS shortcuts uses different word/line modifiers than most other
  // platforms.
  static final Map<ShortcutActivator, Intent> _macShortcuts =
      <ShortcutActivator, Intent>{
    for (final bool pressShift in const <bool>[
      true,
      false
    ]) ...<SingleActivator, Intent>{
      SingleActivator(LogicalKeyboardKey.backspace, shift: pressShift):
          const DeleteCharacterIntent(forward: false),
      SingleActivator(LogicalKeyboardKey.backspace,
              alt: true, shift: pressShift):
          const DeleteToNextWordBoundaryIntent(forward: false),
      SingleActivator(LogicalKeyboardKey.backspace,
          meta: true,
          shift: pressShift): const DeleteToLineBreakIntent(forward: false),
      SingleActivator(LogicalKeyboardKey.delete, shift: pressShift):
          const DeleteCharacterIntent(forward: true),
      SingleActivator(LogicalKeyboardKey.delete, alt: true, shift: pressShift):
          const DeleteToNextWordBoundaryIntent(forward: true),
      SingleActivator(LogicalKeyboardKey.delete, meta: true, shift: pressShift):
          const DeleteToLineBreakIntent(forward: true),
    },

    const SingleActivator(LogicalKeyboardKey.arrowLeft):
        const ExtendSelectionByCharacterIntent(
            forward: false, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.arrowRight):
        const ExtendSelectionByCharacterIntent(
            forward: true, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.arrowUp):
        const ExtendSelectionVerticallyToAdjacentLineIntent(
            forward: false, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.arrowDown):
        const ExtendSelectionVerticallyToAdjacentLineIntent(
            forward: true, collapseSelection: true),

    // Shift + Arrow: Extend selection.
    const SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true):
        const ExtendSelectionByCharacterIntent(
            forward: false, collapseSelection: false),
    const SingleActivator(LogicalKeyboardKey.arrowRight, shift: true):
        const ExtendSelectionByCharacterIntent(
            forward: true, collapseSelection: false),
    const SingleActivator(LogicalKeyboardKey.arrowUp, shift: true):
        const ExtendSelectionVerticallyToAdjacentLineIntent(
            forward: false, collapseSelection: false),
    const SingleActivator(LogicalKeyboardKey.arrowDown, shift: true):
        const ExtendSelectionVerticallyToAdjacentLineIntent(
            forward: true, collapseSelection: false),

    const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true):
        const ExtendSelectionToNextWordBoundaryIntent(
            forward: false, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.arrowRight, alt: true):
        const ExtendSelectionToNextWordBoundaryIntent(
            forward: true, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.arrowUp, alt: true):
        const ExtendSelectionToLineBreakIntent(
            forward: false, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true):
        const ExtendSelectionToLineBreakIntent(
            forward: true, collapseSelection: true),

    const SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true, alt: true):
        const ExtendSelectionToNextWordBoundaryOrCaretLocationIntent(
            forward: false),
    const SingleActivator(LogicalKeyboardKey.arrowRight,
            shift: true, alt: true):
        const ExtendSelectionToNextWordBoundaryOrCaretLocationIntent(
            forward: true),
    const SingleActivator(LogicalKeyboardKey.arrowUp, shift: true, alt: true):
        const ExtendSelectionVerticallyToAdjacentLineIntent(
            forward: false, collapseSelection: false),
    const SingleActivator(LogicalKeyboardKey.arrowDown, shift: true, alt: true):
        const ExtendSelectionVerticallyToAdjacentLineIntent(
            forward: true, collapseSelection: false),

    const SingleActivator(LogicalKeyboardKey.arrowLeft, meta: true):
        const ExtendSelectionToLineBreakIntent(
            forward: false, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.arrowRight, meta: true):
        const ExtendSelectionToLineBreakIntent(
            forward: true, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.arrowUp, meta: true):
        const ExtendSelectionToDocumentBoundaryIntent(
            forward: false, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.arrowDown, meta: true):
        const ExtendSelectionToDocumentBoundaryIntent(
            forward: true, collapseSelection: true),

    const SingleActivator(LogicalKeyboardKey.arrowLeft,
        shift: true,
        meta: true): const ExpandSelectionToLineBreakIntent(forward: false),
    const SingleActivator(LogicalKeyboardKey.arrowRight,
        shift: true,
        meta: true): const ExpandSelectionToLineBreakIntent(forward: true),
    const SingleActivator(LogicalKeyboardKey.arrowUp, shift: true, meta: true):
        const ExpandSelectionToDocumentBoundaryIntent(forward: false),
    const SingleActivator(LogicalKeyboardKey.arrowDown,
            shift: true, meta: true):
        const ExpandSelectionToDocumentBoundaryIntent(forward: true),

    const SingleActivator(LogicalKeyboardKey.keyT, control: true):
        const TransposeCharactersIntent(),

    const SingleActivator(LogicalKeyboardKey.home):
        const ScrollToDocumentBoundaryIntent(forward: false),
    const SingleActivator(LogicalKeyboardKey.end):
        const ScrollToDocumentBoundaryIntent(forward: true),
    const SingleActivator(LogicalKeyboardKey.home, shift: true):
        const ExpandSelectionToDocumentBoundaryIntent(forward: false),
    const SingleActivator(LogicalKeyboardKey.end, shift: true):
        const ExpandSelectionToDocumentBoundaryIntent(forward: true),

    const SingleActivator(LogicalKeyboardKey.pageUp): const ScrollIntent(
        direction: AxisDirection.up, type: ScrollIncrementType.page),
    const SingleActivator(LogicalKeyboardKey.pageDown): const ScrollIntent(
        direction: AxisDirection.down, type: ScrollIncrementType.page),
    const SingleActivator(LogicalKeyboardKey.pageUp, shift: true):
        const ExtendSelectionVerticallyToAdjacentPageIntent(
            forward: false, collapseSelection: false),
    const SingleActivator(LogicalKeyboardKey.pageDown, shift: true):
        const ExtendSelectionVerticallyToAdjacentPageIntent(
            forward: true, collapseSelection: false),

    const SingleActivator(LogicalKeyboardKey.keyX, meta: true):
        const CopySelectionTextIntent.cut(SelectionChangedCause.keyboard),
    const SingleActivator(LogicalKeyboardKey.keyC, meta: true):
        CopySelectionTextIntent.copy,
    const SingleActivator(LogicalKeyboardKey.keyV, meta: true):
        const PasteTextIntent(SelectionChangedCause.keyboard),
    const SingleActivator(LogicalKeyboardKey.keyA, meta: true):
        const SelectAllTextIntent(SelectionChangedCause.keyboard),
    const SingleActivator(LogicalKeyboardKey.keyZ, meta: true):
        const UndoTextIntent(SelectionChangedCause.keyboard),
    const SingleActivator(LogicalKeyboardKey.keyZ, shift: true, meta: true):
        const RedoTextIntent(SelectionChangedCause.keyboard),
    const SingleActivator(LogicalKeyboardKey.keyE, control: true):
        const ExtendSelectionToLineBreakIntent(
            forward: true, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.keyA, control: true):
        const ExtendSelectionToLineBreakIntent(
            forward: false, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.keyF, control: true):
        const ExtendSelectionByCharacterIntent(
            forward: true, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.keyB, control: true):
        const ExtendSelectionByCharacterIntent(
            forward: false, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.keyN, control: true):
        const ExtendSelectionVerticallyToAdjacentLineIntent(
            forward: true, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.keyP, control: true):
        const ExtendSelectionVerticallyToAdjacentLineIntent(
            forward: false, collapseSelection: true),
    // These keys should go to the IME when a field is focused, not to other
    // Shortcuts.
    const SingleActivator(LogicalKeyboardKey.space):
        const DoNothingAndStopPropagationTextIntent(),
    const SingleActivator(LogicalKeyboardKey.enter):
        const DoNothingAndStopPropagationTextIntent(),
    // The following key combinations have no effect on text editing on this
    // platform:
    //   * End
    //   * Home
    //   * Control + shift? + end
    //   * Control + shift? + home
    //   * Control + shift? + Z
  };

  // There is no complete documentation of iOS shortcuts: use macOS ones.
  static final Map<ShortcutActivator, Intent> _iOSShortcuts = _macShortcuts;

  // The following key combinations have no effect on text editing on this
  // platform:
  //   * Meta + X
  //   * Meta + C
  //   * Meta + V
  //   * Meta + A
  //   * Meta + shift? + arrow down
  //   * Meta + shift? + arrow left
  //   * Meta + shift? + arrow right
  //   * Meta + shift? + arrow up
  //   * Meta + delete
  //   * Meta + backspace
  static final Map<ShortcutActivator, Intent> _windowsShortcuts =
      <ShortcutActivator, Intent>{
    ..._commonShortcuts,
    const SingleActivator(LogicalKeyboardKey.pageUp):
        const ExtendSelectionVerticallyToAdjacentPageIntent(
            forward: false, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.pageDown):
        const ExtendSelectionVerticallyToAdjacentPageIntent(
            forward: true, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.home):
        const ExtendSelectionToLineBreakIntent(
            forward: false, collapseSelection: true, continuesAtWrap: true),
    const SingleActivator(LogicalKeyboardKey.end):
        const ExtendSelectionToLineBreakIntent(
            forward: true, collapseSelection: true, continuesAtWrap: true),
    const SingleActivator(LogicalKeyboardKey.home, shift: true):
        const ExtendSelectionToLineBreakIntent(
            forward: false, collapseSelection: false, continuesAtWrap: true),
    const SingleActivator(LogicalKeyboardKey.end, shift: true):
        const ExtendSelectionToLineBreakIntent(
            forward: true, collapseSelection: false, continuesAtWrap: true),
    const SingleActivator(LogicalKeyboardKey.home, control: true):
        const ExtendSelectionToDocumentBoundaryIntent(
            forward: false, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.end, control: true):
        const ExtendSelectionToDocumentBoundaryIntent(
            forward: true, collapseSelection: true),
    const SingleActivator(LogicalKeyboardKey.home, shift: true, control: true):
        const ExtendSelectionToDocumentBoundaryIntent(
            forward: false, collapseSelection: false),
    const SingleActivator(LogicalKeyboardKey.end, shift: true, control: true):
        const ExtendSelectionToDocumentBoundaryIntent(
            forward: true, collapseSelection: false),
  };

  // Web handles its text selection natively and doesn't use any of these
  // shortcuts in Flutter.
  static final Map<ShortcutActivator, Intent> _webDisablingTextShortcuts =
      <ShortcutActivator, Intent>{
    for (final bool pressShift in const <bool>[
      true,
      false
    ]) ...<SingleActivator, Intent>{
      SingleActivator(LogicalKeyboardKey.backspace, shift: pressShift):
          const DoNothingAndStopPropagationTextIntent(),
      SingleActivator(LogicalKeyboardKey.delete, shift: pressShift):
          const DoNothingAndStopPropagationTextIntent(),
      SingleActivator(LogicalKeyboardKey.backspace,
          alt: true,
          shift: pressShift): const DoNothingAndStopPropagationTextIntent(),
      SingleActivator(LogicalKeyboardKey.delete, alt: true, shift: pressShift):
          const DoNothingAndStopPropagationTextIntent(),
      SingleActivator(LogicalKeyboardKey.backspace,
          control: true,
          shift: pressShift): const DoNothingAndStopPropagationTextIntent(),
      SingleActivator(LogicalKeyboardKey.delete,
          control: true,
          shift: pressShift): const DoNothingAndStopPropagationTextIntent(),
      SingleActivator(LogicalKeyboardKey.backspace,
          meta: true,
          shift: pressShift): const DoNothingAndStopPropagationTextIntent(),
      SingleActivator(LogicalKeyboardKey.delete, meta: true, shift: pressShift):
          const DoNothingAndStopPropagationTextIntent(),
    },
    ..._commonDisablingTextShortcuts,
    const SingleActivator(LogicalKeyboardKey.keyX, control: true):
        const DoNothingAndStopPropagationTextIntent(),
    const SingleActivator(LogicalKeyboardKey.keyX, meta: true):
        const DoNothingAndStopPropagationTextIntent(),
    const SingleActivator(LogicalKeyboardKey.keyC, control: true):
        const DoNothingAndStopPropagationTextIntent(),
    const SingleActivator(LogicalKeyboardKey.keyC, meta: true):
        const DoNothingAndStopPropagationTextIntent(),
    const SingleActivator(LogicalKeyboardKey.keyV, control: true):
        const DoNothingAndStopPropagationTextIntent(),
    const SingleActivator(LogicalKeyboardKey.keyV, meta: true):
        const DoNothingAndStopPropagationTextIntent(),
    const SingleActivator(LogicalKeyboardKey.keyA, control: true):
        const DoNothingAndStopPropagationTextIntent(),
    const SingleActivator(LogicalKeyboardKey.keyA, meta: true):
        const DoNothingAndStopPropagationTextIntent(),
  };

  static const Map<ShortcutActivator, Intent> _commonDisablingTextShortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowDown, alt: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowRight, alt: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowUp, alt: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true, alt: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowRight, shift: true, alt: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowDown, meta: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowLeft, meta: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowRight, meta: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowUp, meta: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true, meta: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowRight, shift: true, meta: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowRight, shift: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.pageUp, shift: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.pageDown, shift: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.end, shift: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.home, shift: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowDown):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowLeft):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowRight):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowUp):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowRight, control: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true, control: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.arrowRight, shift: true, control: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.pageUp):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.pageDown):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.end):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.home):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.end, control: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.home, control: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.space):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.enter):
        DoNothingAndStopPropagationTextIntent(),
  };

  static final Map<ShortcutActivator, Intent> _macDisablingTextShortcuts =
      <ShortcutActivator, Intent>{
    ..._commonDisablingTextShortcuts,
    ..._iOSDisablingTextShortcuts,
    const SingleActivator(LogicalKeyboardKey.escape):
        const DoNothingAndStopPropagationTextIntent(),
    const SingleActivator(LogicalKeyboardKey.tab):
        const DoNothingAndStopPropagationTextIntent(),
    const SingleActivator(LogicalKeyboardKey.tab, shift: true):
        const DoNothingAndStopPropagationTextIntent(),
    const SingleActivator(LogicalKeyboardKey.arrowDown, shift: true, alt: true):
        const DoNothingAndStopPropagationTextIntent(),
    const SingleActivator(LogicalKeyboardKey.arrowUp, shift: true, alt: true):
        const DoNothingAndStopPropagationTextIntent(),
  };

  // Hand backspace/delete events that do not depend on text layout (delete
  // character and delete to the next word) back to the IME to allow it to
  // update composing text properly.
  static const Map<ShortcutActivator, Intent> _iOSDisablingTextShortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.backspace):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.backspace, shift: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.delete):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.delete, shift: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.backspace, alt: true, shift: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.backspace, alt: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.delete, alt: true, shift: true):
        DoNothingAndStopPropagationTextIntent(),
    SingleActivator(LogicalKeyboardKey.delete, alt: true):
        DoNothingAndStopPropagationTextIntent(),
  };

  static Map<ShortcutActivator, Intent> get _shortcuts {
    if (Platform.isAndroid) {
      return _androidShortcuts;
    } else if (Platform.isIOS) {
      return _iOSShortcuts;
    } else if (Platform.isMacOS) {
      return _macShortcuts;
    } else if (Platform.isLinux) {
      return _linuxShortcuts;
    } else if (Platform.isWindows) {
      return _windowsShortcuts;
    } else if (Platform.isFuchsia) {
      return _fuchsiaShortcuts;
    }

    return _commonShortcuts;
  }

  static Map<ShortcutActivator, Intent>? _getDisablingShortcut() {
    if (kIsWeb) {
      return _webDisablingTextShortcuts;
    }

    if (Platform.isIOS) {
      return _iOSDisablingTextShortcuts;
    } else if (Platform.isMacOS) {
      return _macDisablingTextShortcuts;
    }

    return null;
  }

  static Map<ShortcutActivator, Intent> get shortcuts {
    return {
      ..._shortcuts,
      ..._getDisablingShortcut() ?? {},
    };
  }
}
