// todo_page.dart
import 'package:flutter/material.dart';
import 'package:todolist_app/database_helper.dart';
import 'package:todolist_app/todo.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _TodoList();
}

class _TodoList extends State<TodoList>{
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _deskripsiCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();
  List<Todo> todoList = [];

  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  void refreshList() async {
    final todos = await dbHelper.getAllTodos();
    setState(() {
      todoList = todos;
    });
  }

  void addItem() async {
    if (_namaCtrl.text.isNotEmpty && _deskripsiCtrl.text.isNotEmpty) {
      await dbHelper.addTodo(Todo(_namaCtrl.text, _deskripsiCtrl.text));
      refreshList();

      _namaCtrl.text = '';
      _deskripsiCtrl.text = '';
    }
  }

  void updateItem(int index, bool done) async {
    todoList[index].done = done;
    await dbHelper.updateTodo(todoList[index]);
    refreshList();
  }

  void deleteItem(int id) async {
    await dbHelper.deleteTodo(id);
    refreshList();
  }

  void cariTodo() async {
    String teks = _searchCtrl.text.trim();
    List<Todo> todos = [];
    if (teks.isEmpty) {
      todos = await dbHelper.getAllTodos();
    } else {
      todos = await dbHelper.searchTodo(teks);
    }

    setState(() {
      todoList = todos;
    });
  }

  void tampilForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.all(20),
        title: Text("Tambah Todo"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Tutup"),
          ),
          ElevatedButton(
            onPressed: () {
              addItem();
              Navigator.pop(context);
            },
            child: Text("Tambah"),
          ),
        ],
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              TextField(
                controller: _namaCtrl,
                decoration: InputDecoration(hintText: 'Nama Todo'),
              ),
              TextField(
                controller: _deskripsiCtrl,
                decoration: InputDecoration(hintText: 'Deskripsi Pekerjaan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplikasi Todo List'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: tampilForm,
        child: Icon(Icons.add_box),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) {
                cariTodo();
              },
              decoration: InputDecoration(
                hintText: 'Cari apa',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: todoList[index].done
                      ? IconButton(
                    icon: const Icon(Icons.check_circle),
                    onPressed: () {
                      updateItem(index, !todoList[index].done);
                    },
                  )
                      : IconButton(
                    icon: const Icon(Icons.radio_button_unchecked),
                    onPressed: () {
                      updateItem(index, !todoList[index].done);
                    },
                  ),
                  title: Text(todoList[index].nama),
                  subtitle: Text(todoList[index].deskripsi),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteItem(todoList[index].id ?? 0);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
