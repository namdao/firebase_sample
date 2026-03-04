import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final _storage = FirebaseStorage.instance;
  final _fileNameController = TextEditingController();
  final _fileContentController = TextEditingController();
  List<Reference> _files = [];
  bool _isLoading = false;
  String? _downloadUrl;

  @override
  void initState() {
    super.initState();
    _listFiles();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _fileContentController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _uploadFile() async {
    final name = _fileNameController.text.trim();
    final content = _fileContentController.text.trim();
    if (name.isEmpty || content.isEmpty) {
      _showMessage('Please enter file name and content');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final ref = _storage.ref('samples/$name.txt');
      await ref.putData(
        utf8.encode(content),
        SettableMetadata(contentType: 'text/plain'),
      );
      _fileNameController.clear();
      _fileContentController.clear();
      _showMessage('File uploaded successfully');
      await _listFiles();
    } catch (e) {
      _showMessage('Upload error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _listFiles() async {
    setState(() => _isLoading = true);
    try {
      final result = await _storage.ref('samples').listAll();
      setState(() => _files = result.items);
    } catch (e) {
      _showMessage('List error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getDownloadUrl(Reference ref) async {
    try {
      final url = await ref.getDownloadURL();
      setState(() => _downloadUrl = url);
      _showMessage('Download URL retrieved');
    } catch (e) {
      _showMessage('URL error: $e');
    }
  }

  Future<void> _deleteFile(Reference ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Delete "${ref.name}"?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.delete();
        _showMessage('File deleted');
        setState(() => _downloadUrl = null);
        await _listFiles();
      } catch (e) {
        _showMessage('Delete error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Storage')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Upload Text File', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _fileNameController,
            decoration: const InputDecoration(
              labelText: 'File Name (without .txt)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.insert_drive_file_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _fileContentController,
            decoration: const InputDecoration(
              labelText: 'File Content',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.text_snippet_outlined),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _isLoading ? null : _uploadFile,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Upload'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Files in /samples/', style: theme.textTheme.titleMedium),
              const Spacer(),
              IconButton(
                onPressed: _listFiles,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_files.isEmpty)
            const Center(child: Text('No files found'))
          else
            ..._files.map(
              (ref) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(ref.name),
                  subtitle: Text(ref.fullPath),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.link),
                        tooltip: 'Get URL',
                        onPressed: () => _getDownloadUrl(ref),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                        onPressed: () => _deleteFile(ref),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_downloadUrl != null) ...[
            const SizedBox(height: 16),
            Card(
              color: theme.colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Download URL',
                        style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    SelectableText(
                      _downloadUrl!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
