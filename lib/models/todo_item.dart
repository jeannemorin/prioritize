import 'dart:ui';

import 'package:flutter/material.dart';

class TodoItem {
  String title;
  int score;
  Color color;

  TodoItem({required this.title, this.score = 0, required this.color});

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      title: json['title'],
      score: 0,
      color: const Color.fromARGB(255, 107, 53, 234),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
    };
  }
}
