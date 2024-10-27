import 'package:fconsole/fconsole.dart';
import 'package:fconsole/src/core/save_app_logs.dart';
import 'package:fconsole/src/style/color.dart';
import 'package:fconsole/src/view/bottom_action_view.dart';
import 'package:fconsole/src/view/logs_view_tap/logs_listview.dart';
import 'package:fconsole/src/view/logs_view_tap/tap_view_btn.dart';
import 'package:flutter/material.dart';

class LogInfoPanel extends StatefulWidget {
  const LogInfoPanel({Key? key}) : super(key: key);

  @override
  _LogInfoPanelState createState() => _LogInfoPanelState();
}

class _LogInfoPanelState extends State<LogInfoPanel>
    with SingleTickerProviderStateMixin {
  int _currentTabIndex = 0;

  int get currentIndex => _currentTabIndex; //0 all 1 log 2 error

  set currentIndex(int index) {
    _currentTabIndex = index;
    FConsole.instance.currentLogIndex = _currentTabIndex;
  }

  @override
  void initState() {
    super.initState();
  }

  final previewContainer1 = GlobalKey();
  final previewContainer2 = GlobalKey();
  final previewContainer3 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var tabbar = Container(
      height: 40,
      decoration: const BoxDecoration(
        color: ColorPlate.lightGray,
        border: Border(
          bottom: BorderSide(color: ColorPlate.gray, width: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TapBtn(
            selected: currentIndex == 0,
            small: true,
            title: "All",
            onTap: () {
              setState(() {
                currentIndex = 0;
              });
            },
          ),
          Container(
            width: 0.5,
            height: double.infinity,
            color: ColorPlate.gray,
          ),
          TapBtn(
            selected: currentIndex == 1,
            small: true,
            title: "Log",
            onTap: () {
              setState(() {
                currentIndex = 1;
              });
            },
          ),
          Container(
            width: 0.5,
            height: double.infinity,
            color: ColorPlate.gray,
          ),
          TapBtn(
            selected: currentIndex == 2,
            small: true,
            title: "Error",
            onTap: () {
              setState(() {
                currentIndex = 2;
              });
            },
          ),
        ],
      ),
    );
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: ColorPlate.gray,
            border: Border(
              bottom: BorderSide(color: ColorPlate.gray, width: 0.2),
            ),
          ),
          child: tabbar,
        ),
        Expanded(
          child: IndexedStack(
            index: currentIndex,
            children: [
              LogListView(
                0,
                globalKey: previewContainer1,
              ),
              LogListView(
                1,
                globalKey: previewContainer2,
              ),
              LogListView(
                2,
                globalKey: previewContainer3,
              )
            ],
          ),
        ),
        BottomActionView(
          onClear: () {
            ///Clear logs
            // FConsole.instance.clear(true);
            SaveAppLogs().saveAndShareLogs(
              logs: FConsole().allLog,
            );
          },
        ),
      ],
    );
  }
}
