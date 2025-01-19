// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

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
import 'package:flutter_application_1/riwayat_page.dart';
import 'package:image_picker/image_picker.dart';
import 'restapi.dart';
import 'package:intl/intl.dart';
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
      builder: (context) => MyApp(),
    ),
  );
}

class SeekJobApp extends StatelessWidget {
  const SeekJobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: SignInPage(), 
        debugShowCheckedModeBanner: false);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class AppPage extends StatefulWidget {
  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          HomePage(),
          HistoryPage(), // Buat halaman ini sesuai kebutuhan
        ],
      ),
      bottomNavigationBar: Container(  
        height: 100, // Set the desired height here  
        padding: const EdgeInsets.only(top: 0),
        child: BottomNavigationBar(  
          backgroundColor: Colors.white,  
          currentIndex: _currentIndex,  
          onTap: _onItemTapped,  
          iconSize: 31.0, // Increase the icon size  
          showSelectedLabels: false, // Hide selected labels  
          showUnselectedLabels: false, // Hide unselected labels  
          items: const [  
            BottomNavigationBarItem(  
              icon: Icon(Icons.home),  
              label: '', // Keep this empty or remove it  
            ),  
            BottomNavigationBarItem(  
              icon: Icon(Icons.history),  
              label: '', // Keep this empty or remove it  
            ),  
          ],  
        ),  
      ),  
    );
  }
}

String formatRupiah(double amount) {  
  // Format the number to two decimal places  
  String formattedAmount = amount.toStringAsFixed(2);  
    
  // Split the amount into whole and decimal parts  
  List<String> parts = formattedAmount.split('.');  
  String wholePart = parts[0];  
  String decimalPart = parts.length > 1 ? parts[1] : '00';  
  
  // Add thousand separators  
  StringBuffer buffer = StringBuffer();  
  for (int i = 0; i < wholePart.length; i++) {  
    if (i > 0 && (wholePart.length - i) % 3 == 0) {  
      buffer.write('.');  
    }  
    buffer.write(wholePart[i]);  
  }  
  
  // Combine whole part and decimal part  
  return 'Rp ${buffer.toString()},$decimalPart';  
}  

 String formatDate(String dateString) {  
    try {  
      DateTime dateTime = DateTime.parse(dateString);  
      return DateFormat('dd MMMM yyyy').format(dateTime); // Format the date  
    } catch (e) {  
      print("Error formatting date: $e");  
      return dateString; // Return the original string if formatting fails  
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
  final String appid = '678d5a6a046a4332b414b79b'; // app ID

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
          AnimatedContainer(  
            duration: Duration(milliseconds: 500), // Duration of the animation  
            curve: Curves.easeInOut, // Curve of the animation  
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
                        formatRupiah(balance), // Use the formatRupiah function  
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

          // Transactions list ====================
          Expanded(
            child: ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                return TransactionItemWidget(
                  transaction: transaction,
                  onTap: () =>
                      _showDetailTransactionDialog(context, transaction),
                );
              },
            ),
          ),
          //transaction list ==================
        ],
      ),

      //add transaction button===================
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15), // Atur jarak dari bawah
        child: FloatingActionButton(
          onPressed: () {
            _showAddTransactionDialog(context);
          },
          child: Icon(Icons.add, size: 30),
          backgroundColor: Colors.green,
        ),
      ),
      //add button===================================
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  //POP UP DETAIL TRANSACTION ================================================
  void _showDetailTransactionDialog(
      BuildContext context, KeuanganModel transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Transaction Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              // Content
              Padding(  
                padding: const EdgeInsets.all(16.0),  
                child: Column(  
                  crossAxisAlignment: CrossAxisAlignment.start,  
                  children: [  
                    _buildDetailItem("Nama", transaction.name),  
                    SizedBox(height: 8),  
                    _buildDetailItem("Tanggal", formatDate(transaction.date)), // Add date here  
                    SizedBox(height: 8),  
                    _buildDetailItem("Deskripsi", transaction.description),  
                    SizedBox(height: 8),  
                    _buildDetailItem("Type", transaction.type),  
                    SizedBox(height: 8),  
                    Column(  
                      crossAxisAlignment: CrossAxisAlignment.start,  
                      children: [  
                        SizedBox(height: 10),  
                        if (transaction.picture != null)  
                          kIsWeb  
                              ? Image.network(transaction.picture!)  
                              : Image.file(  
                                  File(transaction.picture!),  
                                  height: 100,  
                                  width: 100,  
                                  fit: BoxFit.cover,  
                                ),  
                        if (transaction.picture == null)  
                          Text(  
                            'No image available',  
                            style: TextStyle(color: Colors.grey),  
                          ),  
                      ],  
                    ),  
                  ],  
                ),  
              ),  

              // Action Buttons
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Delete button
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Confirm Delete'),
                              content: Text(
                                  'Are you sure you want to delete this transaction?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context); // Kembali tanpa menghapus
                                  },
                                  child: Text('No'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    // Menghapus data
                                    await dataService.removeId(token, project,
                                        collection, appid, transaction.id);
                                    fetchTransactions(); // Refresh daftar transaksi
                                    Navigator.pop(context); // Tutup dialog
                                    Navigator.pop(
                                        context); // Tutup popup detail
                                  },
                                  child: Text('Yes',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.delete, color: Colors.red[900]),
                    ),

                    // Edit button
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditTransactionDialog(context, transaction);
                      },
                      icon: Icon(Icons.edit, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  //POP UP DETAIL TRANSACTION ================================================

//FORM POP UP ADD--------------------------------------------------
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
  //ADD

//POP UP EDIT TRANSACTION ========================
  void _showEditTransactionDialog(
      BuildContext context, KeuanganModel transaction) {
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
          backgroundColor: Colors.white,
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
                  Navigator.pop(context); // Tutup edit dialog
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup edit dialog
                _showDetailTransactionDialog(
                    context, transaction); // Kembali ke tampilan detail
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  //EDIT==========================================
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
              getIconForCategory(transaction.category), // Get the icon based on category  
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
                  // Display the formatted date instead of the description  
                  Text(  
                    formatDate(transaction.date),  
                    style: TextStyle(  
                      color: Colors.grey,  
                      fontSize: 14,  
                    ),  
                  ),  
                ],  
              ),  
            ),  
            // Safely parse the amount and format it  
            Text(  
              formatRupiah(_parseAmount(transaction.amount)), // Format the amount  
              style: TextStyle(  
                color: transaction.type == 'Expense' ? Colors.red : Colors.green,  
                fontWeight: FontWeight.bold,  
              ),  
            ),  
          ],  
        ),  
      ),  
    );  
  }  
  
  double _parseAmount(String amount) {  
    try {  
      // Remove any non-numeric characters except for '.' and '-'  
      String sanitizedAmount = amount.replaceAll(RegExp(r'[^\d.-]'), '');  
      return double.parse(sanitizedAmount);  
    } catch (e) {  
      print("Error parsing amount: $e");  
      return 0.0; // Return 0.0 if parsing fails  
    }  
  }  
}  