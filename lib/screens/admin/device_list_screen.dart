// import 'package:flutter/material.dart';
// import '../../models/device.dart';
// import '../../services/api_service.dart';
// import 'device_form_screen.dart';
//
// class DeviceListScreen extends StatefulWidget {
//   const DeviceListScreen({Key? key}) : super(key: key);
//
//   @override
//   State<DeviceListScreen> createState() => _DeviceListScreenState();
// }
//
// class _DeviceListScreenState extends State<DeviceListScreen> {
//   final ApiService _apiService = ApiService();
//   List<Device> _devices = [];
//   bool _loading = true;
//   String? _error;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDevices();
//   }
//
//   Future<void> _loadDevices() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//
//     try {
//       final devices = await _apiService.getDevices();
//       setState(() {
//         _devices = devices;
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
//   Future<void> _deleteDevice(Device device) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete Device'),
//         content: Text('Are you sure you want to delete ${device.deviceSerial}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm == true && device.deviceId != null) {
//       try {
//         await _apiService.deleteDevice(device.deviceId!);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Device deleted successfully')),
//         );
//         _loadDevices();
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error deleting device: $e')),
//         );
//       }
//     }
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'active':
//         return Colors.green;
//       case 'maintenance':
//         return Colors.orange;
//       case 'retired':
//         return Colors.grey;
//       default:
//         return Colors.blue;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Devices'),
//         backgroundColor: Colors.blue,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _loadDevices,
//           ),
//         ],
//       ),
//       body: _buildBody(),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () async {
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => DeviceFormScreen()),
//           );
//           if (result == true) {
//             _loadDevices();
//           }
//         },
//         icon: Icon(Icons.add),
//         label: Text('Add Device'),
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
//               onPressed: _loadDevices,
//               child: Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (_devices.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.devices, size: 80, color: Colors.grey),
//             SizedBox(height: 16),
//             Text(
//               'No devices found',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Tap + to add a new device',
//               style: TextStyle(fontSize: 14, color: Colors.grey),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: _loadDevices,
//       child: ListView.builder(
//         padding: EdgeInsets.all(16),
//         itemCount: _devices.length,
//         itemBuilder: (context, index) {
//           final device = _devices[index];
//           return Card(
//             elevation: 2,
//             margin: EdgeInsets.only(bottom: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: ListTile(
//               contentPadding: EdgeInsets.all(16),
//               leading: Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(
//                   Icons.router,
//                   color: Colors.blue,
//                   size: 30,
//                 ),
//               ),
//               title: Text(
//                 device.deviceSerial,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 8),
//                   Text(device.deviceModel),
//                   SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: _getStatusColor(device.status).withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           device.status.toUpperCase(),
//                           style: TextStyle(
//                             color: _getStatusColor(device.status),
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       if (device.firmwareVersion != null) ...[
//                         SizedBox(width: 8),
//                         Text(
//                           'v${device.firmwareVersion}',
//                           style: TextStyle(fontSize: 12, color: Colors.grey),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ],
//               ),
//               trailing: PopupMenuButton(
//                 icon: Icon(Icons.more_vert),
//                 itemBuilder: (context) => [
//                   PopupMenuItem(
//                     child: ListTile(
//                       leading: Icon(Icons.delete, color: Colors.red),
//                       title: Text('Delete'),
//                       contentPadding: EdgeInsets.zero,
//                     ),
//                     onTap: () {
//                       Future.delayed(
//                         Duration(milliseconds: 100),
//                             () => _deleteDevice(device),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../../models/device.dart';
import '../../services/api_service.dart';
import 'device_form_screen.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final ApiService _apiService = ApiService();
  List<Device> _devices = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final devices = await _apiService.getDevices();
      setState(() {
        _devices = devices;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _editDevice(Device device) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceFormScreen(),
      ),
    );
    if (result == true) {
      _loadDevices();
    }
  }

  Future<void> _deleteDevice(Device device) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Device'),
        content: Text(
          'Are you sure you want to delete ${device.deviceSerial}?\n\n'
              'Make sure this device is not currently in use.\n\n'
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

    if (confirm == true && device.deviceId != null) {
      try {
        await _apiService.deleteDevice(device.deviceId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Device deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadDevices();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting device: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'retired':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Devices'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDevices,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DeviceFormScreen()),
          );
          if (result == true) {
            _loadDevices();
          }
        },
        icon: Icon(Icons.add),
        label: Text('Add Device'),
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
              onPressed: _loadDevices,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No devices found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to add a new device',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDevices,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.router,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              title: Text(
                device.deviceSerial,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(device.deviceModel),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(device.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          device.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(device.status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (device.firmwareVersion != null) ...[
                        SizedBox(width: 8),
                        Text(
                          'v${device.firmwareVersion}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                icon: Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.edit, color: Colors.blue),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onTap: () {
                      Future.delayed(
                        Duration(milliseconds: 100),
                            () => _editDevice(device),
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
                            () => _deleteDevice(device),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}