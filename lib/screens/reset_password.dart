import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();

  Future<void> _resetPassword() async {
    final String email = _emailController.text.trim();

    if (email.isNotEmpty) {
      try {
        await _auth.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Password reset link has been sent to your email.")),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = "An error occurred, please try again.";
        if (e.code == 'user-not-found') {
          errorMessage = "No user found with this email.";
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
        const SnackBar(content: Text("Please enter your email address.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), // Set AppBar height
        child: Container(
          color: const Color.fromRGBO(3, 169, 244, 1), // Match AppBar color
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  tooltip: 'Back',
                ),
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromRGBO(3, 169, 244, 1), // Set the background color
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Change to start to lift content up
              children: [
                const SizedBox(height: 40), // Added spacing to raise icon and calendar
                // Diary Icon Image
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: AssetImage('lib/images/leather_diary.png'), // Path to your diary image
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: Colors.lightBlueAccent,
                      width: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 32), // Reduced spacing after icon

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
                      fillColor: Colors.white, // Keep the input field white
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // Send Reset Link Button (Updated to match other pages)
                ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 0, 174, 239), // Vibrant blue color for consistency
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 40.0),
                  ),
                  child: const Text(
                    'Send Reset Link',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
