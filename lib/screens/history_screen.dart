import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html; // For web download

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('scan_history') ?? [];
    });
  }

  void _downloadReport() {
    if (_history.isEmpty) return;
    
    // Generate a simple text report
    String report = "Smart Crop AI - Scan Report\n\n";
    report += "Date & Time | Disease | Confidence\n";
    report += "-----------------------------------\n";
    for (var item in _history) {
      var parts = item.split('|');
      report += "${parts[0]} | ${parts[1]} | ${parts[2]}\n";
    }

    // Trigger web download
    final blob = html.Blob([report], 'text/plain');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'crop_ai_report.txt')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadReport,
            tooltip: 'Download Report',
          )
        ],
      ),
      body: _history.isEmpty
          ? const Center(child: Text('No history yet. Scan some crops!'))
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                var parts = _history[index].split('|');
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.history, color: Colors.green),
                    title: Text(parts[1], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Date: ${parts[0]}'),
                    trailing: Text(parts[2], style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
    );
  }
}