import 'package:flutter/material.dart';
import 'package:prioritize/screens/fight_screen.dart';
import 'package:prioritize/services/todo_services.dart';

var colors = [
  const Color.fromARGB(255, 107, 53, 234),
  const Color.fromARGB(255, 187, 221, 142),
  const Color.fromARGB(255, 219, 110, 63),
  const Color.fromARGB(255, 0, 172, 100),
  const Color.fromARGB(255, 195, 151, 255)
];

class TodoListScreen extends StatefulWidget {
  final TodoService todoService;
  const TodoListScreen({required Key key, required this.todoService})
      : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  ScrollController _scrollController = ScrollController();
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late bool isTimetoBounce = false;

  @override
  void initState() {
    super.initState();

    // Bouncing animation controller
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      /*appBar: AppBar(
        title: const 
      ),*/
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Unfocus the TextField
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
                padding: EdgeInsets.only(
                    left: 20,
                    bottom: 20,
                    top: 70), //apply padding to all four sides
                child: Text('Let\'s prioritize !',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 40))),
            _itemList(),
            if (!isKeyboardVisible) _fightButton(context),
          ],
        ),
      ),
    );
  }

  Container _fightButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: ScaleTransition(
        scale: isTimetoBounce
            ? _bounceAnimation
            : Tween(begin: 1.0, end: 1.0).animate(
                CurvedAnimation(
                    parent: _bounceController, curve: Curves.elasticInOut),
              ),
        child: ElevatedButton(
          style: ButtonStyle(
              padding: WidgetStateProperty.all<EdgeInsets>(
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              )),
              backgroundColor: const WidgetStatePropertyAll<Color>(
                  Color.fromARGB(255, 107, 53, 234))),
          onPressed: () {
            if (widget.todoService.length() > 1) {
              widget.todoService.shuffleTodos();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FightScreen(
                            todoService: widget.todoService,
                            key: const Key("list"),
                          )));
            } else {
              null;
            }
          },
          child: const Text('Fights !',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 30)),
        ),
      ),
    );
  }

  Expanded _itemList() {
    return Expanded(
      child: ReorderableListView(
        scrollController: _scrollController,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            widget.todoService.moveTodoItem(oldIndex, newIndex);
          });
        },
        padding: const EdgeInsets.all(20),
        footer: _addButton(),
        proxyDecorator: (child, index, animation) => Material(
            borderRadius: BorderRadius.circular(60),
            color: Colors.black,
            child: child),
        children: [
          for (int index = 0; index < widget.todoService.todos.length; index++)
            Container(
              key: Key(index.toString()),
              decoration: BoxDecoration(
                  color: widget.todoService.todos[index].color,
                  border: Border.all(width: 0, color: Colors.transparent),
                  borderRadius: const BorderRadius.all(Radius.circular(60))),
              child: ListTile(
                title: Text(widget.todoService.todos[index].title),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                titleTextStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 30),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.black,
                  iconSize: 30,
                  onPressed: () {
                    setState(() {
                      widget.todoService.removeTodoItem(index);
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Padding _addButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              maxLines: 1,
              maxLength: 18,
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Enter new prio',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                focusColor: Theme.of(context).colorScheme.secondary,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(60),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 4.0),
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 4.0,
                    ),
                    borderRadius: BorderRadius.circular(60)),
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Ink(
            decoration: ShapeDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: const CircleBorder(),
            ),
            child: IconButton(
              icon: const Icon(Icons.add),
              color: Colors.black,
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (_textController.text.isNotEmpty) {
                  setState(() {
                    widget.todoService.addTodoItem(_textController.text,
                        colors[widget.todoService.length() % colors.length]);
                    _textController.clear();
                    if (widget.todoService.length() > 1) {
                      isTimetoBounce = true;
                    }
                    widget.todoService.saveTodos();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
