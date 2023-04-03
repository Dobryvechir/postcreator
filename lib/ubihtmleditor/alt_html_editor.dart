import 'package:flutter/material.dart';
import 'package:zefyrka/zefyrka.dart';
import './notustohtml.dart';

class AltHtmlEditorWidget extends StatefulWidget {
  final ValueSetter<Function> changer;

  const AltHtmlEditorWidget({super.key, required this.changer});

  @override
  State<AltHtmlEditorWidget> createState() => _AltHtmlEditorWidgetState();
}

class _AltHtmlEditorWidgetState extends State<AltHtmlEditorWidget> {
  final ZefyrController _controller = ZefyrController();

  @override
  void initState() {
    super.initState();
    widget.changer(() {
      var converter = const NotusHtmlCodec();
      String html = converter.encode(_controller.document.toDelta());
      return html;
    });
  }

  @override
  Widget build(BuildContext context) {
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
