import 'package:fconsole/src/view/flow_view_tap/flow_info.dart';
import 'package:fconsole/src/view/logs_view_tap/log_info_panel.dart';
import 'package:fconsole/src/view/system_info_view_tap/system_info_view_tap.dart';
import 'package:flutter/material.dart';

abstract class FConsoleCardDelegate {
  List<FConsoleCard> cardsBuilder(DefaultCards defaultCards);
}

class DefaultCardDelegate extends FConsoleCardDelegate {
  @override
  List<FConsoleCard> cardsBuilder(DefaultCards defaultCards) {
    return [
      defaultCards.logCard,
      defaultCards.flowCard,
      defaultCards.sysInfoCard,
    ];
  }
}

class DefaultCards {
  final FConsoleCard logCard = FConsoleCard(
    name: 'Log',
    builder: (context) => const LogInfoPanel(),
  );
  final FConsoleCard flowCard = FConsoleCard(
    name: 'Flow',
    builder: (context) => const FlowInfo(),
  );
  final FConsoleCard sysInfoCard = FConsoleCard(
    name: 'System',
    builder: (context) => const SystemInfoPanel(),
  );
}

class FConsoleCard {
  final String name;
  final Widget Function(BuildContext context) builder;

  FConsoleCard({required this.name, required this.builder});
}
