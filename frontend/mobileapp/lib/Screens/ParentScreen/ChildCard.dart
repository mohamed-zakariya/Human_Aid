// Event Card Widget
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Childcard extends StatelessWidget {
  final String title;
  final String time;
  final Color color;
  final IconData icon;

  const Childcard({
    required this.title,
    required this.time,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
        subtitle: Text(time, style: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}