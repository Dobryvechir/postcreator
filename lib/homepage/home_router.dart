import 'package:flutter/material.dart';
import 'art_start.dart';
import 'text_input.dart';
import 'image_input.dart';
import 'audio_input.dart';
import 'video_input.dart';
import 'home_main.dart';

List<Widget> routeHome(BuildContext context) => [const HomeMainWidget()];
List<Widget> routeHomeText(BuildContext context) => [const TextInputWidget()];
List<Widget> routeHomeImage(BuildContext context) => [ImageInputWidget()];
List<Widget> routeHomeAudio(BuildContext context) => [const AudioInputWidget()];
List<Widget> routeHomeVideo(BuildContext context) => [VideoInputWidget()];
List<Widget> routeHomeStart(BuildContext context) => [ArtStartWidget()];
