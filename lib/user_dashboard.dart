//992024008 - Nurmei Sarrah
//162022037 - Jamilah Kamaliah
//162022035 - Muhammad Thoriq Aziz
//162022042 - Nail Ghani Prihartono
//162022055 - Muhammad Ghafiki Putra

import 'package:flutter/material.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 240, 184, 15),
        title: const Text("Home page"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Color.fromARGB(255, 240, 184, 15),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search",
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // IconButton(
                    //   icon: const Icon(Icons.arrow_downward),
                    //   onPressed: () {},
                    // ),
                    // IconButton(
                    //   icon: const Icon(Icons.arrow_upward),
                    //   onPressed: () {},
                    // ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.upload),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TransactionCard(
                  title: "Jajan mixue",
                  date: "1 Januari 2025",
                  amount: "Rp. 25.000",
                ),
                TransactionCard(
                  title: "Beli Laptop",
                  date: "1 Januari 2025",
                  amount: "Rp. 10.000.000",
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Wallet",
          ),
        ],
        selectedItemColor: Color.fromARGB(255, 240, 184, 15),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final String title;
  final String date;
  final String amount;

  const TransactionCard({
    required this.title,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(255, 240, 184, 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        //ini disini nanti IMG per listnya
        leading: Container(
          width: 40,
          height: 40,
          color: Colors.grey,
        ),

        //deskripsi list
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: const TextStyle(color: Color.fromARGB(179, 0, 0, 0)),
            ),
            Text(
              amount,
              style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ],
        ),
      ),
    );
  }
}
