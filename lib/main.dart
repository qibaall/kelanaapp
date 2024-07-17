// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelanaapp/screens/onboard.dart';
import 'package:kelanaapp/screens/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kelanaapp/screens/login.dart';
import 'package:kelanaapp/screens/home.dart';
import 'package:kelanaapp/screens/report.dart'; // assuming ReportScreen is imported from 'report.dart'

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelana App',
      theme: ThemeData(fontFamily: GoogleFonts.poppins().fontFamily),
      routes: {
        '/login': (context) => LogInScreen(),
        '/home': (context) => HomeScreen(),
        '/report': (context) => const ReportScreen(),
        '/profile': (context) => ProfileScreen()
        // Add more routes as needed
      },
      home: isLoggedIn
          ? HomeScreen()
          : OnboardScreen(), // Set OnboardScreen sebagai home
    );
  }
}
