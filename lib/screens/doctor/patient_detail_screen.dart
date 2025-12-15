import 'package:flutter/material.dart';
import '../../models/patient.dart';
import '../../models/sensor_reading.dart';
import '../../models/alert.dart';
import '../../services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final ApiService _apiService = ApiService();
  List<SensorReading> _readings = [];
  List<Alert> _alerts = [];
  int? _bandageId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  Future<void> _dischargePatient() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Discharge Patient'),
          ],
        ),
        content: Text(
          'Are you sure you want to discharge ${widget.patient.fullName}?\n\n'
              'This will:\n'
              '• Remove the active bandage\n'
              '• Stop sensor monitoring\n'
              '• Close active alerts\n\n'
              'The patient will no longer be monitored.\n\n'
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Discharge'),
          ),
        ],
      ),
    );

    if (confirm == true && _bandageId != null) {
      try {
        await _apiService.removeBandage(_bandageId!);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Patient discharged successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Go back to patient list
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error discharging patient: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      // Get bandages for patient
      final bandages = await _apiService.getBandagesByPatient(widget.patient.patientId!);

      if (bandages.isNotEmpty) {
        final activeBandage = bandages.firstWhere(
              (b) => b['status'] == 'active',
          orElse: () => bandages.first,
        );
        _bandageId = activeBandage['bandageId'];

        // Get sensor readings
        final readings = await _apiService.getSensorReadingsByBandage(_bandageId!);
        _readings = readings.reversed.toList(); // Reverse for chronological order
      }

      // Get alerts
      final alerts = await _apiService.getAlertsByPatient(widget.patient.patientId!);
      _alerts = alerts.where((a) => a.status == 'active').toList();

      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.patient.fullName),
      //   backgroundColor: Colors.teal,
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.refresh),
      //       onPressed: _loadData,
      //     ),
      //   ],
      // ),
      appBar: AppBar(
        title: Text(widget.patient.fullName),
        backgroundColor: Colors.teal,
        actions: [
          if (_bandageId != null)
            IconButton(
              icon: Icon(Icons.logout),
              tooltip: 'Discharge Patient',
              onPressed: _dischargePatient,
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Info Card
              _buildPatientInfoCard(),
              SizedBox(height: 16),

              // Alerts
              if (_alerts.isNotEmpty) ...[
                _buildAlertsSection(),
                SizedBox(height: 16),
              ],

              // Sensor Charts
              if (_readings.isNotEmpty) ...[
                _buildChartSection('pH Levels', _buildPhChart()),
                SizedBox(height: 16),
                _buildChartSection('Oxygen Levels (%)', _buildOxygenChart()),
                SizedBox(height: 16),
                _buildChartSection('Temperature (°C)', _buildTempChart()),
              ] else ...[
                _buildNoDataCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    final daysAdmitted = DateTime.now()
        .difference(DateTime.parse(widget.patient.admissionDate))
        .inDays;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.teal.shade100,
                  child: Text(
                    widget.patient.firstName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patient.fullName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.patient.gender} • ${_calculateAge(widget.patient.dateOfBirth)} years',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            _buildInfoRow('Wound Type', widget.patient.woundType),
            _buildInfoRow('Location', widget.patient.woundLocation),
            _buildInfoRow('Size', '${widget.patient.woundSizeCm2?.toStringAsFixed(2) ?? 'N/A'} cm²'),
            _buildInfoRow('Days Admitted', '$daysAdmitted days'),
            if (widget.patient.contactNumber != null)
              _buildInfoRow('Contact', widget.patient.contactNumber!),
            if (widget.patient.email != null)
              _buildInfoRow('Email', widget.patient.email!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    return Card(
        elevation: 2,
        color: Colors.red.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Row(
          children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 8),
          Text(
            'Active Alerts (${_alerts.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
          ),
          ],
        ),
        SizedBox(height: 12),
        ..._alerts.map((alert) => Padding(
        padding: EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getSeverityColor(alert.severity),
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
        SizedBox(width: 8),
        Expanded(
          child: Text(
            alert.message,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
        )),
              ],
          ),
        ),
    );
  }

  Widget _buildChartSection(String title, Widget chart) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildPhChart() {
    if (_readings.isEmpty) return Container();

    final spots = _readings.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.phValue?.toDouble() ?? 0,
      );
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        minY: 6,
        maxY: 9,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildOxygenChart() {
    if (_readings.isEmpty) return Container();

    final spots = _readings.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.oxygenPercent?.toDouble() ?? 0,
      );
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildTempChart() {
    if (_readings.isEmpty) return Container();

    final spots = _readings.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.temperatureCelsius?.toDouble() ?? 0,
      );
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        minY: 35,
        maxY: 40,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.timeline, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No sensor data available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Data will appear once a bandage is attached',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
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

  int _calculateAge(String dateOfBirth) {
    final dob = DateTime.parse(dateOfBirth);
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }
}