import 'package:flutter/material.dart';
import '../utils/page_utils.dart';
import '../utils/image_params.dart';
import '../utils/image_calc.dart';
import '../routing.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeMainWidget extends StatelessWidget {
  const HomeMainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<DvAppState>();
    var messager = AppLocalizations.of(context) ??
        lookupAppLocalizations(Locale(appState.defLocale));
    const imageXextra = 10;
    const imageYextra = 25;
    // var appState = context.watch<DvAppState>();
    int boxX = MediaQuery.of(context).size.width.floor() - imageXextra;
    int boxY = MediaQuery.of(context).size.height.floor() - imageYextra;
    int coord =
        calculateProportionalImage(artPuzzleWidth, artPuzzleHeight, boxX, boxY);
    int imageWidth = coordinateX(coord);
    int imageHeight = coordinateY(coord);
    return Scaffold(
      appBar: AppBar(
        title: Text(messager.chooseTextImageAudioVideoCreatePost),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              child: Image(
                  image: ResizeImage(const AssetImage(artPuzzleAssetName),
                      width: imageWidth, height: imageHeight)),
              onTapDown: (TapDownDetails details) {
                int pageNo = calculateSelectedPage(
                    imageWidth,
                    imageHeight,
                    artPuzzleWidth,
                    artPuzzleHeight,
                    details.localPosition.dx,
                    details.localPosition.dy,
                    artPuzzleBlocks);
                print(
                    "Location $pageNo ${details.localPosition.dx},${details.localPosition.dy}");
                String route = pageHomeRoute(pageNo);
                if (route.isNotEmpty) {
                  RouteStateScope.of(context).go(route);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
