import 'package:flutter/material.dart';
import 'package:zefyrka/zefyrka.dart';

class AltHtmlEditorWidget extends StatefulWidget {
  const AltHtmlEditorWidget({super.key});

  @override
  State<AltHtmlEditorWidget> createState() => _AltHtmlEditorWidgetState();
}

class _AltHtmlEditorWidgetState extends State<AltHtmlEditorWidget> {
  final ZefyrController _controller = ZefyrController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ZefyrToolbar.basic(controller: _controller),
        Expanded(
          child: ZefyrEditor(
            controller: _controller,
          ),
        ),
      ],
    );
  }
}
