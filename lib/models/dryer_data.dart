/// Data model untuk Mini Dryer
/// 
/// Merepresentasikan data sensor dan status dari ESP32

class DryerData {
  final double temperature;
  final double humidity;
  final int timestamp;
  final bool relayOn;
  final bool buzzerOn;
  final String state;
  final String message;
  final bool powerOn;
  final bool autoMode;

  DryerData({
    required this.temperature,
    required this.humidity,
    required this.timestamp,
    required this.relayOn,
    required this.buzzerOn,
    required this.state,
    required this.message,
    required this.powerOn,
    required this.autoMode,
  });

  /// Factory constructor untuk parsing dari Firebase snapshot
  factory DryerData.fromMap(Map<dynamic, dynamic> map) {
    final sensor = map['sensor'] as Map<dynamic, dynamic>? ?? {};
    final status = map['status'] as Map<dynamic, dynamic>? ?? {};
    final control = map['control'] as Map<dynamic, dynamic>? ?? {};

    return DryerData(
      temperature: (sensor['temperature'] ?? 0).toDouble(),
      humidity: (sensor['humidity'] ?? 0).toDouble(),
      timestamp: sensor['timestamp'] ?? 0,
      relayOn: status['relay'] ?? false,
      buzzerOn: status['buzzer'] ?? false,
      state: status['state'] ?? 'UNKNOWN',
      message: status['message'] ?? 'Tidak ada data',
      powerOn: control['power'] ?? false,
      autoMode: control['auto_mode'] ?? true,
    );
  }

  /// Default empty data
  factory DryerData.empty() {
    return DryerData(
      temperature: 0,
      humidity: 0,
      timestamp: 0,
      relayOn: false,
      buzzerOn: false,
      state: 'OFFLINE',
      message: 'Menunggu koneksi...',
      powerOn: false,
      autoMode: true,
    );
  }

  /// Check if device is online (data received in last 10 seconds)
  bool get isOnline {
    if (timestamp == 0) return false;
    // Note: timestamp from ESP32 is millis() which resets on reboot
    // For proper online check, use server timestamp
    return true;
  }

  /// Get state color
  String get stateColor {
    switch (state) {
      case 'DRYING':
        return 'orange';
      case 'DONE':
        return 'green';
      case 'OVERHEAT':
        return 'red';
      case 'ERROR':
        return 'red';
      case 'OFF':
        return 'grey';
      default:
        return 'grey';
    }
  }

  /// Get state icon name
  String get stateIcon {
    switch (state) {
      case 'DRYING':
        return 'whatshot';
      case 'DONE':
        return 'check_circle';
      case 'OVERHEAT':
        return 'warning';
      case 'ERROR':
        return 'error';
      case 'OFF':
        return 'power_settings_new';
      default:
        return 'help';
    }
  }
}
