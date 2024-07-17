// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:kelanaapp/api/api_service_.dart';
import 'package:kelanaapp/screens/home.dart';
import 'package:kelanaapp/screens/signup.dart';
import 'package:kelanaapp/theme.dart';
import 'package:kelanaapp/widgets/login_form.dart';
import 'package:kelanaapp/widgets/primary_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart'; // Import Logger

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  final Logger logger = Logger(); // Initialize Logger

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: Stack(
        children: [
          Container(
            height: 400,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backgroundatas.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Padding(
            padding: kDefaultPadding,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 400),
                  Text(
                    'Login',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        'Belum Punya Akun?',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Daftar',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: kPrimaryColor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  LogInForm(
                    emailController: emailController,
                    passwordController: passwordController,
                  ),
                  SizedBox(height: 20),
                  if (isLoading)
                    Center(child: CircularProgressIndicator())
                  else
                    PrimaryButton(
                      buttonText: 'Masuk',
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        String email = emailController.text;
                        String password = passwordController.text;

                        // Validate email and password
                        if (email.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Isi semua data terlebih dahulu'),
                            ),
                          );
                          setState(() {
                            isLoading = false;
                          });
                          return;
                        }

                        try {
                          // Call login method from ApiService
                          var response =
                              await apiService.login(email, password);

                          // Check if the widget is still mounted before setState
                          if (!mounted) return;

                          if (response.statusCode == 200) {
                            // Get token from response
                            String token = response.data['token'];

                            // Save token to SharedPreferences
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setBool('isLoggedIn', true);
                            await prefs.setString('token', token);

                            // Check if the widget is still mounted before using context
                            if (mounted) {
                              // Navigate to HomeScreen
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(),
                                ),
                              );
                            }
                          } else if (response.statusCode == 401) {
                            // Show alert for invalid credentials
                            if (mounted) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Login Failed'),
                                    content:
                                        Text('Email atau password Anda salah.'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          } else {
                            // Handle other status codes
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Terjadi kesalahan: User Tidak Ditemukan'),
                              ),
                            );
                            logger.e('Login failed: ${response.statusMessage}');
                          }
                        } catch (e) {
                          // Handle Dio errors
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Terjadi kesalahan: User Tidak Ditemukan'),
                            ),
                          );
                          logger.e('Login failed: $e');
                        } finally {
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: kPrimaryColor,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
