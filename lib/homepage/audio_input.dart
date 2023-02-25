import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class AudioInputWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<DvAppState>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Audio Input:'),
            SizedBox(height: 100),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
