<?php
// Pengaturan default untuk XAMPP
$host = "localhost";
$user = "root"; 
$pass = "";     
$db   = "db_rental_jaya"; // Pastikan nama database ini sama persis dengan yang ada di phpMyAdmin

$koneksi = mysqli_connect($host, $user, $pass, $db);

// Cek apakah koneksi berhasil
if (!$koneksi) {
    die("Koneksi database gagal: " . mysqli_connect_error());
}
?>