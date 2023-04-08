import 'package:flutter/material.dart';

class ArtStartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<DvAppState>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Art Start:'),
            SizedBox(height: 100),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
