import 'package:flutter/material.dart';  
import 'package:firebase_auth/firebase_auth.dart';  
import 'package:flutter_application_1/main.dart';  
import 'package:flutter_application_1/register_page.dart';  
import 'package:flutter_application_1/main.dart'; // Make sure to import the AppPage  
  
class SignInPage extends StatefulWidget {  
  const SignInPage({super.key});  
  
  @override  
  _SignInPageState createState() => _SignInPageState();  
}  
  
final _auth = FirebaseAuth.instance;  
  
class _SignInPageState extends State<SignInPage> {  
  final _emailController = TextEditingController();  
  final _passwordController = TextEditingController();  
  
  bool _isPasswordVisible = false;  
  
  Future<void> _signIn() async {  
    // Validasi input kosong  
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {  
      showDialog(  
        context: context,  
        builder: (context) => AlertDialog(  
          title: const Text('Error'),  
          content: const Text('Email and password cannot be empty.'),  
          actions: <Widget>[  
            TextButton(  
              onPressed: () {  
                Navigator.pop(context);  
              },  
              child: const Text('OK'),  
            ),  
          ],  
        ),  
      );  
      return;  
    }  
  
    try {  
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(  
        email: _emailController.text.trim(),  
        password: _passwordController.text.trim(),  
      );  
      // Navigasi ke halaman utama setelah login sukses  
      Navigator.pushReplacement(  
        context,  
        MaterialPageRoute(builder: (context) => AppPage()), // Change to AppPage  
      );  
    } on FirebaseAuthException catch (e) {  
      String message = e.message ?? "An error occurred.";  
      showDialog(  
        context: context,  
        builder: (context) => AlertDialog(  
          title: const Text('Login Failed'),  
          content: Text(message),  
          actions: <Widget>[  
            TextButton(  
              onPressed: () {  
                Navigator.pop(context);  
              },  
              child: const Text('OK'),  
            ),  
          ],  
        ),  
      );  
    }  
  }  
  
  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      backgroundColor: Colors.white,  
      body: SafeArea(  
        child: Center(  
          child: Padding(  
            padding: const EdgeInsets.symmetric(horizontal: 24.0),  
            child: Column(  
              mainAxisAlignment: MainAxisAlignment.center,  
              crossAxisAlignment: CrossAxisAlignment.center,  
              children: [  
                Text(  
                  'Welcome Back!',  
                  style: TextStyle(  
                    fontSize: 28,  
                    fontWeight: FontWeight.bold,  
                  ),  
                ),  
                SizedBox(height: 20),  
                Image.asset(  
                  'assets/login_image.png', // Ganti dengan path gambar Anda  
                  height: 150,  
                ),  
                SizedBox(height: 30),  
  
                TextField(  
                  controller: _emailController,  
                  decoration: InputDecoration(  
                    labelText: 'Enter Email Address',  
                    border: OutlineInputBorder(  
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),  
                    ),  
                  ),  
                ),  
                SizedBox(height: 20),  
                TextField(  
                  controller: _passwordController,  
                  decoration: InputDecoration(  
                    labelText: 'Password',  
                    border: OutlineInputBorder(  
                        borderRadius: BorderRadius.circular(10)),  
                    suffixIcon: IconButton(  
                      icon: Icon(  
                        _isPasswordVisible  
                            ? Icons.visibility  
                            : Icons.visibility_off,  
                      ),  
                      onPressed: () {  
                        setState(() {  
                          _isPasswordVisible = !_isPasswordVisible;  
                        });  
                      },  
                    ),  
                  ),  
                  obscureText: !_isPasswordVisible,  
                ),  
                const SizedBox(height: 10),  
  
                SizedBox(height: 30),  
                // Tombol Login  
                ElevatedButton(  
                  onPressed: _signIn,  
                  style: ElevatedButton.styleFrom(  
                    backgroundColor: Colors.green,  
                    shape: RoundedRectangleBorder(  
                      borderRadius: BorderRadius.circular(8.0),  
                    ),  
                    minimumSize: const Size(double.infinity, 50),  
                  ),  
                  child: const Text(  
                    'Login',  
                    style: TextStyle(fontSize: 18, color: Colors.white), // Change text color to white  
                  ),  
                ),  
  
                const SizedBox(height: 20),  
                Row(  
                  mainAxisAlignment: MainAxisAlignment.center,  
                  children: [  
                    const Text("Don't have an account? "),  
                    GestureDetector(  
                      onTap: () {  
                        Navigator.push(  
                          context,  
                          MaterialPageRoute(  
                              builder: (context) => RegisterScreen()),  
                        );  
                      },  
                      child: const Text(  
                        'Register',  
                        style: TextStyle(  
                          color: Colors.blue,  
                          fontWeight: FontWeight.bold,  
                        ),  
                      ),  
                    ),  
                  ],  
                ),  
              ],  
            ),  
          ),  
        ),  
      ),  
    );  
  }  
}  
