import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:postcreator/auth/sign_manager.dart';
import 'package:postcreator/screens/routing_path.dart';

import '../auth/auth.dart';
import '../routing.dart';
import '../screens/sign_in.dart';
import 'fade_transition_page.dart';

/// Builds the top-level navigator for the app. The pages to display are based
/// on the `routeState` that was parsed by the TemplateRouteParser.
class DvdAppNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const DvdAppNavigator({
    required this.navigatorKey,
    super.key,
  });

  @override
  State<DvdAppNavigator> createState() => _DvdAppNavigatorState();
}

class _DvdAppNavigatorState extends State<DvdAppNavigator> {
  final _scaffoldKey = const ValueKey('App scaffold');
  final _bookDetailsKey = const ValueKey('Book details screen');
  final _authorDetailsKey = const ValueKey('Author details screen');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = BookstoreAuthScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;

    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, dynamic result) {
        // When a page that is stacked on top of the scaffold is popped, display
        // the /books or /authors tab in BookstoreScaffold.
        if (route.settings is Page &&
            (route.settings as Page).key == _bookDetailsKey) {
          routeState.go('/books/popular');
        }

        if (route.settings is Page &&
            (route.settings as Page).key == _authorDetailsKey) {
          routeState.go('/authors');
        }

        return route.didPop(result);
      },
      pages: [
        if (pathTemplate == routingPathSignIn)
          getSignManager()
        // Display the sign in screen.
        else ...[
          // Display the app
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            child: const BookstoreScaffold(),
          ),
        ],
      ],
    );
  }
}
