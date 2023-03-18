import 'package:flutter/material.dart';
import 'mob_html_editor.dart';
import 'alt_html_editor.dart';
import 'dart:io' show Platform;

class UbiHtmlEditorWidget extends StatelessWidget {
  const UbiHtmlEditorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return const AltHtmlEditorWidget();
    }
    return const MobHtmlEditorWidget();
  }
}
