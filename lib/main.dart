import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:memolog_new/screens/home_page.dart';
import 'package:memolog_new/screens/login_page.dart';
import 'package:memolog_new/screens/register_page.dart';
import 'package:memolog_new/screens/reset_password.dart';
import 'package:memolog_new/screens/diary_entry_page.dart';
import 'package:memolog_new/screens/diary_history_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/diary': (context) => DiaryEntryPage(selectedDate: DateTime.now()),
        '/history': (context) => const DiaryHistoryPage(),
        '/register': (context) => const RegisterPage(),
        '/resetPassword': (context) => const ResetPasswordPage(),
      },
    );
  }
}
