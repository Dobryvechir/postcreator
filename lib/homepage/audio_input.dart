import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class AudioInputWidget extends StatefulWidget {
  @override
  State<AudioInputWidget> createState() => _AudioInputWidgetState();
}

class _AudioInputWidgetState extends State<AudioInputWidget> {
  final _urlController = TextEditingController();
  final _sourceController = TextEditingController();
  final _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<DvAppState>();

    return Scaffold(
      body: Center(
        child: Card(
          child: Container(
            constraints: BoxConstraints.loose(const Size(600, 600)),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Audio',
                    style: Theme.of(context).textTheme.headlineMedium),
                TextField(
                  decoration: const InputDecoration(labelText: 'Url'),
                  controller: _urlController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Source'),
                  controller: _sourceController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  controller: _titleController,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: () async {
                      widget.onSignIn(Credentials(
                          _usernameController.value.text,
                          _passwordController.value.text));
                    },
                    child: const Text('Ok'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
