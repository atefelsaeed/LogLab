import 'dart:async';

import 'package:fconsole/fconsole.dart';
import 'package:fconsole/src/model/log.dart';
import 'package:fconsole/src/view/messages.dart';
import 'package:flutter/material.dart';

typedef ErrHandler = void Function(
    Zone, ZoneDelegate, Zone, Object, StackTrace);

/// Note: beforeRun will be called before runApp()
/// if some code run ouside runAppWithConsole, the log will not cache by fconsole.
void runAppWithFConsole({
  required Widget app,
  Future Function()? beforeRun,
  required FConsoleCardDelegate? delegate,
  // required ConsoleDisplayMode displayMode,
  ErrHandler? errHandler,
}) async {
// Capture Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FConsole.error(
      'FlutterError: ${details.exception}',
      stackTrace: details.stack,
      noPrint: true, // Avoid redundant logging
    );

    Zone.current.handleUncaughtError(
      details.exception,
      details.stack ?? StackTrace.current,
    );
  };

  FConsole.instance.delegate = delegate ?? DefaultCardDelegate();

  var zoneSpecification = ZoneSpecification(
    print: (
      Zone self,
      ZoneDelegate parent,
      Zone zone,
      String line,
    ) {
      // parent.print(zone, "Intercepted: $line");///TODO
      FConsole.log(line, noPrint: true);
      Zone.root.print(line);
    },
    handleUncaughtError: (
      Zone self,
      ZoneDelegate parent,
      Zone zone,
      Object error,
      StackTrace stackTrace,
    ) {
      FConsole.error(error, noPrint: true);
      Zone.root.print('$error');
      errHandler?.call(self, parent, zone, error, stackTrace);
    },
  );

  runZoned(
    () async {
      await beforeRun?.call();
      runApp(
        ConsoleWidget(
          options: ConsoleOptions(
            // displayMode:displayMode,
          ),
          child: app,
        ),
      );
    },
    zoneSpecification: zoneSpecification,
    onError: (error, stackTrace) {
      // Handle uncaught errors outside the zone specification
      FConsole.error(error, stackTrace: stackTrace, noPrint: true);
    },
  );
}

enum FConsoleStatus {
  hide,
  consoleBtn,
  panel,
}

class FConsole extends ChangeNotifier {
  ConsoleOptions options = ConsoleOptions();

  ValueNotifier<FConsoleStatus> status = ValueNotifier(FConsoleStatus.hide);

  static bool get isOn => FConsole.instance.status.value != FConsoleStatus.hide;

  static bool get isOff => !isOn;

  /// show internal message in panel view.
  static final showMessage = showFconsoleMessage;

  FConsoleCardDelegate? delegate;

  List<Log> allLog = [];
  List<Log> errorLog = [];
  List<Log> verboselog = [];
  int currentLogIndex = 0;

  List<Log>? logListOfType(int? logType) {
    if (logType == 0) {
      return allLog;
    }
    if (logType == 1) {
      return verboselog;
    }
    if (logType == 2) {
      return errorLog;
    }
    return null;
  }

  static log(dynamic log, {bool noPrint = false}) {
    if (!noPrint) print(log);
    if (log != null) {
      Log lg = Log("💡$log", LogType.log);
      FConsole.instance.verboselog.add(lg);
      FConsole.instance.allLog.add(lg);
      FConsole.instance.notifyListeners();
    }
  }

  static error(dynamic error, {StackTrace? stackTrace, bool noPrint = false}) {
    if (!noPrint) print(error);
    if (error != null) {
      if (error is Error && stackTrace == null) {
        stackTrace = error.stackTrace;
      }
      Log lg = Log(error, LogType.error, stackTrace: stackTrace);
      FConsole.instance.errorLog.add(lg);
      FConsole.instance.allLog.add(lg);
      FConsole.instance.notifyListeners();
    }
  }

  void clear(bool clearAll) {
    if (clearAll) {
      allLog.clear();
      verboselog.clear();
      errorLog.clear();
    } else {
      if (currentLogIndex == 0) {
        allLog.clear();
      } else if (currentLogIndex == 1) {
        verboselog.clear();
      } else if (currentLogIndex == 2) {
        errorLog.clear();
      }
    }
    FConsole.instance.notifyListeners();
  }

  /// Singleton
  static FConsole? _instance;

  factory FConsole() => _getInstance();

  static FConsole get instance => _getInstance();

  static FConsole _getInstance() {
    _instance ??= FConsole._();
    return _instance!;
  }

  FConsole._();
}

class ConsoleOptions {
  final bool showTime;
  final String timeFormat;
  final ConsoleDisplayMode displayMode;

  ConsoleOptions({
    this.showTime = true,
    this.timeFormat = "HH:mm:ss",
    this.displayMode = ConsoleDisplayMode.None,
  });
}

///How to show the console button
enum ConsoleDisplayMode {
  None, //Don't show
  Always, // always show
}
