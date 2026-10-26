import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/kendaraan_model.dart';
import '../../services/rental_service.dart';

class DetailScreen extends StatefulWidget {
  final Kendaraan mobil;

  const DetailScreen({super.key, required this.mobil});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  DateTime? _tanggalSewa;
  DateTime? _tanggalKembali;
  int _totalBiaya = 0;
  bool _isLoading = false;

  void _kalkulasiHarga() {
    if (_tanggalSewa != null && _tanggalKembali != null) {
      int durasi = _tanggalKembali!.difference(_tanggalSewa!).inDays;
      if (durasi == 0) durasi = 1;

      setState(() {
        _totalBiaya = durasi * widget.mobil.hargaSewa;
      });
    }
  }

  Future<void> _pilihTanggal(BuildContext context, bool isSewa) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: isSewa ? DateTime.now() : (_tanggalSewa ?? DateTime.now()),
      firstDate: isSewa ? DateTime.now() : (_tanggalSewa ?? DateTime.now()),
      lastDate: DateTime(2030),
    );
    if (d != null) {
      setState(() {
        if (isSewa) {
          _tanggalSewa = d;
          if (_tanggalKembali != null &&
              _tanggalKembali!.isBefore(_tanggalSewa!)) {
            _tanggalKembali = null;
          }
        } else {
          _tanggalKembali = d;
        }
      });
      _kalkulasiHarga();
    }
  }

  void _prosesBooking() async {
    if (_tanggalSewa == null || _tanggalKembali == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Silakan pilih tanggal sewa dan kembali terlebih dahulu.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    String tglSewaFormat =
        "${_tanggalSewa!.year}-${_tanggalSewa!.month.toString().padLeft(2, '0')}-${_tanggalSewa!.day.toString().padLeft(2, '0')}";
    String tglKembaliFormat =
        "${_tanggalKembali!.year}-${_tanggalKembali!.month.toString().padLeft(2, '0')}-${_tanggalKembali!.day.toString().padLeft(2, '0')}";

    int idPelangganSesiSaatIni = 1;

    var response = await RentalService.buatPesanan(
      idPelanggan: idPelangganSesiSaatIni,
      idKendaraan: widget.mobil.idKendaraan,
      tanggalSewa: tglSewaFormat,
      tanggalKembali: tglKembaliFormat,
    );

    // ignore: use_build_context_synchronously
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: Text(
          "Detail Kendaraan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: widget.mobil.gambar.isNotEmpty
                          ? Image.network(
                              '${RentalService.imageUrl}${widget.mobil.gambar}',
                              fit: BoxFit.contain,
                            )
                          : const Icon(
                              Icons.directions_car,
                              size: 100,
                              color: Colors.grey,
                            ),
                    ).animate().fade().slideY(begin: 0.2, end: 0),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    widget.mobil.merk,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Plat Nomor: ${widget.mobil.platNomor}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Rp ${widget.mobil.hargaSewa} / Hari",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: const Color(0xFFE84545),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    "Tentukan Jadwal Sewa",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _pilihTanggal(context, true),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 241, 245, 243),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Mulai Sewa",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _tanggalSewa != null
                                      ? "${_tanggalSewa!.day}/${_tanggalSewa!.month}/${_tanggalSewa!.year}"
                                      : "Pilih Tanggal",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _pilihTanggal(context, false),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Kembali",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _tanggalKembali != null
                                      ? "${_tanggalKembali!.day}/${_tanggalKembali!.month}/${_tanggalKembali!.year}"
                                      : "Pilih Tanggal",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Tagihan",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      "Rp $_totalBiaya",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _prosesBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B2E4A),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Pesan Sekarang",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ],
            ),
          ).animate().slideY(begin: 1, end: 0, duration: 400.ms),
        ],
      ),
    );
  }
}
