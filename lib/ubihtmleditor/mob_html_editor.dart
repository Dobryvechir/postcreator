import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class MobHtmlEditorWidget extends StatefulWidget {
  const MobHtmlEditorWidget({super.key});

  @override
  State<MobHtmlEditorWidget> createState() => _MobHtmlEditorWidgetState();
}

class _MobHtmlEditorWidgetState extends State<MobHtmlEditorWidget> {
  HtmlEditorController controller = HtmlEditorController();

  @override
  Widget build(BuildContext context) {
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
