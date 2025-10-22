// Firebase configuration for development
// Replace these values with your actual Firebase project configuration

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBbtOKgmtWCpTj7rEkoKlzuqKYcPb97l3A',
    appId: '1:501102619445:android:bdea53f446dc42ac0c7a7c',
    messagingSenderId: '501102619445',
    projectId: 'qinspecting-f9826',
    storageBucket: 'qinspecting-f9826.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'qinspecting-f9826',
    storageBucket: 'qinspecting-f9826.appspot.com',
    iosBundleId: 'com.example.appQinspecting',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'qinspecting-f9826',
    storageBucket: 'qinspecting-f9826.appspot.com',
    iosBundleId: 'com.example.appQinspecting',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY',
    appId: 'YOUR_WINDOWS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'qinspecting-f9826',
    storageBucket: 'qinspecting-f9826.appspot.com',
  );
}
