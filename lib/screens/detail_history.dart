// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:kelanaapp/api/api_service_.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelanaapp/theme.dart'; // Make sure this contains kPrimaryColor

class DetailHistory extends StatefulWidget {
  final int reportId;

  const DetailHistory({super.key, required this.reportId});

  @override
  State<DetailHistory> createState() => _DetailHistoryState();
}

class _DetailHistoryState extends State<DetailHistory> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? reportDetails;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    fetchReportDetails();
    super.initState();
  }

  Future<void> fetchReportDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null) {
      try {
        var response = await apiService.getReportHistory(token);

        if (response.statusCode == 200 && response.data != null) {
          List<dynamic>? data = response.data['reports']['data'];

          if (data != null) {
            var report = data.cast<Map<String, dynamic>>().firstWhere(
                (report) => report['id'] == widget.reportId,
                orElse: () => {});

            setState(() {
              reportDetails = report.isNotEmpty ? report : null;
              isLoading = false;
            });
          } else {
            setState(() {
              errorMessage = 'No report data found';
              isLoading = false;
            });
          }
        } else {
          setState(() {
            errorMessage =
                'Failed to fetch report details: ${response.statusMessage}';
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Error: $e';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        errorMessage = 'Token not found';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail History'),
      ),
      backgroundColor: kWhiteColor, // Set background color to kPrimaryColor
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchReportDetails,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : reportDetails == null
                  ? Center(child: Text('Report not found'))
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: kWhiteColor,
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListView.separated(
                            itemCount:
                                10, // Update item count to include 'ket_hasil'
                            separatorBuilder: (context, index) => Divider(
                              color:
                                  Colors.grey, // Set the color of the divider
                            ),
                            itemBuilder: (context, index) {
                              switch (index) {
                                case 0:
                                  return _buildDetailTile('Melapor Sebagai',
                                      reportDetails!['lpr_sebagai']);
                                case 1:
                                  return _buildDetailTile('Tanggal Kejadian',
                                      reportDetails!['tgl_kejadian']);
                                case 2:
                                  return _buildDetailTile('Area Kejadian',
                                      reportDetails!['area_kejadian']);
                                case 3:
                                  return _buildDetailTile(
                                      'Kronologi', reportDetails!['kronologi']);
                                case 4:
                                  return _buildDetailTile('Bentuk Kekerasan',
                                      reportDetails!['bentuk_kekerasan']);
                                case 5:
                                  return _buildDetailTile('Informasi Pelaku',
                                      reportDetails!['informasi_pelaku']);
                                case 6:
                                  return _buildDetailTile('Informasi Korban',
                                      reportDetails!['informasi_korban']);
                                case 7:
                                  return _buildDetailTile(
                                      'Status', reportDetails!['status']);
                                case 8:
                                  return _buildDetailTile('Keterangan',
                                      reportDetails!['ket_hasil']);
                                case 9:
                                  return _buildDetailTile(
                                      'Bukti', reportDetails!['bukti']);

                                default:
                                  return Container();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildDetailTile(String label, dynamic value) {
    return ListTile(
      tileColor: kWhiteColor,
      contentPadding: EdgeInsets.symmetric(vertical: 4.0),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        value != null ? value.toString() : 'N/A',
        style: GoogleFonts.poppins(fontSize: 16),
      ),
    );
  }
}
