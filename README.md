# DRY - IoT Smart Dryer System 🌡️📱

**DRY** adalah proyek sistem pengering pintar (Smart Dryer) berbasis *Internet of Things* (IoT). Proyek ini terdiri dari dua bagian utama: perangkat keras (mikrokontroler ESP32) yang membaca dan mengirimkan data sensor, serta aplikasi *mobile* berbasis **Flutter** untuk memantau dan mengontrol proses pengeringan secara *real-time* melalui **Firebase**.

## 🚀 Fitur Utama

* **Real-time Monitoring:** Memantau suhu, kelembapan, dan status alat pengering secara langsung dari *smartphone*.
* **Remote Control:** Mengontrol alat pengering (menyalakan/mematikan) dari jarak jauh.
* **IoT Integration:** Komunikasi dua arah yang mulus antara perangkat keras ESP32 dan aplikasi *mobile* menggunakan infrastruktur Firebase.
* **Modern UI:** Antarmuka aplikasi yang bersih dan responsif dibangun menggunakan Flutter.

## 🛠️ Tech Stack & Hardware

**Mobile App Development:**
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) ![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white) ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

**IoT & Hardware:**
![ESP32](https://img.shields.io/badge/ESP32-000000?style=for-the-badge&logo=espressif&logoColor=white) ![C++](https://img.shields.io/badge/C%2B%2B-00599C?style=for-the-badge&logo=c%2B%2B&logoColor=white) ![Arduino IDE](https://img.shields.io/badge/Arduino_IDE-00979D?style=for-the-badge&logo=arduino&logoColor=white)

## 📂 Struktur Proyek

Proyek ini dibagi menjadi dua environment utama (Hardware dan Software):

```text
dry/
├── esp32_dryer_firebase/       # Kode sumber C++ untuk mikrokontroler ESP32
│   └── esp32_dryer_firebase.ino
├── lib/                        # Kode sumber aplikasi mobile Flutter
│   ├── models/                 # Model data (contoh: dryer_data.dart)
│   ├── screens/                # Antarmuka pengguna (home_screen.dart)
│   ├── services/               # Logika backend & integrasi Firebase
│   └── main.dart               # Entry point aplikasi mobile
└── android/ & ios/             # Konfigurasi native platform
