// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'parsed_route.dart';
import 'parser.dart';
import 'route_info.dart';

/// The current route state. To change the current route, call obtain the state
/// using `RouteStateScope.of(context)` and call `go()`:
///
/// ```
/// RouteStateScope.of(context).go('/book/2');
/// ```
class RouteState extends ChangeNotifier {
  final TemplateRouteParser _parser;
  ParsedRoute _route;

  RouteState(this._parser) : _route = _parser.initialRoute;

  ParsedRoute get route => _route;

  set route(ParsedRoute route) {
    // Don't notify listeners if the path hasn't changed.
    if (_route == route) return;

    _route = route;
    notifyListeners();
  }

  List<Widget> getPrimary(BuildContext context) {
    RouteInfo? info = _parser.getRouteInfoByPathTemplate(_route.pathTemplate);
    if (info == null) {
      return [];
    }
    return info.primary(context);
  }

  String getKeyName() {
    RouteInfo? info = _parser.getRouteInfoByPathTemplate(_route.pathTemplate);
    if (info == null) {
      return '';
    }
    return info.name;
  }

  Future<void> go(String route) async {
    this.route =
        await _parser.parseRouteInformation(RouteInformation(location: route));
  }
}

/// Provides the current [RouteState] to descendant widgets in the tree.
class RouteStateScope extends InheritedNotifier<RouteState> {
  const RouteStateScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static RouteState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RouteStateScope>()!.notifier!;
}
