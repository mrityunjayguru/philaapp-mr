import 'package:flutter/material.dart';

NavigationService navigationService = NavigationService().get();

class NavigationService {
  GlobalKey<NavigatorState> _navigationKey = GlobalKey<NavigatorState>();

  NavigationService();

  NavigationService? _instance;
  NavigationService get() {
    if (_instance == null) _instance = new NavigationService();

    return _instance!;
  }

  GlobalKey<NavigatorState> get navigationKey => _navigationKey;

  popPage() => _navigationKey.currentState!.pop();
}

class PageObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _printCurrentStack();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _printCurrentStack();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _printCurrentStack();
  }

  void _printCurrentStack() {
    final navigator = NavigationService().get()._navigationKey.currentState;
    if (navigator != null) {
      final stack = navigator.widget.pages;
      print('Current Navigation Stack: ${stack.map((route) => route.name).toList()}');
    }
  }
}
