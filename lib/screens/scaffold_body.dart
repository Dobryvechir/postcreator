import 'package:flutter/material.dart';

import '../routing.dart';
import 'fade_transition_page.dart';
import 'scaffold.dart';

/// Displays the contents of the body of [DvdAppScaffold]
class DvdAppScaffoldBody extends StatelessWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const DvdAppScaffoldBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var routeScope = RouteStateScope.of(context);
    String keyName = routeScope.getKeyName();
    List<Widget> widgets = routeScope.getPrimary(context);

    // A nested Router isn't necessary because the back button behavior doesn't
    // need to be customized.
    return Navigator(
      key: navigatorKey,
      onPopPage: (route, dynamic result) => route.didPop(result),
      pages: [
        if (widgets.isNotEmpty)
          FadeTransitionPage<void>(
            key: ValueKey(keyName),
            child: widgets[0],
          )
        else
          // Avoid building a Navigator with an empty `pages` list when the
          // RouteState is set to an unexpected path, such as /signin.
          //
          // Since RouteStateScope is an InheritedNotifier, any change to the
          // route will result in a call to this build method, even though this
          // widget isn't built when those routes are active.
          FadeTransitionPage<void>(
            key: const ValueKey('empty'),
            child: Container(),
          ),
      ],
    );
  }
}
