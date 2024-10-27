
import 'package:fconsole/src/style/color.dart';
import 'package:fconsole/src/style/text.dart';
import 'package:flutter/material.dart';

///Tab Button
class TapBtn extends StatelessWidget {
  final String? title;
  final double space;
  final double? minWidth;
  final bool selected;
  final bool small;
  final Function? onTap;

  const TapBtn({
    Key? key,
    this.title,
    this.space = 24,
    this.selected = false,
    this.onTap,
    this.small = false,
    this.minWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: minWidth ?? 60),
      child: GestureDetector(
        onTap: onTap as void Function()?,
        behavior: HitTestBehavior.translucent,
        child: Container(
          color: selected ? ColorPlate.white : ColorPlate.clear,
          padding: EdgeInsets.symmetric(horizontal: space),
          child: Center(
            child: small
                ? StText.normal(title ?? '??')
                : StText.big(title ?? '??'),
          ),
        ),
      ),
    );
  }
}
