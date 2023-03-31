import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class DvdGalleryPage extends StatelessWidget {
  const DvdGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<DvAppState>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Gallery page:'),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
