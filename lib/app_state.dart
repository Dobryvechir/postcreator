import 'package:flutter/material.dart';

class DvAppState extends ChangeNotifier {
  var current = "";

  var favorites = <String>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void getNext() {
    current = "";
    notifyListeners();
  }
}

