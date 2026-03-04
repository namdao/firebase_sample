import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/analytics_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/crashlytics_screen.dart';
import '../screens/firestore_screen.dart';
import '../screens/home_screen.dart';
import '../screens/messaging_screen.dart';
import '../screens/performance_screen.dart';
import '../screens/remote_config_screen.dart';
import '../screens/storage_screen.dart';

/// Route paths.
abstract class AppRoutes {
  static const String home = '/';
  static const String auth = '/auth';
  static const String firestore = '/firestore';
  static const String storage = '/storage';
  static const String analytics = '/analytics';
  static const String crashlytics = '/crashlytics';
  static const String messaging = '/messaging';
  static const String performance = '/performance';
  static const String remoteConfig = '/remote-config';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: HomeScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.auth,
      name: 'auth',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const AuthScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.firestore,
      name: 'firestore',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const FirestoreScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.storage,
      name: 'storage',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const StorageScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.analytics,
      name: 'analytics',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const AnalyticsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.crashlytics,
      name: 'crashlytics',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const CrashlyticsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.messaging,
      name: 'messaging',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const MessagingScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.performance,
      name: 'performance',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const PerformanceScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.remoteConfig,
      name: 'remote-config',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const RemoteConfigScreen(),
      ),
    ),
  ],
);
