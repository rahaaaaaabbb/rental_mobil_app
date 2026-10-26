<?php
// 1. Izinkan akses CORS untuk Flutter Web / Edge
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json");

// 2. Tangkap request pemanasan (Preflight OPTIONS) dari browser dan langsung izinkan
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') { 
    http_response_code(200); 
    exit(); 
}

include 'koneksi.php';

// Ambil data JSON yang dikirim dari Flutter
$data = json_decode(file_get_contents("php://input"));

if (isset($data->id_transaksi)) {
    $id = $data->id_transaksi;

    // A. Ubah status transaksi menjadi Selesai
    $query = "UPDATE transaksi SET status_pesanan = 'Selesai' WHERE id_transaksi = '$id'";
    
    if (mysqli_query($koneksi, $query)) {
        
        // B. Cari ID mobil yang disewa pada transaksi ini
        $q_kendaraan = mysqli_query($koneksi, "SELECT id_kendaraan FROM transaksi WHERE id_transaksi = '$id'");
        if(mysqli_num_rows($q_kendaraan) > 0) {
            $row_kend = mysqli_fetch_assoc($q_kendaraan);
            $id_kendaraan = $row_kend['id_kendaraan'];
            
            // C. Kembalikan status fisik mobil menjadi 'Tersedia' agar muncul lagi di katalog
            mysqli_query($koneksi, "UPDATE kendaraan SET status = 'Tersedia' WHERE id_kendaraan = '$id_kendaraan'");
        }
        
        echo json_encode(["status" => "success", "message" => "Transaksi Selesai! Kendaraan telah dikembalikan ke garasi."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Gagal update: " . mysqli_error($koneksi)]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Data tidak lengkap. ID Transaksi tidak ditemukan."]);
}
?>