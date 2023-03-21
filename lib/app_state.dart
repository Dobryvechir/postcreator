import 'package:flutter/material.dart';

class DvAppState extends ChangeNotifier {
  var prefixedProperties = <String, String>{};

  void setPropertySilently(String prefix, String key, String value) {
    String k = "${prefix}_$key";
    prefixedProperties[k] = value;
    notifyListeners();
  }

  void setProperty(String prefix, String key, String value) {
    setPropertySilently(prefix, key, value);
    notifyListeners();
  }

  String? getProperty(String prefix, String key) {
    String k = "${prefix}_$key";
    return prefixedProperties[k];
  }
}
