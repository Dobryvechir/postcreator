import 'package:flutter/material.dart';
import 'package:postcreator/utils/image_calc.dart';
import 'package:postcreator/utils/image_params.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

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
            Image(
                image: ResizeImage(AssetImage(artPuzzleAssetName),
                    width: imageWidth, height: imageHeight)),
          ],
        ),
      ),
    );
  }
}
