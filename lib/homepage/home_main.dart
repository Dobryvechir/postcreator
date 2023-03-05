import 'package:flutter/material.dart';
import 'package:postcreator/utils/image_calc.dart';
import 'package:postcreator/utils/image_params.dart';
import 'package:postcreator/utils/page_names.dart';
import 'package:postcreator/utils/page_utils.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../utils/image_params.dart';
import '../utils/image_calc.dart';

class HomeMainWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const imageXextra = 10;
    const imageYextra = 25;
    var appState = context.watch<DvAppState>();
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
            Text('Choose image/video/audio/text and create a post'),
            SizedBox(height: 5),
            GestureDetector(
              child: Image(
                  image: ResizeImage(AssetImage(artPuzzleAssetName),
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
                    "Location ${pageNo} ${details.localPosition.dx},${details.localPosition.dy}");
                int page = page2level(homePage, pageNo);
              },
            ),
          ],
        ),
      ),
    );
  }
}
