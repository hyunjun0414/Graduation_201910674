// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAdt2ZuraqYbbJlM21BonmdNDv3rwXtou0',
    appId: '1:366347200362:web:e3e6fa9a8c3872e54d2713',
    messagingSenderId: '366347200362',
    projectId: 'hanseisimplerecipe',
    authDomain: 'hanseisimplerecipe.firebaseapp.com',
    storageBucket: 'hanseisimplerecipe.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA8Ps9kB2MtKRmaZpktgWXGCVBmwIgvd2s',
    appId: '1:366347200362:android:563aa88d5e6ad42f4d2713',
    messagingSenderId: '366347200362',
    projectId: 'hanseisimplerecipe',
    storageBucket: 'hanseisimplerecipe.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDMSqO3_LUd45pdGRzPyyV9cRJN5C4ZL6c',
    appId: '1:366347200362:ios:66143d826b0349984d2713',
    messagingSenderId: '366347200362',
    projectId: 'hanseisimplerecipe',
    storageBucket: 'hanseisimplerecipe.appspot.com',
    iosBundleId: 'com.example.menumate',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDMSqO3_LUd45pdGRzPyyV9cRJN5C4ZL6c',
    appId: '1:366347200362:ios:8c334cb2e6ede3754d2713',
    messagingSenderId: '366347200362',
    projectId: 'hanseisimplerecipe',
    storageBucket: 'hanseisimplerecipe.appspot.com',
    iosBundleId: 'com.example.menumate.RunnerTests',
  );
}
