import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'app.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  // web - #, others - does not matter
  setHashUrlStrategy();
  // alternative: setPathUrlStrategy();

  setupWindow();
  runApp(Provider<DvAppState>(
    create: (_) => DvAppState(),
    child: const MaterialApp(
      title: 'Localizations Sample App',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('uk'), // Ukrainian
        Locale('de'), // German
        Locale('es'), // Spanish
        Locale('fr'), // French
        Locale('pl'), // Polish
        Locale('it'), // Italian
        Locale('ru'), // Russian
      ],
      home: DvdMainApp(),
    ),
  ));
}

void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
  }
}
