<?php
// File: api/laporan_pendapatan.php
// Fungsi: Menghasilkan rekapitulasi data transaksi selesai sebagai laporan pendapatan digital untuk Pimpinan
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include '../config/koneksi.php';

// Menangkap filter bulan dan tahun jika Pimpinan ingin melihat laporan bulan tertentu (opsional)
$bulan = isset($_GET['bulan']) ? mysqli_real_escape_string($koneksi, $_GET['bulan']) : '';
$tahun = isset($_GET['tahun']) ? mysqli_real_escape_string($koneksi, $_GET['tahun']) : '';

// 1. Susun Query dasar: Menggabungkan (JOIN) tabel transaksi, pelanggan, kendaraan, dan pengembalian
$query = "SELECT 
            t.id_transaksi, 
            t.tanggal_pesan, 
            t.tanggal_sewa, 
            t.tanggal_kembali, 
            p.nama_lengkap AS nama_penyewa, 
            k.merk AS mobil, 
            k.plat_nomor, 
            pg.tanggal_aktual AS tanggal_dikembalikan,
            t.total_biaya AS biaya_sewa,
            IFNULL(pg.biaya_tambahan, 0) AS biaya_tambahan,
            (t.total_biaya + IFNULL(pg.biaya_tambahan, 0)) AS total_pendapatan_bersih
          FROM transaksi t
          JOIN pelanggan p ON t.id_pelanggan = p.id_pelanggan
          JOIN kendaraan k ON t.id_kendaraan = k.id_kendaraan
          LEFT JOIN pengembalian pg ON t.id_transaksi = pg.id_transaksi
          WHERE t.status_pesanan = 'Selesai'";

// 2. Tambahkan filter bulan dan tahun jika dikirimkan oleh aplikasi
if (!empty($bulan) && !empty($tahun)) {
    // Memfilter berdasarkan tanggal sewa di bulan dan tahun yang diminta
    $query .= " AND MONTH(t.tanggal_sewa) = '$bulan' AND YEAR(t.tanggal_sewa) = '$tahun'";
}

// Urutkan dari transaksi terbaru selesai
$query .= " ORDER BY pg.tanggal_aktual DESC";

$result = mysqli_query($koneksi, $query);

if (mysqli_num_rows($result) > 0) {
    $laporan_data = array();
    $akumulasi_total = 0; // Variabel untuk menghitung total pendapatan keseluruhan

    while ($row = mysqli_fetch_assoc($result)) {
        $laporan_data[] = $row;
        // Menambahkan total bersih tiap transaksi ke akumulasi total
        $akumulasi_total += $row['total_pendapatan_bersih']; 
    }

    // 3. Keluarkan format respons JSON yang siap dirender menjadi grafik/tabel di layar Pimpinan
    echo json_encode([
        "status" => "success",
        "message" => "Laporan pendapatan berhasil ditarik.",
        "periode" => (!empty($bulan) && !empty($tahun)) ? "$bulan-$tahun" : "Semua Waktu",
        "akumulasi_pendapatan" => $akumulasi_total,
        "jumlah_transaksi" => mysqli_num_rows($result),
        "data_transaksi" => $laporan_data
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Belum ada data transaksi yang selesai pada periode ini.",
        "akumulasi_pendapatan" => 0,
        "jumlah_transaksi" => 0,
        "data_transaksi" => []
    ]);
}

// 4. Tutup Koneksi
mysqli_close($koneksi);
?>