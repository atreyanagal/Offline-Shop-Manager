import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());

  runApp(MaterialApp(
    home: SplashScreen(),
  ));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // After 2 seconds, navigate to the TodoApp
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TodoApp(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Welcome to Offline Store Manager App',
          textAlign: TextAlign.center, // Align text in center horizontally
          style: TextStyle(
            fontSize: 24, // Font size 24
            color: Colors.lightBlue, // Light blue font color
          ),
        ),
      ),
    );
  }
}

@override
Widget build(BuildContext context) {
  // Get the current theme
  final currentTheme = Theme.of(context);

  return Scaffold(
    backgroundColor: Colors.white, // Set background color to white
    body: Center(
      child: Text(
        'Welcome to Offline Store Manager App',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          color: currentTheme.primaryColor, // Use primary color of the theme
        ),
      ),
    ),
  );
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

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 0; // Unique ID for this adapter

  @override
  Todo read(BinaryReader reader) {
    return Todo(
      title: reader.read(),
      description: reader.read(),
      category: reader.read(),
      quantity: reader.read(),
      cost: reader.read(),
      isDone: reader.read(),
      createdAt: reader.read(),
      dueDate: reader.read(),
      imagePath: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer.write(obj.title);
    writer.write(obj.description);
    writer.write(obj.category);
    writer.write(obj.quantity);
    writer.write(obj.cost);
    writer.write(obj.isDone);
    writer.write(obj.createdAt);
    writer.write(obj.dueDate);
    writer.write(obj.imagePath);
  }
}

// Main Widget for the Todo App
class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  //List<Todo> todos = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController costController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool isDarkTheme = false;

  ThemeData _currentTheme = ThemeData.light();

  // Method to toggle between light and dark themes
  void _toggleTheme() {
    setState(() {
      _currentTheme = _currentTheme == ThemeData.light()
          ? ThemeData.dark()
          : ThemeData.light();
      _saveTheme(_currentTheme == ThemeData.dark());
    });
  }

  double totalSales = 0.0; // Define totalSales and netWorth here
  List<Todo> todos = [];
  late Box<Todo> _todoBox;

  @override
  void initState() {
    super.initState();
    _openBox();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentTheme = prefs.getBool('isDarkTheme') ?? false
          ? ThemeData.dark()
          : ThemeData.light();
    });
  }

  Future<void> _saveTheme(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
  }

  Future<void> _openBox() async {
    _todoBox = await Hive.openBox<Todo>('todos');
    // After opening the box, populate the todos list with stored items
    setState(() {
      todos = _todoBox.values.toList();
    });
  }

  //double totalSales = 0.0;

  @override
  Widget build(BuildContext context) {
    double netWorth = calculateNetWorth();
    List<Todo> filteredTodos = filterTodos();

    return MaterialApp(
      theme: _currentTheme, // Apply the current theme here
      home: Scaffold(
        appBar: AppBar(
          title: Text('Offline Shop Manager App'),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    DrawerHeader(
                      padding:
                          EdgeInsets.only(top: 16.0, left: 16.0, bottom: 8.0),
                      child: Text('Settings',
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                      decoration: BoxDecoration(
                        color: _currentTheme == ThemeData.light()
                            ? Colors.blue
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    ListTile(
                      title: Text('Toggle Theme'),
                      onTap: () {
                        setState(() {
                          _toggleTheme(); // Call _toggleTheme within setState
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Built By ATREY',
                    style: TextStyle(fontSize: 12, color: Colors.red)),
              ),
            ],
          ),
        ),
        body: buildBody(filteredTodos, netWorth),
        floatingActionButton: buildFloatingActionButton(),
      ),
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
              'Sales Till Now: ₹${salesTillNow >= 0 ? salesTillNow.abs().toStringAsFixed(2) : '0.00'}',
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
  double currentNetWorth = calculateNetWorth();
  double netWorthChange = currentNetWorth - calculateNetWorth();
  double salesTillNow = totalSales - netWorthChange;
  return salesTillNow;
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
          showDeleteConfirmationDialog(
              context, _currentTheme, filteredTodos, index);
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

  void updateTodoItem(Todo editedItem) {
    setState(() {
      final index = todos.indexWhere((todo) =>
          todo.title ==
          editedItem.title); // Assuming title is unique for each Todo
      if (index != -1) {
        int quantityDifference = editedItem.quantity - todos[index].quantity;

        // If quantity is reduced, update the sales till now
        if (quantityDifference < 0) {
          double salesAmount = editedItem.cost *
              quantityDifference.abs(); // Absolute value of the difference
          totalSales -= salesAmount; // Subtract from total sales
        }
        Hive.openBox<Todo>('todos');
        todos[index] = editedItem;
        _todoBox.putAt(index, editedItem);
      }
    });
  }

  void navigateToEditItemPage(Todo todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemPage(
          todo: todo,
          editItem: updateTodoItem,
          theme: _currentTheme, // Pass the current theme
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
              icon: Icon(Icons.image_outlined),
              onPressed: () {
                // Display uploaded image or 'No image uploaded' text
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Uploaded Image'),
                    content: filteredTodos[index].imagePath != null &&
                            filteredTodos[index].imagePath!.isNotEmpty
                        ? Image.file(File(filteredTodos[index].imagePath!))
                        : Text('No image uploaded for this item.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                    backgroundColor: _currentTheme.dialogBackgroundColor,
                    // Apply dialog background color based on current theme
                    titleTextStyle: _currentTheme.textTheme.headline6,
                    // Apply text style for title based on current theme
                    contentTextStyle: _currentTheme.textTheme.bodyText1,
                    // Apply text style for content based on current theme
                  ),
                );
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

  Future<void> decrementTodoQuantity(
      List<Todo> filteredTodos, int index) async {
    await Hive.openBox<Todo>('todos'); // Ensure the box is open
    var todosBox = Hive.box<Todo>('todos');

    setState(() {
      if (filteredTodos[index].quantity > 0) {
        // Calculate and update sales
        int decreasedQuantity = filteredTodos[index].quantity - 1;
        double salesAmount =
            (filteredTodos[index].quantity - decreasedQuantity) *
                filteredTodos[index].cost;
        totalSales += salesAmount;

        // Update quantity and save to Hive
        filteredTodos[index].quantity = decreasedQuantity;
        todosBox.putAt(index, filteredTodos[index]);
      }
    });
  }

// Increments the quantity of a todo item
  Future<void> incrementTodoQuantity(
      List<Todo> filteredTodos, int index) async {
    await Hive.openBox<Todo>('todos'); // Ensure the box is open
    var todosBox = Hive.box<Todo>('todos');

    setState(() {
      // Calculate and update sales for increased quantity
      double salesAmount = filteredTodos[index].cost *
          (filteredTodos[index].quantity + 1 - filteredTodos[index].quantity);
      totalSales -= salesAmount;

      // Increase quantity and save to Hive
      filteredTodos[index].quantity++;
      todosBox.putAt(index, filteredTodos[index]);
    });
  }

  // Shows a dialog to confirm deletion of a todo item
  void showDeleteConfirmationDialog(BuildContext context, ThemeData theme,
      List<Todo> filteredTodos, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item',
            style: TextStyle(
                color: theme.brightness == Brightness.light
                    ? Colors.black
                    : Colors
                        .white)), // Apply text color based on theme brightness
        backgroundColor: theme.brightness == Brightness.light
            ? Colors.white
            : Colors.black, // Apply background color based on theme brightness
        content: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Do you want to delete this item?',
                  style: TextStyle(
                      color: theme.brightness == Brightness.light
                          ? Colors.black
                          : Colors
                              .white)), // Apply text color based on theme brightness
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        todos.remove(filteredTodos[index]);
                        _todoBox.deleteAt(index);
                        Navigator.of(context).pop();
                      });
                    },
                    child: Text('Yes',
                        style: TextStyle(
                            color: theme.brightness == Brightness.light
                                ? Colors.red
                                : Colors
                                    .white)), // Apply text color based on theme brightness
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('No',
                        style: TextStyle(
                            color: theme.brightness == Brightness.light
                                ? theme.primaryColor
                                : Colors
                                    .white)), // Apply text color based on theme brightness
                  ),
                ],
              ),
            ],
          ),
        ),
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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: _currentTheme,
          child: child ?? Container(),
        );
      },
    );
    if (selectedDate != null) {
      setState(() {
        filteredTodos[index].dueDate = selectedDate;

        var todosBox = Hive.box<Todo>('todos');
        todosBox.putAt(index, filteredTodos[index]);
      });
    }
  }

  // Navigates to the page for adding a new todo item
  void navigateToAddItemPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemPage(
          addItem: _addItem,
          theme: _currentTheme, // Pass the current theme
        ),
      ),
    );
  }

  // Adds a new todo item to the list
  void _addItem(Todo newItem) {
    setState(() {
      todos.add(newItem);
    });
    _todoBox.add(newItem);
  }

  // Formats a DateTime object into a string
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}

// Widget for adding a new todo item
class AddItemPage extends StatefulWidget {
  final Function(Todo) addItem;
  final ThemeData theme;

  const AddItemPage({Key? key, required this.addItem, required this.theme})
      : super(key: key);

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
    return Theme(
      data: widget.theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Item'),
        ),
        body: buildAddItemForm(),
      ),
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
        backgroundColor:
            widget.theme.dialogBackgroundColor, // Apply background color here
        title: Text('Select Image Source',
            style: widget.theme.textTheme.headline6),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title:
                  Text('From Camera', style: widget.theme.textTheme.headline6),
              onTap: () {
                Navigator.of(context).pop();
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              title:
                  Text('From Gallery', style: widget.theme.textTheme.headline6),
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
  final void Function(Todo)
      editItem; // Ensure editItem accepts only one Todo argument
  final ThemeData theme;

  const EditItemPage(
      {Key? key,
      required this.todo,
      required this.editItem,
      required this.theme})
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
    return Theme(
      data: widget.theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Item'),
        ),
        body: buildEditItemForm(),
      ),
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
        backgroundColor: widget.theme.dialogBackgroundColor,
        title: Text('Select Image Source',
            style: widget.theme.textTheme.headline6),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title:
                  Text('From Camera', style: widget.theme.textTheme.headline6),
              onTap: () {
                Navigator.of(context).pop();
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              title:
                  Text('From Gallery', style: widget.theme.textTheme.headline6),
              onTap: () {
                Navigator.of(context).pop();
                _getImage(ImageSource.gallery);
              },
            ),
            ListTile(
              title:
                  Text('Remove Image', style: widget.theme.textTheme.headline6),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  imagePath = ''; // Clear the image path
                });
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
