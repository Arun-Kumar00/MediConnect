// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/patient.dart';
// import '../models/device.dart';
// import '../models/sensor_reading.dart';
// import '../models/alert.dart';
//
// class ApiService {
//   // CHANGE THIS TO YOUR IP ADDRESS!
//   static const String baseUrl = 'http://10.62.16.64:8080/api';
//
//   // Helper method for headers
//   Map<String, String> get headers => {
//     'Content-Type': 'application/json',
//   };
//
//   // ========== PATIENT APIs ==========
//
//   Future<List<Patient>> getPatients() async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/patients'));
//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);
//         return data.map((json) => Patient.fromJson(json)).toList();
//       } else {
//         throw Exception('Failed to load patients: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error loading patients: $e');
//     }
//   }
//
//   Future<Patient> getPatientById(int id) async {
//     final response = await http.get(Uri.parse('$baseUrl/patients/$id'));
//     if (response.statusCode == 200) {
//       return Patient.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load patient');
//     }
//   }
//
//   Future<Patient> createPatient(Patient patient) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/patients'),
//       headers: headers,
//       body: json.encode(patient.toJson()),
//     );
//     if (response.statusCode == 201 || response.statusCode == 200) {
//       return Patient.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to create patient: ${response.body}');
//     }
//   }
//
//   Future<Patient> updatePatient(int id, Patient patient) async {
//     final response = await http.put(
//       Uri.parse('$baseUrl/patients/$id'),
//       headers: headers,
//       body: json.encode(patient.toJson()),
//     );
//     if (response.statusCode == 200) {
//       return Patient.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to update patient');
//     }
//   }
//
//   Future<void> deletePatient(int id) async {
//     final response = await http.delete(Uri.parse('$baseUrl/patients/$id'));
//     if (response.statusCode != 204 && response.statusCode != 200) {
//       throw Exception('Failed to delete patient');
//     }
//   }
//
//   // ========== DEVICE APIs ==========
//
//   Future<List<Device>> getDevices() async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/devices'));
//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);
//         return data.map((json) => Device.fromJson(json)).toList();
//       } else {
//         throw Exception('Failed to load devices');
//       }
//     } catch (e) {
//       throw Exception('Error loading devices: $e');
//     }
//   }
//
//   Future<Device> createDevice(Device device) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/devices'),
//       headers: headers,
//       body: json.encode(device.toJson()),
//     );
//     if (response.statusCode == 201 || response.statusCode == 200) {
//       return Device.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to create device: ${response.body}');
//     }
//   }
//
//   Future<void> deleteDevice(int id) async {
//     final response = await http.delete(Uri.parse('$baseUrl/devices/$id'));
//     if (response.statusCode != 204 && response.statusCode != 200) {
//       throw Exception('Failed to delete device');
//     }
//   }
//
//   // ========== SENSOR READING APIs ==========
//
//   Future<List<SensorReading>> getSensorReadingsByBandage(int bandageId, {int limit = 20}) async {
//     final response = await http.get(
//         Uri.parse('$baseUrl/readings/bandage/$bandageId/recent?limit=$limit')
//     );
//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       return data.map((json) => SensorReading.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load sensor readings');
//     }
//   }
//
//   Future<SensorReading?> getLatestReading(int bandageId) async {
//     try {
//       final response = await http.get(
//           Uri.parse('$baseUrl/readings/bandage/$bandageId/latest')
//       );
//       if (response.statusCode == 200) {
//         return SensorReading.fromJson(json.decode(response.body));
//       } else {
//         return null;
//       }
//     } catch (e) {
//       return null;
//     }
//   }
//
//   // ========== ALERT APIs ==========
//
//   Future<List<Alert>> getAlerts() async {
//     final response = await http.get(Uri.parse('$baseUrl/alerts'));
//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       return data.map((json) => Alert.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load alerts');
//     }
//   }
//
//   Future<List<Alert>> getActiveAlerts() async {
//     final response = await http.get(Uri.parse('$baseUrl/alerts/active'));
//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       return data.map((json) => Alert.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load active alerts');
//     }
//   }
//
//   Future<List<Alert>> getAlertsByPatient(int patientId) async {
//     final response = await http.get(Uri.parse('$baseUrl/alerts/patient/$patientId'));
//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       return data.map((json) => Alert.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load patient alerts');
//     }
//   }
//
//   Future<void> acknowledgeAlert(int alertId, int userId) async {
//     final response = await http.patch(
//         Uri.parse('$baseUrl/alerts/$alertId/acknowledge?userId=$userId')
//     );
//     if (response.statusCode != 200) {
//       throw Exception('Failed to acknowledge alert');
//     }
//   }
//
//   // ========== BANDAGE APIs ==========
//
//   Future<List<dynamic>> getBandagesByPatient(int patientId) async {
//     final response = await http.get(Uri.parse('$baseUrl/bandages/patient/$patientId'));
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to load bandages');
//     }
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/patient.dart';
import '../models/device.dart';
import '../models/sensor_reading.dart';
import '../models/alert.dart';

class ApiService {
  // CHANGE THIS TO YOUR IP ADDRESS!
  static const String baseUrl = 'http://10.62.16.64:8080/api';

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };

  // ========== PATIENT APIs ==========

  Future<List<Patient>> getPatients() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/patients'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Patient.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load patients: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading patients: $e');
    }
  }

  Future<Patient> getPatientById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/patients/$id'));
    if (response.statusCode == 200) {
      return Patient.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load patient');
    }
  }

  Future<Patient> createPatient(Patient patient) async {
    final response = await http.post(
      Uri.parse('$baseUrl/patients'),
      headers: headers,
      body: json.encode(patient.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Patient.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create patient: ${response.body}');
    }
  }

  Future<Patient> updatePatient(int id, Patient patient) async {
    final response = await http.put(
      Uri.parse('$baseUrl/patients/$id'),
      headers: headers,
      body: json.encode(patient.toJson()),
    );
    if (response.statusCode == 200) {
      return Patient.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update patient: ${response.body}');
    }
  }

  Future<void> deletePatient(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/patients/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete patient');
    }
  }

  // ========== DEVICE APIs ==========

  Future<List<Device>> getDevices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/devices'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Device.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load devices');
      }
    } catch (e) {
      throw Exception('Error loading devices: $e');
    }
  }

  Future<Device> createDevice(Device device) async {
    final response = await http.post(
      Uri.parse('$baseUrl/devices'),
      headers: headers,
      body: json.encode(device.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Device.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create device: ${response.body}');
    }
  }

  Future<Device> updateDevice(int id, Device device) async {
    final response = await http.put(
      Uri.parse('$baseUrl/devices/$id'),
      headers: headers,
      body: json.encode(device.toJson()),
    );
    if (response.statusCode == 200) {
      return Device.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update device: ${response.body}');
    }
  }

  Future<void> deleteDevice(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/devices/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete device');
    }
  }

  // ========== BANDAGE APIs ==========

  Future<List<dynamic>> getBandagesByPatient(int patientId) async {
    final response = await http.get(Uri.parse('$baseUrl/bandages/patient/$patientId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load bandages');
    }
  }

  Future<void> removeBandage(int bandageId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/bandages/$bandageId/remove'),
        headers: headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to remove bandage: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing bandage: $e');
    }
  }

  // ========== SENSOR READING APIs ==========

  Future<List<SensorReading>> getSensorReadingsByBandage(int bandageId, {int limit = 20}) async {
    final response = await http.get(
        Uri.parse('$baseUrl/readings/bandage/$bandageId/recent?limit=$limit')
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => SensorReading.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sensor readings');
    }
  }

  Future<SensorReading?> getLatestReading(int bandageId) async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/readings/bandage/$bandageId/latest')
      );
      if (response.statusCode == 200) {
        return SensorReading.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // ========== ALERT APIs ==========

  Future<List<Alert>> getAlerts() async {
    final response = await http.get(Uri.parse('$baseUrl/alerts'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Alert.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load alerts');
    }
  }

  Future<List<Alert>> getActiveAlerts() async {
    final response = await http.get(Uri.parse('$baseUrl/alerts/active'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Alert.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load active alerts');
    }
  }

  Future<List<Alert>> getAlertsByPatient(int patientId) async {
    final response = await http.get(Uri.parse('$baseUrl/alerts/patient/$patientId'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Alert.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load patient alerts');
    }
  }

  Future<void> acknowledgeAlert(int alertId, int userId) async {
    final response = await http.patch(
        Uri.parse('$baseUrl/alerts/$alertId/acknowledge?userId=$userId')
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to acknowledge alert');
    }
  }
}