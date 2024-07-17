import 'package:dio/dio.dart';

class Report {
  final int userId;
  final String lprSebagai;
  final String tglKejadian;
  final String areaKejadian;
  final String kronologi;
  final String bentukKekerasan;
  final String informasiPelaku;
  final String informasiKorban;
  final MultipartFile bukti;

  Report({
    required this.userId,
    required this.lprSebagai,
    required this.tglKejadian,
    required this.areaKejadian,
    required this.kronologi,
    required this.bentukKekerasan,
    required this.informasiPelaku,
    required this.informasiKorban,
    required this.bukti,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'lpr_sebagai': lprSebagai,
      'tgl_kejadian': tglKejadian,
      'area_kejadian': areaKejadian,
      'kronologi': kronologi,
      'bentuk_kekerasan': bentukKekerasan,
      'informasi_pelaku': informasiPelaku,
      'informasi_korban': informasiKorban,
      'bukti': bukti.toString(),
    };
  }
}
