import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fconsole/src/model/log.dart';

class SaveAppLogs {
  final String _fileName = "Sulfah_Logs_${DateTime.now()}.json";
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  // Get the log file path
  Future<String> get _logFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_fileName'; // Save logs as JSON
  }

  // Get system information
  Future<Map<String, dynamic>> _getSystemInfo() async {
    Map<String, dynamic> deviceData = {};
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        deviceData = _readAndroidBuildData(androidInfo);
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        deviceData = _readIosDeviceInfo(iosInfo);
      }
    } catch (e) {
      deviceData = {'Error': 'Failed to get device info'};
    }
    return deviceData;
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return {
      'Model': build.model,
      'Version.sdkInt': build.version.sdkInt,
      'Version.release': build.version.release,
      'SupportedAbis': build.supportedAbis,
      'isPhysicalDevice': build.isPhysicalDevice,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return {
      'Name': data.name,
      'SystemName': data.systemName,
      'SystemVersion': data.systemVersion,
      'Model': data.model,
      'IdentifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.machine:': data.utsname.machine,
    };
  }

  // Write the list of logs and system info to a file
  Future<void> writeLogsAndSystemInfoToFile(List<Log> logs) async {
    final filePath = await _logFilePath;
    final file = File(filePath);

    // Get system info
    final systemInfo = await _getSystemInfo();

    // Convert logs and system info to JSON
    List<Map<String, dynamic>> jsonLogs =
        logs.map((log) => log.toJson()).toList();
    Map<String, dynamic> finalData = {
      'system_info': systemInfo,
      'logs': jsonLogs,
    };

    // Write the JSON string to the file
    await file.writeAsString(jsonEncode(finalData), flush: true);
  }

  // Read the list of logs from the file
  Future<List<Log>> readLogsFromFile() async {
    final filePath = await _logFilePath;
    final file = File(filePath);

    if (await file.exists()) {
      String jsonString = await file.readAsString();

      // Parse the JSON string and convert it back to List<Log>
      Map<String, dynamic> jsonData = jsonDecode(jsonString);
      List<dynamic> jsonLogs = jsonData['logs'];
      return jsonLogs.map((json) => Log.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  // Export logs and share
  Future<void> exportLogsToFile() async {
    final filePath = await _logFilePath;
    final file =
        XFile(filePath, mimeType: 'application/json'); // JSON mime type

    await Share.shareXFiles(
      [file],
      text: "Sulfah App Logs",
      subject: "Logs",
    );
  }

  // Save and share logs with system info
  Future<void> saveAndShareLogs({required List<Log> logs}) async {
    await writeLogsAndSystemInfoToFile(logs);
    await exportLogsToFile();
  }
}
