import 'package:flutter/material.dart';
import 'mob_html_editor.dart';
import 'alt_html_editor.dart';
import 'dart:io' show Platform;

class UbiHtmlEditorWidget extends StatelessWidget {
  final ValueSetter<Function> changer;

  const UbiHtmlEditorWidget({super.key, required this.changer});

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return AltHtmlEditorWidget(
        changer: changer,
      );
    }
    return MobHtmlEditorWidget(
      changer: changer,
    );
  }
}
