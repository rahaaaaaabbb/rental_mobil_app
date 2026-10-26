<?php
// File: api/register.php
// Fungsi: Mendaftarkan akun pelanggan baru ke database

// 1. Konfigurasi Header untuk API dan menerima metode POST
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
// 2. Panggil file koneksi
include '../config/koneksi.php';

// 3. Tangkap data JSON yang dikirimkan oleh aplikasi Flutter
$data = json_decode(file_get_contents("php://input"));

// 4. Validasi: Pastikan semua data tidak ada yang kosong
if (
    !empty($data->nama_lengkap) &&
    !empty($data->email) &&
    !empty($data->password) &&
    !empty($data->no_telepon) &&
    !empty($data->alamat)
) {
    // Bersihkan input untuk mencegah SQL Injection
    $nama_lengkap = mysqli_real_escape_string($koneksi, $data->nama_lengkap);
    $email        = mysqli_real_escape_string($koneksi, $data->email);
    $no_telepon   = mysqli_real_escape_string($koneksi, $data->no_telepon);
    $alamat       = mysqli_real_escape_string($koneksi, $data->alamat);
    
    // Hash password agar aman (tidak tersimpan dalam plain-text di database)
    $password_hash = password_hash($data->password, PASSWORD_DEFAULT);

    // 5. Pengecekan: Apakah email sudah terdaftar sebelumnya?
    $cek_email = mysqli_query($koneksi, "SELECT email FROM pelanggan WHERE email = '$email'");
    
    if (mysqli_num_rows($cek_email) > 0) {
        // Jika email sudah ada
        echo json_encode([
            "status" => "error", 
            "message" => "Email sudah terdaftar, silakan gunakan email lain."
        ]);
    } else {
        // 6. Jika email belum ada, simpan data ke tabel pelanggan
        $query = "INSERT INTO pelanggan (nama_lengkap, email, password, no_telepon, alamat) 
                  VALUES ('$nama_lengkap', '$email', '$password_hash', '$no_telepon', '$alamat')";
        
        if (mysqli_query($koneksi, $query)) {
            echo json_encode([
                "status" => "success", 
                "message" => "Registrasi berhasil, silakan login."
            ]);
        } else {
            echo json_encode([
                "status" => "error", 
                "message" => "Terjadi kesalahan pada server saat menyimpan data."
            ]);
        }
    }
} else {
    // Response jika ada field input yang kosong
    echo json_encode([
        "status" => "error", 
        "message" => "Data pendaftaran tidak lengkap. Pastikan semua kolom terisi."
    ]);
}

// 7. Tutup koneksi
mysqli_close($koneksi);
?>