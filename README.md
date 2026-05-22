# Project IoT - Mini Dryer ESP32 + Firebase

Mini Dryer adalah project IoT untuk memantau dan mengontrol alat pengering mini menggunakan ESP32, sensor DHT11, relay, buzzer, Firebase Realtime Database, dan aplikasi Flutter.

Project ini dibuat agar proses pengeringan dapat dipantau dari aplikasi secara realtime. ESP32 membaca suhu dan kelembapan, mengirim status perangkat ke Firebase, lalu aplikasi Flutter menampilkan data tersebut dan mengirim perintah kontrol kembali ke ESP32.

## Fitur

- Monitoring suhu dan kelembapan secara realtime.
- Kontrol power alat pengering dari aplikasi Flutter.
- Mode auto stop untuk menghentikan pengeringan saat kelembapan sudah mencapai target.
- Proteksi overheat saat suhu melewati batas aman.
- Indikator status relay, buzzer, dan kondisi perangkat.
- Integrasi ESP32 dengan Firebase Realtime Database melalui REST API.

## Komponen Hardware

- ESP32
- Sensor DHT11
- Modul relay 1 channel
- Buzzer
- Elemen pengering atau beban yang dikontrol relay
- Kabel jumper dan sumber daya sesuai kebutuhan rangkaian

## Pin ESP32

| Komponen | Pin ESP32 |
| --- | --- |
| DHT11 | GPIO 4 |
| Relay | GPIO 27 |
| Buzzer | GPIO 15 |

Relay pada sketch menggunakan logika aktif LOW:

- `LOW` = relay ON
- `HIGH` = relay OFF

## Alur Sistem

1. ESP32 terhubung ke WiFi.
2. ESP32 membaca suhu dan kelembapan dari DHT11.
3. ESP32 membaca nilai kontrol dari Firebase pada path `dryer/control`.
4. Jika `power` bernilai `true`, relay akan aktif selama suhu aman dan target kelembapan belum tercapai.
5. Jika mode otomatis aktif dan kelembapan sudah mencapai target, relay dimatikan dan buzzer berbunyi.
6. Jika suhu melewati batas aman, relay dimatikan dan buzzer menyala sebagai peringatan.
7. Data sensor dan status dikirim ke Firebase agar aplikasi Flutter dapat menampilkannya secara realtime.

## Struktur Firebase

```json
{
  "dryer": {
    "control": {
      "power": false,
      "auto_mode": true
    },
    "sensor": {
      "temperature": 0,
      "humidity": 0,
      "timestamp": 0
    },
    "status": {
      "relay": false,
      "buzzer": false,
      "state": "OFF",
      "message": "Perangkat dimatikan"
    }
  }
}
```

## Status Perangkat

| Status | Keterangan |
| --- | --- |
| `OFF` | Perangkat dimatikan dari aplikasi |
| `DRYING` | Pengeringan sedang berjalan |
| `DONE` | Target kelembapan tercapai |
| `OVERHEAT` | Suhu melewati batas aman |
| `ERROR` | Sensor tidak terbaca |
| `OFFLINE` | Aplikasi belum menerima data |

## Parameter Default

Parameter utama ada di file `tubes.ino`:

| Parameter | Nilai | Fungsi |
| --- | --- | --- |
| `MAX_TEMP` | `50.0` | Batas suhu maksimum dalam C |
| `TARGET_HUM` | `70.0` | Target kelembapan dalam persen |
| `READ_INTERVAL` | `2500` ms | Interval baca sensor |
| `FIREBASE_INTERVAL` | `3000` ms | Interval update data ke Firebase |

Nilai tersebut bisa disesuaikan dengan kebutuhan pengeringan dan karakteristik alat.

## Menjalankan Aplikasi Flutter

Masuk ke folder project Flutter:

```bash
cd DRY
flutter pub get
flutter run
```

Aplikasi menggunakan package berikut:

- `firebase_core`
- `firebase_database`

Pastikan konfigurasi Firebase pada `lib/firebase_options.dart` dan file platform seperti `android/app/google-services.json` sudah sesuai dengan project Firebase yang digunakan.

## Upload Sketch ESP32

File Arduino untuk ESP32 berada di:

```text
../tubes/tubes.ino
```

Sebelum upload, sesuaikan bagian berikut:

```cpp
#define WIFI_SSID     "nama_wifi"
#define WIFI_PASSWORD "password_wifi"
#define FIREBASE_HOST "https://nama-project.firebaseio.com"
```

Library Arduino yang dibutuhkan:

- WiFi
- HTTPClient
- ArduinoJson
- DHT sensor library

Setelah library terpasang, pilih board ESP32 pada Arduino IDE, pilih port yang benar, lalu upload sketch.

## Struktur Project

```text
DRY/
  lib/
    main.dart
    firebase_options.dart
    models/
      dryer_data.dart
    screens/
      home_screen.dart
    services/
      firebase_service.dart
  esp32_dryer_firebase/
    esp32_dryer_firebase.ino
  README.md

../tubes/
  tubes.ino
```

## Catatan Keamanan

Jangan membagikan kredensial WiFi atau konfigurasi Firebase yang bersifat sensitif ke repository publik. Untuk penggunaan produksi, gunakan aturan keamanan Firebase yang membatasi akses baca dan tulis hanya untuk perangkat atau pengguna yang diizinkan.
