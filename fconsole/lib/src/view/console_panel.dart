part of 'console.dart';

class ConsolePanel extends StatefulWidget {
  final Function onHideTap;

  const ConsolePanel(this.onHideTap, {Key? key}) : super(key: key);

  @override
  _ConsolePanelState createState() => _ConsolePanelState();
}

class _ConsolePanelState extends State<ConsolePanel> {
  int currentIndex = 0;

  Set<Function> clearFunctions = {};

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData =
        MediaQueryData.fromView(View.of(context));

    var customCards =
        FConsole.instance.delegate?.cardsBuilder(DefaultCards()) ?? [];

    var topOpViews = Container(
      height: 50,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: ColorPlate.lightGray,
        border: Border(
          bottom: BorderSide(color: ColorPlate.gray, width: 0.2),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            for (var index in customCards.asMap().keys.toList())
              TapBtn(
                selected: currentIndex == index,
                title: customCards[index].name,
                onTap: () {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
          ].fold<List<Widget>>(
            [],
            (previousValue, element) => [
              ...previousValue,
              element,
              Container(
                width: 0.5,
                height: double.infinity,
                color: ColorPlate.gray.withOpacity(0.5),
              ),
            ],
          )..removeLast(),
        ),
      ),
    );

    return Material(
      color: ColorPlate.black.withOpacity(0.3),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  widget.onHideTap.call();
                },
                behavior: HitTestBehavior.translucent,
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              color: ColorPlate.white,
              width: double.infinity,
              height: mediaQueryData.size.height * 0.8,
              child: Column(
                children: <Widget>[
                  topOpViews,
                  Expanded(
                    child: FconsoleMessageView(
                      child: IndexedStack(
                        index: currentIndex,
                        children: customCards
                            .map(
                              (e) => e.builder(context),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  get isDark =>
      MediaQueryData.fromView(View.of(context)).platformBrightness ==
      Brightness.dark;
}
