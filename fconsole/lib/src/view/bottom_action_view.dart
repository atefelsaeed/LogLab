import 'package:fconsole/src/style/color.dart';
import 'package:fconsole/src/style/text.dart';
import 'package:fconsole/src/view/console.dart';
import 'package:flutter/material.dart';
import 'package:tapped/tapped.dart';

class BottomActionView extends StatelessWidget {
  const BottomActionView({
    Key? key,
    required this.onClear,
  }) : super(key: key);

  final Function onClear;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData =
    MediaQueryData.fromView(View.of(context));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        bottom: mediaQueryData.padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: ColorPlate.lightGray,
        border: Border(
          top: BorderSide(color: ColorPlate.gray, width: 0.2),
        ),
      ),
      child: SizedBox(
        height: 50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Expanded(
            //   child: Tapped(
            //     onTap: () {
            //       onClear();
            //     },
            //     child: Container(
            //       color: ColorPlate.clear,
            //       child: const Center(
            //         child: StText.normal("Clear"),
            //       ),
            //     ),
            //   ),
            // ),
            // Container(
            //   width: 1,
            //   height: 30,
            //   color: ColorPlate.gray,
            // ),
            Expanded(
              child: Tapped(
                onTap: () {
                  hideConsolePanel();
                },
                child: Container(
                  color: ColorPlate.clear,
                  child: const Center(
                    child: StText.normal(
                      "Hide",
                      style: TextStyle(color: ColorPlate.black),
                    ),
                  ),
                ),
              ),
            ),
            // Container(
            //   width: 1,
            //   height: 30,
            //   color: ColorPlate.gray,
            // ),
            Expanded(
              child: Tapped(
                onTap: () {
                  onClear();
                },
                child: Container(
                  color: ColorPlate.primaryColor,
                  child: const Center(
                    child: StText.normal(
                      "Share",
                      style: TextStyle(color: ColorPlate.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
