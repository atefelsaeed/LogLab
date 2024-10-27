import 'dart:collection';

import 'package:fconsole/fconsole.dart';
import 'package:fconsole/src/core/save_app_logs.dart';
import 'package:fconsole/src/style/color.dart';
import 'package:fconsole/src/style/text.dart';
import 'package:fconsole/src/view/console_container/touch_move_view.dart';
import 'package:fconsole/src/view/logs_view_tap/logs_listview.dart';
import 'package:fconsole/src/view/logs_view_tap/tap_view_btn.dart';
import 'package:fconsole/src/view/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

part 'console_container/console_container.dart';
part 'console_panel.dart';

LinkedHashMap<Object, BuildContext> _contextMap = LinkedHashMap();

OverlayEntry? consoleEntry;

///show console btn
void showConsole({BuildContext? context}) {
  if (FConsole.instance.status.value == FConsoleStatus.hide) {
    FConsole.instance.status.value = FConsoleStatus.consoleBtn;
    context ??= _contextMap.values.first;
    _ConsoleTheme _consoleTheme = _ConsoleTheme.of(context)!;
    Widget consoleBtn = _consoleTheme.consoleBtn ?? _consoleBtn();

    Alignment consolePosition =
        _consoleTheme.consolePosition ?? const Alignment(-0.8, 0.7);

    consoleEntry = OverlayEntry(builder: (ctx) {
      return ConsoleContainer(
        consoleBtn: consoleBtn,
        consolePosition: consolePosition,
      );
    });
    Overlay.of(context).insert(consoleEntry!);
  }
}

///hide console btn
void hideConsole({BuildContext? context}) {
  if (consoleEntry != null) {
    FConsole.instance.status.value = FConsoleStatus.hide;
    consoleEntry!.remove();
    consoleEntry = null;
  }
}

OverlayEntry? consolePanelEntry;

///show console panel
showConsolePanel(Function onHideTap, {BuildContext? context}) {
  context ??= _contextMap.values.first;
  consolePanelEntry = OverlayEntry(builder: (ctx) {
    return ConsolePanel(() {
      onHideTap();
      hideConsolePanel();
    });
  });
  Overlay.of(context).insert(consolePanelEntry!);
}

hideConsolePanel() {
  if (consolePanelEntry != null) {
    FConsole.instance.status.value = FConsoleStatus.consoleBtn;
    consolePanelEntry!.remove();
    consolePanelEntry = null;
  }
}

class ConsoleWidget extends StatefulWidget {
  /// Subcomponent, usually App layer
  final Widget child;

  /// Floating button component
  final Widget? consoleBtn;

  /// Floating button configuration
  final ConsoleOptions? options;

  /// Default initialization position
  final Alignment? consolePosition;

  const ConsoleWidget({
    Key? key,
    required this.child,
    this.consolePosition,
    this.consoleBtn,
    this.options,
  }) : super(key: key);

  @override
  _ConsoleWidgetState createState() => _ConsoleWidgetState();
}

class _ConsoleWidgetState extends State<ConsoleWidget> {
  @override
  dispose() {
    _contextMap.remove(this);
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    FConsole.instance.options = widget.options ?? ConsoleOptions();
    WidgetsBinding.instance.addPostFrameCallback((d) {
      if (FConsole.instance.options.displayMode == ConsoleDisplayMode.Always) {
        showConsole();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = _ConsoleTheme(
      consoleBtn: widget.consoleBtn,
      consolePosition: widget.consolePosition,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          textDirection: TextDirection.ltr,
          children: [
            /// Restoring normalcy in the safe zone
            widget.child,
            Localizations(
              locale: const Locale("zh"),
              delegates: const [
                GlobalCupertinoLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              child: Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (ctx) {
                      _contextMap[this] = ctx;
                      return Container();
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return Material(
      child: body,
    );
  }
}

class _ConsoleTheme extends InheritedWidget {
  final Widget? consoleBtn;
  @override
  final Widget child;
  final Alignment? consolePosition;

  const _ConsoleTheme({required this.child, this.consoleBtn, this.consolePosition})
      : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static _ConsoleTheme? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ConsoleTheme>();
}
