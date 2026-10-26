class Transaksi {
  final int idTransaksi;
  final String namaPelanggan;
  final String merkMobil;
  final String tanggalSewa;
  final String tanggalKembali;
  final int totalBiaya;
  final String statusPesanan;
  final int? idPembayaran; 

  Transaksi({
    required this.idTransaksi,
    required this.namaPelanggan,
    required this.merkMobil,
    required this.tanggalSewa,
    required this.tanggalKembali,
    required this.totalBiaya,
    required this.statusPesanan,
    this.idPembayaran,
  });

  factory Transaksi.fromJson(Map json) {
    return Transaksi(
      idTransaksi: int.parse(json['id_transaksi'].toString()),
      namaPelanggan: json['nama_lengkap'] ?? 'Tanpa Nama',
      merkMobil: json['merk'] ?? 'Mobil',
      tanggalSewa: json['tanggal_sewa'],
      tanggalKembali: json['tanggal_kembali'],
      totalBiaya: int.parse(json['total_biaya'].toString()),
      statusPesanan: json['status_pesanan'],
      idPembayaran: json['id_pembayaran'] != null ? int.parse(json['id_pembayaran'].toString()) : null,
    );
  }
}