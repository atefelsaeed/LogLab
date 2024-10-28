import 'package:fconsole/fconsole.dart';
import 'package:flutter/material.dart';

import 'settings_row_item.dart';

void main() => runAppWithFConsole(
      delegate: MyCardDelegate(),
      // displayMode: ConsoleDisplayMode.Always,
      app: const MyApp(),
    );

class MyCardDelegate extends FConsoleCardDelegate {
  @override
  List<FConsoleCard> cardsBuilder(DefaultCards defaultCards) {
    return [
      defaultCards.logCard,
      defaultCards.flowCard,
      FConsoleCard(
        name: "Custom",
        builder: (ctx) => const CustomLogPage(),
      ),
      defaultCards.sysInfoCard,
    ];
  }
}

class CustomLogPage extends StatelessWidget {
  const CustomLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: const Text('custom page content'),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    FConsole.instance.status.addListener(() {
      setState(() {});
    });
  }

  bool get consoleHasShow =>
      FConsole.instance.status.value != FConsoleStatus.hide;

  double slideValue = 0;

  @override
  Widget build(BuildContext context) {
    return ConsoleWidget(
      options: ConsoleOptions(),
      child: MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.grey.shade300,
          appBar: AppBar(
            title: const Text(
              'FConsole example app',
            ),
          ),
          body: ListView(
            children: [
              const SizedBox(
                height: 50,
              ),
              SettingRow(
                icon: consoleHasShow ? Icons.tab : Icons.tab_unselected,
                text: consoleHasShow ? 'Console Open' : 'Console Close',
                right: Container(
                  height: 36,
                  padding: const EdgeInsets.only(right: 12),
                  child: Switch(
                    value: consoleHasShow,
                    onChanged: (v) {
                      if (v) {
                        showConsole();
                      } else {
                        hideConsole();
                      }
                      setState(() {});
                    },
                  ),
                ),
              ),
              Container(height: 12),
              SettingRow(
                icon: Icons.info_outline,
                text: 'Print log',
                right: Container(),
                onTap: () {
                  fconsole.log('Print information:', DateTime.now());
                },
              ),
              SettingRow(
                icon: Icons.warning,
                text: 'Print error',
                right: Container(),
                onTap: () {
                  fconsole.error('Print Error:', DateTime.now());
                },
              ),
              Container(height: 12),
              SettingRow(
                icon: Icons.edit,
                text: 'Native Print',
                right: Container(),
                onTap: () {
                  print(DateTime.now().toIso8601String());
                },
              ),
              SettingRow(
                icon: Icons.edit,
                text: 'Native Throw',
                right: Container(),
                onTap: () {
                  var _ = [][123];
                  throw DateTime.now().toIso8601String();
                },
              ),
              Container(height: 12),
              SettingRow(
                icon: Icons.info_outline,
                text: 'Slide Event Flow',
                right: Slider(
                  value: slideValue,
                  onChanged: (v) {
                    // FlowLog.of(
                    //   'Slider',
                    //   Duration(seconds: 2),
                    // ).log('Value: $v');
                    FlowLog.of(
                      'Slider',
                      const Duration(seconds: 2),
                    ).log({
                      'type': 'slide',
                      "value": [
                        for (var i = 0; i < 100; i++)
                          {
                            "value": {
                              "value": {
                                "value": {
                                  "value": "$v",
                                },
                              },
                            },
                          },
                      ],
                    });
                    setState(() {
                      slideValue = v;
                    });
                  },
                  // onChangeEnd: (value) => FlowLog.of('Slider').end(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
