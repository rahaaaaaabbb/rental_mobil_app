<?php
// Izinkan akses CORS untuk Flutter Web / Edge
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

include 'koneksi.php';

// Query untuk mengambil data transaksi beserta detail pelanggan dan kendaraan
$query = "SELECT 
            t.id_transaksi, 
            p.nama_lengkap, 
            k.merk, 
            t.tanggal_sewa, 
            t.tanggal_kembali, 
            t.total_biaya, 
            t.status_pesanan, 
            t.id_pembayaran 
          FROM transaksi t
          JOIN pelanggan p ON t.id_pelanggan = p.id_pelanggan
          JOIN kendaraan k ON t.id_kendaraan = k.id_kendaraan
          ORDER BY t.id_transaksi DESC"; // Mengurutkan dari transaksi terbaru

$result = mysqli_query($koneksi, $query);

if ($result) {
    $data = array();
    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = $row;
    }
    
    echo json_encode([
        "status" => "success",
        "data" => $data
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Gagal mengambil data transaksi: " . mysqli_error($koneksi)
    ]);
}
?>