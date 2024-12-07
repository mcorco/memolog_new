// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memolog_new/screens/reset_password.dart';
import 'home_page.dart';
import 'register_page.dart';
// ignore: unused_import
import 'reset_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = "An error occurred, please try again.";
        if (e.code == 'user-not-found') {
          errorMessage = "No user found with this email.";
        } else if (e.code == 'wrong-password') {
          errorMessage = "Incorrect password.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "Invalid email address.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromRGBO(3, 169, 244, 1), // Light baby-blue background
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon and Welcome Text
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 174, 239), // Vibrant blue color for the container
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 10),
                      const Text(
                        'Welcome to MemoLog',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Font color updated to white
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Diary Icon Image
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('lib/images/leather_diary.png'), // Path to your diary image
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: Colors.lightBlueAccent,
                      width: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Email Input Field
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.33,
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      ),
                      filled: true,
                      fillColor: Colors.white, // Keep the email field white
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Input Field
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.33,
                  child: TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      ),
                      filled: true,
                      fillColor: Colors.white, // Keep the password field white
                    ),
                    obscureText: true,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 174, 239), // Vibrant blue color for the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                const SizedBox(height: 16),

                // Create Account and Forgot Password Buttons
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text('Create an account', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
                    );
                  },
                  child: const Text('Forgot your password?', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
