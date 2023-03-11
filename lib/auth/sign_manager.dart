import 'package:flutter/material.dart';
import '../screens/fade_transition_page.dart';
import 'sign_in.dart';
import 'auth.dart';
import '../routing.dart';
import '../screens/routing_path.dart';

Page getSignManager(BuildContext context) {
  const signInKey = ValueKey('Sign in');
  final routeState = RouteStateScope.of(context);
  final authState = DvdAuthScope.of(context);

  return FadeTransitionPage<void>(
    key: signInKey,
    child: SignInScreen(
      onSignIn: (credentials) async {
        var signedIn =
            await authState.signIn(credentials.username, credentials.password);
        if (signedIn) {
          await routeState.go(routingPathFirstForSigned);
        }
      },
    ),
  );
}
