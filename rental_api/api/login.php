<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'koneksi.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->email) && isset($data->password)) {
    // Kita menampung inputan 'email' dari Flutter. 
    // Untuk Admin/Pimpinan, inputan ini akan berisi 'username'.
    $identitas = $data->email; 
    $password = $data->password;

    // 1. Cek di tabel Pelanggan
    $query_pelanggan = "SELECT * FROM pelanggan WHERE email = '$identitas' AND password = '$password'";
    $result_pelanggan = mysqli_query($koneksi, $query_pelanggan);

    if(mysqli_num_rows($result_pelanggan) > 0) {
        $user = mysqli_fetch_assoc($result_pelanggan);
        $user['role'] = 'Pelanggan'; // Sisipkan penanda hak akses
        
        echo json_encode(["status" => "success", "message" => "Login Berhasil", "data" => $user]);
        exit();
    } 

    // 2. Jika bukan pelanggan, cek di tabel Pengguna (Admin / Pimpinan)
    $query_pengguna = "SELECT * FROM pengguna WHERE username = '$identitas' AND password = '$password'";
    $result_pengguna = mysqli_query($koneksi, $query_pengguna);

    if(mysqli_num_rows($result_pengguna) > 0) {
        $user = mysqli_fetch_assoc($result_pengguna);
        $user['role'] = $user['level']; // Sisipkan penanda hak akses dari kolom 'level' (Admin/Pimpinan)
        
        echo json_encode(["status" => "success", "message" => "Login Berhasil", "data" => $user]);
        exit();
    }

    // 3. Jika tidak ada di kedua tabel
    echo json_encode(["status" => "error", "message" => "Email/Username atau password salah"]);

} else {
    echo json_encode(["status" => "error", "message" => "Data tidak lengkap"]);
}
?>