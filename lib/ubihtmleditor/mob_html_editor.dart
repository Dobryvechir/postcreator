import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class MobHtmlEditorWidget extends StatefulWidget {
  final ValueSetter<Function> changer;
  final String initialText;

  const MobHtmlEditorWidget(
      {super.key, required this.changer, required this.initialText});

  @override
  State<MobHtmlEditorWidget> createState() => _MobHtmlEditorWidgetState();
}

class _MobHtmlEditorWidgetState extends State<MobHtmlEditorWidget> {
  HtmlEditorController controller = HtmlEditorController();

  @override
  void initState() {
    super.initState();
    widget.changer(() async {
      var a = await controller.getText();
      return a;
    });
    if (widget.initialText != '') {
      controller.setText(widget.initialText);
    }
  }

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
