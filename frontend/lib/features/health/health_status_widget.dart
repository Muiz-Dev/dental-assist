import 'package:flutter/material.dart';
import '../../core/api_client.dart';

class HealthStatusWidget extends StatefulWidget {
  final ApiClient apiClient;

  const HealthStatusWidget({super.key, required this.apiClient});

  @override
  State<HealthStatusWidget> createState() => _HealthStatusWidgetState();
}

class _HealthStatusWidgetState extends State<HealthStatusWidget> {
  bool _isLoading = false;
  String _healthStatus = 'Unknown';
  Map<String, dynamic> _checks = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await widget.apiClient.get('/health/readiness');
      setState(() {
        _healthStatus = res['status'] ?? 'Unknown';
        _checks = res['checks'] ?? {};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _healthStatus = 'Disconnected';
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Backend Connectivity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoading ? null : _checkHealth,
                )
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const LinearProgressIndicator()
            else ...[
              Row(
                children: [
                  Icon(
                    _healthStatus == 'UP' ? Icons.check_circle : Icons.error,
                    color: _healthStatus == 'UP' ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text('Status: $_healthStatus'),
                ],
              ),
              if (_checks.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Database: ${_checks['database'] ?? 'N/A'}'),
                Text('Redis: ${_checks['redis'] ?? 'N/A'}'),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
