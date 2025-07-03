import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() => runApp(InventoryApp());

// Simple in-memory user store
class UserStore {
  static String? currentUser;
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  static Future<bool> login(String username, String password) async {
    bool valid = await _dbHelper.validateUser(username, password);
    if (valid) {
      currentUser = username;
      return true;
    }
    return false;
  }

  static Future<bool> signup(String username, String password) async {
    bool exists = await _dbHelper.userExists(username);
    if (exists) return false;
    bool inserted = await _dbHelper.insertUser(username, password);
    if (inserted) {
      currentUser = username;
      return true;
    }
    return false;
  }

  static void logout() {
    currentUser = null;
  }
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Manager',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Color(0xFFEAF7F1),
      ),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    if (UserStore.currentUser == null) {
      return LoginScreen(onLogin: () => setState(() {}));
    } else {
      return MainNavigation(onLogout: () => setState(() {}));
    }
  }
}

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  const LoginScreen({super.key, required this.onLogin});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _error;

  Future<void> _handleLogin() async {
    bool success = await UserStore.login(
      _username.text.trim(),
      _password.text,
    );
    if (!mounted) return;
    if (success) {
      widget.onLogin();
    } else {
      setState(() => _error = 'Invalid credentials');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF7F1), Colors.teal.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              margin: EdgeInsets.symmetric(horizontal: 28),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.teal[100],
                      child: Icon(
                        Icons.inventory_2,
                        color: Colors.teal[700],
                        size: 40,
                      ),
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.teal[800],
                      ),
                    ),
                    SizedBox(height: 18),
                    TextField(
                      controller: _username,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 14),
                    TextField(
                      controller: _password,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    if (_error != null) ...[
                      SizedBox(height: 10),
                      Text(_error!, style: TextStyle(color: Colors.red)),
                    ],
                    SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SignUpScreen(
                              onSignUp: () {
                                Navigator.pop(context);
                                widget.onLogin();
                              },
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Don\'t have an account? Sign Up',
                        style: TextStyle(
                          color: Colors.teal[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  final VoidCallback onSignUp;
  const SignUpScreen({super.key, required this.onSignUp});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _error;

  Future<void> _handleSignUp() async {
    if (_username.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }
    bool success = await UserStore.signup(
      _username.text.trim(),
      _password.text,
    );
    if (!mounted) return;
    if (!success) {
      setState(() => _error = 'Username already exists');
    } else {
      widget.onSignUp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF7F1), Colors.teal.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              margin: EdgeInsets.symmetric(horizontal: 28),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.teal[100],
                      child: Icon(
                        Icons.person_add,
                        color: Colors.teal[700],
                        size: 40,
                      ),
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.teal[800],
                      ),
                    ),
                    SizedBox(height: 18),
                    TextField(
                      controller: _username,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 14),
                    TextField(
                      controller: _password,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    if (_error != null) ...[
                      SizedBox(height: 10),
                      Text(_error!, style: TextStyle(color: Colors.red)),
                    ],
                    SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const List<String> kCategories = [
  'All',
  'Electronics',
  'Office',
  'Grocery',
  'Clothing',
  'Other',
];

class InventoryHomePage extends StatefulWidget {
  final VoidCallback onLogout;
  const InventoryHomePage({super.key, required this.onLogout});
  @override
  _InventoryHomePageState createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  List<InventoryItem> _items = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  String _selectedCategory = kCategories[1];
  String _filterCategory = kCategories[0];
  int _addQty = 1;
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await dbHelper.getItems();
    setState(() {
      _items = items;
    });
  }

  Future<void> _addItem() async {
    String name = _nameController.text.trim();
    int qty = _addQty;
    String category = _selectedCategory;
    if (name.isNotEmpty && qty > 0) {
      await dbHelper.insertItem(InventoryItem(name, qty, category));
      _nameController.clear();
      setState(() {
        _selectedCategory = kCategories[1];
        _addQty = 1;
      });
      await _loadItems();
    }
  }

  void _editItem(int index) {
    InventoryItem item = _items[index];
    TextEditingController editNameController = TextEditingController(
      text: item.name,
    );
    TextEditingController editQtyController = TextEditingController(
      text: item.quantity.toString(),
    );
    String editCategory = item.category;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Item',
          style: TextStyle(
            color: Colors.teal[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editNameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: editQtyController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: editCategory,
                items: kCategories
                    .sublist(1)
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setStateDialog(() => editCategory = val);
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[700],
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              String newName = editNameController.text.trim();
              int? newQty = int.tryParse(editQtyController.text.trim());
              if (newName.isNotEmpty && newQty != null && newQty > 0) {
                await dbHelper.updateItem(
                  InventoryItem(newName, newQty, editCategory, id: item.id),
                );
                Navigator.pop(context);
                await _loadItems();
              }
            },
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _removeItem(int index) async {
    final item = _items[index];
    await dbHelper.deleteItem(item.id!);
    await _loadItems();
  }

  List<InventoryItem> get _filteredItems {
    if (_filterCategory == 'All') return _items;
    return _items.where((item) => item.category == _filterCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inventory Management',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        backgroundColor: Colors.teal[700],
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              UserStore.logout();
              widget.onLogout();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(18),
            child: Center(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 22,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.teal[100],
                        child: Icon(
                          Icons.add_box,
                          color: Colors.teal[700],
                          size: 32,
                        ),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Add New Item',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.teal[800],
                        ),
                      ),
                      SizedBox(height: 18),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Item Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 12),
                      // Stepper for quantity inside a rounded rectangle
                      Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.teal.shade100,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              color: Colors.teal[700],
                              onPressed: () {
                                if (_addQty > 1) setState(() => _addQty--);
                              },
                            ),
                            Container(
                              width: 48,
                              alignment: Alignment.center,
                              child: Text(
                                '$_addQty',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              color: Colors.teal[700],
                              onPressed: () {
                                setState(() => _addQty++);
                              },
                            ),
                            SizedBox(width: 8),
                            Text('Quantity', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: kCategories
                            .sublist(1)
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCategory = val);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            elevation: 2,
                          ),
                          icon: Icon(Icons.add, size: 20, color: Colors.white),
                          label: Text(
                            'Add',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.filter_list, color: Colors.teal[700]),
                SizedBox(width: 8),
                Text(
                  'Filter by Category:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _filterCategory,
                  items: kCategories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _filterCategory = val);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      "No inventory items yet.",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.teal[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredItems.length,
                    itemBuilder: (_, index) {
                      final item = _filteredItems[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          leading: CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.teal[100],
                            child: Icon(
                              Icons.inventory_2,
                              color: Colors.teal[800],
                              size: 28,
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "Quantity: ${item.quantity} | Category: ${item.category}",
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.teal[700]),
                                tooltip: 'Edit',
                                onPressed: () => _editItem(index),
                              ),
                              SizedBox(width: 4),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red[400],
                                ),
                                tooltip: 'Delete',
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
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

class MainNavigation extends StatefulWidget {
  final VoidCallback onLogout;
  const MainNavigation({super.key, required this.onLogout});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          InventoryHomePage(onLogout: widget.onLogout),
          // Placeholder for future screens
          Center(
            child: Text(
              'Statistics (Coming Soon)',
              style: TextStyle(fontSize: 20, color: Colors.teal[700]),
            ),
          ),
          Center(
            child: Text(
              'Settings (Coming Soon)',
              style: TextStyle(fontSize: 20, color: Colors.teal[700]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: Colors.teal[700],
        unselectedItemColor: Colors.teal[200],
        backgroundColor: Colors.white,
        elevation: 10,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
