import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    home: TodoApp(),
  ));
}

// Model class for a Todo item
class Todo {
  String title;
  String description;
  String category;
  int quantity;
  double cost;
  bool isDone;
  DateTime createdAt;
  DateTime? dueDate;
  String? imagePath;

  Todo({
    required this.title,
    required this.description,
    required this.category,
    required this.quantity,
    required this.cost,
    this.isDone = false,
    required this.createdAt,
    this.dueDate,
    this.imagePath,
  });
}

// Main Widget for the Todo App
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

  double totalSales = 0.0;

  @override
  Widget build(BuildContext context) {
    double netWorth = calculateNetWorth();

    List<Todo> filteredTodos = filterTodos();

    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(filteredTodos, netWorth),
      floatingActionButton: buildFloatingActionButton(),
    );
  }

  // Builds the app bar
  AppBar buildAppBar() {
    return AppBar(
      title: Text('Offline Shop Manager App'),
      centerTitle: true,
      actions: [
        // Reset button
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            setState(() {
              totalSales = 0.0;
            });
          },
        ),
      ],
    );
  }

  // Builds the main body of the app
  Widget buildBody(List<Todo> filteredTodos, double netWorth) {
    double salesTillNow =
        calculateSalesTillNow(); // Calculate total sales till now
    return Column(
      children: [
        // Display total sales till now
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sales Till Now: ₹${totalSales >= 0 ? totalSales.abs().toStringAsFixed(2) : '0.00'}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Reset button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  totalSales = 0.0;
                });
              },
              child: Text('Reset'),
            ),
          ],
        ),
        buildSearchBar(),
        Expanded(
          child: buildTodoList(filteredTodos),
        ),
        buildNetWorth(netWorth),
      ],
    );
  }

// Calculate total sales till now
  double calculateSalesTillNow() {
    return totalSales;
  }

  // Builds the search bar
  Padding buildSearchBar() {
    return Padding(
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
    );
  }

  // Builds the todo list
  Widget buildTodoList(List<Todo> filteredTodos) {
    return filteredTodos.isEmpty
        ? Center(
            child: Text(
              'No items available!!',
              style: TextStyle(fontSize: 18),
            ),
          )
        : ListView.builder(
            itemCount: filteredTodos.length,
            itemBuilder: (context, index) {
              return buildTodoItem(filteredTodos, index);
            },
          );
  }

  // Builds a single todo item
  Card buildTodoItem(List<Todo> filteredTodos, int index) {
    Color quantityColor = getColorForQuantity(filteredTodos[index]);
    return Card(
      child: ListTile(
        title: Text(filteredTodos[index].title),
        subtitle: buildTodoSubtitle(filteredTodos[index], quantityColor),
        trailing: buildTodoTrailing(filteredTodos, index),
        onTap: () {
          navigateToEditItemPage(filteredTodos[index]);
        },
        onLongPress: () {
          showDeleteConfirmationDialog(filteredTodos, index);
        },
      ),
    );
  }

  // Builds the subtitle for a todo item
  Column buildTodoSubtitle(Todo todo, Color quantityColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description: ${todo.description}'),
        Text('Category: ${todo.category}'),
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
              todo.quantity.toString(),
              style: TextStyle(
                color: quantityColor,
              ),
            ),
          ],
        ),
        Text('Cost: ₹${todo.cost.toStringAsFixed(2)}'),
        Text('Total worth: ₹${(todo.quantity * todo.cost).toStringAsFixed(2)}'),
        Text('Created at: ${_formatDate(todo.createdAt)}'),
        Text(
          todo.dueDate != null
              ? 'Exp Date: ${_formatDate(todo.dueDate!)}'
              : 'No Exp Date',
          style: TextStyle(color: getColorForDueDate(todo)),
        ),
      ],
    );
  }

  void updateTodoItem(Todo oldItem, Todo editedItem) {
    setState(() {
      final index = todos.indexOf(oldItem);
      if (index != -1) {
        int quantityDifference = editedItem.quantity - oldItem.quantity;

        // If quantity is reduced, update the sales till now
        if (quantityDifference < 0) {
          double salesAmount = editedItem.cost *
              (quantityDifference); // Absolute value of the difference
          totalSales -= salesAmount; // Subtract from total sales
        }

        todos[index] = editedItem;
      }
    });
  }

  void navigateToEditItemPage(Todo todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemPage(
          todo: todo,
          editItem: (editedItem) {
            updateTodoItem(todo, editedItem);
          },
        ),
      ),
    );
  }

  // Builds the trailing icons/buttons for a todo item
  Widget buildTodoTrailing(List<Todo> filteredTodos, int index) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () async {
                await showDatePickerDialog(filteredTodos, index);
              },
            ),
            IconButton(
              icon: Icon(Icons.image_outlined), // Changed from Icons.edit
              onPressed: () {
                // Display uploaded image
                if (filteredTodos[index].imagePath != null) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Uploaded Image'),
                      content:
                          Image.file(File(filteredTodos[index].imagePath!)),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                decrementTodoQuantity(filteredTodos, index);
              },
            ),
            Text(filteredTodos[index].quantity.toString()),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                incrementTodoQuantity(filteredTodos, index);
              },
            ),
          ],
        ),
      ],
    );
  }

  // Builds the net worth display
  Text buildNetWorth(double netWorth) {
    return Text(
      'Net worth of shop: ₹${netWorth.toStringAsFixed(2)}',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // Builds the floating action button
  FloatingActionButton buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        navigateToAddItemPage();
      },
      child: Icon(Icons.add),
    );
  }

  // Calculates the net worth of the shop
  double calculateNetWorth() {
    return todos.fold(0, (sum, todo) => sum + todo.quantity * todo.cost);
  }

  // Filters the todos based on the search query
  List<Todo> filterTodos() {
    return todos
        .where((todo) => todo.title
            .toLowerCase()
            .contains(searchController.text.toLowerCase()))
        .toList();
  }

  // Gets the color for due date based on the time left
  Color getColorForDueDate(Todo todo) {
    if (todo.dueDate != null) {
      DateTime now = DateTime.now();
      Duration difference = todo.dueDate!.difference(now);
      if (difference.inDays < 0) {
        return Colors.red;
      } else if (difference.inDays <= 30) {
        return Colors.yellow;
      } else {
        return Colors.green;
      }
    }
    return Colors.black;
  }

  // Gets the color for quantity based on its value
  Color getColorForQuantity(Todo todo) {
    if (todo.quantity == 0) {
      return Colors.red;
    } else if (todo.quantity > 0 && todo.quantity <= 10) {
      return Colors.yellow;
    }
    return Colors.green;
  }

  // Toggles the status of a todo item (done/undone)
  void toggleTodoStatus(List<Todo> filteredTodos, int index) {
    setState(() {
      filteredTodos[index].isDone = !filteredTodos[index].isDone;
    });
  }

  // Shows a dialog to edit a todo item
  void showEditTodoDialog(List<Todo> filteredTodos, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Todo'),
        content: SingleChildScrollView(
          child: buildEditTodoDialogContent(filteredTodos, index),
        ),
        actions: buildEditTodoDialogActions(),
      ),
    );
  }

  // Builds the content for the edit todo dialog
  Column buildEditTodoDialogContent(List<Todo> filteredTodos, int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildEditTextField('Title', filteredTodos[index].title, (value) {
          setState(() {
            filteredTodos[index].title = value;
          });
        }),
        buildEditTextField('Description', filteredTodos[index].description,
            (value) {
          setState(() {
            filteredTodos[index].description = value;
          });
        }),
        buildEditTextField('Category', filteredTodos[index].category, (value) {
          setState(() {
            filteredTodos[index].category = value;
          });
        }),
        buildEditTextField('Quantity', filteredTodos[index].quantity.toString(),
            (value) {
          setState(() {
            filteredTodos[index].quantity = int.parse(value);
          });
        }),
        buildEditTextField('Cost', filteredTodos[index].cost.toString(),
            (value) {
          setState(() {
            filteredTodos[index].cost = double.parse(value);
          });
        }),
      ],
    );
  }

  // Builds a text field for editing a todo item property
  TextField buildEditTextField(
      String labelText, String initialValue, Function(String) onChanged) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
      ),
    );
  }

  // Builds the actions for the edit todo dialog
  List<Widget> buildEditTodoDialogActions() {
    return [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text('Save'),
      ),
    ];
  }

  void decrementTodoQuantity(List<Todo> filteredTodos, int index) {
    setState(() {
      if (filteredTodos[index].quantity > 0) {
        // Calculate and update sales
        int decreasedQuantity = filteredTodos[index].quantity - 1;
        double salesAmount =
            (filteredTodos[index].quantity - decreasedQuantity) *
                filteredTodos[index].cost;
        totalSales += salesAmount;

        filteredTodos[index].quantity = decreasedQuantity;
      }
    });
  }

// Increments the quantity of a todo item
  void incrementTodoQuantity(List<Todo> filteredTodos, int index) {
    setState(() {
      // Calculate and update sales for increased quantity
      double salesAmount = filteredTodos[index].cost *
          (filteredTodos[index].quantity + 1 - filteredTodos[index].quantity);
      totalSales -= salesAmount;

      // Increase quantity
      filteredTodos[index].quantity++;
    });
  }

  // Shows a dialog to confirm deletion of a todo item
  void showDeleteConfirmationDialog(List<Todo> filteredTodos, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item'),
        content: Text('Do you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                todos.remove(filteredTodos[index]);
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
  }

  // Shows a date picker dialog to select due date for a todo item
  Future<void> showDatePickerDialog(List<Todo> filteredTodos, int index) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (selectedDate != null) {
      setState(() {
        filteredTodos[index].dueDate = selectedDate;
      });
    }
  }

  // Navigates to the page for adding a new todo item
  void navigateToAddItemPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemPage(addItem: _addItem),
      ),
    );
  }

  // Adds a new todo item to the list
  void _addItem(Todo newItem) {
    setState(() {
      todos.add(newItem);
    });
  }

  // Formats a DateTime object into a string
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}

// Widget for adding a new todo item
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
  late String imagePath = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      body: buildAddItemForm(),
    );
  }

  // Builds the form for adding a new todo item
  Padding buildAddItemForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildTextField('Title', (value) {
            title = value;
          }),
          buildTextField('Description', (value) {
            description = value;
          }),
          buildTextField('Category', (value) {
            category = value;
          }),
          buildTextField('Quantity', (value) {
            quantity = int.tryParse(value) ?? 0;
          }, keyboardType: TextInputType.number),
          buildTextField('Cost', (value) {
            cost = double.tryParse(value) ?? 0.0;
          }, keyboardType: TextInputType.number),
          buildAddImageButton(),
          if (imagePath != null)
            Text(
              '${imagePath!.split('/').last}',
              style: TextStyle(fontSize: 16),
            ),
          buildAddButton(),
        ],
      ),
    );
  }

  // Builds the button for adding images
  ElevatedButton buildAddImageButton() {
    return ElevatedButton(
      onPressed: () {
        // Prompt user to select image from camera or gallery
        _showImageSourceDialog();
      },
      child: Text('Add Image'),
    );
  }

  // Function to show dialog for selecting image source
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('From Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              title: Text('From Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to get image from camera or gallery
  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path; // Store image path
      });
    }
  }

  // Builds the button for adding a new todo item
  ElevatedButton buildAddButton() {
    return ElevatedButton(
      onPressed: () {
        final newItem = Todo(
          title: title,
          description: description,
          category: category,
          quantity: quantity,
          cost: cost,
          createdAt: DateTime.now(),
          imagePath: imagePath, // Assign selected image path
        );
        widget.addItem(newItem);
        Navigator.of(context).pop();
      },
      child: Text('Add'),
    );
  }

  // Builds a text field for input
  TextField buildTextField(String labelText, Function(String) onChanged,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      decoration: InputDecoration(labelText: labelText),
      onChanged: onChanged,
      keyboardType: keyboardType,
    );
  }
}

class EditItemPage extends StatefulWidget {
  final Todo todo;
  final Function(Todo) editItem;

  const EditItemPage({Key? key, required this.todo, required this.editItem})
      : super(key: key);

  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  late String title;
  late String description;
  late String category;
  late int quantity;
  late double cost;
  late String imagePath = '';

  @override
  void initState() {
    super.initState();
    title = widget.todo.title;
    description = widget.todo.description;
    category = widget.todo.category;
    quantity = widget.todo.quantity;
    cost = widget.todo.cost;
    imagePath = widget.todo.imagePath ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Item'),
      ),
      body: buildEditItemForm(),
    );
  }

  Padding buildEditItemForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildTextField('Title', title, (value) {
            title = value;
          }),
          buildTextField('Description', description, (value) {
            description = value;
          }),
          buildTextField('Category', category, (value) {
            category = value;
          }),
          buildTextField('Quantity', quantity.toString(), (value) {
            quantity = int.tryParse(value) ?? 0;
          }, keyboardType: TextInputType.number),
          buildTextField('Cost', cost.toString(), (value) {
            cost = double.tryParse(value) ?? 0.0;
          }, keyboardType: TextInputType.number),
          buildEditImageButton(),
          if (imagePath != null)
            Text(
              '${imagePath!.split('/').last}',
              style: TextStyle(fontSize: 16),
            ),
          buildEditButton(),
        ],
      ),
    );
  }

  ElevatedButton buildEditImageButton() {
    return ElevatedButton(
      onPressed: () {
        _showImageSourceDialog();
      },
      child: Text('Edit Image'),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('From Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              title: Text('From Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path; // Store new image path
      });
    }
  }

  TextField buildTextField(
      String labelText, String initialValue, Function(String) onChanged,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      decoration: InputDecoration(labelText: labelText),
      controller: TextEditingController(text: initialValue),
      onChanged: onChanged,
      keyboardType: keyboardType,
    );
  }

  ElevatedButton buildEditButton() {
    return ElevatedButton(
      onPressed: () {
        final updatedItem = Todo(
          title: title,
          description: description,
          category: category,
          quantity: quantity,
          cost: cost,
          createdAt: widget.todo.createdAt,
          dueDate: widget.todo.dueDate,
          imagePath: imagePath,
        );
        widget.editItem(updatedItem);
        Navigator.of(context).pop();
      },
      child: Text('Edit'),
    );
  }
}
