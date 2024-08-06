import "dart:ui";
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import "package:prioritize/models/todo_item.dart";

var colors = [
  const Color.fromARGB(255, 107, 53, 234),
  const Color.fromARGB(255, 187, 221, 142),
  const Color.fromARGB(255, 219, 110, 63),
  const Color.fromARGB(255, 0, 172, 100),
  const Color.fromARGB(255, 195, 151, 255)
];

class TodoService {
  TodoService._privateConstructor();
  static final TodoService instance = TodoService._privateConstructor();

  List<TodoItem> _todos = [];
  int maxLength = 8;

  List<TodoItem> get todos => _todos;

  void set todos(List<TodoItem> list) => _todos = list;

  void addTodoItem(String title, Color color) {
    if (length() < 6) {
      _todos.insert(
          0,
          TodoItem(
              title:
                  "${title[0].toUpperCase()}${title.substring(1).toLowerCase()}",
              color: color));
    }
  }

  void moveTodoItem(int oldIndex, int newIndex) {
    final item = _todos.removeAt(oldIndex);
    _todos.insert(newIndex, item);
    saveTodos();
  }

  void removeTodoItem(int index) {
    _todos.removeAt(index);
    saveTodos();
  }

  void shuffleTodos() {
    _todos.shuffle();
  }

  void rankTodos(List<TodoItem> results) {
    _todos = results;
    _todos.sort((a, b) => b.score.compareTo(a.score));
  }

  void resetScore() {
    int index = 0;
    for (var item in _todos) {
      item.score = 0;
      item.color = colors[index % colors.length];
      index++;
    }
  }

  int length() {
    return _todos.length;
  }

  Future<String> _localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile() async {
    final path = await _localPath();
    return File('$path/todos.json');
  }

  Future<File> saveTodos() async {
    try {
      final file = await _localFile();
      if (!(await file.exists())) {
        await file.create(recursive: true);
      }
      return file.writeAsString(
          json.encode(todos.map((todo) => todo.toJson()).toList()));
    } catch (e) {
      if (kDebugMode) {
        print("Error saving todos: $e");
      }
      rethrow;
    }
  }

  Future<void> loadTodos() async {
    try {
      final file = await _localFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonTodos = json.decode(contents);
        todos = jsonTodos.map((json) => TodoItem.fromJson(json)).toList();
        for (int index = 0; index < _todos.length; index++) {
          _todos[index].color = colors[index % colors.length];
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading todos: $e");
      }
    }
  }
}
