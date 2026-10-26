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

// Pastikan semua data yang dibutuhkan dikirim oleh aplikasi
if (isset($data->id_pelanggan) && isset($data->id_kendaraan) && isset($data->tanggal_sewa) && isset($data->tanggal_kembali)) {
    
    $id_pelanggan = $data->id_pelanggan;
    $id_kendaraan = $data->id_kendaraan;
    $tanggal_sewa = $data->tanggal_sewa;
    $tanggal_kembali = $data->tanggal_kembali;
    
    // A. Ambil harga sewa per hari dari database (agar aman, tidak percaya begitu saja dari aplikasi)
    $query_kendaraan = mysqli_query($koneksi, "SELECT harga_sewa FROM kendaraan WHERE id_kendaraan = '$id_kendaraan'");
    $kendaraan = mysqli_fetch_assoc($query_kendaraan);
    
    if (!$kendaraan) {
        echo json_encode(["status" => "error", "message" => "Kendaraan tidak ditemukan!"]);
        exit();
    }
    
    $harga_per_hari = $kendaraan['harga_sewa'];
    
    // B. Hitung durasi hari
    $tgl1 = new DateTime($tanggal_sewa);
    $tgl2 = new DateTime($tanggal_kembali);
    $jarak = $tgl2->diff($tgl1)->days;
    $durasi = ($jarak == 0) ? 1 : $jarak; // Jika sewa dan kembali di hari yang sama, dihitung 1 hari
    
    // C. Hitung total biaya
    $total_biaya = $durasi * $harga_per_hari;
    $status = "Menunggu Pembayaran";
    
    // D. Simpan ke tabel transaksi
    $query_insert = "INSERT INTO transaksi (id_pelanggan, id_kendaraan, tanggal_sewa, tanggal_kembali, total_biaya, status_pesanan) 
                     VALUES ('$id_pelanggan', '$id_kendaraan', '$tanggal_sewa', '$tanggal_kembali', '$total_biaya', '$status')";
                     
    if (mysqli_query($koneksi, $query_insert)) {
        echo json_encode(["status" => "success", "message" => "Pesanan berhasil dibuat!"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Gagal membuat pesanan: " . mysqli_error($koneksi)]);
    }

} else {
    echo json_encode(["status" => "error", "message" => "Data pemesanan tidak lengkap!"]);
}
?>