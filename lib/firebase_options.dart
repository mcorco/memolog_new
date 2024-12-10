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
    apiKey: 'AIzaSyDuJVKjYZ8wdddXCh-F-RrRO5krrfFSdoQ',
    appId: '1:68557651466:web:f40b276b80281d46c5e9f3',
    messagingSenderId: '68557651466',
    projectId: 'memolog-5d8cc',
    authDomain: 'memolog-5d8cc.firebaseapp.com',
    storageBucket: 'memolog-5d8cc.firebasestorage.app',
    measurementId: '',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDuJVKjYZ8wdddXCh-F-RrRO5krrfFSdoQ',
    appId: '1:68557651466:android:f40b276b80281d46c5e9f3',
    messagingSenderId: '68557651466',
    projectId: 'memolog-5d8cc',
    storageBucket: 'memolog-5d8cc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDuJVKjYZ8wdddXCh-F-RrRO5krrfFSdoQ',
    appId: '1:68557651466:ios:f40b276b80281d46c5e9f3',
    messagingSenderId: '68557651466',
    projectId: 'memolog-5d8cc',
    storageBucket: 'memolog-5d8cc.firebasestorage.app',
    iosBundleId: 'com.memolog.new',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDuJVKjYZ8wdddXCh-F-RrRO5krrfFSdoQ',
    appId: '1:68557651466:ios:f40b276b80281d46c5e9f3',
    messagingSenderId: '68557651466',
    projectId: 'memolog-5d8cc',
    storageBucket: 'memolog-5d8cc.firebasestorage.app',
    iosBundleId: 'com.memolog.new',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDuJVKjYZ8wdddXCh-F-RrRO5krrfFSdoQ',
    appId: '1:68557651466:web:f40b276b80281d46c5e9f3',
    messagingSenderId: '68557651466',
    projectId: 'memolog-5d8cc',
    authDomain: 'memolog-5d8cc.firebaseapp.com',
    storageBucket: 'memolog-5d8cc.firebasestorage.app',
    measurementId: '',
  );
}
