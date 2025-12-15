// import 'package:flutter/material.dart';
// import '../../models/patient.dart';
// import '../../services/api_service.dart';
// import 'patient_form_screen.dart';
// import 'patient_detail_screen.dart';
// import 'package:intl/intl.dart';
//
// class PatientListScreen extends StatefulWidget {
//   const PatientListScreen({Key? key}) : super(key: key);
//
//   @override
//   State<PatientListScreen> createState() => _PatientListScreenState();
// }
//
// class _PatientListScreenState extends State<PatientListScreen> {
//   final ApiService _apiService = ApiService();
//   List<Patient> _patients = [];
//   List<Patient> _filteredPatients = [];
//   bool _loading = true;
//   String? _error;
//   final _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadPatients();
//     _searchController.addListener(_filterPatients);
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadPatients() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//
//     try {
//       final patients = await _apiService.getPatients();
//       setState(() {
//         _patients = patients;
//         _filteredPatients = patients;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _loading = false;
//       });
//     }
//   }
//
//   void _filterPatients() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       _filteredPatients = _patients.where((patient) {
//         return patient.fullName.toLowerCase().contains(query) ||
//             patient.woundType.toLowerCase().contains(query) ||
//             patient.woundLocation.toLowerCase().contains(query);
//       }).toList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Patients'),
//         backgroundColor: Colors.blue,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _loadPatients,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search patients...',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey.shade100,
//               ),
//             ),
//           ),
//           Expanded(child: _buildBody()),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () async {
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => PatientFormScreen()),
//           );
//           if (result == true) {
//             _loadPatients();
//           }
//         },
//         icon: Icon(Icons.person_add),
//         label: Text('Add Patient'),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
//
//   Widget _buildBody() {
//     if (_loading) {
//       return Center(child: CircularProgressIndicator());
//     }
//
//     if (_error != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 60, color: Colors.red),
//             SizedBox(height: 16),
//             Text('Error: $_error'),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _loadPatients,
//               child: Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (_filteredPatients.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.people, size: 80, color: Colors.grey),
//             SizedBox(height: 16),
//             Text(
//               _searchController.text.isEmpty
//                   ? 'No patients found'
//                   : 'No matching patients',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//             SizedBox(height: 8),
//             Text(
//               _searchController.text.isEmpty
//                   ? 'Tap + to add a new patient'
//                   : 'Try a different search term',
//               style: TextStyle(fontSize: 14, color: Colors.grey),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: _loadPatients,
//       child: ListView.builder(
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         itemCount: _filteredPatients.length,
//         itemBuilder: (context, index) {
//           final patient = _filteredPatients[index];
//           final daysAdmitted = DateTime.now()
//               .difference(DateTime.parse(patient.admissionDate))
//               .inDays;
//
//           return Card(
//             elevation: 2,
//             margin: EdgeInsets.only(bottom: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: InkWell(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => PatientDetailScreen(patient: patient),
//                   ),
//                 );
//               },
//               borderRadius: BorderRadius.circular(12),
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     // Avatar
//                     CircleAvatar(
//                       radius: 30,
//                       backgroundColor: Colors.blue.shade100,
//                       child: Text(
//                         patient.firstName[0].toUpperCase(),
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 16),
//                     // Patient Info
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             patient.fullName,
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             '${patient.woundType} - ${patient.woundLocation}',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey.shade700,
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Row(
//                             children: [
//                               Icon(Icons.straighten, size: 14, color: Colors.grey),
//                               SizedBox(width: 4),
//                               Text(
//                                 '${patient.woundSizeCm2?.toStringAsFixed(2) ?? 'N/A'} cm²',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                               SizedBox(width: 12),
//                               Icon(Icons.calendar_today, size: 14, color: Colors.grey),
//                               SizedBox(width: 4),
//                               Text(
//                                 '$daysAdmitted days',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     Icon(Icons.chevron_right, color: Colors.grey),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../../models/patient.dart';
import '../../services/api_service.dart';
import 'patient_form_screen.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({Key? key}) : super(key: key);

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final ApiService _apiService = ApiService();
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  bool _loading = true;
  String? _error;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final patients = await _apiService.getPatients();
      setState(() {
        _patients = patients;
        _filteredPatients = patients;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _filterPatients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _patients.where((patient) {
        return patient.fullName.toLowerCase().contains(query) ||
            patient.woundType.toLowerCase().contains(query) ||
            patient.woundLocation.toLowerCase().contains(query) ||
            (patient.notes?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  Future<void> _editPatient(Patient patient) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientFormScreen(patient: patient),
      ),
    );
    if (result == true) {
      _loadPatients();
    }
  }

  Future<void> _deletePatient(Patient patient) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Patient'),
        content: Text(
          'Are you sure you want to delete ${patient.fullName}?\n\n'
              'This will also delete:\n'
              '• All sensor readings\n'
              '• All alerts\n'
              '• Medical history\n\n'
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && patient.patientId != null) {
      try {
        await _apiService.deletePatient(patient.patientId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Patient deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadPatients();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting patient: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Patients'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPatients,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search patients...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PatientFormScreen()),
          );
          if (result == true) {
            _loadPatients();
          }
        },
        icon: Icon(Icons.person_add),
        label: Text('Add Patient'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Text('Error: $_error'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPatients,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredPatients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No patients found'
                  : 'No matching patients',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'Tap + to add a new patient'
                  : 'Try a different search term',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPatients,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredPatients.length,
        itemBuilder: (context, index) {
          final patient = _filteredPatients[index];
          final daysAdmitted = DateTime.now()
              .difference(DateTime.parse(patient.admissionDate))
              .inDays;

          return Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientDetailScreen(patient: patient),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        patient.firstName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.fullName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${patient.woundType} - ${patient.woundLocation}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.straighten, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                '${patient.woundSizeCm2?.toStringAsFixed(2) ?? 'N/A'} cm²',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                '$daysAdmitted days',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: ListTile(
                            leading: Icon(Icons.edit, color: Colors.blue),
                            title: Text('Update'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          onTap: () {
                            Future.delayed(
                              Duration(milliseconds: 100),
                                  () => _editPatient(patient),
                            );
                          },
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Delete'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          onTap: () {
                            Future.delayed(
                              Duration(milliseconds: 100),
                                  () => _deletePatient(patient),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}