// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kelanaapp/api/api_service_.dart';
import 'package:kelanaapp/models/report.dart';
import 'package:kelanaapp/theme.dart';
import 'package:kelanaapp/widgets/primary_button.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportForm extends StatefulWidget {
  const ReportForm({super.key});

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _kronologiController = TextEditingController();
  final TextEditingController _bentukKekerasanController =
      TextEditingController();
  final TextEditingController _informasiPelakuController =
      TextEditingController();
  final TextEditingController _informasiKorbanController =
      TextEditingController();
  String? _laporSebagaiValue;
  String? _areaKejadianValue;
  DateTime? _tanggalKejadianDateTime;
  File? _bukti;
  bool _isVideo = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _kronologiController.dispose();
    _bentukKekerasanController.dispose();
    _informasiPelakuController.dispose();
    _informasiKorbanController.dispose();
    super.dispose();
  }

  Future<void> postReport() async {
    ApiService apiService = ApiService();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');
    final String? accessToken = prefs.getString('token');

    if (userId == null || accessToken == null) {
      // Handle the case where the userId or accessToken is not available
      return;
    }

    final String currentDate = DateFormat('yyyyMMdd').format(DateTime.now());
    final String filename =
        _isVideo ? '$userId-$currentDate.mp4' : '$userId-$currentDate.jpg';

    final MultipartFile bukti = await MultipartFile.fromFile(
      _bukti!.path,
      filename: filename,
    );

    try {
      Report reportData = Report(
        userId: userId,
        lprSebagai: _laporSebagaiValue!,
        tglKejadian: DateFormat('yyyy-MM-dd').format(_tanggalKejadianDateTime!),
        areaKejadian: _areaKejadianValue!,
        kronologi: _kronologiController.text,
        bentukKekerasan: _bentukKekerasanController.text,
        informasiPelaku: _informasiPelakuController.text,
        informasiKorban: _informasiKorbanController.text,
        bukti: bukti,
      );

      await apiService.postReport(
        report: reportData,
        token: accessToken,
      );

      // Save report data to SharedPreferences
      List<String> reportHistory = prefs.getStringList('report_history') ?? [];
      reportHistory.add(jsonEncode(reportData.toJson()));
      await prefs.setStringList('report_history', reportHistory);

      // Clear all form fields
      _kronologiController.clear();
      _bentukKekerasanController.clear();
      _informasiPelakuController.clear();
      _informasiKorbanController.clear();
      setState(() {
        _laporSebagaiValue = null;
        _areaKejadianValue = null;
        _tanggalKejadianDateTime = null;
        _bukti = null;
        _isVideo = false;
      });

      // Show snackbar with success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil diunggah')),
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalKejadianDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _tanggalKejadianDateTime) {
      setState(() {
        _tanggalKejadianDateTime = picked;
      });
    }
  }

  Future<void> _pickFile() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galeri'),
                onTap: () async {
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _bukti = File(pickedFile.path);
                      _isVideo = false;
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library),
                title: Text('Video'),
                onTap: () async {
                  final pickedVideo =
                      await _picker.pickVideo(source: ImageSource.gallery);
                  if (pickedVideo != null) {
                    setState(() {
                      _bukti = File(pickedVideo.path);
                      _isVideo = true;
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Kamera'),
                onTap: () async {
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _bukti = File(pickedFile.path);
                      _isVideo = false;
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text('Kamera Video'),
                onTap: () async {
                  final pickedVideo =
                      await _picker.pickVideo(source: ImageSource.camera);
                  if (pickedVideo != null) {
                    setState(() {
                      _bukti = File(pickedVideo.path);
                      _isVideo = true;
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _kronologiController,
                decoration: InputDecoration(
                  labelText: 'Kronologi Singkat',
                  filled: true,
                  fillColor: kWhiteColor,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field ini harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _bentukKekerasanController,
                decoration: InputDecoration(
                  labelText: 'Bentuk Kekerasan',
                  filled: true,
                  fillColor: kWhiteColor,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field ini harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _informasiPelakuController,
                decoration: InputDecoration(
                  labelText: 'Informasi Pelaku',
                  filled: true,
                  fillColor: kWhiteColor,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field ini harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _informasiKorbanController,
                decoration: InputDecoration(
                  labelText: 'Informasi Korban',
                  filled: true,
                  fillColor: kWhiteColor,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field ini harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _laporSebagaiValue,
                decoration: InputDecoration(
                  labelText: 'Melapor Sebagai',
                  filled: true,
                  fillColor: kWhiteColor,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _laporSebagaiValue = newValue;
                  });
                },
                items: <String>['Saksi', 'Korban']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field ini harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _areaKejadianValue,
                decoration: InputDecoration(
                  labelText: 'Area Kejadian',
                  filled: true,
                  fillColor: kWhiteColor,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _areaKejadianValue = newValue;
                  });
                },
                items: <String>['Diluar Kampus', 'Didalam Kampus']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field ini harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _tanggalKejadianDateTime == null
                          ? 'Pilih Tanggal Kejadian'
                          : ' ${_tanggalKejadianDateTime!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select date'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  _bukti == null
                      ? const Text('Upload Bukti')
                      : Expanded(
                          child: _isVideo
                              ? Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.black,
                                  child: Center(
                                    child: Icon(
                                      Icons.videocam,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Image.file(
                                  _bukti!,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                        ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: const Text('Upload File'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    postReport();
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                buttonText: 'Lapor',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
