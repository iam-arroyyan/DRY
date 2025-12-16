import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration options for this app.
/// 
/// NOTE: This file should be replaced with your actual Firebase configuration.
/// 
/// To generate this file automatically:
/// 1. Install FlutterFire CLI: dart pub global activate flutterfire_cli
/// 2. Run: flutterfire configure
/// 
/// Or manually get the values from Firebase Console:
/// Project Settings > Your apps > SDK setup and configuration
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// TODO: Replace with your actual Firebase Web configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDfY4729yQZ-aK8pmABqX-p4_TL_hMK2qk',
    appId: '1:drys-2711e:web:app',
    messagingSenderId: '',
    projectId: 'drys-2711e',
    databaseURL: 'https://drys-2711e-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  /// Android configuration from Firebase Console
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDfY4729yQZ-aK8pmABqX-p4_TL_hMK2qk',
    appId: '1:884352795172:android:aca6eabbb60b8007254eb1',
    messagingSenderId: '884352795172',
    projectId: 'drys-2711e',
    databaseURL: 'https://drys-2711e-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  /// TODO: Replace with your actual Firebase iOS configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDfY4729yQZ-aK8pmABqX-p4_TL_hMK2qk',
    appId: '1:drys-2711e:ios:app',
    messagingSenderId: '',
    projectId: 'drys-2711e',
    databaseURL: 'https://drys-2711e-default-rtdb.asia-southeast1.firebasedatabase.app',
    iosBundleId: 'com.example.dry',
  );

  /// TODO: Replace with your actual Firebase macOS configuration
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDfY4729yQZ-aK8pmABqX-p4_TL_hMK2qk',
    appId: '1:drys-2711e:macos:app',
    messagingSenderId: '',
    projectId: 'drys-2711e',
    databaseURL: 'https://drys-2711e-default-rtdb.asia-southeast1.firebasedatabase.app',
    iosBundleId: 'com.example.dry',
  );

  /// TODO: Replace with your actual Firebase Windows configuration
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDfY4729yQZ-aK8pmABqX-p4_TL_hMK2qk',
    appId: '1:drys-2711e:windows:app',
    messagingSenderId: '',
    projectId: 'drys-2711e',
    databaseURL: 'https://drys-2711e-default-rtdb.asia-southeast1.firebasedatabase.app',
  );
}
