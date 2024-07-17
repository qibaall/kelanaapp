// ignore_for_file: prefer_const_constructors, sort_child_properties_last, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:kelanaapp/models/allinonboardscreenn.dart';
import 'package:kelanaapp/screens/login.dart';
import 'package:kelanaapp/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  int currentIndex = 0;

  List<AllinOnboardModel> allinonboardlist = [
    AllinOnboardModel(
        "assets/images/onboard1.png",
        "Selamat Datang Di Aplikasi KELANA (Kelompok Pendamping  Advokasi Korban Kekerasan Seksual & Bullying)",
        "Welcome"),
    AllinOnboardModel(
        "assets/images/onboard2.png",
        "Kelana adalah sebuah aplikasi pelaporan, penanganan, dan juga monitoring kekerasan seksual dan bullying untuk lingkungan kampus Politeknik Negeri Semarang.",
        "Apa Itu Kelana ?"),
    AllinOnboardModel(
        "assets/images/onboard3.png", "", "Silahkan Masuk atau Daftar"),
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Kelana",
          style: GoogleFonts.poppins(
              color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 30),
          textAlign: TextAlign.center,
        ),
        backgroundColor: kWhiteColor,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            onPageChanged: (value) {
              setState(() {
                currentIndex = value;
              });
            },
            itemCount: allinonboardlist.length,
            itemBuilder: (context, index) {
              return PageBuilderWidget(
                title: allinonboardlist[index].titlestr,
                description: allinonboardlist[index].description,
                imgurl: allinonboardlist[index].imgStr,
              );
            },
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            left: MediaQuery.of(context).size.width * 0.44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                allinonboardlist.length,
                (index) => buildDot(index: index),
              ),
            ),
          ),
          currentIndex < allinonboardlist.length - 1
              ? Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [],
                  ),
                )
              : Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.1,
                  left: MediaQuery.of(context).size.width * 0.33,
                  child: ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

                      if (!isLoggedIn) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogInScreen(),
                          ),
                        );
                      } else {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    child: Text(
                      "Get Started",
                      style:
                          GoogleFonts.poppins(fontSize: 18, color: kWhiteColor),
                      textAlign: TextAlign.center,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  AnimatedContainer buildDot({int? index}) {
    return AnimatedContainer(
      duration: kFloatingActionButtonSegue,
      margin: EdgeInsets.only(right: 5),
      height: 6,
      width: currentIndex == index ? 20 : 6,
      decoration: BoxDecoration(
        color: currentIndex == index ? kPrimaryColor : Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class PageBuilderWidget extends StatelessWidget {
  final String title;
  final String description;
  final String imgurl;

  const PageBuilderWidget({
    super.key,
    required this.title,
    required this.description,
    required this.imgurl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Image.asset(
              imgurl,
              height: imgurl == 'assets/images/onboard1.png' ? 300 : null,
              width: imgurl == 'assets/images/onboard1.png' ? 200 : null,
            ),
          ),
          const SizedBox(height: 20),
          // Title Text
          Text(
            title,
            style: GoogleFonts.poppins(
                color: kPrimaryColor,
                fontSize: 24,
                fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: kBlackColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
