// File: lib/models/kendaraan_model.dart

class Kendaraan {
  final int idKendaraan;
  final String platNomor;
  final String merk;
  final int hargaSewa;
  final String status;
  final String gambar;

  Kendaraan({
    required this.idKendaraan,
    required this.platNomor,
    required this.merk,
    required this.hargaSewa,
    required this.status,
    required this.gambar,
  });

  factory Kendaraan.fromJson(Map json) {
    return Kendaraan(
      idKendaraan: int.parse(json['id_kendaraan'].toString()),
      platNomor: json['plat_nomor'],
      merk: json['merk'],
      hargaSewa: int.parse(json['harga_sewa'].toString()),
      status: json['status'],
      gambar: json['gambar'] ?? '',
    );
  }
}