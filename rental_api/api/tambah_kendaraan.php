<?php
// File: api/tambah_kendaraan.php
// Fungsi: Admin menambahkan master data mobil baru beserta fotonya

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include '../config/koneksi.php';

// Menangkap input form-data karena ada unggahan file foto
$plat_nomor = isset($_POST['plat_nomor']) ? $_POST['plat_nomor'] : '';
// Input merk menggunakan standar ketikan manual (teks) dari form aplikasi
$merk       = isset($_POST['merk']) ? $_POST['merk'] : ''; 
$harga_sewa = isset($_POST['harga_sewa']) ? $_POST['harga_sewa'] : '';

// Validasi input wajib agar tidak ada data kosong yang masuk ke database
if (!empty($plat_nomor) && !empty($merk) && !empty($harga_sewa)) {
    
    $gambar = "";
    // Logika unggah (upload) file foto mobil
    if (isset($_FILES['gambar']['name']) && $_FILES['gambar']['name'] != '') {
        // Menambahkan fungsi time() agar nama file unik dan tidak tertimpa
        $gambar = time() . "_" . basename($_FILES['gambar']['name']);
        
        // Pastikan folder 'uploads' sudah dibuat sejajar dengan folder 'api'
        $target_dir = "../uploads/";
        
        // Pindahkan file foto dari sistem sementara ke folder uploads
        move_uploaded_file($_FILES["gambar"]["tmp_name"], $target_dir . $gambar);
    }

    // Pembersihan data untuk keamanan dari SQL Injection
    $plat_nomor = mysqli_real_escape_string($koneksi, $plat_nomor);
    $merk       = mysqli_real_escape_string($koneksi, $merk);
    $harga_sewa = (int) $harga_sewa; // Pastikan formatnya angka

    // Query menyimpan data kendaraan (Status akan otomatis 'Tersedia' bawaan dari tabel)
    $query = "INSERT INTO kendaraan (plat_nomor, merk, harga_sewa, gambar) 
              VALUES ('$plat_nomor', '$merk', $harga_sewa, '$gambar')";

    if (mysqli_query($koneksi, $query)) {
        echo json_encode([
            "status" => "success", 
            "message" => "Kendaraan baru berhasil ditambahkan."
        ]);
    } else {
        echo json_encode([
            "status" => "error", 
            "message" => "Gagal menyimpan data ke database."
        ]);
    }
} else {
    echo json_encode([
        "status" => "error", 
        "message" => "Data tidak lengkap. Plat nomor, merk, dan harga sewa wajib diisi."
    ]);
}

mysqli_close($koneksi);
?>