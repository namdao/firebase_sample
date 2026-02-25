import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class RemoteConfigScreen extends StatefulWidget {
  const RemoteConfigScreen({super.key});

  @override
  State<RemoteConfigScreen> createState() => _RemoteConfigScreenState();
}

class _RemoteConfigScreenState extends State<RemoteConfigScreen> {
  final _remoteConfig = FirebaseRemoteConfig.instance;
  bool _isLoading = false;
  String _fetchStatus = '';
  DateTime? _lastFetchTime;
  Map<String, RemoteConfigValue> _allValues = {};

  static const _defaults = <String, dynamic>{
    'welcome_message': 'Hello from Firebase!',
    'feature_enabled': false,
    'max_items': 10,
    'api_url': 'https://api.example.com',
  };

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _remoteConfig.setDefaults(_defaults);
      _refreshValues();
    } catch (e) {
      _showMessage('Init error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _refreshValues() {
    setState(() {
      _allValues = _remoteConfig.getAll();
      _lastFetchTime = _remoteConfig.lastFetchTime;
      _fetchStatus = _remoteConfig.lastFetchStatus.name;
    });
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _fetchAndActivate() async {
    setState(() => _isLoading = true);
    try {
      final activated = await _remoteConfig.fetchAndActivate();
      _refreshValues();
      _showMessage(activated
          ? 'Fetched & activated new values'
          : 'Fetched, but no new values');
    } catch (e) {
      _showMessage('Fetch error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchOnly() async {
    setState(() => _isLoading = true);
    try {
      await _remoteConfig.fetch();
      _refreshValues();
      _showMessage('Fetched (not yet activated)');
    } catch (e) {
      _showMessage('Fetch error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _activate() async {
    setState(() => _isLoading = true);
    try {
      final activated = await _remoteConfig.activate();
      _refreshValues();
      _showMessage(activated
          ? 'Activated new values'
          : 'No new values to activate');
    } catch (e) {
      _showMessage('Activate error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _sourceLabel(ValueSource source) {
    switch (source) {
      case ValueSource.valueDefault:
        return 'Default';
      case ValueSource.valueRemote:
        return 'Remote';
      case ValueSource.valueStatic:
        return 'Static';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Remote Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _StatusRow(
                    label: 'Last Fetch Status',
                    value: _fetchStatus.isEmpty ? 'N/A' : _fetchStatus,
                  ),
                  _StatusRow(
                    label: 'Last Fetch Time',
                    value: _lastFetchTime != null
                        ? '${_lastFetchTime!.hour}:${_lastFetchTime!.minute.toString().padLeft(2, '0')}:${_lastFetchTime!.second.toString().padLeft(2, '0')}'
                        : 'Never',
                  ),
                  _StatusRow(
                    label: 'Total Keys',
                    value: '${_allValues.length}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _isLoading ? null : _fetchAndActivate,
                  child: const Text('Fetch & Activate'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _fetchOnly,
                  child: const Text('Fetch Only'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _activate,
                  child: const Text('Activate Only'),
                ),
              ),
            ],
          ),
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
          const SizedBox(height: 24),
          Text('Config Values', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_allValues.isEmpty)
            const Center(child: Text('No values loaded'))
          else
            ..._allValues.entries.map(
              (entry) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: entry.value.source ==
                                      ValueSource.valueRemote
                                  ? theme.colorScheme.primaryContainer
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _sourceLabel(entry.value.source),
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.value.asString(),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text('Default Keys', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _defaults.entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${e.key}: ${e.value}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatusRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
