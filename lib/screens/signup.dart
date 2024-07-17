// ignore_for_file: prefer_const_constructors

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kelanaapp/screens/login.dart';
import 'package:kelanaapp/theme.dart';
import 'package:kelanaapp/widgets/primary_button.dart';
import 'package:kelanaapp/widgets/signup_form.dart';
import 'package:kelanaapp/api/api_service_.dart'; // Import ApiService

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final ApiService apiService = ApiService();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController noHpController = TextEditingController();

  String? selectedJurusan;
  String? selectedProgramStudi;
  String? selectedKelas;

  void showErrorDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void registerUser() async {
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String jurusan = selectedJurusan ?? '';
    String prodi = selectedProgramStudi ?? '';
    String kelas = selectedKelas ?? '';
    String noHp = noHpController.text;

    try {
      var response = await apiService.register(
        name: name,
        email: email,
        password: password,
        jurusan: jurusan,
        prodi: prodi,
        kelas: kelas,
        noHp: noHp,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Handle success, tampilkan popup dan navigasi ke halaman login
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Pendaftaran Berhasil'),
              content: Text('Anda berhasil mendaftar. Silakan login.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LogInScreen(),
                      ),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Handle error
        showErrorDialog(context, 'Pendaftaran Gagal',
            'Terjadi kesalahan saat mendaftar. Status Code: ${response.statusCode}. Message: ${response.statusMessage}');
      }
    } catch (e) {
      if (!mounted) return;

      if (e is DioException) {
        // Handle DioException
        showErrorDialog(context, 'Pendaftaran Gagal',
            'Terjadi kesalahan saat mendaftar: ${e.message}');
      } else {
        // Handle other exceptions
        showErrorDialog(context, 'Pendaftaran Gagal',
            'Terjadi kesalahan tidak terduga. Coba lagi.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 70,
            ),
            Padding(
              padding: kDefaultPadding,
              child: Text(
                'Daftar',
                style: titleText.copyWith(color: kPrimaryColor),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: kDefaultPadding,
              child: Row(
                children: [
                  Text(
                    'Sudah Punya Akun?',
                    style: subTitle,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LogInScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Log In',
                      style: textButton.copyWith(
                        decoration: TextDecoration.underline,
                        decorationThickness: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: kDefaultPadding,
              child: SignUpForm(
                nameController: nameController,
                emailController: emailController,
                passwordController: passwordController,
                noHpController: noHpController,
                onSelectJurusan: (value) {
                  setState(() {
                    selectedJurusan = value;
                  });
                },
                onSelectProgramStudi: (value) {
                  setState(() {
                    selectedProgramStudi = value;
                  });
                },
                onSelectKelas: (value) {
                  setState(() {
                    selectedKelas = value;
                  });
                },
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: kDefaultPadding,
              child: PrimaryButton(
                buttonText: 'Sign Up',
                onPressed: () {
                  // Panggil fungsi registerUser saat tombol ditekan
                  registerUser();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
