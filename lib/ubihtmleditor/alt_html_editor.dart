import 'package:flutter/material.dart';
import 'package:zefyrka/zefyrka.dart';
import './notustohtml.dart';

class AltHtmlEditorWidget extends StatefulWidget {
  final int status;
  final ValueSetter<String> changer;

  const AltHtmlEditorWidget(
      {super.key, required this.status, required this.changer});

  @override
  State<AltHtmlEditorWidget> createState() => _AltHtmlEditorWidgetState();
}

class _AltHtmlEditorWidgetState extends State<AltHtmlEditorWidget> {
  final ZefyrController _controller = ZefyrController();

  @override
  Widget build(BuildContext context) {
    if (widget.status == 1) {
      const converter = NotusHtmlCodec();
      String html = converter.encode(_controller.document.toDelta());
      widget.changer(html);
    }
    return Container(
        height: 400,
        child: Column(
          children: [
            ZefyrToolbar.basic(controller: _controller),
            Expanded(
              child: ZefyrEditor(
                controller: _controller,
              ),
            ),
          ],
        ));
  }
}
