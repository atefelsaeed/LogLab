import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fconsole/src/style/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemInfoPanel extends StatefulWidget {
  const SystemInfoPanel({Key? key}) : super(key: key);

  @override
  _SystemInfoPanelState createState() => _SystemInfoPanelState();
}

class _SystemInfoPanelState extends State<SystemInfoPanel> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      if (Platform.isAndroid) {
        _deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        _deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      _deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    if (mounted) {
      setState(() {});
    }
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      //'Manufacturer': build.manufacturer, //制造商
      'Model': build.model, //终端产品名称
      //'Brand': build.brand, //产品品牌
      // 'version.securityPatch': build.version.securityPatch,
      'Version.sdkInt': build.version.sdkInt,
      'Version.release': build.version.release,
      // 'Version.previewSdkInt': build.version.previewSdkInt,
      // 'Version.incremental': build.version.incremental,
      // 'version.codename': build.version.codename,
      //'version.baseOS': build.version.baseOS,
      // 'Board': build.board,
      //  'bootloader': build.bootloader,

      // 'device': build.device,
      //'display': build.display,
      //'fingerprint': build.fingerprint,
      //'hardware': build.hardware,
      //'host': build.host,
      //'id': build.id,
      // 'product': build.product,
      // 'supported32BitAbis': build.supported32BitAbis,
      // 'supported64BitAbis': build.supported64BitAbis,
      'SupportedAbis': build.supportedAbis,
      // 'tags': build.tags,
      // 'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      // 'AndroidId': build.androidId,
      // 'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'Name': data.name,
      'SystemName': data.systemName,
      'SystemVersion': data.systemVersion,
      'Model': data.model,
      //'LocalizedModel': data.localizedModel,
      'IdentifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
//      'utsname.sysname:': data.utsname.sysname,
//      'utsname.nodename:': data.utsname.nodename,
//      'utsname.release:': data.utsname.release,
//      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _deviceData.keys.map((String property) {
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Text(
                    property,
                    style: const TextStyle(
                      color: ColorPlate.darkGray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                    child: Text(
                  '${_deviceData[property]}',
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                )),
              ],
            ),
            const Divider(
              height: 1,
            ),
          ],
        );
      }).toList(),
    );
  }
}
