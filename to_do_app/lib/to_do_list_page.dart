import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:to_do_app/add_page.dart';
import 'package:http/http.dart' as http;

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
  }

class _ToDoListPageState extends State<ToDoListPage> {
  bool isLoading = true;
  List todos = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To Do List'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchToDo,
        child: ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final item = todos[index] as Map;
              final id = item['_id'] as String;
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(item['title']),
                subtitle: Text(item['description']),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      navigateToEditPage(item);
                    } else if (value == 'delete') {
                      deleteById(id);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ];
                  },
                ),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: const Text('Add To Do'),
      ),
    );
  }

  @override
  void initState() {
    fetchToDo();
    super.initState();
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(builder: (context) => const AddToDoPage());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchToDo();
  }

  void navigateToEditPage(Map item) {
    final route =
        MaterialPageRoute(builder: (context) => AddToDoPage(todo: item));
    Navigator.push(context, route);
  }

  Future<void> fetchToDo() async {
    final response = await http.get(
        Uri.parse('https://api.nstack.in/v1/todos?page=1&limit=10'),
        headers: {
          'content-type': 'application/json',
        });
    print(response.statusCode);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        todos = result;
      });
    } else {
      print('error');
    }
    setState(() {
      isLoading = false;
    });
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> deleteById(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filtered = todos.where((element) => element['_id'] != id).toList();
      setState(() {
        todos = filtered;
      });
    } else {
      showErrorMessage('Deletion failed');
    }
  }
}
