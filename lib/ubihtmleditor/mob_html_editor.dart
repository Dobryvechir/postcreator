import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class MobHtmlEditorWidget extends StatefulWidget {
  final int status;
  final ValueSetter<String> changer;

  const MobHtmlEditorWidget(
      {super.key, required this.status, required this.changer});

  @override
  State<MobHtmlEditorWidget> createState() => _MobHtmlEditorWidgetState();
}

class _MobHtmlEditorWidgetState extends State<MobHtmlEditorWidget> {
  HtmlEditorController controller = HtmlEditorController();

  @override
  Widget build(BuildContext context) {
    if (widget.status == 1) {
      controller.getText().then(widget.changer);
    }
    return HtmlEditor(
      controller: controller, //required
      htmlEditorOptions: const HtmlEditorOptions(
        hint: "Type text here",
      ),
      htmlToolbarOptions: const HtmlToolbarOptions(
        toolbarType: ToolbarType.nativeGrid,
      ),
      otherOptions: const OtherOptions(
        height: 400,
      ),
    );
  }
}
