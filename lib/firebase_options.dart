import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
/// Configurato per il progetto Firebase "channel-gcc-report"
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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB-cmsF8bOJLJECbxMpBY67XmPpOL-ed_I',
    appId: '1:416637337233:web:c2a6446602537b621d8930',
    messagingSenderId: '416637337233',
    projectId: 'channel-gcc-report',
    authDomain: 'channel-gcc-report.firebaseapp.com',
    storageBucket: 'channel-gcc-report.firebasestorage.app',
    databaseURL: 'https://channel-gcc-report-default-rtdb.europe-west1.firebasedatabase.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-cmsF8bOJLJECbxMpBY67XmPpOL-ed_I',
    appId: '1:416637337233:android:c2a6446602537b621d8930',
    messagingSenderId: '416637337233',
    projectId: 'channel-gcc-report',
    storageBucket: 'channel-gcc-report.firebasestorage.app',
    databaseURL: 'https://channel-gcc-report-default-rtdb.europe-west1.firebasedatabase.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBipfgJyaj3mn-bkg16Q926ajQE_ZrJJS0',
    appId: '1:416637337233:ios:5ce796d39066e0ad1d8930',
    messagingSenderId: '416637337233',
    projectId: 'channel-gcc-report',
    storageBucket: 'channel-gcc-report.firebasestorage.app',
    iosClientId: '416637337233-2gbtia29cp0es6jhlpk6dn3p9klf74oq.apps.googleusercontent.com',
    iosBundleId: 'com.pokemontcg.localtracker.pokemonGccTracker',
    databaseURL: 'https://channel-gcc-report-default-rtdb.europe-west1.firebasedatabase.app',
  );
}
