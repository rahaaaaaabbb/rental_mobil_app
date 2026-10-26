<?php

// 1. Izinkan akses dari luar (CORS) dan set output sebagai JSON
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// 2. Panggil file koneksi database
include '../config/koneksi.php';

// 3. Siapkan query untuk mengambil mobil yang berstatus 'Tersedia'
$query = "SELECT * FROM kendaraan WHERE status = 'Tersedia'";
$result = mysqli_query($koneksi, $query);

// 4. Cek apakah ada data yang ditemukan di dalam tabel
if (mysqli_num_rows($result) > 0) {
    // Siapkan array kosong untuk menampung data
    $data_mobil = array();
    
    // Looping untuk mengeluarkan data dari database dan memasukkannya ke array
    while ($row = mysqli_fetch_assoc($result)) {
        $data_mobil[] = $row;
    }
    
    // Format response jika sukses mengambil data
    echo json_encode([
        "status" => "success",
        "message" => "Data kendaraan berhasil diambil",
        "data" => $data_mobil
    ]);
} else {
    // Format response jika tabel kendaraan masih kosong atau tidak ada yang tersedia
    echo json_encode([
        "status" => "error",
        "message" => "Belum ada kendaraan yang tersedia",
        "data" => []
    ]);
}

// 5. Tutup koneksi ke database
mysqli_close($koneksi);
?>