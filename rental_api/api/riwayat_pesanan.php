<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

include 'koneksi.php';

// Memastikan ID pelanggan dikirim oleh aplikasi
if (isset($_GET['id_pelanggan'])) {
    $id_pelanggan = $_GET['id_pelanggan'];

    // Mengambil riwayat transaksi khusus untuk ID pelanggan tersebut
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
              WHERE t.id_pelanggan = '$id_pelanggan'
              ORDER BY t.id_transaksi DESC";

    $result = mysqli_query($koneksi, $query);
    $data = array();
    
    if ($result) {
        while ($row = mysqli_fetch_assoc($result)) {
            $data[] = $row;
        }
        echo json_encode(["status" => "success", "data" => $data]);
    } else {
        echo json_encode(["status" => "error", "message" => "Gagal mengambil data: " . mysqli_error($koneksi)]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "ID Pelanggan tidak disertakan"]);
}
?>