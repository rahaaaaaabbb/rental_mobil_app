import 'dart:typed_data'; // Menggantikan dart:io
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/rental_service.dart';

class TambahKendaraanScreen extends StatefulWidget {
  const TambahKendaraanScreen({super.key});

  @override
  _TambahKendaraanScreenState createState() => _TambahKendaraanScreenState();
}

class _TambahKendaraanScreenState extends State<TambahKendaraanScreen> {
  final TextEditingController _platController = TextEditingController();
  final TextEditingController _merkController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageName;

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Fungsi untuk memilih gambar
  Future<void> _pilihGambar() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = pickedFile.name;
      });
    }
  }

  // Fungsi mengeksekusi penyimpanan
  void _simpanKendaraan() async {
    if (_platController.text.isEmpty ||
        _merkController.text.isEmpty ||
        _hargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap isi seluruh kolom form."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    var response = await RentalService.tambahKendaraan(
      platNomor: _platController.text,
      merk: _merkController.text,
      hargaSewa: _hargaController.text,
      imageBytes: _imageBytes,
      imageName: _imageName,
    );

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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2B2E4A)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: Text(
          "Tambah Master Mobil",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pilihGambar,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Ketuk untuk unggah foto mobil",
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),

            _buildTextField("Plat Nomor (Contoh: Z 1234 AB)", _platController),
            _buildTextField("Merek / Tipe Mobil", _merkController),
            _buildTextField(
              "Harga Sewa per Hari (Rp)",
              _hargaController,
              type: TextInputType.number,
            ),

            const SizedBox(height: 24),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _simpanKendaraan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE84545),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Simpan Data Kendaraan",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
