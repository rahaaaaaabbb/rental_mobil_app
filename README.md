Rental Jaya Abadi (Rental Mobil App)Deskripsi AplikasiRental Mobil App adalah sistem aplikasi berbasis mobile yang dirancang untuk mengelola siklus penyewaan kendaraan dari awal hingga akhir. Aplikasi ini memfasilitasi interaksi antara pelanggan dan pengelola rental melalui antarmuka yang modern, responsif, dan mudah digunakan. 
Sistem ini terintegrasi dengan tiga hak akses (role) utama: Pelanggan (untuk pemesanan), Admin (untuk operasional harian dan validasi), serta Pimpinan (untuk pemantauan laporan dan analitik).  

Teknologi & FrameworkFramework Frontend: Flutter.  
Bahasa Pemrograman: Dart.

HTTP Client: Menggunakan package http untuk konsumsi REST API (berkomunikasi dengan backend PHP/MySQL).  

Desain & UI: Mengimplementasikan elemen antarmuka bergaya modern (Glassmorphism & Apple-style card) menggunakan package google_fonts (font Poppins) dan flutter_animate untuk transisi visual.   

Manajemen Media: Memanfaatkan package image_picker untuk memilih dan mengunggah gambar (bukti transfer pelanggan & foto master kendaraan admin).  

Penyimpanan Lokal: Menggunakan shared_preferences untuk manajemen sesi (session) pengguna.   

Fitur Utama Berdasarkan Role1. Pelanggan (Customer)Katalog Kendaraan: Melihat daftar armada yang statusnya tersedia dilengkapi dengan foto, merk, plat nomor, dan harga sewa per hari.  

Sistem Booking: Memilih tanggal sewa dan tanggal kembali melalui kalender bawaan, di mana aplikasi akan mengkalkulasi total tagihan secara otomatis.   

Manajemen Pembayaran: Mengunggah foto atau screenshot bukti transfer langsung dari galeri HP.  

Pelacakan Riwayat: Memantau status pesanan terkini (Menunggu Pembayaran, Dibayar, Berjalan, atau Selesai).

Admin (Operasional)Validasi Transaksi: Mengawasi pesanan masuk pada Dashboard Pelacakan. Admin berhak memvalidasi ("Jalankan") atau menolak ("Batalkan") pesanan berdasarkan bukti transfer yang diunggah pelanggan.

Penyelesaian Sewa: Mengonfirmasi pengembalian mobil untuk merubah status transaksi menjadi "Selesai".   

Kelola Armada: Menambahkan data master mobil baru (Plat Nomor, Merk/Tipe, Harga Sewa) beserta unggahan foto mobil ke dalam database.   3. Pimpinan (Owner/Manager)Dashboard Analitik: Memantau performa bisnis secara real-time.   

Ringkasan Pendapatan: Melihat kalkulasi Total Pendapatan Bersih dan jumlah total transaksi yang telah berhasil diselesaikan.  

Log Transaksi: Melihat rincian riwayat transaksi yang sudah selesai (nama pelanggan, mobil, nominal pendapatan, dan denda keterlambatan jika ada).   

Alur Penggunaan Aplikasi (Application Flow)Registrasi & Autentikasi
Pengguna baru membuat akun dengan mengisi data diri (Nama, Email, Password, Telepon, Alamat Domisili). Setelah mendaftar, pengguna melakukan Login. 

Sistem akan mendeteksi role pengguna (Admin, Pimpinan, atau Pelanggan) dan mengarahkannya ke halaman dashboard yang tepat.   

Proses Pemesanan (Oleh Pelanggan)
Pelanggan memilih mobil dari halaman Beranda, menentukan durasi sewa (Tanggal Mulai - Kembali), dan menekan "Pesan Sekarang". 
Pesanan akan masuk ke halaman "Riwayat Pesanan" dengan status Menunggu Pembayaran.   
Proses Pembayaran (Oleh Pelanggan)
Pelanggan menekan tombol "Bayar Sekarang" pada pesanan tersebut, melihat instruksi nomor rekening, lalu memilih gambar bukti transfer dari galeri untuk diunggah. Status pesanan berubah menjadi Dibayar.   
Proses Validasi & Operasional (Oleh Admin)
Admin melihat pesanan di tab "Menunggu". Admin memverifikasi dana dan menekan tombol Jalankan. Status pesanan berubah menjadi Berjalan dan masuk ke tab Berjalan.  
Penyelesaian Transaksi (Oleh Admin)
Ketika pelanggan mengembalikan mobil, 
Admin menekan tombol Mobil Dikembalikan (Selesai) pada pesanan terkait di tab "Berjalan".   
Pemantauan Laporan (Oleh Pimpinan)
Pesanan yang telah diselesaikan oleh Admin akan otomatis masuk ke perhitungan akumulasi pendapatan dan daftar riwayat pada layar Dashboard Analitik milik Pimpinan. 
