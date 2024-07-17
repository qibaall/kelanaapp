// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kelanaapp/api/api_service_.dart';
import 'package:kelanaapp/screens/detail_history.dart';
import 'package:kelanaapp/theme.dart';
import 'package:kelanaapp/widgets/buttom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelanaapp/notifications.dart'; // Import NotificationService
import 'package:url_launcher/url_launcher.dart';

const String imagePath = 'assets/images/LogoKelana.png';
const String imageBackground = 'assets/images/Faq Chat.png';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  final NotificationService notificationService =
      NotificationService(); // Instantiate NotificationService
  Map<String, dynamic>? profileData;
  List<Map<String, dynamic>> reportHistory = [];
  bool isLoading = true;

  Map<int, String> previousReportStatus = {};
  Timer? timer;

  @override
  void initState() {
    super.initState();
    notificationService.initializeNotifications();
    getUserId();
    fetchProfileAndReportData();

    // Start polling every minute
    timer = Timer.periodic(
        Duration(minutes: 1), (Timer t) => fetchProfileAndReportData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> getUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token != null) {
        final profileResponse = await apiService.getProfile(token);
        if (profileResponse.statusCode == 200) {
          final Map<String, dynamic> rawJson = profileResponse.data;
          final int id = rawJson['data']['id'];
          prefs.setInt('user_id', id);
        }
      } else {
        debugPrint('Token not found');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> fetchProfileAndReportData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null) {
      try {
        // Fetch Profile Data
        var profileResponse = await apiService.getProfile(token);
        if (profileResponse.statusCode == 200 && profileResponse.data != null) {
          if (mounted) {
            setState(() {
              profileData = profileResponse.data['data'];
            });
          }
        }

        // Fetch Report History
        var reportResponse = await apiService.getReportHistory(token);
        if (reportResponse.statusCode == 200 && reportResponse.data != null) {
          List<dynamic>? data = reportResponse.data['reports']['data'];
          if (data != null) {
            if (mounted) {
              setState(() {
                reportHistory = data.cast<Map<String, dynamic>>();

                // Check for status changes and notify
                for (var report in reportHistory) {
                  int reportId = report['id'];
                  String currentStatus = report['status'];

                  // Compare with the previous status
                  if (previousReportStatus.containsKey(reportId) &&
                      previousReportStatus[reportId] != currentStatus) {
                    // Status has changed, send notification
                    notificationService.sendNotification(
                        reportId, currentStatus);
                  }

                  // Update previous status
                  previousReportStatus[reportId] = currentStatus;
                }
              });
            }
          }
        }
      } catch (e) {
        debugPrint('Error: $e');
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      debugPrint('Token not found');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> openWhatsApp() async {
    const phoneNumber = "+6285162752302"; // Replace with your WhatsApp number
    const message = "Hello, I have a question about..."; // Pre-filled message
    final Uri url = Uri.parse(
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else if (mounted) {
      // Show a message to the user that WhatsApp is not installed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("WhatsApp is not installed on your device."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: kToolbarHeight,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          profileData != null
                              ? RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Selamat Datang, \n ",
                                        style: GoogleFonts.poppins(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                              ),
                                        ),
                                      ),
                                      TextSpan(
                                        text: "${profileData!['name']}",
                                        style: GoogleFonts.poppins(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50.0,
                ),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 150.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                    color: kWhiteColor,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Histori Laporan",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: Color.fromRGBO(19, 22, 33, 1),
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: reportHistory.length,
                                itemBuilder: (context, index) {
                                  var report = reportHistory[index];
                                  return ListTile(
                                    title: Text(
                                      'Melapor Sebagai : ${report['lpr_sebagai']}',
                                      style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Tanggal Kejadian: ${report['tgl_kejadian']}',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    trailing: Text(
                                      '${report['status']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: report['status'] == 'masuk'
                                            ? Colors.blue
                                            : report['status'] == 'proses'
                                                ? Colors.orange
                                                : report['status'] == 'selesai'
                                                    ? Colors.green
                                                    : Colors.red,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailHistory(
                                            reportId: report['id'],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openWhatsApp,
        backgroundColor: kPrimaryColor,
        child: Icon(
          Icons.message,
          color: kWhiteColor,
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
      ),
    );
  }
}
