import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000'; // Adjust as needed
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    String? token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer \$token',
    };
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final url = Uri.parse('\$baseUrl\$endpoint');
    return await http.post(url, headers: headers, body: jsonEncode(data));
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final url = Uri.parse('\$baseUrl\$endpoint');
    return await http.get(url, headers: headers);
  }

  // Authentication APIs
  Future<bool> login(String phone, String otp) async {
    final response = await post('/auth/login', {'phone': phone, 'otp': otp});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['access_token']);
      return true;
    }
    return false;
  }

  Future<bool> register(String phone, String firstName, String lastName) async {
    final response = await post('/auth/register', {
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
    });
    return response.statusCode == 200;
  }

  // Medicines API
  Future<List<dynamic>> fetchMedicines([String? query]) async {
    String endpoint = '/medicines/';
    if (query != null && query.isNotEmpty) {
      endpoint += '?query=\$query';
    }
    final response = await get(endpoint);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  // Orders API
  Future<List<dynamic>> fetchOrders() async {
    final response = await get('/orders/');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  // Add more API methods as needed
}
