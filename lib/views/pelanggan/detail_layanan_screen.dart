import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailLayananScreen extends StatelessWidget {
  const DetailLayananScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 73, 167, 101),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: const Color.fromARGB(
          255,
          31,
          71,
          40,
        ), 
        title: Text(
          "Informasi Layanan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Seksi Cara Memesan
            _buildSectionTitle("Cara Memesan Mobil"),
            _buildInfoCard(
              child: Column(
                children: [
                  _buildStepItem(
                    Icons.search,
                    "1. Pilih Mobil",
                    "Pilih mobil idaman Anda dari katalog di halaman utama.",
                  ),
                  const Divider(),
                  _buildStepItem(
                    Icons.date_range,
                    "2. Tentukan Tanggal",
                    "Masukkan tanggal mulai sewa dan tanggal pengembalian.",
                  ),
                  const Divider(),
                  _buildStepItem(
                    Icons.payment,
                    "3. Lakukan Pembayaran",
                    "Upload bukti transfer atau bayar di tempat sesuai kesepakatan.",
                  ),
                  const Divider(),
                  _buildStepItem(
                    Icons.key,
                    "4. Ambil Mobil",
                    "Admin akan memvalidasi, dan mobil siap Anda bawa jalan!",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Seksi Mobil yang Tersedia
            _buildSectionTitle("Ketersediaan Armada"),
            _buildInfoCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        56,
                        85,
                        51,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: Color.fromARGB(255, 56, 85, 51),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Beragam Pilihan Tipe",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          "Mulai dari mobil keluarga (MPV), City Car, hingga SUV tangguh. Silakan kembali ke Beranda untuk melihat katalog lengkap yang sedang 'Tersedia'.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Seksi Lokasi
            _buildSectionTitle("Lokasi Garasi Kami"),
            _buildInfoCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.redAccent,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rental Jaya Abadi",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          "Jl. Merdeka No. 123, Pusat Kota.\nBuka setiap hari: 08.00 - 20.00 WIB",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. Seksi Kontak & Sosial Media
            _buildSectionTitle("Hubungi Kami"),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                    
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text("WhatsApp"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                     
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Instagram"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32), 
          ],
        ),
      ),
    );
  }

 
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

 
  Widget _buildInfoCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }


  Widget _buildStepItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color.fromARGB(255, 56, 85, 51), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
