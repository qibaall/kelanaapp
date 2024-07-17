// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:kelanaapp/theme.dart';
import 'package:kelanaapp/widgets/buttom_nav_bar.dart';
import 'package:kelanaapp/widgets/report_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    getId();
    super.initState();
  }

  Future<void> getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getInt('user_id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 32.0), // Adjust the top padding to move the text down
              child: Center(
                child: Text(
                  'Lapor',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0), // Space between the text and the form
            Expanded(
              child: ReportForm(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
    );
  }
}
