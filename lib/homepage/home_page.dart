import 'package:flutter/material.dart';
import 'package:postcreator/utils/page_utils.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'audio_input.dart';
import 'video_input.dart';
import 'image_input.dart';
import 'text_input.dart';
import 'home_main.dart';
import 'art_start.dart';

class DvdHomePage extends StatelessWidget {
  const DvdHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<DvAppState>();
    var selectedWidget = 0;
    Widget page;
    switch (selectedWidget) {
      case 0:
        page = HomeMainWidget();
        break;
      case 1:
        page = TextInputWidget();
        break;
      case 2:
        page = ImageInputWidget();
        break;
      case 3:
        page = AudioInputWidget();
        break;
      case 4:
        page = VideoInputWidget();
        break;
      case 5:
        page = ArtStartWidget();
        break;
      default:
        throw UnimplementedError('no widget for $selectedWidget');
    }
    return page;
  }
}
