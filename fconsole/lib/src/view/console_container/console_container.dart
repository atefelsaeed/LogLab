part of '../console.dart';

class ConsoleContainer extends StatefulWidget {
  final Widget? consoleBtn;
  final Alignment? consolePosition;

  const ConsoleContainer({Key? key, this.consoleBtn, this.consolePosition})
      : super(key: key);

  @override
  _ConsoleContainerState createState() => _ConsoleContainerState();
}

class _ConsoleContainerState extends State<ConsoleContainer> {
  final GlobalKey _childGK = GlobalKey();
  double xPosition = 0;
  double yPosition = 0;
  double childWidth = 0;
  double childHeight = 0;

  ///Do you want to calculate the size?
  bool isCalculateSize = true;

  bool get isShowConsoleBtn =>
      FConsole.instance.status.value == FConsoleStatus.consoleBtn;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((d) {
      Size? childSize = _childGK.currentContext!.size;
      setState(() {
        childWidth = childSize!.width;
        childHeight = childSize.height;
        calculatePosition();
        isCalculateSize = false;
      });
    });
  }

  void calculatePosition() {
    final size = MediaQueryData.fromView(View.of(context)).size;
    double width = size.width;
    double height = size.height;

    Alignment position = widget.consolePosition!;
    xPosition = position.x * width / 2 + width / 2;
    yPosition = position.y * height / 2 + height / 2;
    if (xPosition < 0) {
      xPosition = 0;
    } else if (xPosition > width - childWidth) {
      xPosition = width - childWidth;
    }
    if (yPosition < 0) {
      yPosition = 0;
    } else if (yPosition > height - childHeight) {
      yPosition = height - childHeight;
    }
    yPosition = yPosition.clamp(20, 1e10);
  }

  @override
  void dispose() {
    FConsole.instance.status.value = FConsoleStatus.hide;
    super.dispose();
  }

  final saveImage = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          child: isCalculateSize
              ? Opacity(
                  opacity: 0.0001,
                  child: Container(
                    key: _childGK,
                    child: widget.consoleBtn ?? _consoleBtn(),
                  ))
              : TouchMoveView(
                  childWidth: childWidth,
                  childHeight: childHeight,
                  xPosition: xPosition,
                  yPosition: yPosition,
                  child: Visibility(
                    visible: isShowConsoleBtn,
                    child: widget.consoleBtn ?? _consoleBtn(),
                  ),
                  onTap: () async {
                    ///Console Button Action. TODO
                    print('Show Panel!!');
                    FConsole.instance.status.value = FConsoleStatus.panel;
                    showConsolePanel(
                      () {
                        FConsole.instance.status.value =
                            FConsoleStatus.consoleBtn;
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

///Console Button Content.
Widget _consoleBtn() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: ColorPlate.white)),
        color: ColorPlate.primaryColor,
        shadows: [
          BoxShadow(
            color: ColorPlate.gray.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ]),
    child: const StText.normal(
      'المساعدة و الدعم؟',
      style: TextStyle(color: ColorPlate.white),
    ),
  );
}
