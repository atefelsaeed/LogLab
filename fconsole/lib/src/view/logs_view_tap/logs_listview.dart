import 'package:fconsole/fconsole.dart';
import 'package:fconsole/src/model/log.dart';
import 'package:fconsole/src/style/color.dart';
import 'package:fconsole/src/style/exetenstion.dart';
import 'package:fconsole/src/style/text.dart';
import 'package:fconsole/src/view/messages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

class LogListView extends StatefulWidget {
  final int currentIndex;
  final GlobalKey globalKey;

  const LogListView(this.currentIndex, {Key? key, required this.globalKey}) : super(key: key);

  @override
  _LogListViewState createState() => _LogListViewState();
}

class _LogListViewState extends State<LogListView> {
  final TextEditingController _filterTEC = TextEditingController();
  List<Log>? logs;
  int? currentIndex;

  @override
  initState() {
    super.initState();
    currentIndex = widget.currentIndex;
    logs = FConsole.instance.logListOfType(currentIndex);
    FConsole.instance.addListener(_didUpdateLog);
  }

  @override
  dispose() {
    super.dispose();
    FConsole.instance.removeListener(_didUpdateLog);
    _filterTEC.dispose();
  }

  _didUpdateLog() {
    setState(() {
      logs = FConsole.instance.logListOfType(currentIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Log> newlogs = newLogs();

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          filterView(),
          RepaintBoundary(
             key: widget.globalKey,
            child: ListView.builder(
              itemCount: newlogs.length,
              reverse: true,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, index) {
                var log = newlogs[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        if (log.stackTrace != null) {
                          showFconsoleMessage(
                            'Stack Trace:\n${log.stackTrace!.toString()}',
                          );
                        }
                      },
                      onLongPress: () {
                        var logText = log.toString();
                        var stackTrace = log.stackTrace;
                        if (stackTrace != null) {
                          logText += '\nStack Trace:\n$stackTrace';
                        }
                        Clipboard.setData(
                          ClipboardData(text: logText),
                        );
                        showFconsoleMessage("Copy Success");
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        color: ColorPlate.clear,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (log.stackTrace != null)
                              const Icon(
                                Icons.bug_report,
                                color: ColorPlate.red,
                                size: 16,
                              ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: StText.normal(
                                  '${newlogs[index]}',
                                  // maxLines: 100,
                                  style: TextStyle(
                                    color: newlogs[index].color,
                                  ),
                                ),
                              ),
                            ),
                            if (FConsole.instance.options.showTime)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: StText.small(
                                  time(newlogs[index]),
                                  style: TextStyle(
                                    color: currentIndex == 2
                                        ? ColorPlate.red
                                        : ColorPlate.darkGray,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1)
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String time(Log log) {
    if (FConsole.instance.options.showTime) {
      return DateFormat(FConsole.instance.options.timeFormat)
          .format(log.dateTime!);
    }
    return "";
  }

  List<Log> newLogs() {
    List<Log> newlogs = List.from(logs!);
    if (_filterTEC.text.trim().isNotEmpty) {
      String filter = _filterTEC.text.trim();
      //filter
      newlogs
        ..retainWhere((log) {
          return log.toString().contains(filter);
        });
    }
    return newlogs.reversed.toList();
  }

  Widget filterView() {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: ColorPlate.gray, width: 0.2))),
      child: Row(
        children: <Widget>[
          Expanded(
            child: CupertinoTextField(
              controller: _filterTEC,
              clearButtonMode: OverlayVisibilityMode.editing,
              style: const TextStyle(color: ColorPlate.black, fontSize: 16),
              decoration: const BoxDecoration(),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {});
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              height: double.infinity,
              color: ColorPlate.lightGray,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Center(
                child: Text(
                  "Filter",
                  style: TextStyle(color: ColorPlate.black, fontSize: 18),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
