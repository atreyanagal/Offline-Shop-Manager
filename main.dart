import 'package:flutter/material.dart';

void main() {
  runApp(TodoApp());
}

class Todo {
  String title;
  String description;
  int quantity;
  double cost;
  bool isDone;
  DateTime createdAt;
  DateTime? dueDate;

  Todo({
    required this.title,
    required this.description,
    required this.quantity,
    required this.cost,
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
  TextEditingController costController = TextEditingController();
  bool isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    double netWorth =
        todos.fold(0, (sum, todo) => sum + todo.quantity * todo.cost);

    return MaterialApp(
      theme: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Offline Shop Manager App'),
          centerTitle: true,
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
                      Expanded(
                        child: TextField(
                          controller: costController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Cost',
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
                              cost: double.parse(costController.text),
                              createdAt: DateTime.now(),
                            ));
                            titleController.clear();
                            descriptionController.clear();
                            quantityController.clear();
                            costController.clear();
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
                  double totalWorth = todos[index].quantity * todos[index].cost;

                  Color textColor = Colors.black;
                  if (todos[index].dueDate != null) {
                    DateTime now = DateTime.now();
                    Duration difference = todos[index].dueDate!.difference(now);
                    if (difference.inDays < 0) {
                      textColor = Colors.red;
                    } else if (difference.inDays <= 30) {
                      textColor = Colors.yellow;
                    } else {
                      textColor = Colors.green;
                    }
                  }

                  Color quantityColor = Colors.green;
                  if (todos[index].quantity == 0) {
                    quantityColor = Colors.red;
                  } else if (todos[index].quantity > 0 &&
                      todos[index].quantity <= 10) {
                    quantityColor = Colors.yellow;
                  }

                  return Card(
                    child: ListTile(
                      title: Text(todos[index].title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description: ${todos[index].description}'),
                          Row(
                            children: [
                              Text(
                                'Quantity: ',
                                style: TextStyle(
                                  color: quantityColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                todos[index].quantity.toString(),
                                style: TextStyle(
                                  color: quantityColor,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Cost: \₹${todos[index].cost.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          Text(
                            'Total worth: \₹${totalWorth.toStringAsFixed(2)}',
                          ),
                          Text(
                            'Created at: ${_formatDate(todos[index].createdAt)}',
                          ),
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
                                    lastDate: DateTime(DateTime.now().year + 5),
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
                                              text: todos[index].title,
                                            ),
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
                                              text: todos[index].description,
                                            ),
                                            onChanged: (value) {
                                              todos[index].description = value;
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'Description',
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          TextField(
                                            controller: TextEditingController(
                                              text: todos[index]
                                                  .quantity
                                                  .toString(),
                                            ),
                                            onChanged: (value) {
                                              todos[index].quantity =
                                                  int.parse(value);
                                            },
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'Quantity',
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          TextField(
                                            controller: TextEditingController(
                                              text:
                                                  todos[index].cost.toString(),
                                            ),
                                            onChanged: (value) {
                                              todos[index].cost =
                                                  double.parse(value);
                                            },
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'Cost',
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
                              SizedBox(width: 8),
                              Text(todos[index].quantity.toString()),
                              SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    todos[index].quantity++;
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
            Text(
              'Net worth of shop: \₹${netWorth.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
