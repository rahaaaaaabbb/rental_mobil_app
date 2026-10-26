import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Sesuaikan dengan alamat server lokal Anda (127.0.0.1 untuk Chrome)
  static const String baseUrl = 'http://127.0.0.1/rental_api/api';

  // Fungsi Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal terhubung ke server'};
    }
  }

  // Fungsi Registrasi
  static Future<Map<String, dynamic>> register(
      String nama, String email, String password, String telepon, String alamat) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama_lengkap': nama,
          'email': email,
          'password': password,
          'no_telepon': telepon,
          'alamat': alamat,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal terhubung ke server'};
    }
  }
}