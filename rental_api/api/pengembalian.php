<?php
// File: api/pengembalian.php
// Fungsi: Admin memproses pengembalian mobil, menyelesaikan transaksi, dan merilis kembali mobil ke katalog
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
include '../config/koneksi.php';

// Menangkap data JSON yang dikirimkan oleh aplikasi Admin
$data = json_decode(file_get_contents("php://input"));

// Validasi input wajib
if (!empty($data->id_transaksi) && !empty($data->kondisi_mobil)) {
    
    $id_transaksi   = (int) $data->id_transaksi;
    $kondisi_mobil  = mysqli_real_escape_string($koneksi, $data->kondisi_mobil);
    // Jika tidak ada biaya tambahan/denda, nilai defaultnya adalah 0
    $biaya_tambahan = isset($data->biaya_tambahan) ? (int) $data->biaya_tambahan : 0;
    
    // Ambil waktu saat tombol pengembalian ditekan oleh admin
    $tanggal_aktual = date("Y-m-d H:i:s"); 

    // 1. Eksekusi Pertama: Simpan pencatatan pengembalian
    $query_pengembalian = "INSERT INTO pengembalian (id_transaksi, tanggal_aktual, kondisi_mobil, biaya_tambahan) 
                           VALUES ($id_transaksi, '$tanggal_aktual', '$kondisi_mobil', $biaya_tambahan)";

    if (mysqli_query($koneksi, $query_pengembalian)) {
        
        // 2. Eksekusi Kedua: Tutup siklus penyewaan dengan mengubah status transaksi jadi 'Selesai'
        mysqli_query($koneksi, "UPDATE transaksi SET status_pesanan = 'Selesai' WHERE id_transaksi = $id_transaksi");

        // 3. Eksekusi Ketiga: Cari tahu mobil mana yang tadi disewa pada transaksi ini
        $q_kendaraan = mysqli_query($koneksi, "SELECT id_kendaraan FROM transaksi WHERE id_transaksi = $id_transaksi");
        
        if (mysqli_num_rows($q_kendaraan) > 0) {
            $row_kend = mysqli_fetch_assoc($q_kendaraan);
            $id_kendaraan = $row_kend['id_kendaraan'];

            // Rilis kembali ketersediaan mobil ke publik ('Tersedia')
            mysqli_query($koneksi, "UPDATE kendaraan SET status = 'Tersedia' WHERE id_kendaraan = $id_kendaraan");
        }

        echo json_encode([
            "status" => "success", 
            "message" => "Proses pengembalian berhasil. Transaksi selesai dan mobil sudah kembali tersedia di katalog."
        ]);

    } else {
        echo json_encode([
            "status" => "error", 
            "message" => "Gagal menyimpan data pengembalian ke database."
        ]);
    }
} else {
    echo json_encode([
        "status" => "error", 
        "message" => "Data tidak lengkap. ID Transaksi dan Kondisi Mobil wajib diisi."
    ]);
}

mysqli_close($koneksi);
?>