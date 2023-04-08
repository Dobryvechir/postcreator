import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import './home_app_start.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AudioInputWidget extends StatefulWidget {
  const AudioInputWidget({super.key});

  @override
  State<AudioInputWidget> createState() => _AudioInputWidgetState();
}

class _AudioInputWidgetState extends State<AudioInputWidget> {
  final _urlController = TextEditingController();
  final _sourceController = TextEditingController();
  final _titleController = TextEditingController();
  var _initial = true;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<DvAppState>();
    var messager = AppLocalizations.of(context) ??
        lookupAppLocalizations(Locale(appState.defLocale));
    if (_initial) {
      _initial = false;
      final url = appState.getProperty(homePagePrefix, audioUrl) ?? '';
      final source = appState.getProperty(homePagePrefix, audioSource) ?? '';
      final title = appState.getProperty(homePagePrefix, audioTitle) ?? '';
      _urlController.value = TextEditingValue(
        text: url,
        selection: TextSelection.fromPosition(
          TextPosition(offset: url.length),
        ),
      );
      _sourceController.value = TextEditingValue(
        text: source,
        selection: TextSelection.fromPosition(
          TextPosition(offset: source.length),
        ),
      );
      _titleController.value = TextEditingValue(
        text: title,
        selection: TextSelection.fromPosition(
          TextPosition(offset: title.length),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(messager.fillIn),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Card(
          child: Container(
            constraints: BoxConstraints.loose(const Size(600, 600)),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(messager.audio,
                    style: Theme.of(context).textTheme.headlineMedium),
                TextField(
                  decoration: InputDecoration(labelText: messager.url),
                  controller: _urlController,
                ),
                TextField(
                  decoration: InputDecoration(labelText: messager.source),
                  controller: _sourceController,
                ),
                TextField(
                  decoration: InputDecoration(labelText: messager.title),
                  controller: _titleController,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonTheme(
                        minWidth: 100,
                        child: ElevatedButton(
                            onPressed: () async {
                              appState.setProperty(homePagePrefix, audioUrl,
                                  _urlController.value.text);
                              appState.setProperty(homePagePrefix, audioSource,
                                  _sourceController.value.text);
                              appState.setProperty(homePagePrefix, audioTitle,
                                  _titleController.value.text);
                              popArtRoute(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(messager.ok),
                            ))),
                    OutlinedButton(
                        onPressed: () async {
                          popArtRoute(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(messager.cancel),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
