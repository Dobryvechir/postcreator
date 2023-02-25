import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class HomeMainWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<DvAppState>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Choose image/video/audio/text and create a post'),
            SizedBox(height: 5),
            Image(
                image: ResizeImage(
                    AssetImage(
                      'images/artpuzzle.png',
                    ),
                    width: 100,
                    height: 150)),
          ],
        ),
      ),
    );
  }
}
