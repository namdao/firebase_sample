import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  final _performance = FirebasePerformance.instance;
  final _traceNameController = TextEditingController(text: 'sample_trace');
  final _metricNameController = TextEditingController(text: 'item_count');
  final _metricValueController = TextEditingController(text: '42');
  final _attrKeyController = TextEditingController(text: 'region');
  final _attrValueController = TextEditingController(text: 'us-east');
  final _urlController =
      TextEditingController(text: 'https://jsonplaceholder.typicode.com/posts');

  Trace? _activeTrace;
  bool _traceRunning = false;
  final List<String> _log = [];

  @override
  void dispose() {
    _traceNameController.dispose();
    _metricNameController.dispose();
    _metricValueController.dispose();
    _attrKeyController.dispose();
    _attrValueController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _log.insert(0, '[${TimeOfDay.now().format(context)}] $message');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  Future<void> _startTrace() async {
    final name = _traceNameController.text.trim();
    if (name.isEmpty) return;

    _activeTrace = _performance.newTrace(name);
    await _activeTrace!.start();
    setState(() => _traceRunning = true);
    _addLog('Trace "$name" started');
  }

  Future<void> _stopTrace() async {
    if (_activeTrace == null) return;
    await _activeTrace!.stop();
    setState(() {
      _traceRunning = false;
      _activeTrace = null;
    });
    _addLog('Trace stopped');
  }

  void _addMetric() {
    if (_activeTrace == null) {
      _addLog('Start a trace first');
      return;
    }
    final name = _metricNameController.text.trim();
    final value = int.tryParse(_metricValueController.text.trim()) ?? 0;
    if (name.isEmpty) return;

    _activeTrace!.setMetric(name, value);
    _addLog('Metric "$name" set to $value');
  }

  void _addAttribute() {
    if (_activeTrace == null) {
      _addLog('Start a trace first');
      return;
    }
    final key = _attrKeyController.text.trim();
    final value = _attrValueController.text.trim();
    if (key.isEmpty) return;

    _activeTrace!.putAttribute(key, value);
    _addLog('Attribute "$key" = "$value"');
  }

  Future<void> _runHttpMetric() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    try {
      final metric = _performance.newHttpMetric(
        url,
        HttpMethod.Get,
      );
      await metric.start();

      // Simulate work
      await Future<void>.delayed(const Duration(milliseconds: 500));

      metric.httpResponseCode = 200;
      metric.responseContentType = 'application/json';
      metric.responsePayloadSize = 1024;
      metric.requestPayloadSize = 0;
      await metric.stop();

      _addLog('HTTP metric recorded for GET $url');
    } catch (e) {
      _addLog('HTTP metric error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Performance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Custom Trace'),
          TextField(
            controller: _traceNameController,
            decoration: const InputDecoration(
              labelText: 'Trace Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _traceRunning ? null : _startTrace,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Trace'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _traceRunning ? _stopTrace : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Trace'),
                ),
              ),
            ],
          ),
          if (_traceRunning) ...[
            const SizedBox(height: 8),
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Trace running...',
                      style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          _SectionTitle('Add Metric to Active Trace'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _metricNameController,
                  decoration: const InputDecoration(
                    labelText: 'Metric Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _metricValueController,
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _addMetric,
            child: const Text('Set Metric'),
          ),
          const SizedBox(height: 20),
          _SectionTitle('Add Attribute to Active Trace'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _attrKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Attribute Key',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _attrValueController,
                  decoration: const InputDecoration(
                    labelText: 'Attribute Value',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _addAttribute,
            child: const Text('Put Attribute'),
          ),
          const SizedBox(height: 20),
          _SectionTitle('HTTP Metric'),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _runHttpMetric,
            child: const Text('Record HTTP Metric (GET)'),
          ),
          if (_log.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionTitle('Action Log'),
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _log
                      .map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(entry,
                                style: theme.textTheme.bodySmall),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
