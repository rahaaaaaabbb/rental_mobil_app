<?php
// 1. Izin CORS yang diperlengkap (Sangat penting untuk upload file di Web)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Accept");
header("Content-Type: application/json");

// Tangkap request pemanasan (Preflight OPTIONS)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') { 
    http_response_code(200); 
    exit(); 
}

include 'koneksi.php';

// 2. Fitur Pengaman: Cek jika ukuran gambar melebihi batas settingan XAMPP (biasanya 2MB)
if (empty($_POST) && empty($_FILES) && isset($_SERVER['CONTENT_LENGTH']) && $_SERVER['CONTENT_LENGTH'] > 0) {
    echo json_encode(["status" => "error", "message" => "Ukuran gambar terlalu besar! Harap pilih gambar di bawah 2MB."]);
    exit();
}

// Pastikan data yang dikirim Flutter tidak kosong
if (isset($_POST['id_transaksi']) && isset($_FILES['bukti_transfer'])) {
    $id_transaksi = $_POST['id_transaksi'];
    
    // Proses upload gambar
    $target_dir = "../uploads/";
    if (!is_dir($target_dir)) { mkdir($target_dir, 0777, true); }
    
    $file_extension = pathinfo($_FILES["bukti_transfer"]["name"], PATHINFO_EXTENSION);
    $new_filename = "bukti_" . time() . "_" . uniqid() . "." . $file_extension;
    $target_file = $target_dir . $new_filename;

    if (move_uploaded_file($_FILES["bukti_transfer"]["tmp_name"], $target_file)) {
        
        // Simpan ke tabel pembayaran
        $query_bayar = "INSERT INTO pembayaran (id_transaksi, bukti_pembayaran, status_validasi) 
                        VALUES ('$id_transaksi', '$new_filename', 'Menunggu')";
        
        if (mysqli_query($koneksi, $query_bayar)) {
            $id_pembayaran = mysqli_insert_id($koneksi);
            
            // Ubah status pesanan
            $query_transaksi = "UPDATE transaksi 
                                SET status_pesanan = 'Dibayar', id_pembayaran = '$id_pembayaran' 
                                WHERE id_transaksi = '$id_transaksi'";
            mysqli_query($koneksi, $query_transaksi);
            
            echo json_encode(["status" => "success", "message" => "Bukti transfer berhasil diunggah. Menunggu validasi Admin."]);
        } else {
            echo json_encode(["status" => "error", "message" => "Gagal menyimpan ke database."]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Sistem gagal menyimpan file gambar Anda."]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Data atau gambar bukti transfer tidak terbaca oleh server."]);
}
?>