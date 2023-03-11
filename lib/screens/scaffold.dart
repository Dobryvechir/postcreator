import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:flutter/material.dart';

import '../routing.dart';
import 'scaffold_body.dart';

class DvdAppScaffold extends StatelessWidget {
  const DvdAppScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final selectedIndex = _getSelectedIndex(routeState.route.pathTemplate);

    return Scaffold(
      body: AdaptiveNavigationScaffold(
        selectedIndex: selectedIndex,
        body: const DvdAppScaffoldBody(),
        onDestinationSelected: (idx) {
          if (idx == 0) routeState.go('/home');
          if (idx == 1) routeState.go('/home/text');
          if (idx == 2) routeState.go('/home/image');
        },
        destinations: const [
          AdaptiveScaffoldDestination(
            title: 'Books',
            icon: Icons.book,
          ),
          AdaptiveScaffoldDestination(
            title: 'Authors',
            icon: Icons.person,
          ),
          AdaptiveScaffoldDestination(
            title: 'Settings',
            icon: Icons.settings,
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String pathTemplate) {
    if (pathTemplate.startsWith('/home')) return 0;
    if (pathTemplate == '/home/text') return 1;
    if (pathTemplate == '/home/image') return 2;
    return 0;
  }
}
