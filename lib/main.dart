import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
import 'app.dart';

void main() {
  // web - #, others - does not matter
  setHashUrlStrategy();
  // alternative: setPathUrlStrategy();

  setupWindow();
  runApp(const DvdMainApp());
}

void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
  }
}
