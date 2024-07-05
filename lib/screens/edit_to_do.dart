import 'package:flutter/material.dart';
import '../model/todo.dart';
import '../constants/colors.dart';

class EditToDoScreen extends StatefulWidget {
  final ToDo todo;
  final Function(ToDo) onSave;

  EditToDoScreen({required this.todo, required this.onSave});

  @override
  _EditToDoScreenState createState() => _EditToDoScreenState();
}

class _EditToDoScreenState extends State<EditToDoScreen> {
  final _todoController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _todoController.text = widget.todo.todoText;
    _descriptionController.text = widget.todo.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: tdBGColor,
        elevation: 0,
        title: Text('Edit ToDo'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              widget.todo.delete();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _todoController,
              decoration: InputDecoration(labelText: 'ToDo'),
              
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.todo.todoText = _todoController.text;
                  widget.todo.description = _descriptionController.text;
                  widget.todo.save();
                  widget.onSave(widget.todo);
                });
                Navigator.of(context).pop();
              },
              child: Text('Save', style: TextStyle(color: tdBlue),),
            ),
          ],
        ),
      ),
    );
  }
}
