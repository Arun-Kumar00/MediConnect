import 'package:flutter/material.dart';
import '../../models/device.dart';
import '../../services/api_service.dart';

class DeviceFormScreen extends StatefulWidget {
  const DeviceFormScreen({Key? key}) : super(key: key);

  @override
  State<DeviceFormScreen> createState() => _DeviceFormScreenState();
}

class _DeviceFormScreenState extends State<DeviceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final _serialController = TextEditingController();
  final _modelController = TextEditingController();
  final _firmwareController = TextEditingController();

  String _status = 'active';
  bool _saving = false;

  @override
  void dispose() {
    _serialController.dispose();
    _modelController.dispose();
    _firmwareController.dispose();
    super.dispose();
  }

  Future<void> _saveDevice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final device = Device(
        deviceSerial: _serialController.text.trim(),
        deviceModel: _modelController.text.trim(),
        status: _status,
        firmwareVersion: _firmwareController.text.trim().isEmpty
            ? null
            : _firmwareController.text.trim(),
        manufactureDate: DateTime.now().toIso8601String().split('T')[0],
        lastCalibration: DateTime.now().toIso8601String(),
      );

      await _apiService.createDevice(device);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Device added successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Device'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Serial Number
              TextFormField(
                controller: _serialController,
                decoration: InputDecoration(
                  labelText: 'Device Serial Number *',
                  hintText: 'e.g., SC-2025-001',
                  prefixIcon: Icon(Icons.qr_code),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Serial number is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Model
              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(
                  labelText: 'Device Model *',
                  hintText: 'e.g., SmartClip Pro v2',
                  prefixIcon: Icon(Icons.devices),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Model is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Firmware Version
              TextFormField(
                controller: _firmwareController,
                decoration: InputDecoration(
                  labelText: 'Firmware Version',
                  hintText: 'e.g., v2.3.1',
                  prefixIcon: Icon(Icons.system_update),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Status
              Text(
                'Device Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.info),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['active', 'maintenance', 'retired']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.toUpperCase()),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Add Device',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}