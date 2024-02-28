import 'package:flutter/material.dart';

void main() {
  runApp(TodoApp());
}

class Todo {
  String title;
  String description;
  int quantity;
  bool isDone;
  DateTime createdAt;
  DateTime? dueDate; // Nullable DateTime for due date

  Todo({
    required this.title,
    required this.description,
    required this.quantity,
    this.isDone = false,
    required this.createdAt,
    this.dueDate,
  });
}

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  List<Todo> todos = [];

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  bool isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Todo App'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            todos.add(Todo(
                              title: titleController.text,
                              description: descriptionController.text,
                              quantity: int.parse(quantityController.text),
                              createdAt: DateTime.now(),
                            ));
                            titleController.clear();
                            descriptionController.clear();
                            quantityController.clear();
                          });
                        },
                        child: Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  Color textColor = Colors.black;
                  if (todos[index].dueDate != null) {
                    DateTime now = DateTime.now();
                    Duration difference =
                        todos[index].dueDate!.difference(now);
                    if (difference.inDays < 0) {
                      // Due date is passed
                      textColor = Colors.red;
                    } else if (difference.inDays <= 30) {
                      // Due date is within one month
                      textColor = Colors.yellow;
                    } else {
                      // Due date is more than one month away
                      textColor = Colors.green;
                    }
                  }

                  return Card(
                    child: ListTile(
                      title: Text(
                        todos[index].title,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description: ${todos[index].description}'),
                          Text('Quantity: ${todos[index].quantity}'),
                          Text(
                              'Created at: ${_formatDate(todos[index].createdAt)}'),
                          Text(
                            todos[index].dueDate != null
                                ? 'Exp Date: ${_formatDate(todos[index].dueDate!)}'
                                : 'No Exp Date',
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      ),
                      trailing: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.calendar_today),
                                onPressed: () async {
                                  final selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate:
                                        DateTime(DateTime.now().year + 5),
                                  );
                                  if (selectedDate != null) {
                                    setState(() {
                                      todos[index].dueDate = selectedDate;
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Edit Todo'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: TextEditingController(
                                                text: todos[index].title),
                                            onChanged: (value) {
                                              todos[index].title = value;
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'Title',
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          TextField(
                                            controller: TextEditingController(
                                                text: todos[index]
                                                    .description),
                                            onChanged: (value) {
                                              todos[index].description = value;
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'Description',
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              Navigator.of(context).pop();
                                            });
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              Navigator.of(context).pop();
                                            });
                                          },
                                          child: Text('Save'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    todos[index].quantity++;
                                  });
                                },
                              ),
                              SizedBox(width: 8),
                              Text(
                                todos[index].quantity.toString(),
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    todos[index].quantity =
                                        todos[index].quantity > 0
                                            ? todos[index].quantity - 1
                                            : 0;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          todos[index].isDone = !todos[index].isDone;
                        });
                      },
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Todo'),
                            content: Text('Do you want to delete this todo?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    todos.removeAt(index);
                                    Navigator.of(context).pop();
                                  });
                                },
                                child: Text('Yes'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('No'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              isDarkTheme = !isDarkTheme;
            });
          },
          child: Icon(Icons.lightbulb),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}
