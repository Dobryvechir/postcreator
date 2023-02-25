import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'audio_input.dart';
import 'video_input.dart';
import 'image_input.dart';
import 'text_input.dart';
import 'home_main.dart';

class DvdHomePage extends StatefulWidget {
  const DvdHomePage({super.key});

  @override
  State<DvdHomePage> createState() => _DvdHomePageState();
}

class _DvdHomePageState extends State<DvdHomePage> {
  var selectedWidget = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedWidget) {
      case 0:
        page = HomeMainWidget();
        break;
      case 1:
        page = AudioInputWidget();
        break;
      case 2:
        page = VideoInputWidget();
        break;
      case 3:
        page = TextInputWidget();
        break;
      case 4:
        page = ImageInputWidget();
        break;
      default:
        throw UnimplementedError('no widget for $selectedWidget');
    }
    return page;
  }
}
