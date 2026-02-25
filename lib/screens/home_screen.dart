import 'package:flutter/material.dart';

import 'analytics_screen.dart';
import 'auth_screen.dart';
import 'crashlytics_screen.dart';
import 'firestore_screen.dart';
import 'messaging_screen.dart';
import 'performance_screen.dart';
import 'remote_config_screen.dart';
import 'storage_screen.dart';

class _FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget screen;

  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.screen,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  List<_FeatureItem> get _features => [
        _FeatureItem(
          title: 'Authentication',
          subtitle: 'Sign in, sign up, anonymous auth',
          icon: Icons.lock_open_rounded,
          color: const Color(0xFF4CAF50),
          screen: const AuthScreen(),
        ),
        _FeatureItem(
          title: 'Cloud Firestore',
          subtitle: 'Real-time CRUD operations',
          icon: Icons.cloud_rounded,
          color: const Color(0xFF2196F3),
          screen: const FirestoreScreen(),
        ),
        _FeatureItem(
          title: 'Storage',
          subtitle: 'Upload, list & delete files',
          icon: Icons.folder_rounded,
          color: const Color(0xFF9C27B0),
          screen: const StorageScreen(),
        ),
        _FeatureItem(
          title: 'Analytics',
          subtitle: 'Log events & user properties',
          icon: Icons.bar_chart_rounded,
          color: const Color(0xFFFF9800),
          screen: const AnalyticsScreen(),
        ),
        _FeatureItem(
          title: 'Crashlytics',
          subtitle: 'Crash reports & error logging',
          icon: Icons.bug_report_rounded,
          color: const Color(0xFFF44336),
          screen: const CrashlyticsScreen(),
        ),
        _FeatureItem(
          title: 'Messaging',
          subtitle: 'FCM tokens & topic subscriptions',
          icon: Icons.notifications_rounded,
          color: const Color(0xFF00BCD4),
          screen: const MessagingScreen(),
        ),
        _FeatureItem(
          title: 'Performance',
          subtitle: 'Custom traces & HTTP metrics',
          icon: Icons.speed_rounded,
          color: const Color(0xFF795548),
          screen: const PerformanceScreen(),
        ),
        _FeatureItem(
          title: 'Remote Config',
          subtitle: 'Fetch & activate config values',
          icon: Icons.tune_rounded,
          color: const Color(0xFF607D8B),
          screen: const RemoteConfigScreen(),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final features = _features;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Sample'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return _FeatureCard(feature: feature);
        },
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => feature.screen),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: feature.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(feature.icon, color: feature.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feature.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
