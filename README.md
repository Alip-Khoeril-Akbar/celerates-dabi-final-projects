# 📊 Superstore Data Warehouse & Business Intelligence Pipeline

Proyek akhir ini merupakan implementasi pipeline *End-to-End* Data Engineering dan Business Intelligence untuk data penjualan global **Superstore**. Proyek ini mencakup proses perancangan skema database (*Star Schema*), otomatisasi ETL (*Extract, Transform, Load*) menggunakan Pentaho, hingga visualisasi interaktif menggunakan Tableau.

---

## 👥 Tim Proyek & Pembagian Peran (Kelompok 9)

Berikut adalah struktur organisasi dan pembagian tanggung jawab utama dalam pengembangan proyek ini:

1. **Achmad Ridho Fathoni (Data Analyst)**
   * *Tanggung Jawab:* Merancang dan membangun layer Data Mart (`datamart.dm_superstore`), menganalisis metrik bisnis, serta menyusun query analitik utama.
2. **Alip Khoeril Akbar (BI Developer)**
   * *Tanggung Jawab:* Merancang visualisasi data, memetakan kebutuhan bisnis ke grafik interaktif, dan membangun keseluruhan dashboard di Tableau.
3. **Muhamad Ihsan Setiawan / Ican (ETL Engineer)**
   * *Tanggung Jawab:* Membangun otomasi pengolahan data (*data pipeline*) menggunakan Pentaho Data Integration (PDI), mulai dari tahap *Staging* hingga pengisian tabel fakta.
4. **Andra Teguh Ramadhan (DW Designer)**
   * *Tanggung Jawab:* Merancang arsitektur basis data, memetakan struktur *Star Schema* (skema dimensi dan tabel fakta), serta menentukan tipe data komponen *Surrogate Key*.
5. **Rodiah Hasan Alaydrus (Technical Writer)**
   * *Tanggung Jawab:* Menyusun dokumentasi teknis, memetakan *insight* bisnis, serta bertanggung jawab penuh atas penyusunan dan finalisasi laporan proyek akhir kelompok.

---

## 🏗️ Arsitektur Proyek & Struktur Folder

Struktur repositori ini diatur dengan standar industri untuk memisahkan aset data, skrip otomasi ETL, kueri database, dan dashboard visualisasi:

```text
📁 superstore-analytics-finalproject/
│
├── 📁 data/
│   ├── 📄 Sample - Superstore.csv        # Data mentah awal (Raw Data)
│   └── 📄 dm_superstore.csv             # Data Mart akhir hasil denormalisasi ETL
│
├── 📁 sql_scripts/
│   ├── 📜 01_superstore_ddl.sql         # Inisialisasi awal skema (Staging, Dimensi, Fact)
│   └── 📜 02_superstore_analytics.sql   # Pembuatan constraint, query analisis & Datamart
│
├── 📁 etl_pipelines/
│   ├── ⚙️ tf_load_staging.ktr           # ETL: Mengisi data mentah ke layer Staging
│   ├── ⚙️ tf_dim_customer.ktr           # ETL: Transformasi data master Pelanggan
│   ├── ⚙️ tf_dim_product.ktr            # ETL: Transformasi data master Produk
│   ├── ⚙️ tf_dim_region.ktr             # ETL: Transformasi data master Wilayah
│   ├── ⚙️ tf_dim_shipping.ktr           # ETL: Transformasi data master Pengiriman
│   ├── ⚙️ tf_dim_date.ktr               # ETL: Ekstraksi fitur waktu & penanda kalender
│   ├── ⚙️ tf_fact_sales.ktr             # ETL: Pemetaan data transaksi ke tabel Fakta (Fact)
│   └── ⚙️ tf_datamart.ktr               # ETL: Konsolidasi menjadi tabel siap saji (Data Mart)
│
├── 📁 dashboard/
│   ├── 📊 FinalProject_SuperStore_Kel. 9.twbx  # File Workbook Packaged Tableau
│   └── 📁 screenshots/
│       ├── 🖼️ Dashboard_Halaman_1.png    # Dokumentasi visual halaman utama
│       └── 🖼️ Dashboard_Halaman_2.png    # Dokumentasi visual halaman detail
│
└── 📄 README.md                         # Dokumentasi utama proyek
