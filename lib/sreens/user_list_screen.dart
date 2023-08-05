import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/users.dart';
import '../services/api_service.dart';
import '../widget/user_card.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService _apiService = ApiService();
  List<User> _users = [];
  int _currentPage = 1;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadMoreUsers();
      }
    });

    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final result = await _apiService.getUsers(_currentPage);
      final List<User> users = result['data'].map<User>((json) {
        return User(
          id: json['id'],
          name: json['first_name'] + ' ' + json['last_name'],
          email: json['email'],
          avatar: json['avatar'],
        );
      }).toList();

      // Зберегти користувачів в shared_preferences
      final prefs = await SharedPreferences.getInstance();
      final userJsonList = users.map((user) => user.toJson()).toList();
      await prefs.setStringList('users', userJsonList.map((json) => jsonEncode(json)).toList());

      setState(() {
        _users = users;
      });
    } catch (error) {
      // Відновити користувачів з shared_preferences у випадку відсутності Інтернет-з'єднання
      final prefs = await SharedPreferences.getInstance();
      final userJsonList = prefs.getStringList('users');
      if (userJsonList != null) {
        final users = userJsonList.map((json) => User.fromJson(jsonDecode(json))).toList();
        setState(() {
          _users = users;
        });
      }
    }
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _apiService.getUsers(_currentPage + 1);
    final List<User> newUsers = result['data'].map<User>((json) {
      return User(
        id: json['id'],
        name: json['first_name'] + ' ' + json['last_name'],
        email: json['email'],
        avatar: json['avatar'],
      );
    }).toList();

    setState(() {
      _users.addAll(newUsers);
      _currentPage++;
      _isLoading = false;
    });
  }

  void _navigateToDetail(User user) {
    Get.to(UserDetailScreen(user: user));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: ListView.builder(
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: _users.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _users.length) {
              return UserCard(
                user: _users[index],
                onTap: () => _navigateToDetail(_users[index]),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}