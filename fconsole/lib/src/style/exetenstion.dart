import 'package:fconsole/src/model/log.dart';
import 'package:fconsole/src/style/color.dart';
import 'package:flutter/material.dart';

extension LogColor on Log {
  Color get color {
    switch (type) {
      case LogType.log:
        return ColorPlate.darkGray;
      case LogType.error:
        return ColorPlate.red;
    }
  }
}