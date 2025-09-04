// ignore_for_file: constant_identifier_names

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not configured');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError('This platform is not configured');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD8KjxzAov98WXnSYxFgd-IkRRMdjiSdrM',
    appId: '1:987568744743:android:c391b24c3723fdfd792102',
    messagingSenderId: '987568744743',
    projectId: 'm2flutter-1d466',
    storageBucket: 'm2flutter-1d466.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBxyfQJPUJ4Chr47yPiuC8I1hDbMRQfPNk',
    appId: '1:987568744743:ios:37acf13d2bbc7e6c792102',
    messagingSenderId: '987568744743',
    projectId: 'm2flutter-1d466',
    storageBucket: 'm2flutter-1d466.firebasestorage.app',
    iosClientId:
        '987568744743-iohdhqfjq179fafekmocmg8989eg5ph9.apps.googleusercontent.com',
    iosBundleId: 'com.example.ecom',
  );
}
