import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/rental_service.dart';
import '../auth/login_screen.dart';

class PimpinanDashboard extends StatefulWidget {
  const PimpinanDashboard({super.key});

  @override
  _PimpinanDashboardState createState() => _PimpinanDashboardState();
}


class _PimpinanDashboardState extends State<PimpinanDashboard> {
  late Future<Map<String, dynamic>> _futureLaporan;

  @override
  void initState() {
    super.initState();
    _muatLaporan();
  }

  void _muatLaporan() {
    setState(() {
      _futureLaporan = RentalService.fetchLaporanPendapatan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 48, 102, 66),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 245, 243, 243),
        elevation: 0,
        title: Text(
          "Dashboard Analitik",
          style: GoogleFonts.poppins(
            color: const Color.fromARGB(221, 241, 240, 240),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Color.fromARGB(221, 236, 234, 234),
            ),
            tooltip: 'Segarkan',
            onPressed: _muatLaporan,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route route) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureLaporan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }

          final data = snapshot.data;

          if (data == null || data['status'] == 'error') {
            return Center(
              child: Text(data?['message'] ?? 'Gagal memuat laporan'),
            );
          }

          final int totalPendapatan = data['akumulasi_pendapatan'] ?? 0;
          final int jumlahTransaksi = data['jumlah_transaksi'] ?? 0;


          final List<dynamic> listTransaksi = data['data_transaksi'] ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(
                totalPendapatan,
                jumlahTransaksi,
              ).animate().fade().slideY(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Riwayat Transaksi Selesai",
                  style: GoogleFonts.poppins(
                    color: Color.fromARGB(221, 236, 234, 234),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: listTransaksi.isEmpty
                    ? const Center(
                        child: Text("Belum ada transaksi yang selesai."),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        itemCount: listTransaksi.length,
                        itemBuilder: (context, index) {
                          final item = listTransaksi[index];
                          return _buildTransactionItem(item)
                              .animate()
                              .fade(delay: (50 * index).ms)
                              .slideX(begin: 0.1, end: 0);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(int total, int jumlah) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 39, 201, 133),
            Color.fromARGB(255, 15, 92, 44),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 36, 114, 68).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Pendapatan Bersih",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "Rp $total",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Transaksi",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "$jumlah Selesai",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    35,
                    150,
                    111,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Colors.greenAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Semua Waktu",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> item) {
    // SABUK PENGAMAN: Cek panjang teks sebelum dipotong
    String tglKembali = item['tanggal_kembali']?.toString() ?? '-';
    String tglAman = tglKembali.length >= 10
        ? tglKembali.substring(0, 10)
        : tglKembali;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 32, 119, 61),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 245, 244, 244).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_outline, color: Colors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama_penyewa'],
                  style: GoogleFonts.poppins(
                    color: Color.fromARGB(221, 236, 234, 234),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "${item['mobil']} (${item['plat_nomor']})",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 252, 251, 251),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Dikembalikan: $tglAman",
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Rp ${item['total_pendapatan_bersih']}",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 255, 254, 254),
                ),
              ),
              if (item['biaya_tambahan'] != null &&
                  int.parse(item['biaya_tambahan'].toString()) > 0)
                Text(
                  "+ Denda Rp ${item['biaya_tambahan']}",
                  style: const TextStyle(color: Colors.orange, fontSize: 11),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
