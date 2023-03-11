import 'package:flutter/material.dart';

List<Widget> routeEmptyFn(BuildContext context) => [];

class RouteInfo {
  Function primary = routeEmptyFn;
  Function secondary = routeEmptyFn;
  final String name;

  RouteInfo(this.name, this.primary);
  RouteInfo.named(this.name);
}
