import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/todo.dart';
import '../constants/colors.dart';
import '../widgets/items.dart';
import 'edit_to_do.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Box<ToDo> todoBox;
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    todoBox = Hive.box<ToDo>('todoBox');
    _foundToDo = todoBox.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Column(
              children: [
                searchBox(),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: todoBox.listenable(),
                    builder: (context, Box<ToDo> box, _) {
                      List<ToDo> todosList = _searchController.text.isEmpty
                          ? box.values.toList()
                          : _foundToDo;

                      return ListView(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              top: 50,
                              bottom: 20,
                            ),
                            child: const Text(
                              'All ToDos',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w400,
                                color:Color.fromARGB(255, 24, 21, 21)

                              ),
                            ),
                          ),
                          for (ToDo todo in todosList)
                            ToDoItem(
                              todo: todo,
                              onToDoChanged: _handleToDoChange,
                              onDeleteItem: _deleteToDoItem,
                              onEditItem: _editToDoItem,
                            ),
                        ],
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                    left: 20,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 10.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _todoController,
                    decoration: const InputDecoration(
                        hintText: 'Add a new todo item',
                        border: InputBorder.none),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  bottom: 20,
                  right: 20,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _addToDoItem(_todoController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tdBlue,
                    minimumSize: const Size(60, 60),
                    elevation: 10,
                  ),
                  child: const Text(
                    '+',
                    style: TextStyle(
                      fontSize: 40,
                      color: tdWhite
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(
            Icons.menu,
            color: tdBlack,
            size: 30,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearAllToDos,
          ),
        ],
      ),
    );
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _runFilter(value),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
      todo.save();
    });
  }

  void _deleteToDoItem(ToDo todo) {
    setState(() {
      todo.delete();
    });
  }

  void _addToDoItem(String toDo) {
    setState(() {
      final newToDo = ToDo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        todoText: toDo,
      );
      todoBox.add(newToDo);
    });
    _todoController.clear();
  }

  void _editToDoItem(ToDo todo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditToDoScreen(
          todo: todo,
          onSave: (updatedTodo) {
            setState(() {
              todoBox.put(updatedTodo.key, updatedTodo);
            });
          },
        ),
      ),
    );
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todoBox.values.toList();
    } else {
      results = todoBox.values
          .where((item) =>
              item.todoText.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  void _clearAllToDos() {
    setState(() {
      todoBox.clear();
    });
  }
}
