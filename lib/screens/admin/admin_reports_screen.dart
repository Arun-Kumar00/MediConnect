import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({Key? key}) : super(key: key);

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final ApiService _apiService = ApiService();
  Map<String, int> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final devices = await _apiService.getDevices();
      final patients = await _apiService.getPatients();
      final alerts = await _apiService.getAlerts();

      final activeDevices = devices.where((d) => d.status == 'active').length;
      final maintenanceDevices = devices.where((d) => d.status == 'maintenance').length;
      final criticalAlerts = alerts.where((a) => a.severity == 'critical').length;

      setState(() {
        _stats = {
          'Total Devices': devices.length,
          'Active Devices': activeDevices,
          'Devices in Maintenance': maintenanceDevices,
          'Total Patients': patients.length,
          'Total Alerts': alerts.length,
          'Critical Alerts': criticalAlerts,
        };
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('System Reports'),
        backgroundColor: Colors.purple,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadStats,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              'System Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ..._stats.entries.map((entry) => Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(Icons.analytics, color: Colors.purple),
                title: Text(entry.key),
                trailing: Text(
                  entry.value.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}