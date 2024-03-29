import 'package:flutter/material.dart';
import 'gallery_page.dart';
import './homepage/home_main.dart';

class GeneralPagePool extends StatefulWidget {
  const GeneralPagePool({super.key});

  @override
  State<GeneralPagePool> createState() => _GeneralPagePoolState();
}

class _GeneralPagePoolState extends State<GeneralPagePool> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const HomeMainWidget();
        break;
      case 1:
        page = const DvdGalleryPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Gallery'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}
