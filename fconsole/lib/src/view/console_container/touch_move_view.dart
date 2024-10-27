import 'package:flutter/material.dart';

class TouchMoveView extends StatefulWidget {
  final Widget child;
  final Function? onTap;

  final double xPosition;

  final double yPosition;

  final double childWidth;

  final double childHeight;

  const TouchMoveView({
    Key? key,
    required this.child,
    this.onTap,
    this.xPosition = 0,
    this.yPosition = 0,
    this.childWidth = 0,
    this.childHeight = 0,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TouchMoveState();
  }
}

class _TouchMoveState extends State<TouchMoveView> {
  double xPosition = 0;
  double yPosition = 0;
  double childWidth = 0;
  double childHeight = 0;

  @override
  void initState() {
    xPosition = widget.xPosition;
    yPosition = widget.yPosition;
    childWidth = widget.childWidth;
    childHeight = widget.childHeight;

    super.initState();
  }

  @override
  void didUpdateWidget(TouchMoveView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData =
        MediaQueryData.fromView(View.of(context));
    double width = mediaQueryData.size.width;
    double height = mediaQueryData.size.height;

    /// keep safe area
    double top = mediaQueryData.padding.top;
    double btm = mediaQueryData.padding.bottom;
    var _yPosition = yPosition;
    if (_yPosition < top) _yPosition = top;
    if (_yPosition > height - btm) _yPosition = height - btm;

    return Transform.translate(
        offset: Offset(xPosition, _yPosition),
        child: GestureDetector(
          onTap: () {
            widget.onTap?.call();
          },
          onPanUpdate: (detail) {
            setState(() {
              xPosition += detail.delta.dx;
              yPosition += detail.delta.dy;
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
            });
          },
          child: widget.child,
        ));
  }
}
