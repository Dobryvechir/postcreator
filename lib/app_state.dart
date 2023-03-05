import 'package:flutter/material.dart';

class DvAppState extends ChangeNotifier {
  var currentPage = 0;
  var previousPage = 0;

  var favorites = <String>[];

  void globalPage(int page) {
    previousPage = currentPage;
    currentPage = page;
    notifyListeners();
  }

  void getNext() {
    currentPage++;
    notifyListeners();
  }
}
