// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:path_to_regexp/path_to_regexp.dart';
import 'route_info.dart';

import 'parsed_route.dart';

/// Used by [TemplateRouteParser] to guard access to routes.
typedef RouteGuard<T> = Future<T> Function(T from);

/// Parses the URI path into a [ParsedRoute].
class TemplateRouteParser extends RouteInformationParser<ParsedRoute> {
  final Map<String, RouteInfo> _pathTemplates;
  final RouteGuard<ParsedRoute>? guard;
  final ParsedRoute initialRoute;

  TemplateRouteParser({
    /// The list of allowed path templates (['/', '/users/:id'])
    required Map<String, RouteInfo> allowedPaths,

    /// The initial route
    String initialRoute = '/',

    ///  [RouteGuard] used to redirect.
    this.guard,
  })  : initialRoute = ParsedRoute(initialRoute, initialRoute, {}, {}),
        _pathTemplates = allowedPaths,
        assert(allowedPaths.containsKey(initialRoute));

  @override
  Future<ParsedRoute> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final path = routeInformation.location!;
    final queryParams = Uri.parse(path).queryParameters;
    var parsedRoute = initialRoute;

    for (var pathTemplate in _pathTemplates.keys) {
      final parameters = <String>[];
      var pathRegExp = pathToRegExp(pathTemplate, parameters: parameters);
      if (pathRegExp.hasMatch(path)) {
        final match = pathRegExp.matchAsPrefix(path);
        if (match == null) continue;
        final params = extract(parameters, match);
        parsedRoute = ParsedRoute(path, pathTemplate, params, queryParams);
      }
    }

    // Redirect if a guard is present
    var guard = this.guard;
    if (guard != null) {
      return guard(parsedRoute);
    }

    return parsedRoute;
  }

  RouteInfo? getRouteInfoByPathTemplate(String pathTemplate) {
    return _pathTemplates[pathTemplate];
  }

  @override
  RouteInformation restoreRouteInformation(ParsedRoute configuration) =>
      RouteInformation(location: configuration.path);
}
