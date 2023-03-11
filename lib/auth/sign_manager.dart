import 'package:flutter/material.dart';
import '../screens/fade_transition_page.dart';
import 'sign_in.dart';

Page getSignManager() {
  const signInKey = ValueKey('Sign in');

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
