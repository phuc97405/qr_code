import 'package:flutter/material.dart';

class BaseWidgets {
  static BaseWidgets? _instance;
  static BaseWidgets get instance {
    _instance ??= BaseWidgets._init();
    return _instance!;
  }

  BaseWidgets._init();

  Widget rowInfo(String type, String text) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          flex: 1,
          child: Text(type,
              style: const TextStyle(fontSize: 17, color: Colors.grey))),
      Expanded(
        flex: 2,
        child: Text(text,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
      )
    ]);
  }
}
