import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCyWX0yser9gurtR0qSNJ-kd2B-FnrrJes',
    appId: '1:850812786949:web:e1bc25e0bcab7b45a47f6c',
    messagingSenderId: '850812786949',
    projectId: 'flutter-assignment-14c9c',
    authDomain: 'flutter-assignment-14c9c.firebaseapp.com',
    storageBucket: 'flutter-assignment-14c9c.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDzhncijINpNkn3G9XnqBXK-ox5PbzGnyk',
    appId: '1:850812786949:android:662f7a7f4d3ded1ea47f6c',
    messagingSenderId: '850812786949',
    projectId: 'flutter-assignment-14c9c',
    storageBucket: 'flutter-assignment-14c9c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBOkNrI2FH3I4IOvjyut7JNwrzVfBd5L5o',
    appId: '1:850812786949:ios:3e5e2dd53f7004b7a47f6c',
    messagingSenderId: '850812786949',
    projectId: 'flutter-assignment-14c9c',
    storageBucket: 'flutter-assignment-14c9c.firebasestorage.app',
    iosClientId:
        '850812786949-ffosio0rt1u4cn8kfbhmqktmhsupscs2.apps.googleusercontent.com',
    iosBundleId: 'com.example.project',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBOkNrI2FH3I4IOvjyut7JNwrzVfBd5L5o',
    appId: '1:850812786949:ios:3e5e2dd53f7004b7a47f6c',
    messagingSenderId: '850812786949',
    projectId: 'flutter-assignment-14c9c',
    storageBucket: 'flutter-assignment-14c9c.firebasestorage.app',
    iosClientId:
        '850812786949-ffosio0rt1u4cn8kfbhmqktmhsupscs2.apps.googleusercontent.com',
    iosBundleId: 'com.example.project',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCyWX0yser9gurtR0qSNJ-kd2B-FnrrJes',
    appId: '1:850812786949:web:639e9b0fb1340966a47f6c',
    messagingSenderId: '850812786949',
    projectId: 'flutter-assignment-14c9c',
    authDomain: 'flutter-assignment-14c9c.firebaseapp.com',
    storageBucket: 'flutter-assignment-14c9c.firebasestorage.app',
  );
}
