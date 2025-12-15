import 'package:flutter/material.dart';
import '../../models/patient.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class PatientFormScreen extends StatefulWidget {
  final Patient? patient;

  const PatientFormScreen({Key? key, this.patient}) : super(key: key);

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _woundTypeController = TextEditingController();
  final _woundLocationController = TextEditingController();
  final _woundSizeController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _dateOfBirth = DateTime.now().subtract(Duration(days: 365 * 30));
  String _gender = 'M';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      _firstNameController.text = widget.patient!.firstName;
      _lastNameController.text = widget.patient!.lastName;
      _contactController.text = widget.patient!.contactNumber ?? '';
      _emailController.text = widget.patient!.email ?? '';
      _woundTypeController.text = widget.patient!.woundType;
      _woundLocationController.text = widget.patient!.woundLocation;
      _woundSizeController.text = widget.patient!.woundSizeCm2?.toString() ?? '';
      _notesController.text = widget.patient!.notes ?? '';
      _dateOfBirth = DateTime.parse(widget.patient!.dateOfBirth);
      _gender = widget.patient!.gender;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _woundTypeController.dispose();
    _woundLocationController.dispose();
    _woundSizeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final patient = Patient(
        patientId: widget.patient?.patientId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dateOfBirth: DateFormat('yyyy-MM-dd').format(_dateOfBirth),
        gender: _gender,
        contactNumber: _contactController.text.trim().isEmpty
            ? null
            : _contactController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        woundType: _woundTypeController.text.trim(),
        woundLocation: _woundLocationController.text.trim(),
        woundSizeCm2: _woundSizeController.text.trim().isEmpty
            ? null
            : double.parse(_woundSizeController.text.trim()),
        admissionDate: DateTime.now().toIso8601String(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (widget.patient == null) {
        await _apiService.createPatient(patient);
      } else {
        await _apiService.updatePatient(widget.patient!.patientId!, patient);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.patient == null
                ? 'Patient added successfully'
                : 'Patient updated successfully'),
          ),
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
        title: Text(widget.patient == null ? 'Add Patient' : 'Edit Patient'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              // First Name
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Last Name
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Last name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Date of Birth
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date of Birth *',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(_dateOfBirth)),
                ),
              ),
              SizedBox(height: 16),

              // Gender
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(
                  labelText: 'Gender *',
                  prefixIcon: Icon(Icons.transgender),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: 'M', child: Text('Male')),
                  DropdownMenuItem(value: 'F', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _gender = value);
                  }
                },
              ),
              SizedBox(height: 16),

              // Contact
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Wound Information
              Text(
                'Wound Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              // Wound Type
              TextFormField(
                controller: _woundTypeController,
                decoration: InputDecoration(
                  labelText: 'Wound Type *',
                  hintText: 'e.g., Surgical, Burn, Diabetic Ulcer',
                  prefixIcon: Icon(Icons.healing),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Wound type is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Wound Location
              TextFormField(
                controller: _woundLocationController,
                decoration: InputDecoration(
                  labelText: 'Wound Location *',
                  hintText: 'e.g., Left Leg, Right Arm',
                  prefixIcon: Icon(Icons.place),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Wound location is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Wound Size
              TextFormField(
                controller: _woundSizeController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Wound Size (cm²)',
                  prefixIcon: Icon(Icons.straighten),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Additional Notes',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _savePatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    widget.patient == null ? 'Add Patient' : 'Update Patient',
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