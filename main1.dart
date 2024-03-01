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
                      'No search results found, Try again!!',
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
          _showAddItemDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Item'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(
                  controller: titleController,
                  labelText: 'Title',
                ),
                SizedBox(height: 8),
                _buildTextField(
                  controller: descriptionController,
                  labelText: 'Description',
                ),
                SizedBox(height: 8),
                _buildTextField(
                  controller: categoryController,
                  labelText: 'Category',
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: quantityController,
                        labelText: 'Quantity',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        controller: costController,
                        labelText: 'Cost',
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addItem(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
    );
  }

  void _addItem(BuildContext context) {
    setState(() {
      todos.add(Todo(
        title: titleController.text,
        description: descriptionController.text,
        category: categoryController.text,
        quantity: int.parse(quantityController.text),
        cost: double.parse(costController.text),
        createdAt: DateTime.now(),
      ));
      titleController.clear();
      descriptionController.clear();
      categoryController.clear();
      quantityController.clear();
      costController.clear();
    });
    Navigator.of(context).pop(); // Close the dialog
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}
