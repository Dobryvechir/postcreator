import 'package:flutter/material.dart';

import '../routing/route_state.dart';

const textInfo = 'textInfo';
const imageUrl = 'imageUrl';
const imageTitle = 'imageTitle';
const imageSource = 'imageSource';
const audioUrl = 'audioUrl';
const audioTitle = 'audioTitle';
const audioSource = 'audioSource';
const videoUrl = 'videoUrl';
const videoTitle = 'videoTitle';
const videoSource = 'videoSource';

const homePagePrefix = 'homepage';

const homePageAppState = [
  textInfo,
  imageUrl,
  imageTitle,
  imageSource,
  audioUrl,
  audioTitle,
  audioSource,
  videoUrl,
  videoTitle,
  videoSource,
];

void popArtRoute(BuildContext context) {
  var route = '/home';
  Navigator.of(context).pop();
  RouteStateScope.of(context).go(route);
}

List<Object> popArtRoute1of2Step(BuildContext context) {
  return [Navigator.of(context), RouteStateScope.of(context)];
}

void popArtRoute2of2Step(List<Object> lst) {
  var route = '/home';
  (lst[0] as NavigatorState).pop();
  (lst[1] as RouteState).go(route);
}
