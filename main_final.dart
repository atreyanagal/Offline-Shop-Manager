import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: TodoApp(),
  ));
}

class Todo {
  String title;
  String description;
  String category;
  int quantity;
  double cost;
  bool isDone;
  DateTime createdAt;
  DateTime? dueDate;

  Todo({
    required this.title,
    required this.description,
    required this.category,
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
  TextEditingController categoryController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController costController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    double netWorth =
        todos.fold(0, (sum, todo) => sum + todo.quantity * todo.cost);

    List<Todo> filteredTodos = todos
        .where((todo) => todo.title
            .toLowerCase()
            .contains(searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Shop Manager App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredTodos.isEmpty
                ? Center(
                    child: Text(
                      'No items available!!',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      double totalWorth = filteredTodos[index].quantity *
                          filteredTodos[index].cost;

                      Color textColor = Colors.black;
                      if (filteredTodos[index].dueDate != null) {
                        DateTime now = DateTime.now();
                        Duration difference =
                            filteredTodos[index].dueDate!.difference(now);
                        if (difference.inDays < 0) {
                          textColor = Colors.red;
                        } else if (difference.inDays <= 30) {
                          textColor = Colors.yellow;
                        } else {
                          textColor = Colors.green;
                        }
                      }

                      Color quantityColor = Colors.green;
                      if (filteredTodos[index].quantity == 0) {
                        quantityColor = Colors.red;
                      } else if (filteredTodos[index].quantity > 0 &&
                          filteredTodos[index].quantity <= 10) {
                        quantityColor = Colors.yellow;
                      }

                      return Card(
                        child: ListTile(
                          title: Text(filteredTodos[index].title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Description: ${filteredTodos[index].description}'),
                              Text(
                                  'Category: ${filteredTodos[index].category}'),
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
                                    filteredTodos[index].quantity.toString(),
                                    style: TextStyle(
                                      color: quantityColor,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Cost: \₹${filteredTodos[index].cost.toStringAsFixed(2)}',
                                  ),
                                ],
                              ),
                              Text(
                                'Total worth: \₹${totalWorth.toStringAsFixed(2)}',
                              ),
                              Text(
                                'Created at: ${_formatDate(filteredTodos[index].createdAt)}',
                              ),
                              Text(
                                filteredTodos[index].dueDate != null
                                    ? 'Exp Date: ${_formatDate(filteredTodos[index].dueDate!)}'
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
                                          filteredTodos[index].dueDate =
                                              selectedDate;
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
                                          content: SingleChildScrollView(
                                            // Make the content scrollable
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller:
                                                      TextEditingController(
                                                    text: filteredTodos[index]
                                                        .title,
                                                  ),
                                                  onChanged: (value) {
                                                    filteredTodos[index].title =
                                                        value;
                                                  },
                                                  decoration: InputDecoration(
                                                    labelText: 'Title',
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                TextField(
                                                  controller:
                                                      TextEditingController(
                                                    text: filteredTodos[index]
                                                        .description,
                                                  ),
                                                  onChanged: (value) {
                                                    filteredTodos[index]
                                                        .description = value;
                                                  },
                                                  decoration: InputDecoration(
                                                    labelText: 'Description',
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                TextField(
                                                  controller:
                                                      TextEditingController(
                                                    text: filteredTodos[index]
                                                        .category,
                                                  ),
                                                  onChanged: (value) {
                                                    filteredTodos[index]
                                                        .category = value;
                                                  },
                                                  decoration: InputDecoration(
                                                    labelText: 'Category',
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                TextField(
                                                  controller:
                                                      TextEditingController(
                                                    text: filteredTodos[index]
                                                        .quantity
                                                        .toString(),
                                                  ),
                                                  onChanged: (value) {
                                                    filteredTodos[index]
                                                            .quantity =
                                                        int.parse(value);
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    labelText: 'Quantity',
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                TextField(
                                                  controller:
                                                      TextEditingController(
                                                    text: filteredTodos[index]
                                                        .cost
                                                        .toString(),
                                                  ),
                                                  onChanged: (value) {
                                                    filteredTodos[index].cost =
                                                        double.parse(value);
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    labelText: 'Cost',
                                                  ),
                                                ),
                                              ],
                                            ),
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
                                        if (filteredTodos[index].quantity > 0) {
                                          filteredTodos[index].quantity--;
                                        }
                                      });
                                    },
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                      filteredTodos[index].quantity.toString()),
                                  SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        filteredTodos[index].quantity++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              filteredTodos[index].isDone =
                                  !filteredTodos[index].isDone;
                            });
                          },
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete Todo'),
                                content:
                                    Text('Do you want to delete this todo?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        todos.remove(filteredTodos[
                                            index]); // Remove from todos list
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddItemPage(addItem: _addItem),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addItem(Todo newItem) {
    setState(() {
      todos.add(newItem);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}

class AddItemPage extends StatefulWidget {
  final Function(Todo) addItem;

  const AddItemPage({Key? key, required this.addItem}) : super(key: key);

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  late String title;
  late String description;
  late String category;
  late int quantity;
  late double cost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              onChanged: (value) {
                title = value;
              },
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) {
                description = value;
              },
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(labelText: 'Category'),
              onChanged: (value) {
                category = value;
              },
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                quantity = int.tryParse(value) ?? 0;
              },
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(labelText: 'Cost'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                cost = double.tryParse(value) ?? 0.0;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Create a new Todo instance with the provided data
                final newItem = Todo(
                  title: title,
                  description: description,
                  category: category,
                  quantity: quantity,
                  cost: cost,
                  createdAt: DateTime.now(),
                );
                // Call the addItem callback to add the new item
                widget.addItem(newItem);
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
