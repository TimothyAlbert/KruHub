## 🎯 Visi & Ruang Lingkup Proyek (Project Scope)

### 1. Deskripsi Masalah
Dalam kepanitiaan acara berskala besar, koordinasi antar divisi sering menjadi kacau karena hanya mengandalkan grup pesan instan. Draf desain publikasi, dokumen penting, dan revisi sering tertumpuk, hilang, atau sulit dilacak. Selain itu, alur persetujuan (*approval*) dari koordinator tidak terstruktur secara digital, menyebabkan hambatan operasional, miskomunikasi *timeline*, dan inkonsistensi pada hasil akhir (karya visual maupun operasional).

### 2. Profil Target Pengguna
Pengguna aplikasi ini adalah panitia pelaksana acara (*Event Organizer* tingkat kampus atau regional) yang dibagi menjadi beberapa peran hak akses (*Role-Based Access Control*):
*   **Super/Ketua Pelaksana:** Memantau seluruh *timeline* acara dan *progress* antar divisi.
*   **Koordinator Divisi (misal: Media Kreatif):** Bertugas memberikan *approval* desain/dokumen, menugaskan PIC, dan mengunci revisi.
*   **Staf / Anggota Divisi:** Bertugas mengerjakan tugas yang didelegasikan, mengunggah draf/file, dan melaporkan *progress*.

### 3. Manfaat Aplikasi
*   **Single Source of Truth:** Menyediakan satu *platform* terpusat untuk koordinasi tugas tanpa perlu mencari *file* yang tertumpuk di aplikasi *chat*.
*   **Akuntabilitas Transparan:** Memperjelas siapa yang bertanggung jawab atas suatu tugas (sistem PIC).
*   **Keamanan Aset:** Mencegah hilangnya data atau revisi desain yang tertimpa secara tidak sengaja berkat sistem *versioning* dan *soft-delete*.
*   **Birokrasi Otomatis:** Mempercepat dan memperjelas proses validasi karya melalui sistem *approval state machine*.

### 4. Daftar Fitur Inti (Target 12 Pertemuan)
1.  **Sistem Autentikasi & RBAC:** *Login* dengan pembagian hak akses (Staf vs Koordinator).
2.  **Manajemen Tugas (CRUD Dasar):** Pembuatan tugas, penugasan ke PIC, dan pembaruan *progress* (menampilkan antarmuka daftar tugas / *Index*).
3.  **Approval State Machine:** Logika *backend* (*Draft* ➔ *In Review* ➔ *Approved*). Mengunci *file* agar tidak bisa diedit setelah status diubah menjadi *Approved* oleh Koordinator.
4.  **Creative Asset Versioning:** Fitur unggah *file* tugas yang memungkinkan penyimpanan riwayat revisi (versi 1, versi 2, dst) tanpa menimpa *file* lama.
5.  **Soft-Delete Mechanism:** Memastikan data yang dihapus (seperti tugas yang dibatalkan) di antarmuka tidak benar-benar hilang dari *database* (kolom `is_active`).

### 5. Fitur yang Tidak Dikerjakan (Out of Scope)
*   **Real-time Chat Internal:** Aplikasi berfokus pada manajemen tugas dan status persetujuan, sedangkan obrolan berbasis teks tetap diserahkan pada aplikasi pihak ketiga (WhatsApp/Line).
*   **Integrasi IoT & AI:** Aplikasi tidak mencakup sistem pengenalan wajah biometrik atau kendali akses gerbang perangkat keras.
*   **Sistem Tiket / Keuangan:** Tidak ada fitur untuk mengelola transaksi pembayaran dari pengunjung acara.

### 6. Kriteria Aplikasi Dinyatakan Berhasil
*   **Autentikasi Berhasil:** Pengguna dapat masuk dan hanya melihat *dashboard* serta fitur yang sesuai dengan peran mereka.
*   **State Machine Berjalan:** Alur persetujuan valid (Staf mengunggah tugas ➔ Koordinator menekan *Approve* ➔ Staf kehilangan tombol *Edit* atau *Delete* pada tugas tersebut).
*   **Versioning Berjalan:** Sistem mampu menampilkan lebih dari satu versi draf untuk satu tugas yang sama, dan pengguna dapat mengunduh versi mana pun.
*   **Integritas Data:** Implementasi *soft-delete* berfungsi; tugas yang "dihapus" di aplikasi mobile menghilang dari layar, namun *record*-nya masih tersimpan secara utuh di *database* relasional.
