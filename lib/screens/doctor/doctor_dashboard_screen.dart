import 'package:flutter/material.dart';
import 'package:wound_healing_app/screens/doctor/patient_form_screen.dart';
import 'patient_list_screen.dart';
import 'alert_screen.dart';
import '../../services/api_service.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({Key? key}) : super(key: key);

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final ApiService _apiService = ApiService();
  int _patientCount = 0;
  int _activeAlertsCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final patients = await _apiService.getPatients();
      final alerts = await _apiService.getActiveAlerts();

      setState(() {
        _patientCount = patients.length;
        _activeAlertsCount = alerts.length;
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
        title: Text('Doctor Dashboard'),
    backgroundColor: Colors.teal,
    elevation: 0,
    ),
    body: _loading
    ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
    onRefresh: _loadDashboardData,
    child: SingleChildScrollView(
    physics: AlwaysScrollableScrollPhysics(),
    padding: EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Welcome Card
    Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
    ),
    child: Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [Colors.teal.shade400, Colors.teal.shade700],
    ),
    borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
    children: [
    Icon(Icons.medical_information, size: 50, color: Colors.white),
    SizedBox(width: 16),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Welcome, Doctor',
    style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    ),
    ),
    Text(
    'Patient Care Center',
    style: TextStyle(
    fontSize: 14,
    color: Colors.white70,
    ),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    ),
    SizedBox(height: 24),

    // Statistics
    Text(
    'Overview',
    style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    ),
    ),
    SizedBox(height: 12),

    Row(
    children: [
    Expanded(
    child: _buildStatCard(
    'My Patients',
    _patientCount.toString(),
    Icons.people,
    Colors.blue,
    ),
    ),
    SizedBox(width: 12),
    Expanded(
    child: _buildStatCard(
    'Active Alerts',
    _activeAlertsCount.toString(),
    Icons.warning,
    Colors.red,
    ),
    ),
    ],
    ),

    SizedBox(height: 24),

    // Quick Actions
    Text(
    'Quick Actions',
    style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    ),
    ),
    SizedBox(height: 12),

    _buildActionCard(
    title: 'My Patients',
    subtitle: 'View and manage patients',
    icon: Icons.people,
    color: Colors.blue,
        onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PatientListScreen()),
    );
    },
    ),

      SizedBox(height: 12),

      _buildActionCard(
        title: 'Active Alerts',
        subtitle: 'Review patient alerts',
        icon: Icons.notifications_active,
        color: Colors.orange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AlertsScreen()),
          );
        },
      ),

      SizedBox(height: 12),

      _buildActionCard(
        title: 'Add New Patient',
        subtitle: 'Register a new patient',
        icon: Icons.person_add,
        color: Colors.green,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientFormScreen(),
            ),
          );
        },
      ),
      ],
    ),
    ),
    ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 30),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}