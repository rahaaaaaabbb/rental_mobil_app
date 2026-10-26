import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/transaksi_model.dart';
import '../../services/rental_service.dart';
import 'upload_pembayaran_screen.dart';

class RiwayatScreen extends StatefulWidget {
  final int idPelanggan;
  const RiwayatScreen({super.key, required this.idPelanggan});

  @override
  _RiwayatScreenState createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  late Future<List<Transaksi>> _futureRiwayat;

  @override
  void initState() {
    super.initState();
    _muatRiwayat();
  }

  void _muatRiwayat() {
    setState(() {
      _futureRiwayat = RentalService.fetchRiwayatPesanan(widget.idPelanggan);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 45, 90, 53),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 244, 245, 244),
        elevation: 1,
        foregroundColor: Colors.black87,
        title: Text(
          "Riwayat Pesanan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Transaksi>>(
        future: _futureRiwayat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Gagal memuat: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Anda belum memiliki riwayat pesanan."),
            );
          }

          List<Transaksi> listRiwayat = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listRiwayat.length,
            itemBuilder: (context, index) {
              final trx = listRiwayat[index];
              return _buildRiwayatCard(trx)
                  .animate()
                  .fade(delay: (100 * index).ms)
                  .slideY(begin: 0.1, end: 0);
            },
          );
        },
      ),
    );
  }

  Widget _buildRiwayatCard(Transaksi trx) {
    bool butuhBayar = trx.statusPesanan == 'Menunggu Pembayaran';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(trx.statusPesanan),
                ),
              ],
            ),
            const Divider(),
            Text(
              "Mobil: ${trx.merkMobil}",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Durasi: ${trx.tanggalSewa} s/d ${trx.tanggalKembali}",
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              "Total Tagihan: Rp ${trx.totalBiaya}",
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Color.fromARGB(255, 45, 90, 53),
                fontWeight: FontWeight.bold,
              ),
            ),

            if (butuhBayar) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B2E4A),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UploadPembayaranScreen(transaksi: trx),
                      ),
                    ).then((_) => _muatRiwayat());
                  },
                  child: const Text("Bayar Sekarang"),
                ),
              ),
            ],
          ],
        ),
      ),
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
