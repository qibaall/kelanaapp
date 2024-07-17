import 'package:dio/dio.dart';
import 'package:kelanaapp/models/report.dart';
import 'package:logger/logger.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl =
      'https://kelanaadmin.online/api'; // Sesuaikan dengan URL API Anda
  final Logger _logger = Logger();

  ApiService() {
    // Tambahkan interceptor atau pengaturan tambahan jika diperlukan
  }

  Future<Response> login(String email, String password) async {
    try {
      Response response = await _dio.post('$baseUrl/login', data: {
        'email': email,
        'password': password,
      });
      return response;
    } catch (e) {
      _logger.e('Error: $e');
      rethrow; // Anda bisa menangani error lebih lanjut di UI
    }
  }

  Future<Response> register({
    required String name,
    required String email,
    required String password,
    required String jurusan,
    required String prodi,
    required String kelas,
    required String noHp,
  }) async {
    try {
      Response response = await _dio.post(
        '$baseUrl/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'jurusan': jurusan,
          'prodi': prodi,
          'kelas': kelas,
          'no_hp': noHp,
        },
        options: Options(
          followRedirects: false,
          validateStatus: (status) => true, // Accept all status codes
        ),
      );
      return response;
    } catch (e) {
      _logger.e('Error: $e');
      rethrow; // Anda bisa menangani error lebih lanjut di UI
    }
  }

  Future<Response> getProfile(String token) async {
    try {
      // Menambahkan token ke header Authorization
      _dio.options.headers["Authorization"] = "Bearer $token";
      Response response = await _dio.get('$baseUrl/profile');
      return response;
    } catch (e) {
      _logger.e('Error: $e');
      throw Exception(e);
    }
  }

  Future<Response> postReport({
    required Report report,
    required String token,
  }) async {
    try {
      _dio.options.headers["Authorization"] = "Bearer $token";

      FormData reportFormData = FormData.fromMap(
        {
          'user_id': report.userId,
          'lpr_sebagai': report.lprSebagai,
          'tgl_kejadian': report.tglKejadian,
          'kronologi': report.kronologi,
          'area_kejadian': report.areaKejadian,
          'bentuk_kekerasan': report.bentukKekerasan,
          'informasi_pelaku': report.informasiPelaku,
          'informasi_korban': report.informasiKorban,
          'bukti': report.bukti,
        },
      );

      Response response = await _dio.post(
        '$baseUrl/reports',
        data: reportFormData,
      );

      return response;
    } catch (e) {
      _logger.e('Error: $e');
      throw Exception(e);
    }
  }

  Future<Response> getReportHistory(String token) async {
    return await _dio.get(
      '$baseUrl/history',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }
}
