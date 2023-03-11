import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'general_page.dart';
import 'routing.dart';
import 'screens/routing_path.dart';
import 'auth/auth.dart';

class DvdMainApp extends StatefulWidget {
  const DvdMainApp({super.key});

  @override
  State<DvdMainApp> createState() => _DvdMainAppState();
}

class _DvdMainAppState extends State<DvdMainApp> {
  final _auth = DvdAuth();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final RouteState _routeState;
  late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;

  @override
  void initState() {
    /// Configure the parser with all of the app's allowed path templates.
    _routeParser = TemplateRouteParser(
      allowedPaths: routingPathAllowed,
      guard: _guard,
      initialRoute: routingPathInitial,
    );

    _routerDelegate = SimpleRouterDelegate(
      routeState: _routeState,
      navigatorKey: _navigatorKey,
      builder: (context) => BookstoreNavigator(
        navigatorKey: _navigatorKey,
      ),
    );

    _auth.addListener(_handleAuthStateChanged);

    _routeState = RouteState(_routeParser);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DvAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sponsorschoose Poster',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: GeneralPagePool(),
      ),
    );
  }

  Future<ParsedRoute> _guard(ParsedRoute from) async {
    final signedIn = _auth.signedIn;
    final signInRoute =
        ParsedRoute(routingPathSignIn, routingPathSignIn, {}, {});

    // Go to /signin if the user is not signed in
    if (!signedIn && from != signInRoute) {
      return signInRoute;
    }
    // Go to first if the user is signed in and tries to go to /signin.
    else if (signedIn && from == signInRoute) {
      return ParsedRoute(
          routingPathFirstForSigned, routingPathFirstForSigned, {}, {});
    }

    return from;
  }

  void _handleAuthStateChanged() {
    if (!_auth.signedIn) {
      _routeState.go(routingPathSignIn);
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_handleAuthStateChanged);
    _routeState.dispose();
    _routerDelegate.dispose();
    super.dispose();
  }
}
