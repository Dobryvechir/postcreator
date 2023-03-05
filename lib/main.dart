import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
import 'app.dart';

void main() {
  // web - #, others - does not matter
  setHashUrlStrategy();
  // setPathUrlStrategy();

  setupWindow();
  runApp(const DvdMainApp());
}

void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Navigation and routing');
  }
}
