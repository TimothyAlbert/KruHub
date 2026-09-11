# KruHub 🚀 
**Event Collaboration & Creative Asset Management System**

KruHub adalah aplikasi *mobile* dan sistem *backend* (RESTful API) yang dirancang untuk mengatasi kekacauan koordinasi dalam kepanitiaan acara berskala besar. Sistem ini menggantikan alur komunikasi berbasis *chat* yang tidak terstruktur menjadi *workflow* berbasis *Role-Based Access Control* (RBAC), memfasilitasi persetujuan aset, dan pelacakan tugas antar divisi.

## ✨ Fitur Utama

*   **Approval State Machine:** Logika *backend* ketat yang mengatur alur status aset (*Draft ➔ Review ➔ Approved*). Aset yang sudah disetujui akan otomatis terkunci dari akses edit/hapus.
*   **Creative Asset Versioning:** Sistem penyimpanan berjenjang untuk melacak riwayat revisi desain visual atau draf publikasi tanpa menimpa (*overwrite*) *file* sebelumnya.
*   **Structured PIC Assignment:** Pendelegasian tugas dengan *timeline* yang jelas kepada penanggung jawab (PIC) spesifik.
*   **Data Integrity & Audit Trail:** Menggunakan implementasi *SoftDeletes* (kolom `is_active`) pada semua operasi modifikasi data untuk mencegah kehilangan data historis.

## 🛠️ Tech Stack

**Backend & API:**
*   [Laravel](https://laravel.com/) (PHP) - *Core framework* & RESTful API
*   MySQL / PostgreSQL - Relational Database Management

**Frontend (Mobile & Web Admin):**
*   *Mobile UI Framework* (Flutter / React Native)
*   Blade Templating (Untuk Web Admin Panel)

## 📂 Arsitektur API Dasar
API dirancang dengan pendekatan standar operasional:
1.  `GET /api/v1/...` - **Index**: Menampilkan data *list* (tugas, revisi, draf).
2.  `POST /api/v1/...` - **Store**: Membuat *task* atau mengunggah iterasi desain baru.
3.  `PUT/PATCH /api/v1/...` - **Update**: Mengubah metadata atau memicu perubahan *state* (misal: *Approve*).
4.  `DELETE /api/v1/...` - **SoftDelete**: Menonaktifkan data secara aman tanpa menghapus *record* di *database*.

## 🤝 Developer
Proyek ini dikembangkan untuk kebutuhan manajemen festival berskala regional.
*   **Timothy Albert P.** - *Backend Engineering & API Design*

---
*Dibuat untuk mempermudah alur birokrasi dan menjaga kualitas visual acara Anda.* 🎨
