import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'https://reqres.in/api';

  Future<Map<String, dynamic>> getUsers(int page) async {
    final response = await http.get(Uri.parse('$baseUrl/users?page=$page'));
    if (response.statusCode == 200) {
      return {'data': json.decode(response.body)['data']};
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Реалізуйте метод для отримання детальної інформації про користувача
  Future<Map<String, dynamic>> getUserDetail(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
    if (response.statusCode == 200) {
      return {'data': json.decode(response.body)['data']};
    } else {
      throw Exception('Failed to load user detail');
    }
  }
}
