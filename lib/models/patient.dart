class Patient {
  final int? patientId;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String gender;
  final String? contactNumber;
  final String? email;
  final String woundType;
  final String woundLocation;
  final double? woundSizeCm2;
  final String admissionDate;
  final String? notes;

  Patient({
    this.patientId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.contactNumber,
    this.email,
    required this.woundType,
    required this.woundLocation,
    this.woundSizeCm2,
    required this.admissionDate,
    this.notes,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientId: json['patientId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      contactNumber: json['contactNumber'],
      email: json['email'],
      woundType: json['woundType'],
      woundLocation: json['woundLocation'],
      woundSizeCm2: json['woundSizeCm2']?.toDouble(),
      admissionDate: json['admissionDate'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'contactNumber': contactNumber,
      'email': email,
      'woundType': woundType,
      'woundLocation': woundLocation,
      'woundSizeCm2': woundSizeCm2,
      'admissionDate': admissionDate,
      'notes': notes,
    };
  }

  String get fullName => '$firstName $lastName';
}