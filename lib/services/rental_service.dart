import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/kendaraan_model.dart';
import '../models/transaksi_model.dart';
import 'dart:typed_data';

class RentalService {
  // Sesuaikan dengan alamat server lokal Anda (127.0.0.1 untuk Chrome, 10.0.2.2 untuk Emulator Android)
  static const String baseUrl = 'http://127.0.0.1/rental_api/api';
  static const String imageUrl = 'http://127.0.0.1/rental_api/uploads/';

  // 1. Fungsi Ambil Data Kendaraan (Beranda Pelanggan)
  static Future<List<Kendaraan>> fetchKendaraanTersedia() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_kendaraan.php'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          List<dynamic> listJson = data['data'];
          return listJson.map((json) => Kendaraan.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Gagal mengambil data kendaraan: $e');
    }
  }

  // 2. Fungsi Buat Pesanan (Pelanggan)
  static Future<Map<String, dynamic>> buatPesanan({
    required int idPelanggan,
    required int idKendaraan,
    required String tanggalSewa,
    required String tanggalKembali,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/buat_pesanan.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_pelanggan': idPelanggan,
          'id_kendaraan': idKendaraan,
          'tanggal_sewa': tanggalSewa,
          'tanggal_kembali': tanggalKembali,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal terhubung ke server'};
    }
  }

  // 3. Fungsi Ambil Semua Transaksi (Pelacakan Admin)
  static Future<List<Transaksi>> fetchSemuaTransaksi() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_transaksi.php'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          List<dynamic> listJson = data['data'];
          return listJson.map((json) => Transaksi.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Gagal mengambil data transaksi: $e');
    }
  }

  // 4. Fungsi Validasi Pembayaran (Admin)
  static Future<Map<String, dynamic>> validasiPembayaran(
    int? idPembayaran,
    String statusValidasi,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verifikasi_pembayaran.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_pembayaran':
              idPembayaran, // Menggunakan id_pembayaran sesuai permintaan PHP
          'status_validasi': statusValidasi,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal terhubung ke server'};
    }
  }

  // Tambahkan fungsi baru ini di bawah fungsi No. 4
  // 4B. Fungsi Selesaikan Pesanan (Admin)
  static Future<Map<String, dynamic>> selesaikanPesanan(int idTransaksi) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/selesaikan_pesanan.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_transaksi': idTransaksi}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal terhubung ke server'};
    }
  }

  // 5. Fungsi Tambah Master Mobil Baru (Admin)
  static Future<Map<String, dynamic>> tambahKendaraan({
    required String platNomor,
    required String merk,
    required String hargaSewa,
    Uint8List? imageBytes, // Ubah dari File? menjadi Uint8List?
    String? imageName, // Tambahkan parameter untuk nama file
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/tambah_kendaraan.php'),
      );
      request.fields['plat_nomor'] = platNomor;
      request.fields['merk'] = merk;
      request.fields['harga_sewa'] = hargaSewa;

      // Gunakan fromBytes agar mendukung Web dan Mobile
      if (imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'gambar',
            imageBytes,
            filename: imageName ?? 'mobil.jpg',
          ),
        );
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      return jsonDecode(responseData);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal terhubung ke server'};
    }
  }

  // 6. Fungsi Laporan Pendapatan (Dashboard Pimpinan)
  static Future<Map<String, dynamic>> fetchLaporanPendapatan({
    String? bulan,
    String? tahun,
  }) async {
    try {
      String url = '$baseUrl/laporan_pendapatan.php';
      if (bulan != null && tahun != null) {
        url += '?bulan=$bulan&tahun=$tahun';
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'Gagal mengambil data'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal terhubung ke server'};
    }
  }

  // 7. Fungsi Upload Bukti Pembayaran (Pelanggan)
  static Future<Map<String, dynamic>> uploadBuktiPembayaran({
    required int idTransaksi,
    required Uint8List imageBytes,
    required String imageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_pembayaran.php'),
      );

      // Kirim ID Transaksi sebagai teks
      request.fields['id_transaksi'] = idTransaksi.toString();

      // Kirim Gambar
      request.files.add(
        http.MultipartFile.fromBytes(
          'bukti_transfer',
          imageBytes,
          filename: imageName,
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      print("Balasan Server PHP: $responseData");
      return jsonDecode(responseData);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal terhubung ke server'};
    }
  }

  // 8. Fungsi Ambil Riwayat Pesanan Pelanggan
  static Future<List<Transaksi>> fetchRiwayatPesanan(int idPelanggan) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/riwayat_pesanan.php?id_pelanggan=$idPelanggan'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          List<dynamic> listJson = data['data'];
          return listJson.map((json) => Transaksi.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Gagal mengambil riwayat pesanan: $e');
    }
  }
}
