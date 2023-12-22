import 'package:convogen/screens/home.dart';
import 'package:convogen/screens/splash.dart';
import 'package:go_router/go_router.dart';

GoRouter router = GoRouter(initialLocation: splashRoute, routes: routes);

List<GoRoute> routes = [
  GoRoute(path: homeRoute, builder: (context, state) => const RootPage()),
  GoRoute(
    path: splashRoute,
    builder: (context, state) => const SplashScreen(),
  )
];

String homeRoute = "/";
String splashRoute = "/splash";
