<?php
$host = "localhost";
$user = "root";           
$pass = "";               
$db   = "db_rental_jaya"; 

$koneksi = mysqli_connect($host, $user, $pass, $db);

// 3. Mengecek apakah koneksi berhasil atau gagal
if (mysqli_connect_errno()) {

    header("Content-Type: application/json; charset=UTF-8");
    
    
    echo json_encode([
        "status" => "error", 
        "message" => "Gagal terhubung ke database: " . mysqli_connect_error()
    ]);
    
    
    exit(); 
}


?>