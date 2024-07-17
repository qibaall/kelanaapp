// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:kelanaapp/screens/home.dart';
import 'package:kelanaapp/screens/profile.dart';
import 'package:kelanaapp/screens/report.dart';
import 'package:kelanaapp/theme.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ReportScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: _onItemTapped,
      backgroundColor: kWhiteColor,
      selectedItemColor: kPrimaryColor, // Set the color for selected items
      unselectedItemColor: Colors.grey, // Set the color for unselected items
      items: [
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/icons/home.png'),
          ),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/icons/file.png'),
          ),
          label: 'Lapor',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/icons/user.png'),
          ),
          label: 'Profil',
        ),
      ],
    );
  }
}
