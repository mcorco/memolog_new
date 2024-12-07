import 'package:flutter/material.dart'; 
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core
import 'package:memolog_new/screens/diary_entry_page.dart';
import 'package:memolog_new/screens/diary_history_page.dart';
import 'package:memolog_new/screens/home_page.dart';
import 'package:memolog_new/screens/login_page.dart';
import 'package:memolog_new/screens/register_page.dart';
import 'package:memolog_new/screens/reset_password.dart';
import 'firebase_options.dart'; // Import the Firebase options file

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures that Firebase is properly initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Ensure proper Firebase configuration
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoLog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // Define initial route
      routes: {
        '/': (context) => const LoginPage(),            // Set LoginPage as the initial page
        '/home': (context) => const HomePage(),         // Route for the Home Page
        '/diary': (context) => DiaryEntryPage(selectedDate: DateTime.now()), // Route for the diary entry page
        '/history': (context) => const DiaryHistoryPage(), // Route for the diary history page
        '/register': (context) => const RegisterPage(),   // Route for the Register Page
        '/resetPassword': (context) => const ResetPasswordPage(), // Route for the Reset Password Page
      },
    );
  }
}
