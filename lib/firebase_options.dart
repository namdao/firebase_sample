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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'run flutterfire configure to generate them.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'run flutterfire configure to generate them.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for fuchsia - '
          'run flutterfire configure to generate them.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAapQCFBzQhr9C6Ib_4LQ7n2fbCfv0-YbI',
    appId: '1:703598673962:android:5366f2727cf2b7aad00353',
    messagingSenderId: '703598673962',
    projectId: 'healcare-flutter',
    storageBucket: 'healcare-flutter.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAapQCFBzQhr9C6Ib_4LQ7n2fbCfv0-YbI',
    appId: '1:703598673962:android:9585d91bb115994bd00353',
    messagingSenderId: '703598673962',
    projectId: 'healcare-flutter',
    storageBucket: 'healcare-flutter.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCWf61qH6MwuTV4g87xup07jrIwFlIgvHE',
    appId: '1:703598673962:ios:f071de25f16a5405d00353',
    messagingSenderId: '703598673962',
    projectId: 'healcare-flutter',
    storageBucket: 'healcare-flutter.firebasestorage.app',
    iosBundleId: 'com.namdao.healthcareApp.ios',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCWf61qH6MwuTV4g87xup07jrIwFlIgvHE',
    appId: '1:703598673962:ios:68633aa6fbd375f1d00353',
    messagingSenderId: '703598673962',
    projectId: 'healcare-flutter',
    storageBucket: 'healcare-flutter.firebasestorage.app',
    iosBundleId: 'com.example.fbSample',
  );
}