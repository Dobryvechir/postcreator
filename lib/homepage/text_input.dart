import 'package:flutter/material.dart';
import './home_app_start.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../ubihtmleditor/ubi_html_editor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TextInputWidget extends StatefulWidget {
  const TextInputWidget({super.key});

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  late Function valuer;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<DvAppState>();
    var messager = AppLocalizations.of(context) ??
        lookupAppLocalizations(Locale(appState.defLocale));
    return Scaffold(
        appBar: AppBar(
          title: Text(messager.provideTextForPost),
          backgroundColor: Colors.blueAccent,
        ),
        body: Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
              children: [
                UbiHtmlEditorWidget(
                  changer: (Function data) {
                    valuer = data;
                  },
                  initialText:
                      appState.getProperty(homePagePrefix, textInfo) ?? '',
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonTheme(
                        minWidth: 100,
                        child: ElevatedButton(
                            onPressed: () async {
                              List<Object> lst = popArtRoute1of2Step(context);
                              String value = await valuer();
                              appState.setProperty(
                                  homePagePrefix, textInfo, value);
                              popArtRoute2of2Step(lst);
                            },
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(messager.ok),
                            ))),
                    OutlinedButton(
                        onPressed: () async {
                          popArtRoute(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(messager.cancel),
                        ))
                  ],
                ),
              ],
            )));
  }
}
