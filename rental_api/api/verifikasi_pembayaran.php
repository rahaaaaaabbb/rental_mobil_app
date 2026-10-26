<?php
// File: api/verifikasi_pembayaran.php
// Fungsi: Admin memvalidasi pembayaran, lalu sistem mengotomatisasi perubahan status pesanan dan ketersediaan armada

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include '../config/koneksi.php';

// Menangkap data JSON yang dikirimkan oleh aplikasi Admin
$data = json_decode(file_get_contents("php://input"));

// Validasi input agar tidak ada parameter yang kosong
if (!empty($data->id_pembayaran) && !empty($data->status_validasi)) {
    
    $id_pembayaran   = (int) $data->id_pembayaran;
    // Parameter yang diharapkan masuk adalah 'Valid' atau 'Ditolak'
    $status_validasi = mysqli_real_escape_string($koneksi, $data->status_validasi); 

    // 1. Eksekusi pertama: Update hasil tinjauan admin di tabel pembayaran
    $query_update_bayar = "UPDATE pembayaran SET status_validasi = '$status_validasi' WHERE id_pembayaran = $id_pembayaran";

    if (mysqli_query($koneksi, $query_update_bayar)) {
        
        // Cari id_transaksi yang terikat dengan pembayaran ini
        $q_transaksi = mysqli_query($koneksi, "SELECT id_transaksi FROM pembayaran WHERE id_pembayaran = $id_pembayaran");
        
        if (mysqli_num_rows($q_transaksi) > 0) {
            $row_trans = mysqli_fetch_assoc($q_transaksi);
            $id_transaksi = $row_trans['id_transaksi'];

            if ($status_validasi == 'Valid') {
                // 2A. Jika VALID: Ubah status pesanan menjadi 'Berjalan'
                mysqli_query($koneksi, "UPDATE transaksi SET status_pesanan = 'Berjalan' WHERE id_transaksi = $id_transaksi");

                // 3A. Cari unit mobil yang disewa pada transaksi ini
                $q_kendaraan = mysqli_query($koneksi, "SELECT id_kendaraan FROM transaksi WHERE id_transaksi = $id_transaksi");
                if (mysqli_num_rows($q_kendaraan) > 0) {
                    $row_kend = mysqli_fetch_assoc($q_kendaraan);
                    $id_kendaraan = $row_kend['id_kendaraan'];

                    // 4A. Ubah status fisik mobil menjadi 'Disewa' agar hilang dari katalog publik
                    mysqli_query($koneksi, "UPDATE kendaraan SET status = 'Disewa' WHERE id_kendaraan = $id_kendaraan");
                }
            } else if ($status_validasi == 'Ditolak') {
                // 2B. Jika DITOLAK: Kembalikan status transaksi agar pelanggan bisa mengunggah ulang
                mysqli_query($koneksi, "UPDATE transaksi SET status_pesanan = 'Menunggu Pembayaran' WHERE id_transaksi = $id_transaksi");
            }
        }

        echo json_encode([
            "status" => "success", 
            "message" => "Validasi pembayaran berhasil dieksekusi, status pesanan telah diperbarui."
        ]);

    } else {
        echo json_encode([
            "status" => "error", 
            "message" => "Gagal memproses validasi pembayaran ke dalam database."
        ]);
    }
} else {
    echo json_encode([
        "status" => "error", 
        "message" => "Data tidak lengkap. id_pembayaran dan status_validasi wajib dikirimkan."
    ]);
}

mysqli_close($koneksi);
?>