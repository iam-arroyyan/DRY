import 'package:firebase_database/firebase_database.dart';
import '../models/dryer_data.dart';

/// Service untuk komunikasi dengan Firebase Realtime Database
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// Stream data dryer secara realtime
  Stream<DryerData> getDryerStream() {
    return _dbRef.child('dryer').onValue.map((event) {
      if (event.snapshot.value == null) {
        return DryerData.empty();
      }
      
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return DryerData.fromMap(data);
    });
  }

  /// Set power ON/OFF
  Future<void> setPower(bool on) async {
    await _dbRef.child('dryer/control/power').set(on);
  }

  /// Set auto mode ON/OFF
  Future<void> setAutoMode(bool auto) async {
    await _dbRef.child('dryer/control/auto_mode').set(auto);
  }

  /// Get current control values
  Future<Map<String, bool>> getControlValues() async {
    final snapshot = await _dbRef.child('dryer/control').get();
    if (snapshot.value == null) {
      return {'power': false, 'auto_mode': true};
    }
    
    final data = snapshot.value as Map<dynamic, dynamic>;
    return {
      'power': data['power'] ?? false,
      'auto_mode': data['auto_mode'] ?? true,
    };
  }
}
