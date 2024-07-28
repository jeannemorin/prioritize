import 'package:flutter/material.dart';
import 'package:prioritize/screens/todo_list_screen.dart';
import 'package:prioritize/services/todo_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TodoService.instance.loadTodos();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final TodoService todoService = TodoService.instance;

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prioritize',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            primary: const Color.fromARGB(255, 107, 53, 234),
            secondary: const Color.fromARGB(255, 195, 245, 129),
            tertiary: const Color.fromARGB(255, 255, 80, 3),

            seedColor: const Color.fromARGB(255, 107, 53, 234),

            // ···
            brightness: Brightness.dark,
          ),
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.black),
      home: TodoListScreen(
        todoService: todoService,
        key: const Key("list"),
      ),
    );
  }
}
