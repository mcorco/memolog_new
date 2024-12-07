// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
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
        if (e.code == 'email-already-in-use') {
          errorMessage = "An account already exists with this email.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "Invalid email address.";
        } else if (e.code == 'weak-password') {
          errorMessage = "The password is too weak.";
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
      appBar: AppBar(
        title: const Text(
          'Register with MemoLog',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(3, 169, 244, 1),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromRGBO(3, 169, 244, 1),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                      fillColor: Colors.white,
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
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // Register Button
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 174, 239), // Vibrant blue color for the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                  ),
                  child: const Text('Register', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
