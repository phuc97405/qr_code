import 'package:flutter/material.dart';

class BaseWidgets {
  static BaseWidgets? _instance;
  static BaseWidgets get instance {
    _instance ??= BaseWidgets._init();
    return _instance!;
  }

  BaseWidgets._init();

  Widget rowInfo(String type, String text) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
          flex: 2,
          child: Text(type,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w300))),
      Expanded(
        flex: 5,
        child: Text(text,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500)),
      )
    ]);
  }
}
