import 'package:flutter/material.dart';

class DvdGalleryPage extends StatelessWidget {
  const DvdGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
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
