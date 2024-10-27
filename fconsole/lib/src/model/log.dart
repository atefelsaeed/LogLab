import 'dart:convert';

enum LogType {
  log,
  error,
}

class Log {
  final dynamic log;
  final LogType type;
  final StackTrace? stackTrace;
  DateTime? dateTime;

  Log(
    this.log,
    this.type, {
    this.stackTrace,
  }) {
    dateTime = DateTime.now();
  }

  bool get isJson => log is Map || log is List;

  @override
  String toString() {
    var logText = log.toString();
    return logText;
  }

  // Convert Log object to a Map (for JSON serialization)
  Map<String, dynamic> toJson() {
    return {
      'log': isJson ? jsonEncode(log) : log.toString(),
      'type': type
          .toString()
          .split('.')
          .last, // Save enum as string (e.g., 'log', 'error')
      'stackTrace': stackTrace?.toString(),
      'dateTime': dateTime?.toIso8601String(),
    };
  }

  // Convert a Map (JSON) to a Log object
  factory Log.fromJson(Map<String, dynamic> json) {
    dynamic logContent;
    try {
      // If the log is JSON, decode it
      logContent = jsonDecode(json['log']);
    } catch (e) {
      // Otherwise, keep it as a string
      logContent = json['log'];
    }

    return Log(
      logContent,
      LogType.values
          .firstWhere((e) => e.toString().split('.').last == json['type']),
      stackTrace: json['stackTrace'] != null
          ? StackTrace.fromString(json['stackTrace'])
          : null,
    )..dateTime = DateTime.parse(json['dateTime']);
  }
}
