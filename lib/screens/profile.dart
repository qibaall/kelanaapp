// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:kelanaapp/theme.dart';
import 'package:kelanaapp/widgets/buttom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kelanaapp/api/api_service_.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null) {
      try {
        var response = await apiService.getProfile(token);
        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              profileData = response.data['data'];
              isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs
        .clear(); // Clear all preferences including the token and login state
    Navigator.pushReplacementNamed(
        context, '/login'); // Navigate to the login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : profileData == null
              ? Center(
                  child: Text('Failed to load profile',
                      style: GoogleFonts.poppins()))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person,
                          size: 140,
                          color: kPrimaryColor,
                        ),
                        SizedBox(height: 20),
                        Text(
                          '${profileData!['name']}',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 20),
                        Card(
                          color: kWhiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              ListTile(
                                title:
                                    Text('Email', style: GoogleFonts.poppins()),
                                subtitle: Text('${profileData!['email']}',
                                    style: GoogleFonts.poppins()),
                              ),
                              Divider(),
                              ListTile(
                                title: Text('Jurusan',
                                    style: GoogleFonts.poppins()),
                                subtitle: Text('${profileData!['jurusan']}',
                                    style: GoogleFonts.poppins()),
                              ),
                              Divider(),
                              ListTile(
                                title: Text('Program Studi',
                                    style: GoogleFonts.poppins()),
                                subtitle: Text('${profileData!['prodi']}',
                                    style: GoogleFonts.poppins()),
                              ),
                              Divider(),
                              ListTile(
                                title:
                                    Text('Kelas', style: GoogleFonts.poppins()),
                                subtitle: Text('${profileData!['kelas']}',
                                    style: GoogleFonts.poppins()),
                              ),
                              Divider(),
                              ListTile(
                                title: Text('Nomor HP',
                                    style: GoogleFonts.poppins()),
                                subtitle: Text('${profileData!['no_hp']}',
                                    style: GoogleFonts.poppins()),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            _logout(context);
                          },
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(width: 2, color: Colors.red),
                            backgroundColor: kWhiteColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 150, vertical: 15),
                            textStyle: GoogleFonts.poppins(
                                fontSize: 18, color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('Keluar',
                              style: GoogleFonts.poppins(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
      ),
    );
  }
}
