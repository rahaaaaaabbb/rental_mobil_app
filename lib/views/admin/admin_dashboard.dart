import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/transaksi_model.dart';
import '../../services/rental_service.dart';
import 'tambah_kendaraan_screen.dart';
import '../auth/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

// Perbaikan: Menambahkan <AdminDashboard> yang sebelumnya hilang
class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Perbaikan: Menambahkan <List<Transaksi>> yang sebelumnya menjadi 'Future>'
  late Future<List<Transaksi>> _futureTransaksi;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _muatData();
  }

  void _muatData() {
    setState(() {
      _futureTransaksi = RentalService.fetchSemuaTransaksi();
    });
  }

  void _prosesValidasi(int? idPembayaran, String status) async {
    // Karena PHP wajib meminta id_pembayaran, kita cegah error jika data kosong
    if (idPembayaran == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Belum ada ID Pembayaran dari pelanggan!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    var response = await RentalService.validasiPembayaran(idPembayaran, status);

    // ignore: use_build_context_synchronously
    if (!mounted) return;
    Navigator.pop(context); // Tutup loading

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.green,
        ),
      );
      _muatData(); // Refresh data pelacakan
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 58, 46),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Pelacakan Transaksi",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Tambahkan blok actions ini:
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Logout',
            onPressed: () {
              // Fungsi untuk menghapus riwayat halaman dan kembali ke Login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route route) => false,
              );
            },
          ),
        ],
        // ... (kode bottom: TabBar tetap sama)
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color.fromARGB(255, 28, 73, 35),
          unselectedLabelColor: const Color.fromARGB(255, 22, 20, 20),
          indicatorColor: const Color.fromARGB(255, 26, 255, 122),
          tabs: const [
            Tab(text: "Menunggu"),
            Tab(text: "Berjalan"),
            Tab(text: "Selesai"),
          ],
        ),
      ),
      // Perbaikan: Menambahkan <List<Transaksi>>
      body: FutureBuilder<List<Transaksi>>(
        future: _futureTransaksi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Gagal memuat: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada data transaksi."));
          }

          // Perbaikan: Mengembalikan <Transaksi> yang terhapus
          List<Transaksi> semuaTransaksi = snapshot.data!;

          List<Transaksi> listMenunggu = semuaTransaksi
              .where(
                (t) =>
                    t.statusPesanan == 'Menunggu Pembayaran' ||
                    t.statusPesanan == 'Dibayar',
              )
              .toList();
          List<Transaksi> listBerjalan = semuaTransaksi
              .where((t) => t.statusPesanan == 'Berjalan')
              .toList();
          List<Transaksi> listSelesai = semuaTransaksi
              .where((t) => t.statusPesanan == 'Selesai')
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildListTransaksi(listMenunggu, isMenunggu: true),
              _buildListTransaksi(listBerjalan, isBerjalan: true),
              _buildListTransaksi(listSelesai),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2B2E4A),
        // Menggunakan icon plus (tambah) standar
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Navigasi ke Halaman Tambah Kendaraan Baru
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahKendaraanScreen(),
            ),
          );
        },
      ),
    );
  }

  // Perbaikan: Mengembalikan <Transaksi> pada parameter list
  Widget _buildListTransaksi(
    List<Transaksi> list, {
    bool isMenunggu = false,
    bool isBerjalan = false,
  }) {
    if (list.isEmpty)
      return const Center(child: Text("Tidak ada data di kategori ini."));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final trx = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "#TRX-${trx.idTransaksi}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Chip(
                      label: Text(
                        trx.statusPesanan,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 243, 245, 244),
                        ),
                      ),
                      backgroundColor: _getStatusColor(trx.statusPesanan),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  trx.namaPelanggan,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Mobil: ${trx.merkMobil}",
                  style: const TextStyle(color: Colors.black87),
                ),
                Text(
                  "Durasi: ${trx.tanggalSewa} s/d ${trx.tanggalKembali}",
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Text(
                  "Total: Rp ${trx.totalBiaya}",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color.fromARGB(255, 36, 122, 96),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Tombol aksi untuk Tab "Menunggu"
                if (isMenunggu &&
                    trx.statusPesanan == 'Dibayar' &&
                    trx.idPembayaran != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () =>
                              _prosesValidasi(trx.idPembayaran, 'Ditolak'),
                          child: const Text("Batalkan"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: const Color.fromARGB(
                              255,
                              33,
                              119,
                              41,
                            ),
                          ),
                          onPressed: () =>
                              _prosesValidasi(trx.idPembayaran, 'Valid'),
                          child: const Text("Jalankan"),
                        ),
                      ),
                    ],
                  ),
                ],
                // Tombol aksi untuk Tab "Berjalan"
                if (isBerjalan) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B2E4A),
                      ),
                      onPressed: () async {
                        // Tampilkan loading
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        // Panggil API selesaikan pesanan
                        var response = await RentalService.selesaikanPesanan(
                          trx.idTransaksi,
                        );

                        // ignore: use_build_context_synchronously
                        Navigator.pop(context); // Tutup loading

                        if (response['status'] == 'success') {
                          _muatData(); // Refresh layar
                        }
                      },
                      child: const Text("Mobil Dikembalikan (Selesai)"),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Menunggu Pembayaran':
        return Colors.orange;
      case 'Dibayar':
        return Colors.blue;
      case 'Berjalan':
        return Colors.green;
      case 'Selesai':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
