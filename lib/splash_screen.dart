import 'dart:async';  
import 'package:flutter/material.dart';  
import 'login_page.dart'; // Make sure to import the SignInPage  
  
class SplashScreen extends StatefulWidget {  
  const SplashScreen({super.key});  
  
  @override  
  _SplashScreenState createState() => _SplashScreenState();  
}  
  
class _SplashScreenState extends State<SplashScreen> {  
  @override  
  void initState() {  
    super.initState();  
    // Delay navigation to SignInPage by 3 seconds  
    Timer(const Duration(seconds: 3), () {  
      Navigator.pushReplacement(  
        context,  
        MaterialPageRoute(builder: (context) => const SignInPage()),  
      );  
    });  
  }  
  
  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      backgroundColor: Colors.white,  
      body: Center(  
        child: Image.asset(  
          'assets/business.png', // Replace with your splash image path  
          width: 200,  
          height: 200,  
        ),  
      ),  
    );  
  }  
}  
