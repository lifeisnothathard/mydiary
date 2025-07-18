// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
/// 
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAafWMUNVt6d7dm_qBAfDTV-fq1q9FPV4U',
    appId: '1:12048812642:web:3df0d70ae24da58cd71f3b',
    messagingSenderId: '12048812642',
    projectId: 'mydiary-9ae39',
    authDomain: 'mydiary-9ae39.firebaseapp.com',
    storageBucket: 'mydiary-9ae39.firebasestorage.app',
    measurementId: 'G-0DW9SLX7JQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB0z2Oog6_JuB1ZqTlgCPR8atNUxNhhGos',
    appId: '1:12048812642:android:f8a2535083496503d71f3b',
    messagingSenderId: '12048812642',
    projectId: 'mydiary-9ae39',
    storageBucket: 'mydiary-9ae39.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAqCkXSc3M4WTcbKNa_KERRkkSC4SW1X58',
    appId: '1:12048812642:ios:c4e45e1301d9f16bd71f3b',
    messagingSenderId: '12048812642',
    projectId: 'mydiary-9ae39',
    storageBucket: 'mydiary-9ae39.firebasestorage.app',
    iosClientId: '12048812642-9u1kn6ibcgt7tlcj7sgsmlutb0cck3ai.apps.googleusercontent.com',
    iosBundleId: 'com.example.mydiary',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAqCkXSc3M4WTcbKNa_KERRkkSC4SW1X58',
    appId: '1:12048812642:ios:c4e45e1301d9f16bd71f3b',
    messagingSenderId: '12048812642',
    projectId: 'mydiary-9ae39',
    storageBucket: 'mydiary-9ae39.firebasestorage.app',
    iosClientId: '12048812642-9u1kn6ibcgt7tlcj7sgsmlutb0cck3ai.apps.googleusercontent.com',
    iosBundleId: 'com.example.mydiary',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAafWMUNVt6d7dm_qBAfDTV-fq1q9FPV4U',
    appId: '1:12048812642:web:31eb47b91e2087ead71f3b',
    messagingSenderId: '12048812642',
    projectId: 'mydiary-9ae39',
    authDomain: 'mydiary-9ae39.firebaseapp.com',
    storageBucket: 'mydiary-9ae39.firebasestorage.app',
    measurementId: 'G-JG3G68HBVY',
  );
}
