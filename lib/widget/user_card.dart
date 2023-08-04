import 'package:flutter/material.dart';
import '../models/users.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const UserCard({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Додаткова тінь для карточки
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 24), // Збільшити відступи
      child: ListTile(
        contentPadding: EdgeInsets.all(16), // Збільшити відступи внутрішнього контенту
        leading: CircleAvatar(
          radius: 36, // Збільшити радіус аватарки
          backgroundImage: NetworkImage(user.avatar),
        ),
        title: Text(
          user.name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Збільшити розмір шрифту
        ),
        subtitle: Text(user.email, style: TextStyle(fontSize: 16)), // Збільшити розмір шрифту
        onTap: onTap,
      ),
    );
  }
}
