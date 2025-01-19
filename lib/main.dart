import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/landing_page.dart';
import 'package:flutter_application_1/login_page.dart';
import 'package:image_picker/image_picker.dart';
import 'restapi.dart';
import 'model.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _GotonavigateToHome();
  }

  _GotonavigateToHome() async {
    await Future.delayed(Duration(seconds: 4));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image(
          image: AssetImage('assets/business.png'),
          width: 500,
          height: 500,
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => SeekJobApp(),
    ),
  );
}

class SeekJobApp extends StatelessWidget {
  const SeekJobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: SignInPage(), debugShowCheckedModeBanner: false);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  String selectedFilter = 'All';
  String searchQuery = '';
  bool sortNewestFirst = true; // Track sorting order
  List<KeuanganModel> allTransactions = [];
  final DataService dataService = DataService();
  final String token = '6717db9aec5074ec8261d698'; // token
  final String project = 'uts-remedial'; //  project
  final String collection = 'keuangan'; // collection
  final String appid = '677a97e3f853312de5509ec0'; // app ID

  double totalIncome = 0.0; // Track total income
  double totalExpense = 0.0; // Track total expenses

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      String response =
          await dataService.selectAll(token, project, collection, appid);
      List<dynamic> jsonData = jsonDecode(response);
      setState(() {
        allTransactions =
            jsonData.map((data) => KeuanganModel.fromJson(data)).toList();
        calculateTotals(); // Calculate totals after fetching transactions
      });
    } catch (e) {
      print("Error fetching transactions: $e");
      // Optionally show a dialog or snackbar to inform the user
    }
  }

  void calculateTotals() {
    totalIncome = allTransactions
        .where((transaction) => transaction.type == 'Income')
        .fold(
            0.0, (sum, transaction) => sum + double.parse(transaction.amount));
    totalExpense = allTransactions
        .where((transaction) => transaction.type == 'Expense')
        .fold(
            0.0, (sum, transaction) => sum + double.parse(transaction.amount));
  }

  List<KeuanganModel> get filteredTransactions {
    return allTransactions.where((transaction) {
      final matchesFilter = selectedFilter == 'All' ||
          (selectedFilter == 'Income' && transaction.type == 'Income') ||
          (selectedFilter == 'Expense' && transaction.type == 'Expense');
      final matchesSearch =
          transaction.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList()
      ..sort((a, b) {
        // Convert amount to double for accurate sorting
        double amountA =
            double.tryParse(a.amount.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
        double amountB =
            double.tryParse(b.amount.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
        return sortNewestFirst
            ? amountB.compareTo(amountA)
            : amountA.compareTo(amountB);
      });
  }

  @override
  Widget build(BuildContext context) {
    double balance = totalIncome - totalExpense; // Calculate balance

    // Determine the color for the box decoration based on the balance
    Color boxColor = balance < 0 ? Colors.red : Colors.green;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome,',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Muhammad Thoriq Aziz',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        _auth.signOut();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                        //Navigator.pushNamed(context, 'sign_page');
                        // print("Logout button pressed");
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Your Balance',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${balance.toStringAsFixed(2)}', // Display the balance
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Search and Sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Transactions...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.sort, size: 24),
                  onPressed: () {
                    setState(() {
                      sortNewestFirst =
                          !sortNewestFirst; // Toggle sorting order
                    });
                  },
                ),
              ],
            ),
          ),

          // Filter buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilterButton(
                  label: 'All',
                  isSelected: selectedFilter == 'All',
                  onPressed: () {
                    setState(() {
                      selectedFilter = 'All';
                    });
                  },
                ),
                FilterButton(
                  label: 'Income',
                  isSelected: selectedFilter == 'Income',
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                  onPressed: () {
                    setState(() {
                      selectedFilter = 'Income';
                    });
                  },
                ),
                FilterButton(
                  label: 'Expense',
                  isSelected: selectedFilter == 'Expense',
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                  onPressed: () {
                    setState(() {
                      selectedFilter = 'Expense';
                    });
                  },
                ),
              ],
            ),
          ),

          // Transactions list
          Expanded(
            child: ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                return TransactionItemWidget(
                  transaction: transaction,
                  onTap: () => _showTransactionDialog(context, transaction),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTransactionDialog(context);
        },
        child: Icon(Icons.add, size: 30),
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    String selectedType = 'Expense';
    String selectedCategory = 'Consumables';
    String? picture;

    final ImagePicker _picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Transaction"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(labelText: 'Category'),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedCategory = newValue;
                    }
                  },
                  items: <String>['Consumables', 'Shopping', 'Transfer']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(labelText: 'Type'),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedType = newValue;
                    }
                  },
                  items: <String>['Income', 'Expense']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a transaction type';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    // milih gambar dari galeri
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        picture = image.path;
                      });
                    }
                  },
                  child: Text('Pick an Image'),
                ),
                if (picture != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text('Selected Image: $picture'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    await dataService.insertKeuangan(
                      appid,
                      nameController.text,
                      descriptionController.text,
                      amountController.text,
                      selectedType,
                      selectedCategory,
                      DateTime.now().toIso8601String(),
                      picture ?? '',
                    );
                    fetchTransactions();
                    Navigator.pop(context);
                  } catch (e) {
                    print("Error adding transaction: $e");
                  }
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showTransactionDialog(BuildContext context, KeuanganModel transaction) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController nameController =
        TextEditingController(text: transaction.name);
    TextEditingController descriptionController =
        TextEditingController(text: transaction.description);
    TextEditingController amountController =
        TextEditingController(text: transaction.amount);
    String selectedType = transaction.type;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Transaction"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  // Dropdown buat pengeluaran atau pemasukan
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(labelText: 'Type'),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        selectedType = newValue;
                      }
                    },
                    items: <String>['Income', 'Expense']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a transaction type';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      return null;
                    },
                  ),
                  // Display the image if it exists
                  if (transaction.picture != null &&
                      transaction.picture!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          Text('Current Image:'),
                          SizedBox(height: 10),
                          kIsWeb
                              ? Image.network(transaction.picture!)
                              : Image.file(
                                  File(transaction.picture!),
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // nyimpen data yang di perbarui
                  await dataService.updateId('name', nameController.text, token,
                      project, collection, appid, transaction.id);
                  await dataService.updateId(
                      'description',
                      descriptionController.text,
                      token,
                      project,
                      collection,
                      appid,
                      transaction.id);
                  await dataService.updateId('amount', amountController.text,
                      token, project, collection, appid, transaction.id);
                  await dataService.updateId('type', selectedType, token,
                      project, collection, appid, transaction.id);
                  fetchTransactions(); // Refresh list
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () async {
                await dataService.removeId(
                    token, project, collection, appid, transaction.id);
                fetchTransactions(); // Refresh the list
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onPressed;

  FilterButton({
    required this.label,
    this.isSelected = false,
    this.icon,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.grey[200] : Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: color, size: 18),
          if (icon != null) SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}

class TransactionItemWidget extends StatelessWidget {
  final KeuanganModel transaction;
  final VoidCallback onTap;

  TransactionItemWidget({required this.transaction, required this.onTap});

  IconData getIconForCategory(String category) {
    switch (category) {
      case 'Consumables':
        return Icons.fastfood; // Food icon
      case 'Shopping':
        return Icons.shopping_cart; // Shopping cart icon
      case 'Transfer':
        return Icons.transfer_within_a_station; // Transfer icon
      default:
        return Icons.attach_money; // Default money icon
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Ensure the entire widget is tappable
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              getIconForCategory(
                  transaction.category), // Get the icon based on category
              color: transaction.type == 'Expense' ? Colors.red : Colors.green,
              size: 40,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    transaction.description,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              transaction.amount,
              style: TextStyle(
                color:
                    transaction.type == 'Expense' ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
