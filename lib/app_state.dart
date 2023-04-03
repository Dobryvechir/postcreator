import 'package:flutter/material.dart';

class DvAppState extends ChangeNotifier {
  var prefixedProperties = <String, String>{};
  var defLocale = 'uk';

  void setProperty(String prefix, String key, String value) {
    String k = "${prefix}_$key";
    prefixedProperties[k] = value;
  }

  void setPropertyNotify(String prefix, String key, String value) {
    setProperty(prefix, key, value);
    notifyListeners();
  }

  String? getProperty(String prefix, String key) {
    String k = "${prefix}_$key";
    return prefixedProperties[k];
  }
}
