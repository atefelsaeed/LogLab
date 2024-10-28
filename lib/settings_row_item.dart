
import 'package:flutter/material.dart';
import 'package:tapped/tapped.dart';

class SettingRow extends StatelessWidget {
  final double? padding;
  final IconData? icon;
  final Widget? right;
  final Widget? beforeRight;
  final String? text;
  final Color? textColor;
  final Function? onTap;

  const SettingRow({
    super.key,
    this.padding = 14,
    this.icon,
    this.text,
    this.textColor,
    this.right,
    this.onTap,
    this.beforeRight,
  });

  @override
  Widget build(BuildContext context) {
    var child = Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: <Widget>[
          icon == null
              ? Container()
              : Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              icon,
              size: 20,
              color: textColor,
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: padding ?? 0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      text ?? '--',
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      beforeRight ?? Container(),
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        child: right ??
                            Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                                size: 12,
                              ),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) {
      return child;
    }
    return Tapped(
      onTap: onTap,
      child: child,
    );
  }
}