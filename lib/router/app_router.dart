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
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.auth,
      name: 'auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: AppRoutes.firestore,
      name: 'firestore',
      builder: (context, state) => const FirestoreScreen(),
    ),
    GoRoute(
      path: AppRoutes.storage,
      name: 'storage',
      builder: (context, state) => const StorageScreen(),
    ),
    GoRoute(
      path: AppRoutes.analytics,
      name: 'analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: AppRoutes.crashlytics,
      name: 'crashlytics',
      builder: (context, state) => const CrashlyticsScreen(),
    ),
    GoRoute(
      path: AppRoutes.messaging,
      name: 'messaging',
      builder: (context, state) => const MessagingScreen(),
    ),
    GoRoute(
      path: AppRoutes.performance,
      name: 'performance',
      builder: (context, state) => const PerformanceScreen(),
    ),
    GoRoute(
      path: AppRoutes.remoteConfig,
      name: 'remote-config',
      builder: (context, state) => const RemoteConfigScreen(),
    ),
  ],
);
