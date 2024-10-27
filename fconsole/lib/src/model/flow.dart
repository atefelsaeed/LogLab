import 'dart:async';


import 'package:fconsole/src/core/fconsole.dart';
import 'package:fconsole/src/model/log.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FlowLogDesc {
  final String? detail;
  final bool? hasError;
  final bool? hasItem;

  FlowLogDesc({
    this.detail,
    this.hasError,
    this.hasItem,
  });

  @override
  String toString() {
    return detail!;
  }
}

enum FlowLogEvent {
  start,
  log,
  error,
  end,
}

Set<Function(FlowLogEvent, FlowLog)> _callers = Set();

//A workflow
class FlowLog {
  final String name;

  /// id, optional, empty by default, used as a unique identifier when name conflicts.
  final String id;
  List<Log>? logs;

  DateTime? createdAt;

  static addGlobalListener(void Function(FlowLogEvent, FlowLog) listener) {
    _callers.add(listener);
  }

  static removeGlobalListener(void Function(FlowLogEvent, FlowLog) listener) {
    _callers.remove(listener);
  }

  static clearGlobalListener() {
    _callers.clear();
  }

  _emit(FlowLogEvent event, FlowLog log) {
    for (var call in _callers) {
      call.call(event, log);
    }
  }

  /// Timeout period. If it exceeds this period, it will be considered as a new Flow.
  final Duration? timeout;

  DateTime? _endAt;
  DateTime? get endAt => _endAt;

  FlowLog._({
    required this.name,
    this.logs,
    this.timeout,
    this.createdAt,
    DateTime? end,
    this.id = '',
    required bool hasError,
  }) : _endAt = end {
    logs ??= [];
    _hasError = hasError;
  }

  bool _hasError = false;

  FlowLog({
    this.name = "system",
    this.id = "",
    this.logs,
    Duration? timeout = const Duration(seconds: 30),
  })  : createdAt = DateTime.now(),
        timeout = timeout ?? const Duration(seconds: 30) {
    logs ??= [];
    FlowCenter.instance.workingFlow[name + id] = this;
    _emit(FlowLogEvent.start, this);
  }

  DateTime? get latestTime {
    if (logs!.isEmpty) {
      return createdAt;
    }
    return logs!.last.dateTime;
  }

  DateTime get expireTime =>
      latestTime!.add(timeout ?? const Duration(seconds: 30));

  bool get isTimeout =>
      expireTime.millisecondsSinceEpoch < DateTime.now().millisecondsSinceEpoch;

  Timer? timer;

  /// Add a new log. If the timeout occurs, summarize the log and add the completed.
  _addRawLog(Log log) {
    if (isTimeout) {
      end(
        'End with timeout(${timeout!.inSeconds}s)',
        LogType.error,
      );
    } else {
      timer?.cancel();
      timer = null;
      timer = Timer(timeout!, () {
        end(
          'End with timeout(${timeout!.inSeconds}s)',
          LogType.error,
        );
        timer?.cancel();
        timer = null;
      });
    }
    if (log.type == LogType.error) {
      _hasError = true;
      _emit(FlowLogEvent.error, this);
    } else {
      _emit(FlowLogEvent.error, this);
    }
    logs!.add(log);
    FlowCenter.instance._notify();
  }

  /// Add a regular log.
  log(dynamic log) {
    _addRawLog(Log(log, LogType.log));
  }

  /// Add a regular log.
  add(dynamic log) => this.log(log);

  /// Add an Error log
  error(dynamic log) {
    _addRawLog(Log(log, LogType.error));
  }

  /// End the current Flow.
  end([dynamic log, LogType? type]) {
    if (log != null) {
      if (type == LogType.error) {
        _hasError = true;
      }
      logs!.add(Log(log, type ?? LogType.log));
    }

    timer?.cancel();
    timer = null;
    _endAt = DateTime.now();
    final newLog = FlowLog._(
      name: name,
      logs: List.from(logs!),
      timeout: timeout,
      createdAt: createdAt,
      end: endAt,
      id: id,
      hasError: _hasError,
    );
    // Make a copy
    FlowCenter.instance.flowList.add(newLog);
    _emit(FlowLogEvent.end, newLog);
    createdAt = DateTime.now();
    _endAt = null;
    FlowCenter.instance.workingFlow.remove(name + id);
    logs!.clear();
    FlowCenter.instance._notify();
  }

  FlowLogDesc get desc {
    int normalCount = 0;
    int errorCount = 0;
    for (var log in logs!) {
      if (log.type == LogType.log) {
        normalCount += 1;
      } else {
        errorCount += 1;
      }
    }
    var detail = '$normalCount Logs, $errorCount Errors';
    var duration = '';
    if (endAt != null) {
      duration = ", ${createdAt!.difference(endAt!).inMilliseconds * -1}ms";
    }
    return FlowLogDesc(
      detail: detail + duration,
      hasError: errorCount > 0,
      hasItem: (errorCount + errorCount) > 0,
    );
  }

  String get startTimeText =>
      DateFormat(FConsole.instance.options.timeFormat).format(createdAt!);

  String get endTimeText => endAt == null
      ? 'null'
      : DateFormat(FConsole.instance.options.timeFormat).format(endAt!);

  String get shareText => [
        if (logs!.isNotEmpty) "Time: ${logs!.first.dateTime}",
        "Event: $name",
        "Overview: $desc",
        "-----------------",
        logsDesc,
        "-------EOF-------",
      ].join('\n');

  String get logsDesc {
    List<String> logStr = [];
    for (var i = 0; i < logs!.length; i++) {
      var log = logs![i];
      if (i == 0) {
        logStr.add('[start]$log');
        continue;
      }
      var lastLog = logs![i - 1];
      var diff = log.dateTime!.difference(lastLog.dateTime!).inMilliseconds;
      logStr.add('[${diff}ms]$log');
    }
    return logStr.join('\n');
  }

  /// Get an ongoing Flow by name. If the flow has not been created yet, create a new one and return it.
  static FlowLog of(String name, [Duration? initTimeOut]) {
    if (FlowCenter.instance.workingFlow[name] == null) {
      FlowCenter.instance.workingFlow[name] = FlowLog(
        name: name,
        timeout: initTimeOut,
      );
    }
    return FlowCenter.instance.workingFlow[name]!;
  }

  ///Get an ongoing Flow by name. If the flow has not been created, create a new one and return it.
  /// This method can additionally specify an id. When the names are the same, use the id to determine whether it is the same flow.
  static FlowLog ofNameAndId(
    String name, {
    Duration? initTimeOut,
    String id = '',
  }) {
    if (FlowCenter.instance.workingFlow[name + id] == null) {
      FlowCenter.instance.workingFlow[name + id] = FlowLog(
        name: name,
        timeout: initTimeOut,
        id: id,
      );
    }
    return FlowCenter.instance.workingFlow[name + id]!;
  }

  @override
  String toString() {
    return 'FlowLog: $name\nLog: $logs\n';
  }
}

class FlowCenter extends ChangeNotifier {
  /// Ongoing process documentation.
  Map<String?, FlowLog> workingFlow = {};

  /// Completed process records.
  List<FlowLog> flowList = [];

  clearAll() {
    flowList.clear();
    workingFlow.clear();
  }

  _notify() {
    notifyListeners();
  }

  // Factory Pattern
  factory FlowCenter() => _getInstance()!;
  static FlowCenter get instance => _getInstance()!;
  static FlowCenter? _instance;
  FlowCenter._internal() {
    // initialization
  }
  static FlowCenter? _getInstance() {
    _instance ??= FlowCenter._internal();
    return _instance;
  }
}
