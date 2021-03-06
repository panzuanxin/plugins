// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';
import 'package:flutter/widgets.dart';

import 'firebase_analytics.dart';

/// Signature for a function that extracts a screen name from [RouteSettings].
///
/// Usually, the route name is not a plain string, and it may contains some
/// unique ids that makes it difficult to aggregate over them in Firebase
/// Analytics.
typedef String ScreenNameExtractor(RouteSettings settings);

String defaultNameExtractor(RouteSettings settings) => settings.name;

/// A [NavigatorObserver] that sends events to Firebase Analytics when the
/// currently active [PageRoute] changes.
///
/// When a route is pushed or poped, [nameExtractor] is used to extract a name
/// from [RouteSettings] of the now active route and that name is send to
/// Firebase.
///
/// The following operations will result in sending a screen view event:
/// ```dart
/// Navigator.pushNamed(context, '/contact/123');
///
/// Navigator.push(context, new MaterialPageRoute(
///   settings: new RouteSettings(name: '/contact/123',
///   builder: new ContactDetail(123)))),
///
/// Navigator.pop(context);
/// ```
///
/// To use it, add it to the `navigatorObservers` of your [Navigator], e.g. if
/// you're using a [MaterialApp]:
/// ```dart
/// MaterialApp(
///   home: new MyAppHome(),
///   navigatorObservers: [
///     new FirebaseAnalyticsObserver(analytics: service.analytics),
///   ],
/// );
/// ```
///
/// You can also track screen views within your [PageRoute] by implementing
/// [PageRouteAware] and subscribing it to [FirebaseAnalyticsObserver]. See the
/// [PageRouteObserver] docs for an example.
class FirebaseAnalyticsObserver extends RouteObserver<PageRoute<dynamic>> {
  FirebaseAnalyticsObserver({
    @required this.analytics,
    this.nameExtractor = defaultNameExtractor,
  });

  final FirebaseAnalytics analytics;
  final ScreenNameExtractor nameExtractor;

  void _sendScreenView(PageRoute<dynamic> route) {
    final String screenName = nameExtractor(route.settings);
    if (screenName != null) {
      analytics.setCurrentScreen(screenName: screenName);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }
}
