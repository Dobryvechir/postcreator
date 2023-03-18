import 'package:flutter/material.dart';
import '../utils/page_utils.dart';
import '../utils/image_params.dart';
import '../utils/image_calc.dart';
import '../routing.dart';

class HomeMainWidget extends StatelessWidget {
  const HomeMainWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Choose image/video/audio/text and create a post'),
            const SizedBox(height: 5),
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
