import 'package:flutter/material.dart';
import '../../models/alert.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final ApiService _apiService = ApiService();
  List<Alert> _alerts = [];
  bool _loading = true;
  String _filter = 'active'; // active, all

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _loading = true);

    try {
      final alerts = _filter == 'active'
          ? await _apiService.getActiveAlerts()
          : await _apiService.getAlerts();

      setState(() {
        _alerts = alerts;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading alerts: $e')),
        );
      }
    }
  }

  Future<void> _acknowledgeAlert(Alert alert) async {
    try {
      await _apiService.acknowledgeAlert(alert.alertId!, 1); // userId = 1 for demo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alert acknowledged')),
      );
      _loadAlerts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error acknowledging alert: $e')),
      );
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow.shade700;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getAlertIcon(String alertType) {
    switch (alertType.toLowerCase()) {
      case 'high_ph':
        return Icons.science;
      case 'low_oxygen':
        return Icons.air;
      case 'high_temp':
        return Icons.thermostat;
      case 'infection_risk':
        return Icons.warning;
      case 'enzyme_spike':
        return Icons.trending_up;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alerts'),
        backgroundColor: Colors.orange,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _filter = value);
              _loadAlerts();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'active', child: Text('Active Alerts')),
              PopupMenuItem(value: 'all', child: Text('All Alerts')),
            ],
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAlerts,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _alerts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'No ${_filter == 'active' ? 'active' : ''} alerts',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'All patients are doing well!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadAlerts,
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: _alerts.length,
          itemBuilder: (context, index) {
            final alert = _alerts[index];
            final severityColor = _getSeverityColor(alert.severity);

            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: severityColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ExpansionTile(
                leading: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getAlertIcon(alert.alertType),
                    color: severityColor,
                  ),
                ),
                title: Text(
                  alert.alertType.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: severityColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        alert.severity.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy, hh:mm a')
                          .format(DateTime.parse(alert.triggeredAt)),
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Message:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(alert.message),
                        SizedBox(height: 8),
                        Text(
                          'Patient ID: ${alert.patientId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Bandage ID: ${alert.bandageId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        if (alert.status == 'active') ...[
                          SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _acknowledgeAlert(alert),
                              icon: Icon(Icons.check),
                              label: Text('Acknowledge'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                            ),
                          ),
                        ] else ...[
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Acknowledged',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}