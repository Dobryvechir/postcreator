import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../ubihtmleditor/ubi_html_editor.dart';

class TextInputWidget extends StatefulWidget {
  const TextInputWidget({super.key});

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  int status = 0;

  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<DvAppState>();

    return Scaffold(
        appBar: AppBar(
          title: const Text("Provide your text for the post"),
          backgroundColor: Colors.redAccent,
        ),
        body: Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
              children: [
                UbiHtmlEditorWidget(
                  status: status,
                  changer: (String data) => {},
                ),
                ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        status = 1;
                      });
                      // String data = await controller.getText();
                    },
                    child: const Text("OK"))
              ],
            )));
  }
}
