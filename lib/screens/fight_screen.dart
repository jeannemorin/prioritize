import 'package:flutter/material.dart';
import 'package:prioritize/screens/todo_list_screen.dart';
import 'package:prioritize/services/todo_services.dart';
import 'package:prioritize/models/todo_item.dart';

class FightScreen extends StatefulWidget {
  final TodoService todoService;
  const FightScreen({required Key key, required this.todoService})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FightScreenState createState() => _FightScreenState();
}

class _FightScreenState extends State<FightScreen>
    with SingleTickerProviderStateMixin {
  late List<TodoItem> fightResults;
  late AnimationController _controller;
  // ignore: unused_field
  late Animation<Offset> _animation;
  int currentIndex = 0;
  int firstItemIndex = 0;
  int secondItemIndex = 1;
  Offset cardOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    fightResults = List.from(widget.todoService.todos);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_controller);
  }

  void handleSwipe(TodoItem winner, TodoItem loser) {
    setState(() {
      winner.score += loser.score + 1;
    });
    /*for (var i = 0; i < widget.todoService.todos.length; i++) {
      print(
          '${widget.todoService.todos[i].title} : ${widget.todoService.todos[i].score}');
    }*/
  }

  void nextFight(CardSwipeOrientation orientation) {
    final TodoItem firstItem = widget.todoService.todos[firstItemIndex];
    final TodoItem secondItem = widget.todoService.todos[secondItemIndex];

    if (orientation == CardSwipeOrientation.LEFT) {
      handleSwipe(firstItem, secondItem);
    } else if (orientation == CardSwipeOrientation.RIGHT) {
      handleSwipe(secondItem, firstItem);
    }

    if (secondItemIndex == widget.todoService.todos.length - 1) {
      firstItemIndex++;
      secondItemIndex = firstItemIndex + 1;
    } else {
      secondItemIndex++;
    }

    if (firstItemIndex == widget.todoService.todos.length - 1) {
      widget.todoService.rankTodos(fightResults);
      widget.todoService.resetScore();
      widget.todoService.saveTodos();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TodoListScreen(
                    todoService: widget.todoService,
                    key: const Key("list"),
                  )));
    } else {
      _controller.reset();
      _animation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_controller);
      _controller.forward();
    }
    cardOffset = Offset.zero;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Padding(
      padding: const EdgeInsets.all(20), //apply padding to all four sides
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Let\'s fight !',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 50)),
        const SizedBox(height: 80),
        Stack(
          children: [
            if (firstItemIndex < widget.todoService.todos.length &&
                secondItemIndex < widget.todoService.todos.length)
              GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      cardOffset += details.delta;
                    });
                  },
                  onPanEnd: (details) {
                    if (cardOffset.dx > 100) {
                      nextFight(CardSwipeOrientation.RIGHT);
                    } else if (cardOffset.dx < -100) {
                      nextFight(CardSwipeOrientation.LEFT);
                    } else {
                      setState(() {
                        cardOffset = Offset.zero;
                      });
                    }
                  },
                  child: Transform.translate(
                      offset: cardOffset,
                      child: Container(
                        height: 500,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: widget.todoService
                                        .todos[firstItemIndex].color,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10))),
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    widget.todoService.todos[firstItemIndex]
                                        .title,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 40),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: widget.todoService
                                        .todos[secondItemIndex].color,
                                    borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10))),
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    widget.todoService.todos[secondItemIndex]
                                        .title,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 40),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )))
          ],
        ),
      ]),
    )));
  }
}

// ignore: constant_identifier_names
enum CardSwipeOrientation { LEFT, RIGHT }
