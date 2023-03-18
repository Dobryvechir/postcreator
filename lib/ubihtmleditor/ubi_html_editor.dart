import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'mob_html_editor.dart';
import 'alt_html_editor.dart';
import 'dart:io' show Platform;

class UbiHtmlEditorWidget extends StatelessWidget {
  final int status;
  final ValueSetter<String> changer;

  const UbiHtmlEditorWidget(
      {super.key, required this.status, required this.changer});

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return AltHtmlEditorWidget(
        status: status,
        changer: changer,
      );
    }
    return MobHtmlEditorWidget(
      status: status,
      changer: changer,
    );
  }
}
