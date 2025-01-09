import 'dart:convert'; 
import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart'; 
import 'restapi.dart'; 
import 'model.dart'; 

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(),
    ),
  );
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
  String selectedFilter = 'All';
  String searchQuery = '';
  bool sortNewestFirst = true; // track order by date
  List<KeuanganModel> allTransactions = [];
  final DataService dataService = DataService();
  final String token = '6717db9aec5074ec8261d698'; 
  final String project = 'uts-remedial'; 
  final String collection = 'keuangan'; 
  final String appid = '677a97e3f853312de5509ec0'; 

  double totalIncome = 0.0; // track total pemasukan
  double totalExpense = 0.0; // track total pengeluaran

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    String response = await dataService.selectAll(token, project, collection, appid);
    List<dynamic> jsonData = jsonDecode(response);
    setState(() {
      allTransactions = jsonData.map((data) => KeuanganModel.fromJson(data)).toList();
      calculateTotals(); // ngitung total saldo ngambil dr etter
    });
  }

  void calculateTotals() {
    totalIncome = allTransactions
        .where((transaction) => transaction.type == 'Income')
        .fold(0.0, (sum, transaction) => sum + double.parse(transaction.amount));
    totalExpense = allTransactions
        .where((transaction) => transaction.type == 'Expense')
        .fold(0.0, (sum, transaction) => sum + double.parse(transaction.amount));
  }

  List<KeuanganModel> get filteredTransactions {
    return allTransactions.where((transaction) {
      final matchesFilter = selectedFilter == 'All' ||
          (selectedFilter == 'Income' && transaction.type == 'Income') ||
          (selectedFilter == 'Expense' && transaction.type == 'Expense');
      final matchesSearch = transaction.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList()
      ..sort((a, b) {
        // ngerubah ke double buat sorting
        double amountA = double.tryParse(a.amount.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
        double amountB = double.tryParse(b.amount.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0;
        return sortNewestFirst ? amountB.compareTo(amountA) : amountA.compareTo(amountB);
      });
  }

  @override
  Widget build(BuildContext context) {
    double balance = totalIncome - totalExpense; // ngitung saldo

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // bagian atas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome,',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Muhammad Thoriq Aziz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
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
                      SizedBox(height: 8),
                      Text(
                        'Rp ${balance.toStringAsFixed(2)}', // munculin saldo
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

          // bagian search dan sort
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
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                      sortNewestFirst = !sortNewestFirst; // sorting transaksi
                    });
                  },
                ),
              ],
            ),
          ),

          // tombol filter
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

          // list transaksi
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
    String picture = '';

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
                // dropdown buat income atau expense
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
                    // milih gambar
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        picture = image.path; // nyimpen gambar
                      });
                    }
                  },
                  child: Text('Pick an Image'),
                ),
                if (picture != null) // munculin gambar
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
                  // logic buat nge simpen transaksi baru
                  await dataService.insertKeuangan(
                    appid,
                    nameController.text,
                    descriptionController.text,
                    amountController.text,
                    selectedType,
                    selectedCategory,
                    DateTime.now().toIso8601String(), // otomatis tanggal sekarang
                    picture,
                  );
                  fetchTransactions(); // refresh list
                  Navigator.pop(context);
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
    TextEditingController nameController = TextEditingController(text: transaction.name);
    TextEditingController descriptionController = TextEditingController(text: transaction.description);
    TextEditingController amountController = TextEditingController(text: transaction.amount);
    String selectedType = transaction.type; 

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Transaction"),
          content: SingleChildScrollView( // make singlechildscrollview biar gambar ga kelebihan pixel
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
                  // dropdown buat income atau expense
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
                  // nampilin gambar kalo ada
                  if (transaction.picture != null && transaction.picture!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          Text('Current Image:'),
                          SizedBox(height: 10),
                          kIsWeb
                              ? Image.network(transaction.picture!) // make image.network buat internet
                              : Image.file(
                                  File(transaction.picture!), // make image.file buat local
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
                  // logic ngedit transaksi
                  await dataService.updateId('name', nameController.text, token, project, collection, appid, transaction.id);
                  await dataService.updateId('description', descriptionController.text, token, project, collection, appid, transaction.id);
                  await dataService.updateId('amount', amountController.text, token, project, collection, appid, transaction.id);
                  await dataService.updateId('type', selectedType, token, project, collection, appid, transaction.id);
                  fetchTransactions(); // refresh list
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () async {
                await dataService.removeId(token, project, collection, appid, transaction.id);
                fetchTransactions(); // refresh list
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
        return Icons.fastfood; // icon makan
      case 'Shopping':
        return Icons.shopping_cart; // icon keranjang
      case 'Transfer':
        return Icons.attach_money; // icon transfer
      default:
        return Icons.attach_money; // icon default
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // bisa mencet
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
              getIconForCategory(transaction.category), // ngambil icon sesuai kategori transaksi
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
                color: transaction.type == 'Expense' ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
