//992024008 - Nurmei Sarrah
//162022037 - Jamilah Kamaliah
//162022035 - Muhammad Thoriq Aziz
//162022042 - Nail Ghani Prihartono
//162022055 - Muhammad Ghafiki Putra

// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_application_1/login_page.dart';
import 'package:flutter_application_1/register_page.dart';
import 'package:google_fonts/google_fonts.dart';

import 'user_dashboard.dart';
//import 'register_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _gotoNavigateToHome();
  }

  _gotoNavigateToHome() async {
    await Future.delayed(Duration(seconds: 4));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // Menghindari kolom mengambil seluruh tinggi layar
            children: [
              Image.asset(
                'assets/logo.png',
                height: 250,
              ),
              SizedBox(
                  height:
                      8), // Menambahkan sedikit jarak antara gambar dan teks
              Text(
                'neynote',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  textStyle: const TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tambahkan gambar di sini
          Image.asset(
            'assets/logo.png', // Path ke gambar Anda
            width: 250, // Sesuaikan ukuran gambar
            height: 250,
          ),

          // Baris teks Login dan Register
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Navigasi ke halaman Login
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                },
                child: Text(
                  'Login',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                height: 20,
                width: 1,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  // Navigasi ke halaman Register
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterPage()),
                  );
                },
                child: Text(
                  'Register',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
