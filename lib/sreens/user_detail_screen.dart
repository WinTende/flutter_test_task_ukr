import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/users.dart';
import '../services/api_service.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;

  const UserDetailScreen({required this.user});

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _userDetail = {};
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserDetail();
  }

  Future<void> _loadUserDetail() async {
    try {
      final result = await _apiService.getUserDetail(widget.user.id);
      setState(() {
        _userDetail = result['data'];
        _avatarUrl = _userDetail['avatar'];
        _saveToCache(result['data'], _avatarUrl);
      });
    } catch (error) {
      final prefs = await SharedPreferences.getInstance();
      final userDetailJson = prefs.getString('userDetail_${widget.user.id}');
      final avatarUrl = prefs.getString('avatarUrl_${widget.user.id}');
      if (userDetailJson != null) {
        setState(() {
          _userDetail = jsonDecode(userDetailJson);
          _avatarUrl = avatarUrl;
        });
      }
    }
  }

  Future<void> _saveToCache(Map<String, dynamic> userDetail, String? avatarUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userDetail_${widget.user.id}', jsonEncode(userDetail));
    await prefs.setString('avatarUrl_${widget.user.id}', avatarUrl ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${widget.user.id}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Name: ${widget.user.name}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Email: ${widget.user.email}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Additional Info:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Position: ${_userDetail['last_name'] ?? "N/A"}',
              style: TextStyle(fontSize: 18),
            ),
            if (_avatarUrl != null)
              Image.network(
                _avatarUrl!,
                width: 100,
                height: 100,
              ),
          ],
        ),
      ),
    );
  }
}
